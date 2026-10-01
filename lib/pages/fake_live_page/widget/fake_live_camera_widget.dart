import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortie/pages/fake_live_page/controller/fake_live_controller.dart';
import 'package:shortie/ui/loading_ui.dart';
import 'package:shortie/utils/color.dart';
import 'package:video_player/video_player.dart';

class FakeLiveCameraWidget extends GetView<FakeLiveController> {
  const FakeLiveCameraWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return controller.isPkMode == false
        ? SingleChildScrollView(
            physics: NeverScrollableScrollPhysics(),
            child: Container(
              color: AppColor.transparent,
              width: Get.width,
              height: Get.height,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  LoadingUi(color: AppColor.white),
                  controller.videoPlayerController != null
                      ? SizedBox.expand(
                          child: FittedBox(
                            fit: BoxFit.cover,
                            child: SizedBox(
                              width: controller.videoPlayerController?.value.size.width ?? 0,
                              height: controller.videoPlayerController?.value.size.height ?? 0,
                              child: VideoPlayer(controller.videoPlayerController!),
                            ),
                          ),
                        )
                      : Offstage(),
                ],
              ),
            ),
          )
        : Offstage();
  }
}
