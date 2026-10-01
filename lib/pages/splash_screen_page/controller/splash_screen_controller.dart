// import 'dart:async';
//
// import 'package:get/get.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';
// import 'package:shortie/google_ad/google_ad_setting_api.dart';
// import 'package:shortie/main.dart';
// import 'package:shortie/pages/login_page/api/fetch_images_api.dart';
// import 'package:shortie/pages/splash_screen_page/api/admin_setting_api.dart';
// import 'package:shortie/routes/app_routes.dart';
// import 'package:shortie/utils/database.dart';
// import 'package:shortie/utils/enums.dart';
// import 'package:shortie/utils/internet_connection.dart';
// import 'package:shortie/utils/request.dart';
// import 'package:shortie/utils/utils.dart';
//
// class SplashScreenController extends GetxController {
//   @override
//   void onInit() {
//     init();
//     super.onInit();
//   }
//
//   Future<void> init() async {
//     await onInitializeCrashlytics();
//     await MobileAds.instance.initialize(); // *** >>> Google Ad Code <<< ***
//
//     FetchImagesApi.callApi();
//
//     await AppRequest.notificationPermission();
//
//     if (InternetConnection.isConnect.value) {
//       await AdminSettingsApi.callApi(); // Get Admin Setting Data...
//       await GoogleAdSettingApi.callApi(); // *** >>> Google Ad Code <<< ***
//       if (AdminSettingsApi.adminSettingModel?.data != null) {
//         await Utils.onInitCreateEngine(); // Init Live...
//
//         await Utils.onInitPayment(); // Init Payment...
//
//         await splashScreen();
//       } else {
//         Utils.showToast(EnumLocal.txtSomeThingWentWrong.name.tr);
//         Utils.showLog("Admin Setting Api Calling Failed !!");
//       }
//     } else {
//       Utils.showToast(EnumLocal.txtConnectionLost.name.tr);
//       Utils.showLog("Internet Connection Lost !!");
//     }
//   }
//
//   Future<void> splashScreen() async {
//     Timer(
//       Duration(milliseconds: 1000),
//       () {
//         // Check User Is Login Or Not...
//
//         print("******Database.isNewUser******* ${Database.isNewUser}");
//
//         if (Database.isNewUser == false && Database.fetchLoginUserProfileModel?.status == false)
//           Utils.showToast(Database.fetchLoginUserProfileModel?.message ?? "");
//
//         if (Database.isNewUser == false && Database.fetchLoginUserProfileModel?.user?.id != null) {
//           Get.offAllNamed(AppRoutes.bottomBarPage);
//         } else {
//           Get.offAllNamed(AppRoutes.onBoardingPage);
//         }
//       },
//     );
//   }
// }
//

import 'dart:async';
import 'dart:io';

import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shortie/google_ad/google_ad_setting_api.dart';
import 'package:shortie/main.dart';
import 'package:shortie/pages/login_page/api/fetch_images_api.dart';
import 'package:shortie/pages/splash_screen_page/api/admin_setting_api.dart';
import 'package:shortie/routes/app_routes.dart';
import 'package:shortie/ui/force_update_dialog.dart';
import 'package:shortie/utils/database.dart';
import 'package:shortie/utils/enums.dart';
import 'package:shortie/utils/internet_connection.dart';
import 'package:shortie/utils/request.dart';
import 'package:shortie/utils/utils.dart';

class SplashScreenController extends GetxController {
  @override
  void onInit() {
    init();
    super.onInit();
  }

  Future<void> init() async {
    await onInitializeCrashlytics();
    await MobileAds.instance.initialize(); // *** >>> Google Ad Code <<< ***

    FetchImagesApi.callApi();

    await AppRequest.notificationPermission();

    if (InternetConnection.isConnect.value) {
      await AdminSettingsApi.callApi(); // Get Admin Setting Data...
      await GoogleAdSettingApi.callApi(); // *** >>> Google Ad Code <<< ***


      if (AdminSettingsApi.adminSettingModel?.data != null) {
        try {
          await Utils.onInitCreateEngine(); // Init Live...
        } catch (e) {
          Utils.showLog("Create engine error: $e");
        }

        try {
          await Utils.onInitPayment(); // Init Payment...
        } catch (e) {
          Utils.showLog("Init payment error: $e");
        }

        await checkForceUpdate();
      } else {
        Utils.showToast(EnumLocal.txtSomeThingWentWrong.name.tr);
        Utils.showLog("Admin Setting Api Calling Failed !!");
        splashScreen();
      }
    } else {
      Utils.showToast(EnumLocal.txtConnectionLost.name.tr);
      Utils.showLog("Internet Connection Lost !!");
      splashScreen();
    }
  }

  Future<void> splashScreen() async {
    Timer(
      Duration(milliseconds: 1000),
          () {
        // Check User Is Login Or Not...

        print("******Database.isNewUser******* ${Database.isNewUser}");

        if (Database.isNewUser == false && Database.fetchLoginUserProfileModel?.status == false)
          Utils.showToast(Database.fetchLoginUserProfileModel?.message ?? "");

        if (Database.isNewUser == false && Database.fetchLoginUserProfileModel?.user?.id != null) {
          Get.offAllNamed(AppRoutes.bottomBarPage);
        } else {
          Get.offAllNamed(AppRoutes.onBoardingPage);
        }
      },
    );
  }


  Future<void> checkForceUpdate() async {
    final packageInfo = await PackageInfo.fromPlatform();
    final currentVersion = packageInfo.version;
    Utils.showLog("Current version ==> ${packageInfo.version}");
    // 🔴 Replace this with API response


    final latestVersion = Platform.isIOS ? AdminSettingsApi.adminSettingModel?.data?.iosAppVersion ?? "" : AdminSettingsApi.adminSettingModel?.data?.androidAppVersion ?? "";

     Utils.showLog("Latest  version ==> $latestVersion");
    if (latestVersion.isEmpty) {
      Utils.showLog("⚠️ Latest version missing from API");

      splashScreen();

      return;
    }
    if (isUpdateRequired(currentVersion, latestVersion)) {
      Get.dialog(
        const ForceUpdateDialog(),
        barrierDismissible: false, // ❌ outside tap disabled
      );
    } else {

      splashScreen();

    }
  }

  bool isUpdateRequired(String current, String latest) {
    final currentParts = current.split('.').map(int.parse).toList();
    final latestParts = latest.split('.').map(int.parse).toList();

    for (int i = 0; i < latestParts.length; i++) {
      if (currentParts[i] < latestParts[i]) return true;
      if (currentParts[i] > latestParts[i]) return false;
    }
    return false;
  }
}
