import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortie/main.dart';
import 'package:shortie/pages/multi_live_page/bottom_sheet/invite_user_for_pk_bottom_sheet.dart';
import 'package:shortie/pages/multi_live_page/bottom_sheet/sending_pk_request_bottom_sheet.dart';
import 'package:shortie/pages/multi_live_page/controller/multi_live_controller.dart';
import 'package:shortie/ui/preview_network_image_ui.dart';
import 'package:shortie/utils/asset.dart';
import 'package:shortie/utils/color.dart';
import 'package:shortie/utils/enums.dart';
import 'package:shortie/utils/font_style.dart';
import 'package:shortie/utils/socket_services.dart';
import 'package:shortie/utils/utils.dart';

/// Enum to represent the PK battle result
enum PKResult { win, lose, tie }

/// Base class for PK result bottom sheets
class PkResultBottomSheetUi {
  static bool isOpenBottomSheet = false;

  static Future<void> show({
    required PKResult result,
    required String h1Name,
    required String h1Image,
    required String h2Name,
    required String h2Image,
    required int host1WinnerPoint,
    required int host2WinnerPoint,
    required int h1RankTotal,
    required int h2RankTotal,
    int totalPkRounds = 0,
  }) async {
    isOpenBottomSheet = true;

    final controller = Get.isRegistered<MultiLiveController>() ? Get.find<MultiLiveController>() : null;
    final bool isHost = controller?.isHost ?? false;

    String title;
    String subtitle;
    String emojiAsset;
    LinearGradient gradient;

    switch (result) {
      case PKResult.win:
        title = "Victory!";
        subtitle = isHost ? "You Won the PK Battle" : "$h1Name Won the PK Battle";
        emojiAsset = AppAsset.img_pk_win_emoji;
        gradient = AppColor.primaryLinearGradient;
        break;
      case PKResult.lose:
        title = isHost ? "Better Luck Next Time" : "Battle Ended";
        subtitle = isHost ? "You Lost the PK Battle" : "$h2Name Won the PK Battle";
        emojiAsset = AppAsset.img_pk_lose_emoji;
        gradient = AppColor.redGradient;
        break;
      case PKResult.tie:
        title = "It's a Draw!";
        subtitle = "Both Hosts Gave Their Best";
        emojiAsset = AppAsset.img_pk_tie_emoji;
        gradient = AppColor.greyGradient;
        break;
    }

    await showModalBottomSheet(
      isScrollControlled: true,
      context: Get.context!,
      backgroundColor: AppColor.transparent,
      builder: (context) => Container(
        width: Get.width,
        clipBehavior: Clip.antiAlias,
        decoration: const BoxDecoration(
          color: AppColor.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(gradient: gradient),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: _buildResultHeader(
                    title,
                    subtitle,
                    emojiAsset,
                    totalPkRounds,
                    result,
                  ),
                ),
              ),
              result == PKResult.tie ? 15.height : 10.height,
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: _buildStatsSection(
                  h1Name,
                  h1Image,
                  h2Name,
                  h2Image,
                  host1WinnerPoint,
                  host2WinnerPoint,
                  h1RankTotal,
                  h2RankTotal,
                  result,
                ),
              ),
              15.height,
              _buildActionButtons(context),
              15.height,
            ],
          ),
        ),
      ),
    ).whenComplete(() => isOpenBottomSheet = false);
  }

  static Widget _buildResultHeader(
    String title,
    String subtitle,
    String emojiAsset,
    int totalPkRounds,
    PKResult result,
  ) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              15.height,
              Text(title, style: AppFontStyle.styleW600(AppColor.white, 16)),
              8.height,
              Text(
                subtitle,
                style: AppFontStyle.styleW900(AppColor.white, PKResult.tie == result ? 19 : 23),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              5.height,
              if (totalPkRounds > 0) Text("$totalPkRounds Rounds Completed", style: AppFontStyle.styleW500(AppColor.white, 14)),
              12.height,
            ],
          ),
        ),
        10.width,
        if (emojiAsset.isNotEmpty)
          Image.asset(
            emojiAsset,
            width: result == PKResult.tie ? 55 : 85,
            height: result == PKResult.tie ? 55 : 85,
            fit: BoxFit.contain,
          ),
      ],
    );
  }

  // static Widget _buildTieHeader(String title, String subtitle) {
  //   return Center(
  //     child: Column(
  //       children: [
  //         10.height,
  //         Container(
  //           height: 4,
  //           width: 35,
  //           decoration: BoxDecoration(
  //             color: AppColor.colorTextDarkGrey,
  //             borderRadius: BorderRadius.circular(10),
  //           ),
  //         ),
  //         10.height,
  //         Text(title, style: AppFontStyle.styleW800(AppColor.black, 17)),
  //         4.height,
  //         Text(subtitle, style: AppFontStyle.styleW500(AppColor.black, 14)),
  //       ],
  //     ),
  //   );
  // }

  static Widget _buildStatsSection(
    String h1Name,
    String h1Image,
    String h2Name,
    String h2Image,
    int host1WinnerPoint,
    int host2WinnerPoint,
    int h1RankTotal,
    int h2RankTotal,
    PKResult result,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildUserAvatar(h1Image, result),
          10.width,
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(h1Name, style: AppFontStyle.styleW600(AppColor.black, 13), maxLines: 1, overflow: TextOverflow.ellipsis)),
                    10.width,
                    Expanded(child: Text(h2Name, textAlign: TextAlign.end, style: AppFontStyle.styleW600(AppColor.black, 13), maxLines: 1, overflow: TextOverflow.ellipsis)),
                  ],
                ),
                5.height,
                // Row(
                //   children: [
                //     _buildPointsText(host1WinnerPoint),
                //     Spacer(),
                //     _buildPointsText(host2WinnerPoint),
                //   ],
                // ),
                // 5.height,
                _buildProgressBar(h1RankTotal, h2RankTotal),
              ],
            ),
          ),
          10.width,
          _buildUserAvatar(h2Image, result),
        ],
      ),
    );
  }

  static Widget _buildUserAvatar(String image, PKResult result) {
    return Container(
      padding: EdgeInsets.all(1),
      decoration: BoxDecoration(
        gradient: AppColor.primaryLinearGradient,
        shape: BoxShape.circle,
      ),
      child: Container(
        height: 50,
        width: 50,
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
              child: PreviewNetworkImageUi(image: image),
            ),
          ],
        ),
      ),
    );
  }

  // static Widget _buildPointsText(int points) {
  //   return Text(
  //     "Win $points",
  //     style: TextStyle(
  //       fontSize: 16,
  //       fontWeight: FontWeight.bold,
  //       fontFamily: AppConstant.appFontBold,
  //       fontStyle: FontStyle.italic,
  //       foreground: Paint()
  //         ..shader = LinearGradient(
  //           colors: [AppColor.primary, AppColor.secondary],
  //           begin: Alignment.topLeft,
  //           end: Alignment.bottomRight,
  //         ).createShader(Rect.fromLTWH(10, 0, 0, 10)),
  //       shadows: [
  //         Shadow(offset: Offset(2, 2), blurRadius: 3, color: Colors.black),
  //         Shadow(offset: Offset(1, 1), blurRadius: 0, color: Colors.white),
  //       ],
  //     ),
  //   );
  // }

  static Widget _buildProgressBar(int h1RankTotal, int h2RankTotal) {
    Utils.showLog("h1RankTotal When End => $h1RankTotal");
    bool tie = false;
    if (h1RankTotal == 0 && h2RankTotal == 0) {
      tie = true;
    }
    return Align(
      alignment: Alignment.center,
      child: Container(
        height: 15,
        // color: Colors.pink,
        width: Get.width,
        child: Row(
          children: [
            Expanded(
              flex: tie ? 1 : h1RankTotal * 100,
              child: Container(
                height: 15,
                padding: EdgeInsets.only(left: 5),
                alignment: Alignment.centerLeft,
                color: AppColor.primary,
                child: Text("$h1RankTotal", style: AppFontStyle.styleW500(AppColor.white, 10)),
              ),
            ),
            Expanded(
              flex: tie ? 1 : h2RankTotal * 100,
              child: Container(
                height: 15,
                alignment: Alignment.centerRight,
                padding: EdgeInsets.only(right: 5),
                color: AppColor.secondary,
                child: Text("$h2RankTotal", style: AppFontStyle.styleW500(AppColor.white, 10)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GetBuilder<MultiLiveController>(
            builder: (controller) {
              return !controller.isHost
                  ? Container()
                  : Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Get.back();
                          InviteUserForPkBottomSheet.show(
                            context: context,
                            callback: () async {
                              SocketServices.onSendPkRequest(
                                host1ChannelId: controller.host1ChannelId,
                                host1RoomId: controller.host1RoomId,
                                host1Token: controller.host1Token,
                                host2Id: controller.host2Id,
                                host2ChannelId: controller.host2ChannelId,
                                host2RoomId: controller.host2RoomId,
                                host2Token: controller.host2Token,
                              );
                              Get.back();
                              SendingPkRequestBottomSheet.onShow(
                                context: Get.context!,
                                h1Name: controller.host1Name,
                                h1Image: controller.host1Image,
                                h2Name: controller.host2Name,
                                h2Image: controller.host2Image,
                                callback: () {
                                  Get.back();
                                  SocketServices.onCancelPkRequest(
                                    host1Id: controller.host1Id,
                                    host2Id: controller.host2Id,
                                  );
                                },
                              );
                            },
                          );
                        },
                        child: Container(
                          height: 45,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColor.colorRedContainer,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Text(EnumLocal.txtBattleAgain.name.tr + "!", style: AppFontStyle.styleW700(AppColor.white, 16)),
                        ),
                      ).paddingOnly(right: 10),
                    );
            },
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => Get.back(),
              child: Container(
                height: 45,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColor.coloGreyText,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: GetBuilder<MultiLiveController>(
                  builder: (controller) => Text(
                    controller.isHost ? EnumLocal.txtEndBattle.name.tr : "Close",
                    style: AppFontStyle.styleW700(AppColor.white, 16),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// /// Implementation for win scenario
// class PkYouWinBottomSheetUi {
//   static bool isOpenBottomSheet = false;
//
//   static Future<void> show({
//     required String h1Name,
//     required String h1Image,
//     required String h2Name,
//     required String h2Image,
//     required int host1WinnerPoint,
//     required int host2WinnerPoint,
//     required int h1RankTotal,
//     required int h2RankTotal,
//     required int totalPkRounds,
//   }) async {
//     return PkResultBottomSheetUi.show(
//       result: PKResult.win,
//       h1Name: h1Name,
//       h1Image: h1Image,
//       h2Name: h2Name,
//       h2Image: h2Image,
//       host1WinnerPoint: host1WinnerPoint,
//       host2WinnerPoint: host2WinnerPoint,
//       h1RankTotal: h1RankTotal,
//       h2RankTotal: h2RankTotal,
//       totalPkRounds: totalPkRounds,
//     );
//   }
// }
//
// /// Implementation for lose scenario
// class PkYouLoseBottomSheetUi {
//   static bool isOpenBottomSheet = false;
//
//   static Future<void> show({
//     required String h1Name,
//     required String h1Image,
//     required String h2Name,
//     required String h2Image,
//     required int host1WinnerPoint,
//     required int host2WinnerPoint,
//     required int h1RankTotal,
//     required int h2RankTotal,
//   }) async {
//     return PkResultBottomSheetUi.show(
//       result: PKResult.lose,
//       h1Name: h1Name,
//       h1Image: h1Image,
//       h2Name: h2Name,
//       h2Image: h2Image,
//       host1WinnerPoint: host1WinnerPoint,
//       host2WinnerPoint: host2WinnerPoint,
//       h1RankTotal: h1RankTotal,
//       h2RankTotal: h2RankTotal,
//     );
//   }
// }
//
// /// Implementation for tie scenario
// class PkTieBottomSheetUi {
//   static bool isOpenBottomSheet = false;
//
//   static Future<void> show({
//     required String h1Name,
//     required String h1Image,
//     required String h2Name,
//     required String h2Image,
//     required int host1WinnerPoint,
//     required int host2WinnerPoint,
//     required int h1RankTotal,
//     required int h2RankTotal,
//   }) async {
//     return PkResultBottomSheetUi.show(
//       result: PKResult.tie,
//       h1Name: h1Name,
//       h1Image: h1Image,
//       h2Name: h2Name,
//       h2Image: h2Image,
//       host1WinnerPoint: host1WinnerPoint,
//       host2WinnerPoint: host2WinnerPoint,
//       h1RankTotal: h1RankTotal,
//       h2RankTotal: h2RankTotal,
//     );
//   }
// }
