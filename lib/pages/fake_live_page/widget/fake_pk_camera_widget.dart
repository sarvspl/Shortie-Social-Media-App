import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortie/pages/fake_live_page/controller/fake_live_controller.dart';
import 'package:shortie/pages/multi_live_page/widget/modern_pk_battle_widget.dart';
import 'package:shortie/ui/preview_network_image_ui.dart';
import 'package:shortie/utils/color.dart';
import 'package:shortie/utils/font_style.dart';
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
                    decoration: const BoxDecoration(),
                    width: Get.width,
                    child: Stack(
                      children: [
                        SizedBox(
                          height: height - 80,
                          width: Get.width,
                          child: Row(
                            children: [
                              // Left Host 1 Video
                              Expanded(
                                child: Stack(
                                  children: [
                                    Container(
                                      color: AppColor.black,
                                      height: Get.height,
                                      width: Get.width,
                                      child: Stack(
                                        children: [
                                          CustomPreviewImage(
                                            image: controller.image,
                                            isProfileImage: false,
                                          ),
                                          controller.videoPlayerController != null
                                              ? VideoPlayer(controller.videoPlayerController!)
                                              : const Offstage(),
                                        ],
                                      ),
                                    ),
                                    // Host 1 Pink Badge
                                    Positioned(
                                      top: 8,
                                      left: 8,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [Color(0xFFE91E63), Color(0xFFFF4081)],
                                          ),
                                          borderRadius: BorderRadius.circular(12),
                                          boxShadow: [
                                            BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 4),
                                          ],
                                        ),
                                        child: Text(
                                          controller.name.isNotEmpty ? controller.name : "Host 1",
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: AppFontStyle.styleW700(Colors.white, 10),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              Container(width: 1.5, color: Colors.black),

                              // Right Host 2 Video
                              Expanded(
                                child: Stack(
                                  children: [
                                    Container(
                                      color: AppColor.black,
                                      width: Get.width,
                                      height: Get.height,
                                      child: Stack(
                                        children: [
                                          CustomPreviewImage(
                                            image: controller.host2Image,
                                            isProfileImage: false,
                                          ),
                                          controller.host2VideoPlayerController != null
                                              ? VideoPlayer(controller.host2VideoPlayerController!)
                                              : const Offstage(),
                                        ],
                                      ),
                                    ),
                                    // Host 2 Cyan Badge + Mic
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [Color(0xFF00E5FF), Color(0xFF0091EA)],
                                          ),
                                          borderRadius: BorderRadius.circular(12),
                                          boxShadow: [
                                            BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 4),
                                          ],
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Flexible(
                                              child: Text(
                                                "Opponent",
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: AppFontStyle.styleW700(Colors.white, 10),
                                              ),
                                            ),
                                            const SizedBox(width: 3),
                                            const Icon(Icons.mic, color: Colors.white, size: 11),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Modern PK Battle Score Bar with Top Gifters
                  GetBuilder<FakeLiveController>(
                    id: "onUpdateRank",
                    builder: (c) => GetBuilder<FakeLiveController>(
                      id: "onChangeTime",
                      builder: (c2) => ModernPkScoreBarWidget(
                        rank1: c.h1Rank,
                        rank2: c.h2Rank,
                        pkTimeSeconds: c.pkCountTime,
                        host1Gifters: const [],
                        host2Gifters: const [],
                      ),
                    ),
                  ),
                ],
              ),
            )
          : const Offstage(),
    );
  }
}
