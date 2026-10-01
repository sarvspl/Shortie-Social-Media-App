import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_typedefs/rx_typedefs.dart';
import 'package:shortie/main.dart';
import 'package:shortie/pages/multi_live_page/controller/multi_live_controller.dart';
import 'package:shortie/ui/preview_network_image_ui.dart';
import 'package:shortie/utils/asset.dart';
import 'package:shortie/utils/color.dart';
import 'package:shortie/utils/database.dart';
import 'package:shortie/utils/font_style.dart';

class JoinMultiLiveRequestBottomSheetWidget {
  static Future<void> show() async {
    await showModalBottomSheet(
      isScrollControlled: true,
      context: Get.context!,
      backgroundColor: AppColor.transparent,
      builder: (context) {
        return GetBuilder<MultiLiveController>(
          id: "onUpdateMultiLive",
          builder: (controller) {
            bool hasAcceptedRequest = controller.multiLiveRequestedList.any((user) => user.userId == Database.loginUserId && (user.isAccepted ?? false) == true);
            return Container(
              height: 180,
              width: Get.width,
              decoration: BoxDecoration(
                color: AppColor.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  25.height,
                  Container(
                    height: 30,
                    width: Get.width,
                    decoration: BoxDecoration(
                      color: AppColor.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        20.width,
                        Text(
                          "Join Request",
                          style: AppFontStyle.styleW700(AppColor.black, 16),
                        ),
                        Spacer(),
                        Visibility(
                          visible: (controller.multiLiveRequestedList.isEmpty || !hasAcceptedRequest && controller.multiLiveRequestedList.any((user) => user.userId != Database.loginUserId)),
                          child: GestureDetector(
                            onTap: () {
                              Get.back();

                              controller.onSendMultiLiveRequestOnSocket();
                              // Utils.showToast("Join request send success");
                            },
                            child: Container(
                              height: 35,
                              width: 60,
                              alignment: Alignment.center,
                              margin: EdgeInsets.only(right: 15),
                              decoration: BoxDecoration(
                                gradient: AppColor.primaryLinearGradient,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Text(
                                "Join",
                                style: AppFontStyle.styleW600(AppColor.white, 14),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  20.height,
                  Expanded(
                    child: controller.multiLiveRequestedList.isEmpty
                        ? Center(
                            child: Text(
                              "No Data Found",
                              style: AppFontStyle.styleW700(AppColor.black, 14),
                            ),
                          )
                        : SingleChildScrollView(
                            child: ListView.builder(
                              itemCount: controller.multiLiveRequestedList.length,
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              padding: EdgeInsets.zero,
                              itemBuilder: (context, index) {
                                if (controller.multiLiveRequestedList.isNotEmpty && controller.multiLiveRequestedList[index].name != null && controller.multiLiveRequestedList[index].name != "") {
                                  log("multiLiveRequestedList>>>>>>${controller.multiLiveRequestedList[index].name}");
                                  log("multiLiveRequestedList>>>multiLiveRequestedList>>>>>>${controller.multiLiveRequestedList[index].isAccepted}");
                                }

                                final indexData = controller.multiLiveRequestedList[index];
                                return indexData.userId == Database.loginUserId
                                    ? UserItemWidget(
                                        title: controller.name,
                                        subTitle: controller.userName,
                                        leading: controller.image,
                                        isVerified: false,
                                        isInvited: indexData.isInvited ?? false,
                                        isRequested: indexData.isRequested ?? false,
                                        isAccepted: indexData.isAccepted ?? false,
                                        callback: () {
                                          if (indexData.isAccepted == true) {
                                            Get.back();
                                            controller.onLeftMultiLiveOnSocket();
                                          }
                                        },
                                      )
                                    : Offstage();
                              },
                            ),
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class UserItemWidget extends StatelessWidget {
  const UserItemWidget({
    super.key,
    required this.title,
    required this.subTitle,
    required this.leading,
    required this.isVerified,
    required this.isInvited,
    required this.isRequested,
    required this.isAccepted,
    required this.callback,
  });

  final String title;
  final String subTitle;
  final String leading;
  final bool isVerified;
  final bool isInvited;
  final bool isRequested;
  final bool isAccepted;
  final Callback callback;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      width: Get.width,
      padding: EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(color: AppColor.transparent),
      child: Row(
        children: [
          Container(
            height: 46,
            width: 46,
            clipBehavior: Clip.antiAlias,
            decoration: const BoxDecoration(shape: BoxShape.circle),
            child: Stack(
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: Image.asset(AppAsset.icProfilePlaceHolder),
                ),
                AspectRatio(
                  aspectRatio: 1,
                  child: PreviewNetworkImageUi(image: leading),
                ),
              ],
            ),
          ),
          12.width,
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      fit: FlexFit.loose,
                      child: Text(
                        title,
                        maxLines: 1,
                        style: AppFontStyle.styleW700(AppColor.black, 15.5),
                      ),
                    ),
                    Visibility(
                      visible: isVerified,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 3),
                        child: Image.asset(AppAsset.icBlueTick, width: 20),
                      ),
                    ),
                  ],
                ),
                Text(
                  subTitle,
                  maxLines: 1,
                  style: AppFontStyle.styleW400(AppColor.coloGreyText, 14),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: callback,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
              decoration: BoxDecoration(
                gradient: AppColor.primaryLinearGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isAccepted ? "Leave" : "Requested",
                style: AppFontStyle.styleW600(AppColor.white, 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
