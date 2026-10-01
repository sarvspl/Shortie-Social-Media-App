import 'dart:developer';

import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortie/main.dart';
import 'package:shortie/pages/multi_live_page/bottom_sheet/user_view_list_bottom_sheet.dart';
import 'package:shortie/pages/multi_live_page/controller/multi_live_controller.dart';
import 'package:shortie/ui/preview_network_image_ui.dart';
import 'package:shortie/utils/asset.dart';
import 'package:shortie/utils/color.dart';
import 'package:shortie/utils/font_style.dart';
import 'package:shortie/utils/utils.dart';

class PkTopGiftUserWidget extends StatefulWidget {
  const PkTopGiftUserWidget({super.key});

  @override
  State<PkTopGiftUserWidget> createState() => _PkTopGiftUserWidgetState();
}

class _PkTopGiftUserWidgetState extends State<PkTopGiftUserWidget> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<MultiLiveController>(
      id: "onUpdateMultiLive",
      builder: (controller) => GestureDetector(
        onTap: () {
          log("pK tpp gifter");
        },
        child: Container(
          height: 50,
          width: Get.width,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColor.blue.withValues(alpha: 0.5),
                AppColor.black,
                AppColor.pink.withValues(alpha: 0.9),
              ],
            ),
          ),
          child: Row(
            children: [
              15.width,
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: GestureDetector(
                    onTap: () {
                      UserViewListBottomSheet.show(context: context, title: "Top Gifter", topGifter: controller.host1TopGiftUsers);
                    },
                    child: Container(
                      color: Colors.transparent,
                      child: ListView.builder(
                        itemCount: 3,
                        // itemCount: (controller.host1TopGiftUsers.length ?? 0) < 10 ? 3 : controller.host1TopGiftUsers.length,
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,

                        physics: NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          final isAvailable = (controller.host1TopGiftUsers.length) > index;

                          final indexData = isAvailable ? controller.host1TopGiftUsers[index] : null;
                          return Container(
                            height: 30,
                            width: 30,
                            margin: EdgeInsets.only(right: 10),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColor.white),
                            ),
                            child: Container(
                              height: 30,
                              width: 30,
                              alignment: Alignment.center,
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColor.transparent,
                              ),
                              child: isAvailable == false
                                  ? Image.asset(
                                      AppAsset.icSeat,
                                      width: 15,
                                    )
                                  : Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Container(
                                          height: 30,
                                          width: 30,
                                          clipBehavior: Clip.antiAlias,
                                          decoration: BoxDecoration(shape: BoxShape.circle),
                                          child: PreviewNetworkImageUi(image: indexData?.userId?.image),
                                        ),
                                        Visibility(
                                          visible: indexData?.userId?.isProfilePicBanned ?? false,
                                          child: Container(
                                            clipBehavior: Clip.antiAlias,
                                            decoration: BoxDecoration(shape: BoxShape.circle),
                                            child: BlurryContainer(
                                              height: 30,
                                              width: 30,
                                              blur: 3,
                                              borderRadius: BorderRadius.circular(50),
                                              color: AppColor.black.withValues(alpha:0.3),
                                              child: Offstage(),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          bottom: -10,
                                          child: Container(
                                            height: 22,
                                            width: 22,
                                            alignment: Alignment.center,
                                            padding: EdgeInsets.only(bottom: 14),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: AppColor.primary,
                                            ),
                                            child: Text(
                                              "${index + 1}",
                                              style: AppFontStyle.styleW600(AppColor.white, 8),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
              40.width,
              Expanded(
                child: Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: GestureDetector(
                      onTap: () {
                        log("Tap Top Gifter");
                        UserViewListBottomSheet.show(context: context, title: "Top Gifter", topGifter: controller.host2TopGiftUsers);
                      },
                      child: ListView.builder(
                        itemCount: 3,
                        reverse: true,
                        // itemCount: (controller.host2TopGiftUsers.length ?? 0) < 3 ? 3 : controller.host2TopGiftUsers.length,
                        shrinkWrap: true,

                        scrollDirection: Axis.horizontal,
                        physics: NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          final isAvailable = (controller.host2TopGiftUsers.length) > index;

                          final indexData = isAvailable ? controller.host2TopGiftUsers[index] : null;
                          return GestureDetector(
                            onTap: () => Utils.showLog("******$index"),
                            child: Container(
                              height: 30,
                              width: 30,
                              margin: EdgeInsets.only(right: 10),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColor.white),
                              ),
                              child: Container(
                                height: 30,
                                width: 30,
                                alignment: Alignment.center,
                                clipBehavior: Clip.antiAlias,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColor.transparent,
                                ),
                                child: isAvailable == false
                                    ? Image.asset(
                                        AppAsset.icSeat,
                                        width: 15,
                                      )
                                    : Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          Container(
                                            height: 30,
                                            width: 30,
                                            clipBehavior: Clip.antiAlias,
                                            decoration: BoxDecoration(shape: BoxShape.circle),
                                            child: PreviewNetworkImageUi(image: indexData?.userId?.image),
                                          ),
                                          Visibility(
                                            visible: indexData?.userId?.isProfilePicBanned ?? false,
                                            child: Container(
                                              clipBehavior: Clip.antiAlias,
                                              decoration: BoxDecoration(shape: BoxShape.circle),
                                              child: BlurryContainer(
                                                height: 30,
                                                width: 30,
                                                blur: 3,
                                                borderRadius: BorderRadius.circular(50),
                                                color: AppColor.black.withValues(alpha:0.3),
                                                child: Offstage(),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            bottom: -10,
                                            child: Container(
                                              height: 22,
                                              width: 22,
                                              alignment: Alignment.center,
                                              padding: EdgeInsets.only(bottom: 14),
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: AppColor.primary,
                                              ),
                                              child: Text(
                                                "${index + 1}",
                                                style: AppFontStyle.styleW600(AppColor.white, 8),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
