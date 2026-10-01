import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_typedefs/rx_typedefs.dart';
import 'package:shortie/main.dart';
import 'package:shortie/pages/multi_live_page/controller/multi_live_controller.dart';
import 'package:shortie/ui/circle_icon_button_ui.dart';
import 'package:shortie/ui/preview_network_image_ui.dart';
import 'package:shortie/utils/asset.dart';
import 'package:shortie/utils/color.dart';
import 'package:shortie/utils/font_style.dart';
import 'package:shortie/utils/socket_services.dart';
import 'package:shortie/utils/utils.dart';

class IncomingMultiLiveRequestBottomSheetWidget {
  static bool isTapButton = false;

  static Future<void> show() async {
    isTapButton = false;

    // controller.onChangeRedDot(false);
    await showModalBottomSheet(
      isScrollControlled: true,
      context: Get.context!,
      backgroundColor: AppColor.transparent,
      builder: (context) => GetBuilder<MultiLiveController>(
        id: "onUpdateMultiLive",
        builder: (controller) => Container(
          height: Get.height / 2,
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
              15.height,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(width: 120),
                  Spacer(),
                  Container(
                    height: 4,
                    width: 35,
                    decoration: BoxDecoration(
                      color: AppColor.colorTextDarkGrey,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  Spacer(),
                  GestureDetector(
                    onTap: () {
                      controller.onSwitchToCoHost(liveType: controller.isEnableCoHost ? 2 : 1);
                      Get.back();
                    },
                    child: Container(
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(6), gradient: AppColor.primaryLinearGradient),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 12),
                          child: Text(controller.isEnableCoHost ? "Enable Co-Host" : "Disable Co-Host", style: AppFontStyle.styleW700(AppColor.white, 14)),
                        )),
                  ),
                  12.width
                ],
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
                          itemBuilder: (context, index) {
                            final indexData = controller.multiLiveRequestedList[index];
                            return indexData.userId != null && indexData.userId?.trim() != ""
                                ? UserItemWidget(
                                    title: indexData.name ?? "",
                                    subTitle: indexData.userName ?? "",
                                    leading: indexData.image ?? "",
                                    isVerified: indexData.isVerified ?? false,
                                    isInvited: indexData.isInvited ?? false,
                                    isRequested: indexData.isRequested ?? false,
                                    isAccepted: indexData.isAccepted ?? false,
                                    isMute: indexData.isMute ?? false,
                                    MuteCallback: () {
                                      bool? isMute = indexData.isMute;
                                      isMute = !isMute!;
                                      log("ismute>>>>>>>>. $isMute");
                                      SocketServices().onEmitUpdateMuteStatus(
                                        userId: indexData.userId ?? '',
                                        liveHistoryId: controller.roomID,
                                        liveUserObjId: controller.liveUserObjId,
                                        isMute: isMute,
                                        isCameraEnabled: controller.isCameraOn,
                                        position: controller.coHostRequestPosition,
                                      );
                                    },
                                    rejectCallback: () {
                                      Get.back();

                                      if (isTapButton == false) {
                                        isTapButton = true;
                                        SocketServices().onEmitRemoveCallJoinRequest(
                                          userId: indexData.userId ?? "",
                                          liveHistoryId: controller.roomID,
                                          liveUserObjId: controller.liveUserObjId,
                                          isMute: indexData.isMute ?? false,
                                          isCameraEnabled: indexData.isCameraEnabled ?? false,
                                          coHostRequestPosition: indexData.position ?? 0,
                                        );
                                      }
                                    },
                                    callback: () async {
                                      Utils.showLog("*******${indexData.isAccepted}**********${indexData.isRequested}*********** ${indexData.isInvited}");

                                      Get.back();

                                      await 500.milliseconds.delay();

                                      if (isTapButton == false) {
                                        isTapButton = true;
                                        log("message>>>>>>>>>>>>>>>> controller.joinMultiLiveUsers.length>> ${controller.multiLiveRequestedList.length} ${controller.requestedList?.length}");

                                        if (indexData.isAccepted == true) {
                                          SocketServices().onEmitLeftParticipantOfCallJoin(
                                            userId: indexData.userId ?? "",
                                            liveHistoryId: controller.roomID,
                                            liveUserObjId: controller.liveUserObjId,
                                            isCameraEnabled: indexData.isCameraEnabled ?? false,
                                            position: indexData.position ?? 0,
                                            isMute: indexData.isMute ?? false,
                                          );
                                        } else {
                                          if (controller.multiLiveRequestedList.length == (controller.maxGuestSlots)) {
                                            SocketServices().onEmitAddParticipantToCallJoin(
                                              userId: indexData.userId ?? "",
                                              liveHistoryId: controller.roomID,
                                              liveUserObjId: controller.liveUserObjId,
                                              agoraUid: indexData.agoraUid ?? "",
                                              position: indexData.position ?? 0,
                                              isCameraEnabled: indexData.isCameraEnabled ?? false,
                                              isMute: indexData.isMute ?? false,
                                            );
                                          } else {
                                            Utils.showToast("Maximum 4 user join multi live");
                                          }
                                        }
                                      }
                                    },
                                  )
                                : SizedBox.shrink();
                          },
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
    required this.rejectCallback,
    required this.MuteCallback,
    required this.isMute,
  });

  final String title;
  final String subTitle;
  final String leading;
  final bool isVerified;
  final bool isInvited;
  final bool isRequested;
  final bool isAccepted;
  final bool isMute;
  final Callback callback;
  final Callback MuteCallback;
  final Callback rejectCallback;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      width: Get.width,
      padding: EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: AppColor.transparent,
        border: Border(
          bottom: BorderSide(color: AppColor.colorBorder.withValues(alpha:0.5)),
        ),
      ),
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
          isAccepted
              ? CircleIconButtonUi(
                  circleSize: 40,
                  iconSize: 20,
                  gradient: AppColor.primaryLinearGradient,
                  icon: isMute ? AppAsset.icMicOn : AppAsset.icMicOff,
                  iconColor: AppColor.white,
                  callback: MuteCallback,
                ).paddingOnly(right: 8)
              : SizedBox(),
          GestureDetector(
            onTap: callback,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
              decoration: BoxDecoration(
                gradient: AppColor.primaryLinearGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isAccepted ? "Remove" : "Add",
                style: AppFontStyle.styleW600(AppColor.white, 14),
              ),
            ),
          ),
          Visibility(
            visible: isRequested,
            child: GestureDetector(
              onTap: rejectCallback,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                margin: EdgeInsets.only(left: 8),
                decoration: BoxDecoration(
                  gradient: AppColor.primaryLinearGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "Reject",
                  style: AppFontStyle.styleW600(AppColor.white, 14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
