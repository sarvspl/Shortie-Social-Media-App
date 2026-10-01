import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortie/main.dart';
import 'package:shortie/pages/fake_live_page/controller/fake_live_controller.dart';
import 'package:shortie/pages/fake_live_page/widget/fake_pk_timer_widget.dart';
import 'package:shortie/pages/fake_live_page/widget/fake_pk_top_gift_user_widget.dart';
import 'package:shortie/pages/multi_live_page/widget/rank_slider_ui.dart';
import 'package:shortie/ui/preview_network_image_ui.dart';
import 'package:shortie/utils/color.dart';
import 'package:video_player/video_player.dart';

class FakePkCameraWidget extends GetView<FakeLiveController> {
  const FakePkCameraWidget({super.key, required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FakeLiveController>(
      id: "initializeVideoPlayer",
      builder: (controller) => controller.isPkMode == true
          ? SizedBox(
              height: height,
              child: Column(
                children: [
                  Container(
                    height: height - 80,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(),
                    width: Get.width,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          height: height - 70,
                          width: Get.width,
                          child: Row(
                            children: [
                              Expanded(
                                child: Container(
                                  color: AppColor.black,
                                  height: Get.height,
                                  width: Get.width,
                                  child: Stack(
                                    children: [
                                      CustomPreviewImage(
                                        image: controller.image,
                                        isProfileImage: false,
                                      ),
                                      controller.videoPlayerController != null ? VideoPlayer(controller.videoPlayerController!) : Offstage(),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  color: AppColor.black,
                                  width: Get.width,
                                  height: Get.height,
                                  child: Stack(
                                    children: [
                                      CustomPreviewImage(
                                        image: controller.host2Image,
                                        isProfileImage: false,
                                      ),
                                      controller.host2VideoPlayerController != null ? VideoPlayer(controller.host2VideoPlayerController!) : Offstage(),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(top: 0, child: FakePkTimerWidget()),
                      ],
                    ),
                  ),
                  GetBuilder<FakeLiveController>(
                    id: "onUpdateRank",
                    builder: (controller) => SizedBox(
                      width: Get.width,
                      child: CustomRankSliderWidget(
                        height: 20,
                        rank1: controller.h1Rank,
                        rank2: controller.h2Rank,
                        width: Get.width,
                      ),
                    ),
                  ),
                  FakePkTopGiftUserWidget(),
                  10.height,
                ],
              ),
            )
          : Offstage(),
    );
  }
}
