// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:shortie/main.dart';
// import 'package:shortie/pages/multi_live_page/bottom_sheet/invite_user_for_pk_bottom_sheet.dart';
// import 'package:shortie/pages/multi_live_page/bottom_sheet/sending_pk_request_bottom_sheet.dart';
// import 'package:shortie/pages/multi_live_page/controller/multi_live_controller.dart';
// import 'package:shortie/ui/preview_network_image_ui.dart';
// import 'package:shortie/utils/asset.dart';
// import 'package:shortie/utils/color.dart';
// import 'package:shortie/utils/enums.dart';
// import 'package:shortie/utils/font_style.dart';
// import 'package:shortie/utils/socket_services.dart';
// import 'package:shortie/utils/utils.dart';
//
// class PkRoundOverBottomSheetUi {
//   static bool isOpenBottomSheet = false;
//
//   // Win Types: 0=>Tie 1=>Lose 2=>Win
//   static Future<void> show({
//     required String h1Name,
//     required String h1Image,
//     required String h2Name,
//     required String h2Image,
//     required int winType,
//     required String currentUserId,
//     required String winnerUserId,
//     int h1Rank = 0,
//     int h2Rank = 0,
//   }) async {
//     isOpenBottomSheet = true;
//
//     // Determine if the current user is the winner
//     bool isCurrentUserWinner = winType == 2;
//     bool isTie = winType == 0;
//     String resultText;
//     final controller = Get.find<MultiLiveController>();
//
//     final winnerName = (winnerUserId == controller.host1Id) ? h1Name : h2Name;
//     final loserName = (winnerUserId == controller.host1Id) ? h2Name : h1Name;
//     final bool isHost = controller.isHost;
//
//     if (isTie) {
//       resultText = "It's a Draw! ⚔️";
//     } else if (isHost) {
//       resultText = isCurrentUserWinner ? "Victory is Yours! 🏆" : "💔 Better Luck Next Time!";
//     } else {
//       resultText = isCurrentUserWinner ? "$winnerName just won the battle! 🏆" : "💔 $loserName couldn't win this time!";
//     }
//     Color resultColor = isTie
//         ? AppColor.coloGreyText
//         : isCurrentUserWinner
//             ? AppColor.primary
//             : AppColor.colorRedContainer;
//
//     await showModalBottomSheet(
//       isScrollControlled: true,
//       isDismissible: false,
//       context: Get.context!,
//       backgroundColor: AppColor.white,
//       builder: (context) => WillPopScope(
//         onWillPop: () async {
//           return false;
//         },
//         child: Container(
//           height: 280,
//           width: Get.width,
//           clipBehavior: Clip.antiAlias,
//           decoration: const BoxDecoration(
//             color: AppColor.white,
//             borderRadius: BorderRadius.only(
//               topLeft: Radius.circular(15),
//               topRight: Radius.circular(15),
//             ),
//           ),
//           child: Column(
//             children: [
//               Container(
//                 decoration: BoxDecoration(
//                   gradient: AppColor.primaryLinearGradient,
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 15),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       15.height,
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           // if (isCurrentUserWinner) Image.asset(AppAsset.img_pk_win_emoji, width: 30),
//                           5.width,
//                           Text(
//                             resultText,
//                             style: AppFontStyle.styleW700(AppColor.white, 20),
//                           ),
//                           5.width,
//                           // if (isCurrentUserWinner) Image.asset(AppAsset.img_pk_win_emoji, width: 30),
//                         ],
//                       ),
//                       20.height,
//                       Container(
//                         height: 90,
//                         padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.start,
//                           crossAxisAlignment: CrossAxisAlignment.center,
//                           children: [
//                             Column(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 Container(
//                                   padding: EdgeInsets.all(2),
//                                   decoration: BoxDecoration(
//                                     color: isTie
//                                         ? AppColor.coloGreyText
//                                         : (currentUserId == winnerUserId)
//                                             ? AppColor.primary
//                                             : AppColor.coloGreyText,
//                                     shape: BoxShape.circle,
//                                   ),
//                                   child: Container(
//                                     height: 50,
//                                     width: 50,
//                                     clipBehavior: Clip.antiAlias,
//                                     alignment: Alignment.center,
//                                     decoration: BoxDecoration(shape: BoxShape.circle),
//                                     child: Stack(
//                                       children: [
//                                         AspectRatio(
//                                           aspectRatio: 1,
//                                           child: Image.asset(
//                                             AppAsset.icProfilePlaceHolder,
//                                             fit: BoxFit.cover,
//                                           ),
//                                         ),
//                                         AspectRatio(
//                                           aspectRatio: 1,
//                                           child: PreviewNetworkImageUi(image: h1Image),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                                 5.height,
//                                 Text(
//                                   isTie
//                                       ? "Tie"
//                                       : (currentUserId == winnerUserId)
//                                           ? "Winner"
//                                           : "Loser",
//                                   style: AppFontStyle.styleW600(
//                                       isTie
//                                           ? AppColor.coloGreyText
//                                           : (currentUserId == winnerUserId)
//                                               ? AppColor.primary
//                                               : AppColor.coloGreyText,
//                                       12),
//                                 ),
//                               ],
//                             ),
//                             10.width,
//                             Expanded(
//                               child: Column(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   Row(
//                                     children: [
//                                       Text(
//                                         h1Name,
//                                         style: AppFontStyle.styleW600(AppColor.black, 13),
//                                       ),
//                                       Spacer(),
//                                       Text(
//                                         h2Name,
//                                         style: AppFontStyle.styleW600(AppColor.black, 13),
//                                       ),
//                                     ],
//                                   ),
//                                   8.height,
//                                   Align(
//                                     alignment: Alignment.center,
//                                     child: Container(
//                                       height: 15,
//                                       color: Colors.pink,
//                                       width: Get.width,
//                                       child: Row(
//                                         children: [
//                                           Expanded(
//                                             flex: isTie ? 1 : h1Rank * 100,
//                                             child: Container(
//                                               height: 15,
//                                               padding: EdgeInsets.only(left: 5),
//                                               alignment: Alignment.centerLeft,
//                                               color: AppColor.primary,
//                                               child: Text("$h1Rank", style: AppFontStyle.styleW500(AppColor.white, 10)),
//                                             ),
//                                           ),
//                                           Expanded(
//                                             flex: isTie ? 1 : h2Rank * 100,
//                                             child: Container(
//                                               height: 15,
//                                               alignment: Alignment.centerRight,
//                                               padding: EdgeInsets.only(right: 5),
//                                               color: AppColor.secondary,
//                                               child: Text("$h2Rank", style: AppFontStyle.styleW500(AppColor.white, 10)),
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             10.width,
//                             Column(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 Container(
//                                   padding: EdgeInsets.all(2),
//                                   decoration: BoxDecoration(
//                                     color: isTie
//                                         ? AppColor.coloGreyText
//                                         : (currentUserId != winnerUserId)
//                                             ? AppColor.primary
//                                             : AppColor.coloGreyText,
//                                     shape: BoxShape.circle,
//                                   ),
//                                   child: Container(
//                                     height: 50,
//                                     width: 50,
//                                     clipBehavior: Clip.antiAlias,
//                                     alignment: Alignment.center,
//                                     decoration: BoxDecoration(shape: BoxShape.circle),
//                                     child: Stack(
//                                       children: [
//                                         AspectRatio(
//                                           aspectRatio: 1,
//                                           child: Image.asset(
//                                             AppAsset.icProfilePlaceHolder,
//                                             fit: BoxFit.cover,
//                                           ),
//                                         ),
//                                         AspectRatio(
//                                           aspectRatio: 1,
//                                           child: PreviewNetworkImageUi(image: h2Image),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                                 5.height,
//                                 Text(
//                                   isTie
//                                       ? "Tie"
//                                       : (currentUserId != winnerUserId)
//                                           ? "Winner"
//                                           : "Loser",
//                                   style: AppFontStyle.styleW600(
//                                       isTie
//                                           ? AppColor.coloGreyText
//                                           : (currentUserId != winnerUserId)
//                                               ? AppColor.primary
//                                               : AppColor.coloGreyText,
//                                       12),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                       15.height,
//                       GetBuilder<MultiLiveController>(builder: (controller) {
//                         return controller.isHost
//                             ? Text(
//                                 "Do you want to continue this battle with this host?",
//                                 style: AppFontStyle.styleW600(AppColor.white, 14),
//                                 textAlign: TextAlign.center,
//                               ).paddingOnly(bottom: 15)
//                             : Offstage();
//                       }),
//                     ],
//                   ),
//                 ),
//               ),
//               20.height,
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 20),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     GetBuilder<MultiLiveController>(
//                       builder: (controller) {
//                         return !controller.isHost
//                             ? Container()
//                             : Expanded(
//                                 child: GestureDetector(
//                                   onTap: () {
//                                     Get.back();
//                                     SocketServices.onSendPkRequest(
//                                       host1ChannelId: controller.host1ChannelId,
//                                       host1RoomId: controller.host1RoomId,
//                                       host1Token: controller.host1Token,
//                                       host2Id: controller.host2Id,
//                                       host2ChannelId: controller.host2ChannelId,
//                                       host2RoomId: controller.host2RoomId,
//                                       host2Token: controller.host2Token,
//                                     );
//
//                                     SendingPkRequestBottomSheet.onShow(
//                                         context: Get.context!,
//                                         h1Name: controller.host1Name,
//                                         h1Image: controller.host1Image,
//                                         h2Name: controller.host2Name,
//                                         h2Image: controller.host2Image,
//                                         callback: () {
//                                           Get.back();
//                                         });
//                                   },
//                                   child: Container(
//                                     height: 45,
//                                     alignment: Alignment.center,
//                                     decoration: BoxDecoration(
//                                       color: AppColor.colorRedContainer,
//                                       borderRadius: BorderRadius.circular(30),
//                                     ),
//                                     child: Text(
//                                       EnumLocal.txtBattleAgain.name.tr,
//                                       // "Battle again",
//                                       style: AppFontStyle.styleW700(AppColor.white, 16),
//                                     ),
//                                   ),
//                                 ),
//                               );
//                       },
//                     ),
//                     10.width,
//                     GetBuilder<MultiLiveController>(builder: (logic) {
//                       return Expanded(
//                         child: GestureDetector(
//                           onTap: () {
//                             if (logic.isHost) {
//                               logic.onPkEnd(isManualMode: false);
//                               Get.back();
//                             } else {
//                               Get.close(2);
//                             }
//                           },
//                           child: Container(
//                             height: 45,
//                             alignment: Alignment.center,
//                             decoration: BoxDecoration(
//                               color: AppColor.coloGreyText,
//                               borderRadius: BorderRadius.circular(30),
//                             ),
//                             child: Text(
//                               EnumLocal.txtEndBattle.name.tr,
//                               style: AppFontStyle.styleW700(AppColor.white, 16),
//                             ),
//                           ),
//                         ),
//                       );
//                     }),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     ).whenComplete(() => isOpenBottomSheet = false);
//   }
// }
