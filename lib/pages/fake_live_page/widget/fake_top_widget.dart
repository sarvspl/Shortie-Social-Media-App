import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:shortie/google_ad/google_ad_interstitial.dart';
import 'package:shortie/google_ad/google_ad_services.dart';
import 'package:shortie/main.dart';
import 'package:shortie/pages/fake_live_page/controller/fake_live_controller.dart';
import 'package:shortie/ui/circle_icon_button_ui.dart';
import 'package:shortie/ui/preview_network_image_ui.dart';
import 'package:shortie/ui/preview_profile_bottom_sheet_ui.dart';
import 'package:shortie/ui/stop_live_streaming_dialog_ui.dart';
import 'package:shortie/utils/asset.dart';
import 'package:shortie/utils/color.dart';
import 'package:shortie/utils/font_style.dart';

class FakeTopWidget extends GetView<FakeLiveController> {
  const FakeTopWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      color: Colors.transparent,
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GetBuilder<FakeLiveController>(
            id: "updateProfile",
            builder: (controller) => Container(
              height: 50,
              padding: EdgeInsets.only(left: 5, right: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(56),
                border: Border.all(color: AppColor.colorBorder.withValues(alpha: 0.3)),
                color: AppColor.black.withValues(alpha: 0.45),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () => PreviewProfileBottomSheetUi.show(
                      context: context,
                      userId: controller.userId,
                      onFollowChange: (isFollow) {
                        controller.isFollow = isFollow;
                        controller.update(["onClickFollow", "updateProfile"]);
                      },
                    ),
                    child: Container(
                      height: 40,
                      width: 40,
                      clipBehavior: Clip.antiAlias,
                      decoration: const BoxDecoration(shape: BoxShape.circle),
                      child: CustomPreviewImage(image: controller.image),
                    ),
                  ),
                  5.width,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 75,
                        child: Text(
                          controller.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppFontStyle.styleW600(AppColor.white, 14),
                        ),
                      ),
                      Stack(
                        children: [
                          Positioned(
                            left: -10,
                            child: Lottie.asset(AppAsset.lottieWaveAnimation, fit: BoxFit.cover, height: 20, width: 15),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 18, top: 2.5),
                            child: SizedBox(
                              width: 60,
                              child: Text(
                                controller.userName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppFontStyle.styleW500(AppColor.white, 9),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  5.width,
                  GetBuilder<FakeLiveController>(
                    id: "onClickFollow",
                    builder: (controller) => GestureDetector(
                      onTap: controller.onClickFollow,
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColor.coloGreyText,
                          gradient: controller.isFollow ? null : AppColor.primaryLinearGradient,
                        ),
                        child: Center(
                          child: Image.asset(
                            controller.isFollow ? AppAsset.icFollowing : AppAsset.icFollow,
                            height: 22,
                            width: 22,
                            color: AppColor.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          CircleIconButtonUi(
            circleSize: 38,
            color: controller.isPkMode == true ? AppColor.white.withValues(alpha:0.2) : AppColor.black.withValues(alpha:0.3),

            iconSize: 20,
            icon: AppAsset.icClose,
            iconColor: AppColor.white,

            // <<< Code Start *** >>> Google Ad Code <<< ***
            callback: () {
              ExitLiveStreamingDialogUi.onShow(
                onClickStop: () {
                  if (GoogleAdServices.isShowInterstitialAdLive) {
                    Get.back();
                    GoogleAdInterstitial.showAd(navigation: () => Get.back());
                  } else {
                    Get.close(2);
                  }
                },
              );
            },

            // *** >>> Google Ad Code <<< *** Code End >>>

            // callback: () {
            //   Get.back();
            // },
          ),
        ],
      ),
    );
  }
}
