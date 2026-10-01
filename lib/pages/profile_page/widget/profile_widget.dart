import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:shortie/custom/custom_format_number.dart';
import 'package:shortie/main.dart';
import 'package:shortie/pages/profile_page/controller/profile_controller.dart';
import 'package:shortie/pages/profile_page/view/profile_feed_view.dart';
import 'package:shortie/routes/app_routes.dart';
import 'package:shortie/shimmer/grid_view_shimmer_ui.dart';
import 'package:shortie/shimmer/post_list_shimmer_ui.dart';
import 'package:shortie/ui/no_data_found_ui.dart';
import 'package:shortie/ui/preview_network_image_ui.dart';
import 'package:shortie/utils/asset.dart';
import 'package:shortie/utils/color.dart';
import 'package:shortie/utils/enums.dart';
import 'package:shortie/utils/font_style.dart';

class ProfileAppBarUi extends StatelessWidget {
  const ProfileAppBarUi({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProfileController>();
    return SafeArea(
      bottom: false,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 15),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            40.width,
            Spacer(),
            Obx(
              () => Text(
                controller.isTabBarPinned.value ? controller.fetchProfileModel?.userProfileData?.user?.name ?? "" : EnumLocal.txtMyProfile.name.tr,
                style: AppFontStyle.styleW700(AppColor.black, 19),
              ),
            ),
            Spacer(),
            GestureDetector(
              onTap: () => Get.toNamed(AppRoutes.settingPage),
              child: Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(border: Border.all(color: AppColor.colorBorder), shape: BoxShape.circle),
                child: Center(child: Image.asset(AppAsset.icSetting, width: 20)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ReelsTabView extends StatelessWidget {
  const ReelsTabView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProfileController>(
        id: "onGetVideo",
        builder: (controller) => controller.isLoadingVideo
            ? GridViewShimmerUi()
            : controller.videoCollection.isEmpty
                ? Center(
                    child: SingleChildScrollView(
                      child: const NoDataFoundUi(
                        iconSize: 140,
                        fontSize: 16,
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    child: GridView.builder(
                      shrinkWrap: true,
                      itemCount: controller.videoCollection.length,
                      padding: const EdgeInsets.all(10),
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 0.75,
                      ),
                      itemBuilder: (context, index) {
                        return Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            GestureDetector(
                              onTap: () {
                                if (!(controller.videoCollection[index].isBanned ?? false)) {
                                  controller.onClickReels(index);
                                }
                              },
                              child: Container(
                                clipBehavior: Clip.antiAlias,
                                decoration:
                                    BoxDecoration(color: AppColor.colorTextGrey.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14)),
                                child: AspectRatio(
                                  aspectRatio: 0.75,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Image.asset(AppAsset.icImagePlaceHolder, width: 60),
                                      AspectRatio(
                                        aspectRatio: 0.75,
                                        child: PreviewNetworkImageUi(
                                          image: controller.videoCollection[index].videoImage,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Visibility(
                              visible: controller.videoCollection[index].isBanned ?? false,
                              child: BlurryContainer(
                                height: Get.height,
                                width: Get.width,
                                blur: 5,
                                borderRadius: BorderRadius.circular(14),
                                color: AppColor.black.withValues(alpha: 0.3),
                                child: Offstage(),
                              ),
                            ),
                            // Visibility(
                            //   visible: (controller.videoCollection[index].isBanned ?? false),
                            //   child: Container(
                            //     height: Get.height,
                            //     alignment: Alignment.topRight,
                            //     decoration: BoxDecoration(
                            //       color: AppColor.black.withValues(alpha:0.65),
                            //       borderRadius: BorderRadius.circular(14),
                            //     ),
                            //     child: Padding(
                            //       padding: const EdgeInsets.all(8.0),
                            //       child: Image.asset(AppAsset.icNone, color: AppColor.colorRedContainer, width: 20),
                            //     ),
                            //   ),
                            // ),
                            Container(
                              height: 35,
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(14),
                                  bottomRight: Radius.circular(14),
                                ),
                                gradient: LinearGradient(
                                  colors: [AppColor.transparent, AppColor.black.withValues(alpha: 0.6)],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Image.asset(
                                      AppAsset.icLike,
                                      width: 18,
                                      color: (controller.videoCollection[index].isLike ?? false) ? AppColor.colorTextRed : AppColor.white,
                                    ),
                                    Text(
                                      " ${CustomFormatNumber.convert(controller.videoCollection[index].totalLikes ?? 0)}",
                                      style: AppFontStyle.styleW600(AppColor.white, 11),
                                    ),
                                    8.width,
                                    Image.asset(AppAsset.icComment, width: 18),
                                    Text(
                                      " ${CustomFormatNumber.convert(controller.videoCollection[index].totalComments ?? 0)}",
                                      style: AppFontStyle.styleW600(AppColor.white, 11),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ));
  }
}

class FeedsTabView extends StatelessWidget {
  const FeedsTabView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProfileController>(
      id: "onGetPost",
      builder: (controller) => controller.isLoadingPost
          ? PostListShimmerUi()
          : controller.postCollection.isEmpty
              ? Center(
                  child: SingleChildScrollView(
                    child: const NoDataFoundUi(
                      iconSize: 140,
                      fontSize: 16,
                    ),
                  ),
                )
              : ProfileFeedGridView(controller: controller),
    );
  }
}

class CollectionsTabView extends StatelessWidget {
  const CollectionsTabView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProfileController>(
      id: "onGetCollection",
      builder: (controller) => controller.isLoadingCollection
          ? GridViewShimmerUi()
          : controller.giftCollection.isEmpty
              ? Center(
                  child: SingleChildScrollView(
                    child: const NoDataFoundUi(
                      iconSize: 140,
                      fontSize: 16,
                    ),
                  ),
                )
              : GridView.builder(
                  itemCount: controller.giftCollection.length,
                  padding: const EdgeInsets.all(10),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.85,
                  ),
                  itemBuilder: (context, index) {
                    return Container(
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        color: AppColor.white,
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(color: AppColor.colorBorder),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          5.height,
                          Expanded(
                            child: PreviewGiftWidget(
                              isShowThumbnail: true,
                              url: controller.giftCollection[index].giftImage,
                              type: controller.giftCollection[index].giftType,
                              thumbnailUrl: controller.giftCollection[index].giftSvgaImage,
                            ),
                          ),
                          5.height,
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColor.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              "${CustomFormatNumber.convert(controller.giftCollection[index].giftCoin ?? 0)} Coins",
                              style: AppFontStyle.styleW700(AppColor.primary, 12),
                            ),
                          ),
                          8.height,
                          Container(
                            height: 35,
                            width: Get.width,
                            decoration: const BoxDecoration(
                              gradient: AppColor.primaryLinearGradient,
                              borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
                            ),
                            child: Center(
                              child: Text(
                                "X ${CustomFormatNumber.convert(controller.giftCollection[index].total ?? 0)}",
                                style: AppFontStyle.styleW600(AppColor.white, 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
