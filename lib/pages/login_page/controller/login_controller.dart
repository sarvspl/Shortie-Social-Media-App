import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shortie/pages/login_page/api/check_user_exist_api.dart';
import 'package:shortie/pages/login_page/api/fetch_images_api.dart';
import 'package:shortie/pages/login_page/api/login_api.dart';
import 'package:shortie/pages/login_page/model/login_model.dart' hide User;
import 'package:shortie/pages/splash_screen_page/api/fetch_login_user_profile_api.dart';
import 'package:shortie/pages/splash_screen_page/model/fetch_login_user_profile_model.dart';
import 'package:shortie/pages/profile_page/controller/profile_controller.dart';
import 'package:shortie/routes/app_routes.dart';
import 'package:shortie/ui/loading_ui.dart';
import 'package:shortie/utils/database.dart';
import 'package:shortie/utils/enums.dart';
import 'package:shortie/utils/internet_connection.dart';
import 'package:shortie/utils/notification_services.dart';
import 'package:shortie/utils/platform_device_id.dart';
import 'package:shortie/utils/utils.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginController extends GetxController {
  LoginModel? loginModel;
  FetchLoginUserProfileModel? fetchLoginUserProfileModel;

  // Reactive variables for checkbox states
  RxBool isTermsAccepted = false.obs;

  static String? lastUsedEmail;
  static String? lastUsedName;
  static String? lastUsedPhoto;

  @override
  void onInit() {
    if (FetchImagesApi.images.isEmpty) FetchImagesApi.callApi();
    super.onInit();
  }

  Future<String> _ensureValidFcmToken() async {
    String token = Database.fcmToken.trim();
    if (token.length > 20 && !token.startsWith("token_") && !token.startsWith("dummy") && !token.startsWith("connect_")) {
      return token;
    }
    try {
      await NotificationServices.init();
      await FirebaseMessaging.instance.requestPermission();
      for (int i = 0; i < 4; i++) {
        final fetched = await FirebaseMessaging.instance.getToken().timeout(const Duration(seconds: 2)).catchError((_) => null);
        if (fetched != null && fetched.trim().length > 20 && !fetched.startsWith("token_") && !fetched.startsWith("dummy") && !fetched.startsWith("connect_")) {
          token = fetched.trim();
          await Database.onSetFcmToken(token);
          return token;
        }
        await Future.delayed(const Duration(milliseconds: 500));
      }
    } catch (e) {
      Utils.showLog("Error fetching FCM token in login: $e");
    }
    return token;
  }

  Future<void> onQuickLogin() async {
    if (!isTermsAccepted.value) {
      onShowTermsError();
      return;
    }

    // Ensure persistent quickLoginIdentity across re-logins
    String identity = Database.quickLoginIdentity.trim();
    if (identity.isEmpty) {
      identity = Database.identity.trim();
    }
    if (identity.isEmpty) {
      identity = (await PlatformDeviceId.getDeviceId) ?? "";
      if (identity.trim().isEmpty) {
        identity = "dev_${DateTime.now().millisecondsSinceEpoch}";
      }
    }
    await Database.onSetQuickLoginIdentity(identity);
    await Database.onSetIdentity(identity);

    String fcmToken = await _ensureValidFcmToken();

    Get.dialog(const LoadingUi(), barrierDismissible: false); // Start Loading...

    if (InternetConnection.isConnect.value) {
      try {
        final isLogin = await CheckUserExistApi.callApi(identity: identity) ?? false;
        Utils.showLog("Quick Login User Is Exist => $isLogin");

        loginModel = await LoginApi.callApi(
          loginType: 3,
          email: identity,
          identity: identity,
          fcmToken: fcmToken,
          name: isLogin ? null : "", // Don't prefill random name
          userName: isLogin ? null : "", // Don't prefill random username
          image: isLogin ? null : "", // Don't prefill random image
          gender: isLogin ? null : "male",
        );
      } catch (e) {
        Utils.showLog("Quick Login API exception: $e");
        loginModel = null;
      }

      if (Get.isDialogOpen == true) Get.back(); // Stop Loading...

      if (loginModel?.status == true && loginModel?.user?.id != null) {
        await onGetProfile(loginUserId: loginModel!.user!.id!, isNewUser: loginModel?.signUp == true);
      } else if (loginModel?.message == "You are blocked by the admin.") {
        Utils.showToast("${loginModel?.message}");
        Utils.showLog("User Blocked By Admin !!");
      } else {
        // Server error (502) / down — activate bypass
        Utils.showLog("Quick Login API failed. Activating bypass mode.");
        await onBypassQuickLogin(identity);
      }
    } else {
      if (Get.isDialogOpen == true) Get.back();
      Utils.showLog("Offline mode. Activating bypass mode.");
      await onBypassQuickLogin(identity);
    }
  }

  Future<void> onBypassQuickLogin(String identity) async {
    final cleanId = identity.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
    final fallbackUserId = "quick_$cleanId";

    await Database.onSetIsNewUser(false);
    await Database.onSetLoginUserId(fallbackUserId);
    await Database.onSetLoginType(3);
    await Database.onSetIdentity(identity);

    final fallbackUser = User(
      id: fallbackUserId,
      name: "",
      userName: "",
      image: "",
      gender: "male",
      loginType: 3,
    );

    Database.fetchLoginUserProfileModel = FetchLoginUserProfileModel(
      status: true,
      message: "Offline Quick Login",
      user: fallbackUser,
    );

    await Database.onSetIsProfileComplete(false);
    Utils.showToast("Quick Login active (Bypass mode)");
    Get.offAllNamed(AppRoutes.fillProfilePage);
  }

  Future<void> onGoogleLogin() async {
    if (!InternetConnection.isConnect.value) {
      Utils.showToast(EnumLocal.txtConnectionLost.name.tr);
      Utils.showLog("Internet Connection Lost !!");
    } else if (!isTermsAccepted.value) {
      onShowTermsError();
      return;
    } else {
      Get.dialog(const LoadingUi(), barrierDismissible: false); // Start Loading...

      UserCredential? userCredential = await signInWithGoogle();

      if (userCredential == null) {
        Get.back(); // stop loading
        Utils.showToast("Google Sign-In Cancelled");
        return;
      }

      final String? email = userCredential.user?.email;

      // Google sometimes returns null displayName — fall back gracefully
      final String rawDisplayName = userCredential.user?.displayName?.trim() ?? "";
      final String googleProfileName = userCredential.additionalUserInfo?.profile?['name']?.toString().trim() ?? "";
      final String emailPrefix = email?.split('@').first ?? "";

      // Best available display name: Firebase displayName → Google profile name → email prefix → random
      final String resolvedName = rawDisplayName.isNotEmpty
          ? rawDisplayName
          : googleProfileName.isNotEmpty
              ? googleProfileName
              : emailPrefix.isNotEmpty
                  ? emailPrefix
                  : onGetRandomName();

      final bool isNewUser = userCredential.additionalUserInfo?.isNewUser ?? true;

      Utils.showLog("Google Login — email: $email | displayName: '$rawDisplayName' | resolved: '$resolvedName' | isNewUser: $isNewUser");

      // Only email is required — displayName is optional (same as Apple login)
      if (email != null && email.isNotEmpty) {
        final String safeUserName = "@${resolvedName.replaceAll(' ', '').trim().toLowerCase()}";
        final String? profilePicture = userCredential.additionalUserInfo?.profile?['picture']?.toString();

        String googleFcmToken = Database.fcmToken.trim();
        if (googleFcmToken.isEmpty || googleFcmToken.startsWith("token_") || googleFcmToken.startsWith("dummy") || googleFcmToken.startsWith("connect_")) {
          try {
            final t = await FirebaseMessaging.instance.getToken().timeout(const Duration(seconds: 4));
            if (t != null && t.trim().isNotEmpty && t.trim().length > 20) {
              googleFcmToken = t.trim();
              await Database.onSetFcmToken(googleFcmToken);
            }
          } catch (_) {}
        }

        loginModel = await LoginApi.callApi(
          loginType: 2,
          email: email,
          identity: Database.identity,
          fcmToken: googleFcmToken,
          image: isNewUser ? (profilePicture ?? '') : null,
          name: isNewUser ? resolvedName : null,
          userName: isNewUser ? safeUserName : null,
          gender: isNewUser ? "male" : null, // DEFAULT VALUE => MALE
        );

        Get.back(); // Stop Loading...

        if (loginModel?.status == true && loginModel?.user?.id != null) {
          await onGetProfile(loginUserId: loginModel!.user!.id!, isNewUser: isNewUser);
        } else if (loginModel?.message == "You are blocked by the admin.") {
          Utils.showToast("${loginModel?.message}");
          Utils.showLog("User Blocked By Admin !!");
        } else {
          Utils.showToast(EnumLocal.txtSomeThingWentWrong.name.tr);
          Utils.showLog("Login Api Calling Failed !!");
        }
      } else {
        Utils.showToast(EnumLocal.txtSomeThingWentWrong.name.tr);
        Utils.showLog("Google Login Failed — no email returned !!");
        Get.back(); // Stop Loading...
      }
    }
  }

  void onMobileNumber() {
    if (!isTermsAccepted.value) {
      onShowTermsError();
      return;
    }
    Get.toNamed(AppRoutes.mobileNumLoginPage);
  }

  Future<void> onGetProfile({required String loginUserId, required bool isNewUser}) async {
    Get.dialog(const LoadingUi(), barrierDismissible: false); // Start Loading...
    try {
      fetchLoginUserProfileModel = await FetchLoginUserProfileApi.callApi(loginUserId: loginUserId, fcmToken: Database.fcmToken);
    } catch (e) {
      fetchLoginUserProfileModel = null;
    }
    if (Get.isDialogOpen == true) Get.back(); // Stop Loading...

    if (fetchLoginUserProfileModel?.user?.id != null && fetchLoginUserProfileModel?.user?.loginType != null) {
      Database.onSetIsNewUser(false);
      Database.onSetLoginUserId(fetchLoginUserProfileModel!.user!.id!);
      Database.onSetLoginType(int.parse((fetchLoginUserProfileModel?.user?.loginType ?? 0).toString()));
      Database.fetchLoginUserProfileModel = fetchLoginUserProfileModel;

      final user = fetchLoginUserProfileModel?.user;
      final bool hasProfile = (user?.name?.trim().isNotEmpty ?? false) && (user?.userName?.trim().isNotEmpty ?? false);
      // Fake users created by admin already have profile data — skip fill profile
      final bool isFakeUser = user?.isFake == true;

      if (!isFakeUser && (isNewUser || !hasProfile)) {
        await Database.onSetIsProfileComplete(false);
        Get.offAllNamed(AppRoutes.fillProfilePage);
      } else {
        await Database.onSetIsProfileComplete(true);
        if (Get.isRegistered<ProfileController>()) Get.delete<ProfileController>(force: true);
        Get.offAllNamed(AppRoutes.bottomBarPage);
      }
    } else {
      // Server down during profile fetch -> route to fill profile with existing or clean session
      await Database.onSetIsProfileComplete(false);
      Get.offAllNamed(AppRoutes.fillProfilePage);
    }
  }

  // Future<void> onGetProfile1({
  //   required String loginUserId,
  // }) async {
  //   Get.dialog(const LoadingUi(), barrierDismissible: false);
  //
  //   fetchLoginUserProfileModel =
  //   await FetchLoginUserProfileApi.callApi(loginUserId: loginUserId);
  //
  //   Get.back();
  //
  //   final user = fetchLoginUserProfileModel?.user;
  //
  //   if (user?.id != null) {
  //     Database.onSetIsNewUser(false);
  //     Database.onSetLoginUserId(user!.id!);
  //     Database.onSetLoginType(int.parse(user.loginType.toString()));
  //     Database.fetchLoginUserProfileModel = fetchLoginUserProfileModel;
  //
  //     /// ✅ REAL CHECK
  //     bool isProfileIncomplete =
  //         user.name == null ||
  //             user.name!.isEmpty ||
  //             user.userName == null ||
  //             user.userName!.isEmpty ||
  //             user.gender == null ||
  //             user.gender!.isEmpty;
  //
  //     if (isProfileIncomplete) {
  //       Get.toNamed(AppRoutes.fillProfilePage);
  //     } else {
  //       Get.offAllNamed(AppRoutes.bottomBarPage);
  //     }
  //   } else {
  //     Utils.showToast(EnumLocal.txtSomeThingWentWrong.name.tr);
  //   }
  // }

  static Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(scopes: [
        'email',
        'https://www.googleapis.com/auth/userinfo.email',
        'https://www.googleapis.com/auth/userinfo.profile',
      ], serverClientId: '62445718384-d415spsbkcd86ml1f3lqoe3cme2o2okm.apps.googleusercontent.com');

      await googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) return null;

      lastUsedEmail = googleUser.email;
      lastUsedName = googleUser.displayName;
      lastUsedPhoto = googleUser.photoUrl;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential result = await FirebaseAuth.instance.signInWithCredential(credential);

      return result;
    } catch (error) {
      Utils.showLog("Google Login Error => $error");
    }
    return null;
  }

  Future<void> onAppleLogin() async {
    if (!isTermsAccepted.value) {
      onShowTermsError();
      return;
    }

    if (InternetConnection.isConnect.value) {
      Get.dialog(const LoadingUi(), barrierDismissible: false); // Start Loading...

      UserCredential? userCredential = await signInWithApple();

      if (userCredential?.user?.email != null) {
        // Calling Sign Up Api...
        String displayName = userCredential?.user?.displayName ?? "";
        // Check if user is new (userCredential.additionalUserInfo?.isNewUser is true for new users)
        bool isNewUser = userCredential?.additionalUserInfo?.isNewUser ?? false;
        if (displayName.isEmpty) {
          // Apple often doesn't provide name, use email or random name
          displayName = userCredential?.user?.email?.split('@').first ?? onGetRandomName();
        }

        String appleFcmToken = Database.fcmToken.trim();
        if (appleFcmToken.isEmpty || appleFcmToken.startsWith("token_") || appleFcmToken.startsWith("dummy") || appleFcmToken.startsWith("connect_")) {
          try {
            final t = await FirebaseMessaging.instance.getToken().timeout(const Duration(seconds: 4));
            if (t != null && t.trim().isNotEmpty && t.trim().length > 20) {
              appleFcmToken = t.trim();
              await Database.onSetFcmToken(appleFcmToken);
            }
          } catch (_) {}
        }

        loginModel = await LoginApi.callApi(
          loginType: 4,
          // Apple login type
          email: userCredential?.user?.email ?? "",
          identity: Database.identity,
          fcmToken: appleFcmToken,
          userName: displayName,
        );

        Get.back(); // Stop Loading...

        if (loginModel?.status == true && loginModel?.user?.id != null) {
          await onGetProfile(
            loginUserId: loginModel?.user?.id ?? "",
            isNewUser: isNewUser,
          ); // Get Profile Api...
        } else if (loginModel?.message == "You are blocked by the admin.") {
          Utils.showToast("${loginModel?.message}");
          Utils.showLog("User Blocked By Admin !!");
        } else {
          Utils.showToast(EnumLocal.txtSomeThingWentWrong.name.tr);
          Utils.showLog("Login Api Calling Failed !!");
        }
      } else {
        Utils.showToast(EnumLocal.txtSomeThingWentWrong.name.tr);
        Utils.showLog("Apple Login Failed !!");
        Get.back(); // Stop Loading...
      }
    } else {
      Utils.showToast(EnumLocal.txtConnectionLost.name.tr);
      Utils.showLog("Internet Connection Lost !!");
    }
  }

  void onShowTermsError() {
    String message = "";
    if (!isTermsAccepted.value) {
      message = "Please accept Terms & Conditions to continue";
    }

    Utils.showToast(message);
  }

  static Future<UserCredential?> signInWithApple() async {
    try {
      // Request Apple credential
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // Convert to OAuthCredential
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      // Sign in with Firebase
      final result = await FirebaseAuth.instance.signInWithCredential(oauthCredential);

      Utils.showLog("Apple Login Email => ${result.user?.email}");
      Utils.showLog("Apple Login isNewUser => ${result.additionalUserInfo?.isNewUser}");

      return result;
    } catch (error) {
      Utils.showLog("Apple Login Error => $error");
    }
    return null;
  }

  void toggleTermsAcceptance() {
    isTermsAccepted.value = !isTermsAccepted.value;
  }

  // Terms and Conditions Handler
  void onTermsAndConditionsPressed() {
    Utils.showLog("Terms and Conditions Pressed ${Utils.termsOfUseLink}");
    _launchURL(Utils.termsOfUseLink);
  }

// Helper method to launch URLs
  Future<void> _launchURL(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        Utils.showToast("Could not launch $url");
      }
    } catch (e) {
      Utils.showToast("Error opening link");
      Utils.showLog("URL Launch Error: $e");
    }
  }
}

List<String> randomNames = [
  "Liam Smith",
  "Emily Johnson",
  "Noah Brown",
  "Sofia Davis",
  "Oliver Wilson",
  "Mia Anderson",
  "James Thomas",
  "Ava Robinson",
  "Benjamin Lee",
  "Charlotte Miller",
  "Lucas Garcia",
  "Amelia White",
  "Ethan Harris",
  "Harper Clark",
  "Alexander Lewis",
  "Evelyn Walker",
  "Daniel Hall",
  "Grace Young",
  "Michael Allen",
  "Emily Johnson",
  "Liam Smith",
  "Isabella Martinez",
  "Noah Brown",
  "Sofia Davis",
  "Oliver Wilson",
  "Mia Anderson",
  "James Thomas",
  "Ava Robinson",
  "Benjamin Lee",
  "Charlotte Miller",
  "Lucas Garcia",
  "Amelia White",
  "Ethan Harris",
  "Harper Clark",
  "Alexander Lewis",
  "Evelyn Walker",
  "Daniel Hall",
  "Grace Young",
  "Michael Allen",
  "Emily Johnson",
  "Liam Smith",
  "Isabella Martinez",
  "Noah Brown",
  "Sofia Davis",
  "Oliver Wilson",
  "Mia Anderson",
  "James Thomas",
  "Ava Robinson",
  "Benjamin Lee",
  "Charlotte Miller",
];

String onGetRandomName() {
  Random random = new Random();
  int index = random.nextInt(randomNames.length);
  return randomNames[index];
}
