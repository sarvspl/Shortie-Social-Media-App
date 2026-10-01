// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:get/get_rx/src/rx_typedefs/rx_typedefs.dart';
// import 'package:lottie/lottie.dart';
// import 'package:shortie/custom/custom_format_number.dart';
// import 'package:shortie/google_ad/google_ad_interstitial.dart';
// import 'package:shortie/google_ad/google_ad_services.dart';
// import 'package:shortie/pages/fake_live_page/widget/fake_bottom_widget.dart';
// import 'package:shortie/pages/fake_live_page/widget/fake_comment_data.dart';
// import 'package:shortie/pages/fake_live_page/widget/fake_pk_timer_widget.dart';
// import 'package:shortie/pages/fake_live_page/widget/fake_pk_top_gift_user_widget.dart';
// import 'package:shortie/pages/multi_live_page/widget/rank_slider_ui.dart';
// import 'package:shortie/ui/circle_icon_button_ui.dart';
// import 'package:shortie/ui/loading_ui.dart';
// import 'package:shortie/ui/preview_network_image_ui.dart';
// import 'package:shortie/main.dart';
// import 'package:shortie/ui/preview_profile_bottom_sheet_ui.dart';
// import 'package:shortie/ui/scroll_fade_effect_widget.dart';
// import 'package:shortie/ui/stop_live_streaming_dialog_ui.dart';
//
// import 'package:shortie/utils/asset.dart';
// import 'package:shortie/utils/color.dart';
// import 'package:shortie/utils/enums.dart';
// import 'package:shortie/utils/font_style.dart';
// import 'package:shortie/utils/socket_services.dart';
// import 'package:shortie/utils/utils.dart';
// import 'package:video_player/video_player.dart';
//
// import '../controller/fake_live_controller.dart';
//
// class FakePkCameraWidget extends GetView<FakeLiveController> {
//   const FakePkCameraWidget({super.key, required this.height});
//
//   final double height;
//
//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       height: height,
//       child: Column(
//         children: [
//           GetBuilder<FakeLiveController>(
//             id: "onUpdateRank",
//             builder: (controller) => SizedBox(
//               width: Get.width,
//               child: CustomRankSliderWidget(
//                 height: 20,
//                 rank1: controller.h1Rank,
//                 rank2: controller.h2Rank,
//                 width: Get.width,
//               ),
//             ),
//           ),
//           Container(
//             height: height - 70,
//             clipBehavior: Clip.antiAlias,
//             decoration: BoxDecoration(),
//             width: Get.width,
//             child: Stack(
//               alignment: Alignment.center,
//               children: [
//                 SizedBox(
//                   height: height - 70,
//                   width: Get.width,
//                   child: Row(
//                     children: [
//                       Expanded(
//                         child: Container(
//                           color: AppColor.black,
//                           height: Get.height,
//                           width: Get.width,
//                           child: Stack(
//                             children: [
//                               LoadingUi(color: AppColor.white),
//                               controller.videoPlayerController != null ? VideoPlayer(controller.videoPlayerController!) : Offstage(),
//                             ],
//                           ),
//                         ),
//                       ),
//                       Expanded(
//                         child: Container(
//                           color: AppColor.black,
//                           width: Get.width,
//                           height: Get.height,
//                           child: Stack(
//                             children: [
//                               LoadingUi(color: AppColor.white),
//                               controller.host2VideoPlayerController != null ? VideoPlayer(controller.host2VideoPlayerController!) : Offstage(),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Positioned(top: 0, child: FakePkTimerWidget()),
//               ],
//             ),
//           ),
//           FakePkTopGiftUserWidget(),
//         ],
//       ),
//     );
//   }
// }
//
// class UserLiveUi extends GetView<FakeLiveController> {
//   const UserLiveUi({super.key, required this.liveRoomId, required this.liveUserId});
//
//   final String liveRoomId;
//   final String liveUserId;
//
//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       alignment: Alignment.center,
//       children: [
//         GetBuilder<FakeLiveController>(
//             id: "initializeVideoPlayer",
//             builder: (controller) {
//               return controller.isPkMode
//                   ? Positioned(
//                       top: 110,
//                       child: SizedBox(
//                         height: 380,
//                         child: Column(
//                           children: [
//                             GetBuilder<FakeLiveController>(
//                               id: "onUpdateRank",
//                               builder: (controller) => SizedBox(
//                                 width: Get.width,
//                                 child: CustomRankSliderWidget(
//                                   height: 20,
//                                   rank1: controller.h1Rank,
//                                   rank2: controller.h2Rank,
//                                   width: Get.width,
//                                 ),
//                               ),
//                             ),
//                             Container(
//                               height: Get.height / 2.9,
//                               clipBehavior: Clip.antiAlias,
//                               decoration: BoxDecoration(),
//                               width: Get.width,
//                               child: Stack(
//                                 alignment: Alignment.center,
//                                 children: [
//                                   SizedBox(
//                                     height: Get.height / 2.9,
//                                     width: Get.width,
//                                     child: Row(
//                                       children: [
//                                         Expanded(
//                                           child: Container(
//                                             color: AppColor.black,
//                                             height: Get.height,
//                                             width: Get.width,
//                                             child: Stack(
//                                               children: [
//                                                 LoadingUi(color: AppColor.white),
//                                                 controller.videoPlayerController != null ? VideoPlayer(controller.videoPlayerController!) : Offstage(),
//                                               ],
//                                             ),
//                                           ),
//                                         ),
//                                         Expanded(
//                                           child: Container(
//                                             color: AppColor.black,
//                                             width: Get.width,
//                                             height: Get.height,
//                                             child: Stack(
//                                               children: [
//                                                 LoadingUi(color: AppColor.white),
//                                                 controller.host2VideoPlayerController != null ? VideoPlayer(controller.host2VideoPlayerController!) : Offstage(),
//                                               ],
//                                             ),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                   Positioned(top: 0, child: FakePkTimerWidget()),
//                                 ],
//                               ),
//                             ),
//                             FakePkTopGiftUserWidget(),
//                           ],
//                         ),
//                       ),
//                     )
//                   : Container(
//                       color: AppColor.transparent,
//                       width: Get.width,
//                       height: Get.height,
//                       child: Stack(
//                         alignment: Alignment.center,
//                         children: [
//                           LoadingUi(color: AppColor.white),
//                           controller.videoPlayerController != null
//                               ? SizedBox.expand(
//                                   child: FittedBox(
//                                     fit: BoxFit.cover,
//                                     child: SizedBox(
//                                       width: controller.videoPlayerController?.value.size.width ?? 0,
//                                       height: controller.videoPlayerController?.value.size.height ?? 0,
//                                       child: VideoPlayer(controller.videoPlayerController!),
//                                     ),
//                                   ),
//                                 )
//                               : Offstage(),
//                         ],
//                       ),
//                     );
//             }),
//         Align(
//           alignment: Alignment.center,
//           child: SendGiftOnLiveBottomSheetUi.onShowGift(),
//         ),
//         // Positioned(
//         //   top: 40,
//         //   child: SizedBox(
//         //     width: Get.width,
//         //     child: Padding(
//         //       padding: const EdgeInsets.symmetric(horizontal: 15),
//         //       child: ,
//         //     ),
//         //   ),
//         // ),
//         // Positioned(
//         //   bottom: 0,
//         //   child: Container(
//         //     height: 400,
//         //     width: Get.width,
//         //     decoration: BoxDecoration(
//         //       gradient: LinearGradient(
//         //         colors: [AppColor.transparent, AppColor.black.withValues(alpha:0.7)],
//         //         begin: Alignment.topCenter,
//         //         end: Alignment.bottomCenter,
//         //       ),
//         //     ),
//         //   ),
//         // ),
//         Positioned(
//           bottom: 0,
//           child: FakeBottomWidget(),
//         ),
//         // Positioned(
//         //   left: 0,
//         //   bottom: 70,
//         //   child: GetBuilder<FakeLiveController>(
//         //     id: "initializeVideoPlayer",
//         //     builder: (controller) => GetBuilder<FakeLiveController>(
//         //       id: "onChangeComment",
//         //       builder: (controller) {
//         //         return Container(
//         //           height: Get.height / 3.5,
//         //           width: Get.width / 1.8,
//         //           color: AppColor.transparent,
//         //           child: Align(
//         //             alignment: Alignment.bottomCenter,
//         //             child: ScrollFadeEffectWidget(
//         //               axis: Axis.vertical,
//         //               child: SingleChildScrollView(
//         //                 controller: controller.scrollController,
//         //                 child: ListView.builder(
//         //                   itemCount: fakeHostCommentListBlank.length,
//         //                   shrinkWrap: true,
//         //                   physics: const NeverScrollableScrollPhysics(),
//         //                   padding: EdgeInsets.zero,
//         //                   itemBuilder: (context, index) {
//         //                     return CommentItemUi(
//         //                       title: fakeHostCommentListBlank[index].user,
//         //                       subTitle: fakeHostCommentListBlank[index].message,
//         //                       leading: fakeHostCommentListBlank[index].image,
//         //                     );
//         //                   },
//         //                 ),
//         //               ),
//         //             ),
//         //           ),
//         //         );
//         //       },
//         //     ),
//         //   ),
//         // ),
//       ],
//     );
//   }
// }
