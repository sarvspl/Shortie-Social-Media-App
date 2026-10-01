import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortie/main.dart';
import 'package:shortie/pages/multi_live_page/model/pk_gift_top_user_model.dart';
import 'package:shortie/ui/preview_network_image_ui.dart';
import 'package:shortie/ui/preview_profile_bottom_sheet_ui.dart';
import 'package:shortie/utils/color.dart';
import 'package:shortie/utils/font_style.dart';

class UserViewListBottomSheet {
  static bool isOpenBottomSheet = false;

  static Future<void> show({required BuildContext context, required String title, List? list, List<PkGiftTopUserModel>? topGifter}) async {
    log("UserViewList>>>>>list>>>>>$list");
    log("UserViewList>>>>>topGifter>>>>>$topGifter");
    await showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      backgroundColor: AppColor.transparent,
      builder: (context) => Container(
        height: 315,
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
              width: Get.width,
              color: AppColor.grey_100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 4,
                        width: 35,
                        decoration: BoxDecoration(
                          color: AppColor.colorTextDarkGrey.withValues(alpha:0.3),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      10.height,
                      Text(
                        title,
                        style: AppFontStyle.styleW700(AppColor.black, 17),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            10.height,
            list != null
                ? Expanded(
                    child: list.isEmpty
                        ? Center(
                            child: Text(
                              "Live User Not Available",
                              style: AppFontStyle.styleW700(AppColor.black, 17),
                            ),
                          )
                        : ListView.builder(
                            itemCount: list.length,
                            itemBuilder: (context, index) {
                              final indexData = list[index];

                              print("--------------- ${indexData}");

                              return GestureDetector(
                                onTap: () async {
                                  PreviewProfileBottomSheetUi.show(context: context, userId: indexData["userId"]);
                                },
                                child: Container(
                                  height: 60,
                                  width: Get.width,
                                  color: Colors.transparent,
                                  margin: EdgeInsets.only(bottom: 10, left: 15, right: 15),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Container(
                                        height: 55,
                                        width: 55,
                                        clipBehavior: Clip.antiAlias,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(shape: BoxShape.circle),
                                        child: indexData['image'],
                                      ),
                                      10.width,
                                      Text(
                                        indexData['name'] ?? "Unknown",
                                        style: AppFontStyle.styleW700(AppColor.black, 17),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  )
                : Expanded(
                    child: topGifter?.isEmpty ?? true
                        ? Center(
                            child: Text(
                              "Top Gifter Not Available",
                              style: AppFontStyle.styleW700(AppColor.black, 17),
                            ),
                          )
                        : ListView.builder(
                            itemCount: topGifter?.length,
                            itemBuilder: (context, index) {
                              final indexData = topGifter?[index];
                              return GestureDetector(
                                onTap: () async {},
                                child: Container(
                                  height: 60,
                                  width: Get.width,
                                  color: Colors.transparent,
                                  margin: EdgeInsets.only(bottom: 10, left: 15, right: 15),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Container(
                                        height: 55,
                                        width: 55,
                                        clipBehavior: Clip.antiAlias,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(shape: BoxShape.circle),
                                        child: CustomPreviewImage(image: indexData?.userId?.image),
                                      ),
                                      10.width,
                                      Text(
                                        indexData?.userId?.name ?? "Unknown",
                                        style: AppFontStyle.styleW700(AppColor.black, 17),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
          ],
        ),
      ),
    ).then((value) {
      return isOpenBottomSheet = false;
    });
  }
}
