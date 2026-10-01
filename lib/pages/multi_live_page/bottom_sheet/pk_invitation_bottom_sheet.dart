import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortie/main.dart';
import 'package:shortie/pages/multi_live_page/controller/multi_live_controller.dart';
import 'package:shortie/ui/preview_network_image_ui.dart';
import 'package:shortie/utils/asset.dart';
import 'package:shortie/utils/color.dart';
import 'package:shortie/utils/font_style.dart';
import 'package:shortie/utils/socket_services.dart';

class PkInvitationBottomSheet {
  static bool? isButtonPress;
  static bool isOpenBottomSheet = false;
  static Future<void> show({required String host1Image, required String host1Name}) async {
    isButtonPress = null;
    isOpenBottomSheet = true;
    await showModalBottomSheet(
      isScrollControlled: true,
      context: Get.context!,
      // isDismissible: false,
      // enableDrag: false,
      backgroundColor: AppColor.transparent,
      builder: (context) => PopScope(
        canPop: false,
        child: Container(
          height: 270,
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
                          "Invitation For Pk Battle",
                          style: AppFontStyle.styleW700(AppColor.black, 17),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              15.height,
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () {},
                          child: Container(
                            height: 65,
                            width: 65,
                            clipBehavior: Clip.antiAlias,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(shape: BoxShape.circle),
                            child: Stack(
                              children: [
                                AspectRatio(
                                  aspectRatio: 1,
                                  child: Image.asset(
                                    AppAsset.icProfilePlaceHolder,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                AspectRatio(
                                  aspectRatio: 1,
                                  child: PreviewNetworkImageUi(image: host1Image),
                                ),
                              ],
                            ),
                          ),
                        ),
                        10.width,
                        Text(
                          host1Name,
                          style: AppFontStyle.styleW700(AppColor.black, 17),
                        ),
                      ],
                    ),
                    10.height,
                    Center(
                      child: Text(
                        "Join PK battle to gain more exposure and coins!",
                        style: AppFontStyle.styleW700(AppColor.black, 15),
                      ),
                    ),
                    15.height,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GetBuilder<MultiLiveController>(
                          builder: (controller) {
                            return Expanded(
                              child: GestureDetector(
                                onTap: () async {
                                  if (isButtonPress == null) {
                                    isButtonPress = true;

                                    SocketServices.onPkAnswer(isAccept: false, isPkRound: false);

                                    Get.back();
                                  }
                                },
                                child: Container(
                                  height: 45,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: AppColor.colorRedContainer,
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.call_end_rounded,
                                        color: AppColor.white,
                                        size: 28,
                                      ),
                                      8.width,
                                      Text(
                                        "Reject",
                                        style: AppFontStyle.styleW700(AppColor.white, 16),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        10.width,
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              await 300.milliseconds.delay();
                              if (isButtonPress == null) {
                                isButtonPress = true;
                                SocketServices.onPkAnswer(isAccept: true, isPkRound: true);
                                Get.back();
                              }

                              // final controller = Get.put(MultiLiveController());
                              //
                              // // Host 2 Mean => PK Request Sender
                              // controller.host2Id = SocketServices.pkRequestResponse["host1Id"];
                              // controller.host2Name = SocketServices.pkRequestResponse["host1Name"];
                              // controller.host2UserName = SocketServices.pkRequestResponse["host1UserName"];
                              // controller.host2Image = SocketServices.pkRequestResponse["host1Image"];
                              //
                              // controller.host2Token = SocketServices.pkRequestResponse["host1Token"];
                              // controller.host2ChannelId = SocketServices.pkRequestResponse["host1ChannelId"];
                              //
                              // log("controller.host2ChannelId>>>>>>>${controller.host2ChannelId}");
                              // controller.host2RoomId = SocketServices.pkRequestResponse["host1RoomId"];
                              //
                              // controller.onStartRelay();
                              //
                              // Get.back();
                              // Utils.showLog("Pk Event => Host1 Close Opened Invitation Pk Request Bs (Accept)");
                            },
                            child: Container(
                              height: 45,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: AppColor.colorClosedGreen,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.phone_rounded,
                                    color: AppColor.white,
                                    size: 28,
                                  ),
                                  8.width,
                                  Text(
                                    "Accept",
                                    style: AppFontStyle.styleW700(AppColor.white, 16),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ).then((value) => isOpenBottomSheet = false);
  }
}
