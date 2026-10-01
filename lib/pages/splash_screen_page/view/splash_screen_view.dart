import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:shortie/pages/splash_screen_page/controller/splash_screen_controller.dart';
import 'package:shortie/utils/asset.dart';
import 'package:shortie/utils/color.dart';
import 'package:shortie/utils/utils.dart';

class SplashScreenView extends GetView<SplashScreenController> {
  const SplashScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    Utils.onChangeStatusBar(brightness: Brightness.light);
    return Scaffold(
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Image.asset(
            AppAsset.imgSplashScreen,
            height: Get.height,
            width: Get.width,
            fit: BoxFit.cover,
          ),
          Container(
            height: 50,
            color: AppColor.transparent,
            child: SpinKitCircle(color: AppColor.primary, size: 80),
          ).paddingOnly(bottom: 70),
        ],
      ),
    );
  }
}
