import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shortie/deep_link/services/deep_link_services.dart';
import 'package:shortie/localization/locale_constant.dart';
import 'package:shortie/localization/localization_service.dart';
import 'package:shortie/localization/localizations_delegate.dart';
import 'package:shortie/pages/splash_screen_page/binding/splash_screen_binding.dart';
import 'package:shortie/pages/splash_screen_page/view/splash_screen_view.dart';
import 'package:shortie/routes/app_pages.dart';
import 'package:shortie/routes/app_routes.dart';
import 'package:shortie/utils/color.dart';
import 'package:shortie/utils/constant.dart';
import 'package:shortie/utils/database.dart';
import 'package:shortie/utils/enums.dart';
import 'package:shortie/utils/internet_connection.dart';
import 'package:shortie/utils/notification_services.dart';
import 'package:shortie/utils/platform_device_id.dart';
import 'package:shortie/utils/utils.dart';

void main() async {
  try {
    // Initialize Flutter bindings first
    WidgetsFlutterBinding.ensureInitialized();

    // Initialize platform-specific services
    await Future.wait([
      // Initialize Firebase
      Firebase.initializeApp(),
      // Initialize GetStorage with error handling
      GetStorage.init().catchError((error) {
        debugPrint('Error initializing GetStorage: $error');
        return false;
      }),
      // Initialize Branch.io
    ]);
    await onInitializeBranchIo();
    // Initialize other services
    InternetConnection.init();

    // Wait for any platform initialization to complete
    await 500.milliseconds.delay(); // THIS USE TO IOS WHITE SCREEN

    // Initialize notifications
    NotificationServices.init();
    NotificationServices.firebaseInit();
    await FirebaseMessaging.instance.requestPermission();
    FirebaseMessaging.onBackgroundMessage(NotificationServices.onShowBackgroundNotification);

    // Get device info
    String? identity;
    String? fcmToken;

    try {
      identity = await PlatformDeviceId.getDeviceId;
      fcmToken = await FirebaseMessaging.instance.getToken();

      Utils.showLog("Device Id => $identity");
      Utils.showLog("FCM Token => $fcmToken");

      debugPrint("FCM Token => $fcmToken");
      debugPrint("identity => $identity");
    } catch (e) {
      debugPrint('Error getting device info: $e');
    }

    identity = (identity != null && identity.trim().isNotEmpty)
        ? identity.trim()
        : (Database.identity.isNotEmpty ? Database.identity : "dev_${DateTime.now().millisecondsSinceEpoch}");

    fcmToken = (fcmToken != null && fcmToken.trim().isNotEmpty)
        ? fcmToken.trim()
        : (Database.fcmToken.isNotEmpty ? Database.fcmToken : "token_$identity");

    await Database.init(identity, fcmToken);
    // Initialize Dynamic Localization Service
    Get.put(LocalizationService());
    await Get.find<LocalizationService>().init();
    runApp(const MyApp());
  } catch (e) {
    log("Error => $e");
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static final StreamController purchaseStreamController = StreamController<PurchaseDetails>.broadcast();

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    Utils.isAppOpen.value = true;
    WidgetsBinding.instance.addObserver(this);
    DeepLinkServices.onInitDeepLinks();

    super.initState();
  }

  @override
  void dispose() {
    Utils.isAppOpen.value = false;
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      Utils.isAppOpen.value = true;
      Utils.showLog("User Back To App...");
    }
    if (state == AppLifecycleState.inactive) {
      Utils.isAppOpen.value = false;
      Utils.showLog("User Try To Exit...");
    }
  }

  @override
  void didChangeDependencies() {
    getLocale().then((locale) {
      setState(() {
        Utils.showLog("Preference LanguageCode => ${locale.languageCode}");
        Utils.showLog("GetX locale LanguageCode => ${Get.locale?.languageCode ?? ""}");
        Get.updateLocale(locale);
      });
    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: EnumLocal.txtAppName.name.tr,
      debugShowCheckedModeBanner: false,
      color: AppColor.white,
      translations: AppLanguages(),
      fallbackLocale: const Locale(AppConstant.languageEn, AppConstant.countryCodeEn),
      locale: const Locale(AppConstant.languageEn),
      defaultTransition: Transition.fade,
      getPages: AppPages.list,
      initialRoute: AppRoutes.initial,
      unknownRoute: GetPage(
        name: AppRoutes.splashScreenPage,
        page: () => const SplashScreenView(),
        binding: SplashScreenBinding(),
      ),
      theme: ThemeData(scaffoldBackgroundColor: AppColor.white),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.0)),
          child: Container(
            color: AppColor.white,
            child: SafeArea(
              right: false,
              top: false,
              left: false,
              bottom: Platform.isIOS ? false : true,
              child: Scaffold(
                body: Stack(
                  children: [
                    child ?? const SizedBox(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// >>>>>> >>>>>> Sized Box Extension <<<<<< <<<<<<

extension HeightExtension on num {
  SizedBox get height => SizedBox(height: toDouble());
}

extension WidthExtension on num {
  SizedBox get width => SizedBox(width: toDouble());
}

Future<void> onInitializeCrashlytics() async {
  try {
    FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  } catch (e) {
    Utils.showLog("Initialize Crashlytics Failed !! => $e");
  }
}

Future<void> onInitializeBranchIo() async {
  try {
    await FlutterBranchSdk.init().then((value) {
      // FlutterBranchSdk.validateSDKIntegration();
    });
  } catch (e) {
    Utils.showLog("Initialize Branch Io Failed !! => $e");
  }
}
