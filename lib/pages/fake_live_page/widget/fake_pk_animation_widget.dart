import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:shortie/pages/fake_live_page/controller/fake_live_controller.dart';
import 'package:shortie/utils/asset.dart';

class FakePkAnimationWidget extends GetView<FakeLiveController> {
  const FakePkAnimationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      alignment: Alignment.center,
      children: [
        Obx(
          () => Visibility(
            visible: controller.isShowPkAnimation.value,
            child: Lottie.asset(AppAsset.lottiePk, width: 200),
          ),
        ),
        Obx(
          () => AnimatedPositioned(
            duration: const Duration(seconds: 1, milliseconds: 500),
            right: controller.isShowPkAnimation.value ? 300 : -50,
            child: Padding(
              padding: EdgeInsets.only(bottom: 50),
              child: controller.isShowPkAnimation.value ? Image.asset(AppAsset.imgPkSideBlue, width: 200, fit: BoxFit.cover, height: 45) : Offstage(),
            ),
          ),
        ),
        Obx(
          () => AnimatedPositioned(
            duration: const Duration(seconds: 1, milliseconds: 500),
            left: controller.isShowPkAnimation.value ? 300 : -50,
            child: Padding(
              padding: EdgeInsets.only(top: 50),
              child: controller.isShowPkAnimation.value ? Image.asset(AppAsset.imgPkSidePink, width: 200, fit: BoxFit.cover, height: 45) : Offstage(),
            ),
          ),
        ),
      ],
    );
  }
}
