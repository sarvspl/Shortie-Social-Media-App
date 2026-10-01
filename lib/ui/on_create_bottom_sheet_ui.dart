import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_typedefs/rx_typedefs.dart';
import 'package:shortie/main.dart';
import 'package:shortie/utils/asset.dart';
import 'package:shortie/utils/color.dart';
import 'package:shortie/utils/font_style.dart';

class OnCreateBottomSheetUi {
  static Future<void> show({
    required BuildContext context,
    required Callback onClickReels,
    required Callback onClickFeed,
    required Callback onClickStory,
  }) async {
    await showModalBottomSheet(
      isScrollControlled: false,
      context: context,
      backgroundColor: AppColor.transparent,
      builder: (context) => Container(
        height: 250,
        width: Get.width,
        clipBehavior: Clip.antiAlias,
        decoration: const BoxDecoration(
          color: AppColor.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(40),
            topRight: Radius.circular(40),
          ),
        ),
        child: Column(
          children: [
            Container(
              height: 65,

              color: AppColor.grey_100,
              child: Row(
                children: [
                  const Spacer(),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 4,
                        width: 35,
                        decoration: BoxDecoration(
                          color: AppColor.colorTextDarkGrey,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      10.height,
                      Text(
                        'Select Upload Type',
                        style: AppFontStyle.styleW700(AppColor.black, 17),
                      ),
                    ],
                  ).paddingOnly(left: 50),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      height: 30,
                      width: 30,
                      margin: const EdgeInsets.only(right: 20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColor.black),
                      ),
                      child: Center(
                        child: Image.asset(
                          AppAsset.icClose,
                          width: 18,
                          color: AppColor.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            5.height,

            // ===== REELS =====
            _bottomItem(
              icon: AppAsset.icReels,
              title: "Reels",
              onTap: () {
                Get.back();
                onClickReels.call();
              },
            ),

            // ===== FEED =====
            _bottomItem(
              icon: AppAsset.icFeeds,
              title: "Feed",
              onTap: () {
                Get.back();
                onClickFeed.call();
              },
            ),

            // ===== STORY =====
            _bottomItem(
              icon: AppAsset.icVideoPickerImage,
              title: "Story",
              onTap: () {
                Get.back();
                onClickStory.call();
              },
            ),
          ],
        ),
      ),
    );
  }

  // COMMON WIDGET
  static Widget _bottomItem({
    required String icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 55,
        width: Get.width,
        color: AppColor.white,
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Row(
          children: [
            Image.asset(icon, width: 26, color: AppColor.black),
            15.width,
            Text(
              title,
              style: AppFontStyle.styleW700(AppColor.black, 17),
            ),
          ],
        ),
      ),
    );
  }
}
