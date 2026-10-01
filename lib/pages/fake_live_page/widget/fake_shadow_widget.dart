import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortie/pages/fake_live_page/controller/fake_live_controller.dart';
import 'package:shortie/utils/color.dart';

class FakeShadowWidget extends StatelessWidget {
  const FakeShadowWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FakeLiveController>(
      id: "initializeVideoPlayer",
      builder: (controller) => controller.isPkMode == false
          ? Stack(
              children: [
                Positioned(
                  bottom: 0,
                  child: Container(
                    height: 400,
                    width: Get.width,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColor.transparent, AppColor.black.withValues(alpha: 0.7)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  child: Container(
                    height: 400,
                    width: Get.width,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColor.transparent, AppColor.black.withValues(alpha: 0.7)],
                        end: Alignment.topCenter,
                        begin: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
              ],
            )
          : Offstage(),
    );
  }
}
