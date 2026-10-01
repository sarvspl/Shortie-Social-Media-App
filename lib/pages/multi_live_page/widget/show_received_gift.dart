import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortie/main.dart';
import 'package:shortie/ui/preview_network_image_ui.dart';
import 'package:shortie/utils/color.dart';
import 'package:shortie/utils/constant.dart';
import 'package:shortie/utils/font_style.dart';
import 'package:shortie/utils/utils.dart';

class ShowReceivedGift {
  static bool isGiftProcessRunning = false;
  static RxBool isShow = false.obs;
  static RxDouble senderDetailsPosition = (-500.0).obs;
  static RxList<GiftModel> giftList = <GiftModel>[].obs;

  static RxBool isShowLuckyWin = false.obs;
  static RxDouble luckyWinPosition = (-500.0).obs;
  static RxInt luckyCoin = 0.obs;

  static void onGetNewGift(GiftModel gift) {
    Utils.showLog("GET NEW GIFT TO AUDIO ROOM => ${gift.receiverName}");

    Utils.showLog("Previous Gift Collection => ${giftList.length}");
    giftList.add(gift);
    Utils.showLog("After Add Gift Collection => ${giftList.length}");

    if (isGiftProcessRunning == false) _onShowGiftTime();
  }

  static void onGetLuckyWinCoin({required int coin}) async {
    luckyCoin.value = coin;
    Utils.showLog("Lucky Win Show Start....");
    isShowLuckyWin.value = true;
    luckyWinPosition.value = 0;
    await 1500.milliseconds.delay();
    luckyWinPosition.value = -500;

    await 1000.milliseconds.delay();

    isShowLuckyWin.value = false;
    Utils.showLog("Lucky Win Show Complete....");
  }

  static Future<void> _onShowGiftTime() async {
    if (giftList.isNotEmpty) {
      Utils.showLog("Gift Show Running....");

      isGiftProcessRunning = true;

      isShow.value = true;

      senderDetailsPosition.value = 0;

      if (giftList[0].giftType != 3) await 5000.milliseconds.delay();

      if (giftList[0].giftType != 3) await onCompleteGiftShow();
    }
  }

  static Future<void> onCompleteGiftShow() async {
    senderDetailsPosition.value = -500;
    await Future.delayed(Duration(seconds: 1));
    isShow.value = false;
    if (giftList.isNotEmpty) giftList.removeAt(0);
    await 500.milliseconds.delay();
    Utils.showLog("Gift Show Complete....");
    Utils.showLog("My After Remove Gift Collection => ${giftList.length}");
    if (giftList.isEmpty) isGiftProcessRunning = false;
    if (isGiftProcessRunning) _onShowGiftTime();
  }

  static Widget onShowGift() {
    return Obx(
      () => isShow.value
          ? AnimatedOpacity(
              opacity: 0.99,
              curve: Curves.easeInToLinear,
              duration: Duration(milliseconds: 500),
              child: Container(
                height: giftList[0].giftType == 3 ? Get.height : 250,
                width: giftList[0].giftType == 3 ? Get.width : 250,
                color: AppColor.transparent,
                child: PreviewGiftWidget(
                  url: giftList[0].giftUrl,
                  type: giftList[0].giftType,
                  whenCompleteSVGA: () => onCompleteGiftShow(),
                ),
              ),
            )
          : Offstage(),
    );
  }

  static Widget onShowSenderDetails() {
    return Obx(
      () => isShow.value
          ? AnimatedPositioned(
              duration: Duration(milliseconds: 1000),
              right: senderDetailsPosition.value,
              curve: Curves.easeInOut,
              child: Container(
                height: 55,
                margin: EdgeInsets.only(top: Get.height / 3),
                padding: EdgeInsets.all(3),
                width: giftList[0].receiverName.trim().isEmpty ? Get.width / 2 : 230,
                decoration: BoxDecoration(
                  color: AppColor.lighterYellow,
                  boxShadow: [
                    BoxShadow(
                      color: AppColor.lightYellow.withValues(alpha: 0.3),
                      blurRadius: 10,
                      spreadRadius: 10,
                    ),
                  ],
                  border: Border(
                    top: BorderSide(color: AppColor.orange.withValues(alpha: 0.5), width: 3),
                    left: BorderSide(color: AppColor.orange.withValues(alpha: 0.5), width: 3),
                    bottom: BorderSide(color: AppColor.orange.withValues(alpha: 0.5), width: 3),
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(100),
                    bottomLeft: Radius.circular(100),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      height: 45,
                      width: 45,
                      padding: EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColor.white),
                        shape: BoxShape.circle,
                      ),
                      child: Container(
                        height: 45,
                        width: 45,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          gradient: AppColor.lightYellowOrangeGradient,
                          shape: BoxShape.circle,
                        ),
                        child: PreviewProfileImageWidget(
                          image: giftList[0].senderImage,
                          isBanned: giftList[0].senderProfilePicBanned,
                        ),
                      ),
                    ),
                    5.width,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            giftList[0].senderName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppFontStyle.styleW700(AppColor.orange, 14),
                          ),
                          Flexible(
                            fit: FlexFit.loose,
                            child: Text(
                              giftList[0].receiverName.trim().isEmpty ? "ID: ${giftList[0].senderUniqueId}" : "Send To : ${giftList[0].receiverName}",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppFontStyle.styleW600(AppColor.brown, giftList[0].receiverName.trim().isEmpty ? 11 : 10),
                            ),
                          ),
                        ],
                      ),
                    ),
                    5.width,
                    Text(
                      "X${giftList[0].giftCount}",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        fontFamily: AppConstant.appFontExtraBold,
                        fontStyle: FontStyle.italic,
                        foreground: Paint()
                          ..shader = LinearGradient(
                            colors: [AppColor.orange, AppColor.orange],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ).createShader(const Rect.fromLTWH(10, 0, 0, 10)),
                        shadows: [
                          const Shadow(
                            offset: Offset(3, 3),
                            blurRadius: 3,
                            color: Colors.black,
                          ),
                          const Shadow(
                            offset: Offset(1, 1),
                            blurRadius: 0,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                    10.width,
                  ],
                ),
              ),
            )
          : Offstage(),
    );
  }
}

class GiftModel {
  int giftType;
  String giftUrl;
  int giftCount;
  String senderName;
  String senderImage;
  bool senderProfilePicBanned;
  String senderUniqueId;
  String receiverName;
  bool? isFake;

  GiftModel({
    required this.giftType,
    required this.giftUrl,
    required this.giftCount,
    required this.senderName,
    required this.senderImage,
    required this.senderProfilePicBanned,
    required this.senderUniqueId,
    this.isFake,
    required this.receiverName, // STORE IN AUDIO ROOM ONLY
  });
}
