import 'dart:async';
import 'dart:developer';
import 'dart:ui';

import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_typedefs/rx_typedefs.dart';
import 'package:lottie/lottie.dart';
import 'package:shortie/custom/custom_fetch_user_coin.dart';
import 'package:shortie/custom/custom_format_number.dart';
import 'package:shortie/custom/custom_shedow_widget.dart';
import 'package:shortie/main.dart';
import 'package:shortie/pages/fake_live_page/widget/fake_comments_widget.dart';
import 'package:shortie/pages/fake_live_page/widget/fake_send_gift_bottom_sheet_widget.dart';
import 'package:shortie/pages/multi_live_page/bottom_sheet/invite_user_for_pk_bottom_sheet.dart';
import 'package:shortie/pages/multi_live_page/bottom_sheet/sending_pk_request_bottom_sheet.dart';
import 'package:shortie/pages/multi_live_page/controller/multi_live_controller.dart';
import 'package:shortie/pages/multi_live_page/view/keepalive.dart';
import 'package:shortie/pages/multi_live_page/widget/HostVideoView.dart';
import 'package:shortie/pages/multi_live_page/widget/gift_animation.dart';
import 'package:shortie/pages/multi_live_page/widget/pk_animation_dart.dart';
import 'package:shortie/pages/multi_live_page/widget/pk_top_gift_user_widget.dart';
import 'package:shortie/pages/multi_live_page/widget/rank_slider_ui.dart';
import 'package:shortie/pages/multi_live_page/widget/show_received_gift.dart';
import 'package:shortie/ui/circle_icon_button_ui.dart';
import 'package:shortie/ui/loading_ui.dart';
import 'package:shortie/ui/preview_network_image_ui.dart';
import 'package:shortie/ui/preview_profile_bottom_sheet_ui.dart';
import 'package:shortie/ui/report_bottom_sheet_ui.dart';
import 'package:shortie/ui/stop_live_streaming_dialog_ui.dart';
import 'package:shortie/utils/asset.dart';
import 'package:shortie/utils/color.dart';
import 'package:shortie/utils/database.dart';
import 'package:shortie/utils/enums.dart';
import 'package:shortie/utils/font_style.dart';
import 'package:shortie/utils/socket_services.dart';
import 'package:shortie/utils/utils.dart';

class MultiLivePageView extends StatefulWidget {
  MultiLivePageView({
    super.key,
    required this.userId,
    required this.liveUserObjId,
    required this.liveHistoryId,
    required this.isHost,
  });

  final String userId;
  final String liveUserObjId;
  final String liveHistoryId;
  final bool isHost;

  @override
  State<MultiLivePageView> createState() => _MultiLivePageViewState();
}

class _MultiLivePageViewState extends State<MultiLivePageView> with WidgetsBindingObserver {
  final controller = Get.isRegistered<MultiLiveController>() ? Get.find<MultiLiveController>() : Get.put(MultiLiveController());

  RxBool isLoading = false.obs;

  @override
  void initState() {
    Utils.showLog("Call ALL the User Data ${widget.userId} ==== ${widget.liveUserObjId} ==== ${widget.liveHistoryId}");
    _startInitialization();
    Utils.onChangeStatusBar(brightness: Brightness.light, delay: 300);

    super.initState();
  }

  Future<void> _startInitialization() async {
    isLoading.value = true;

    await controller.init(
      isHost: widget.isHost,
      userId: widget.userId,
      liveUserObjId: widget.liveUserObjId,
      liveHistoryId: widget.liveHistoryId,
    );
    controller.onStartCamera();
    controller.update(["onUpdateRank"]);

    isLoading.value = false;
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    controller.onDispose();
    super.dispose();
  }

  double _previousBottomInset = 0.0;

  @override
  void didChangeMetrics() {
    final currentBottomInset = WidgetsBinding.instance.window.viewInsets.bottom;

    // Check if keyboard state changed
    final keyboardOpened = currentBottomInset > 0.0;
    final prevKeyboardOpened = _previousBottomInset > 0.0;

    if (keyboardOpened != prevKeyboardOpened) {
      // State changed, trigger your logic
      controller.bottomInset = currentBottomInset;
      controller.update(["onUpdateTextField"]);

      if (keyboardOpened) {
        print("✅ Keyboard opened");
      } else {
        print("✅ Keyboard closed");
      }
    }

    _previousBottomInset = currentBottomInset;
  }

  @override
  void didUpdateWidget(MultiLivePageView oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.black,
      body: KeepAliveWrapper(
        child: Obx(
          () => WillPopScope(
            onWillPop: () async => _handleBackPress(),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Main streaming content area - wrapped in Container
                Container(
                  height: Get.height,
                  width: Get.width,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(gradient: AppColor.audioRoomGradient),
                  child: isLoading.value ? LoadingUi() : _buildStreamingContent(),
                ),

                GetBuilder<MultiLiveController>(
                  id: "onUpdateMultiLive",
                  builder: (logic) => Visibility(
                    visible: logic.liveUserObject?.isPkMode == false,
                    child: Positioned(
                      bottom: 0,
                      child: Container(
                        height: 400,
                        width: Get.width,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColor.black.withValues(alpha: 0.7),
                              AppColor.transparent,
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                ShadowWidget(),
                // Gift animation overlay
                // Align(
                //   alignment: Alignment.bottomCenter,
                //   child: SendGiftBottomSheetUi.onShowGift(),
                // ),

                // Header (user info, viewers count)
                ShowReceivedGift.onShowGift(),
                Positioned(
                  top: 40,
                  left: 10,
                  child: _buildHeader(context),
                ),

                // Top right action buttons
                Positioned(
                  top: 85, //45
                  right: 10,
                  child: _buildTopRightActions(),
                ),

                GetBuilder<MultiLiveController>(
                  id: "onUpdateTextField",
                  builder: (controller) {
                    log("onUpdateMultiLive => ${controller.bottomInset}");
                    return Positioned(
                      bottom: controller.bottomInset > 0.0 || controller.showEmojiPicker ? 0 : 15,
                      child: SizedBox(
                        width: Get.width,
                        child: Stack(
                          children: [
                            // Bottom controls (shown when keyboard and emoji picker are closed)
                            Offstage(
                              offstage: controller.bottomInset > 0.0 || controller.showEmojiPicker,
                              child: _buildBottomControls(context),
                            ),

                            // Comment input (shown when keyboard is open OR emoji picker is open)
                            Offstage(
                              offstage: controller.bottomInset == 0.0 && !controller.showEmojiPicker,
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                                decoration: BoxDecoration(color: Colors.white),
                                child: Column(
                                  children: [
                                    _buildCommentInputArea(context),
                                    // Emoji Picker - Show when showEmojiPicker is true
                                    GetBuilder<MultiLiveController>(
                                      id: "onUpdateEmojiPicker",
                                      builder: (controller) => controller.showEmojiPicker
                                          ? Container(
                                              height: Get.height * 0.4,
                                              width: Get.width,
                                              child: CustomEmojiPicker(
                                                onEmojiSelected: (emoji) {
                                                  print("Selected emoji: $emoji");
                                                  // Insert emoji into text field
                                                  _insertEmojiIntoTextField(controller, emoji);
                                                },
                                              ),
                                            )
                                          : SizedBox.shrink(), // Use SizedBox.shrink() instead of 0.height
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                // Comments list
                _buildCommentsList(),

                Obx(
                  () => Visibility(
                    visible: controller.isShowPkAnimation.value,
                    child: Lottie.asset(AppAsset.lottiePk, width: 200),
                  ),
                ),
                Obx(
                  () => AnimatedPositioned(
                    duration: const Duration(seconds: 1, milliseconds: 500),
                    right: controller.isShowPkAnimation.value ? 300 : -50,
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 50),
                      child: controller.isShowPkAnimation.value
                          ? Image.asset(AppAsset.imgPkSideBlue, width: 200, fit: BoxFit.cover, height: 45)
                          : Offstage(),
                    ),
                  ),
                ),
                Obx(
                  () => AnimatedPositioned(
                    duration: const Duration(seconds: 1, milliseconds: 500),
                    left: controller.isShowPkAnimation.value ? 300 : -50,
                    child: Padding(
                      padding: EdgeInsets.only(top: 50),
                      child: controller.isShowPkAnimation.value
                          ? Image.asset(AppAsset.imgPkSidePink, width: 200, fit: BoxFit.cover, height: 45)
                          : Offstage(),
                    ),
                  ),
                ),

                // ShowReceivedGift.onShowGift(),
                ShowReceivedGift.onShowSenderDetails(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Handle back button press based on user role and live type
  Future<bool> _handleBackPress() async {
    final isHost = controller.isHost;

    // Show dialog only for host
    if (isHost) {
      ExitLiveStreamingDialogUi.onShow(
        onClickStop: () {
          Get.close(2);
        },
      );
    } else {
      ExitLiveStreamingDialogUi.onShow(
        onClickStop: () {
          Get.close(2);
        },
      );
    }

    return false;
  }

  // Main streaming content based on live type
  Widget _buildStreamingContent() {
    return GetBuilder<MultiLiveController>(
      id: "onUpdateMultiLive",
      builder: (logic) {
        switch (controller.liveUserObject?.isPkMode == true) {
          case true:
            return _buildPkLiveView(logic);

          case false:
            return _buildSingleLiveView(logic);
        }
      },
    );
  }

  // Single host live view (Type 1)
  Widget _buildSingleLiveView(MultiLiveController logic) {
    // if (logic.isHostCameraOn) {
    return Obx(
      () => SizedBox(
        height: Get.height,
        width: Get.width,
        child: SingleChildScrollView(
          child: Stack(
            children: [
              logic.isLoading.value
                  ? Container(
                      width: Get.width,
                      height: Get.height,
                      child: LoadingUi(color: AppColor.white),
                    )
                  : SizedBox(
                      child: logic.isHost ? logic.liveScreen : logic.remoteView,
                      width: Get.width,
                      height: Get.height,
                    ),
            ],
          ),
        ),
      ),
    );
    // } else {
    //   return _buildOffCameraUserProfile(logic, Get.height, Get.width);
    // }
  }

  // Shows user profile when camera is off
  Widget _buildOffCameraUserProfile(MultiLiveController logic, double height, double width) {
    return SizedBox(
      height: height,
      width: width,
      child: Stack(
        children: [
          SizedBox(
            height: height,
            width: width,
            child: PreviewNetworkImageUi(image: logic.image),
          ),
          ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                color: Colors.grey.withValues(alpha:0.1),
                alignment: Alignment.center,
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 100,
                  width: 100,
                  clipBehavior: Clip.hardEdge,
                  decoration: const BoxDecoration(shape: BoxShape.circle),
                  child: PreviewNetworkImageUi(image: logic.image),
                ),
                const SizedBox(height: 5),
                Text(logic.name, style: AppFontStyle.styleW700(AppColor.white, 14))
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Show fix view to camara manage
  Widget buildPkCameraView({
    required Widget cameraView,
    required bool isCameraVisible,
    required bool isMyCamera,
  }) {
    return Stack(
      children: [
        // Show camera view only if camera is visible
        if (isCameraVisible) cameraView,

        // Show placeholder when camera is off
        if (!isCameraVisible)
          Container(
            color: Colors.black,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.videocam_off,
                    color: Colors.white,
                    size: 48,
                  ),
                  SizedBox(height: 8),
                  Text(
                    isMyCamera ? "Camera Off" : "Opponent Camera Off",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  // PK live view (Type 3)
  Widget _buildPkLiveView(MultiLiveController logic) {
    return Column(
      // mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 110,
        ),
        GetBuilder<MultiLiveController>(
          id: "onUpdateRank",
          builder: (controller) => SizedBox(
            width: Get.width,
            child: CustomRankSliderWidget(
              height: 20,
              rank1: logic.host2Rank,
              rank2: logic.host1Rank,
              width: Get.width,
            ),
          ),
        ),
        _buildPkBattleView(logic),
        SizedBox(height: 10),
        SuperTimerShow()
      ],
    );
  }

  Widget SuperTimerShow() {
    return GetBuilder<MultiLiveController>(
      id: 'onUpdateMultiLive',
      builder: (logic) => Container(
        child: logic.pkUntilSuperTime > 0
            // && logic.isHost == false && logic.isCoHost == false
            ? GiftingReminder(
                creatorName: logic.host1Name,
                timeUntilEvent: Duration(seconds: logic.pkUntilSuperTime ?? 0),
              )
            : Visibility(
                visible: logic.isOnSuperTimer.value,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: AppColor.primaryLinearGradient,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "X ${Utils.isShowMultiplier} ${EnumLocal.txtGiftingPoints.name.tr}",
                        style: AppFontStyle.styleW800(AppColor.white, 14),
                      ),
                      10.width,
                      Container(
                        height: 15,
                        width: 1,
                        color: AppColor.white,
                      ),
                      10.width,
                      Text(
                        logic.onConvertSecondOnly(logic.pkSuperCountTime),
                        style: AppFontStyle.styleW800(AppColor.white, 14),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  // PK Battle view with hosts and animations
  Widget _buildPkBattleView(MultiLiveController logic) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        // Host views
        Row(
          children: [
            Expanded(
              child: !logic.isHostCameraOn
                  ? _buildOffCameraUserProfile(logic, Get.height / 2.5, Get.width)
                  : SizedBox(
                      height: Get.height / 2.5,
                      child: logic.isHost ? logic.liveScreen : logic.remoteView,
                    ),
            ),
            Expanded(
              child: SizedBox(
                height: Get.height / 2.5,
                child: PkHostVideoView(
                  streamID: logic.host2ChannelId,
                  height: Get.height * 0.4,
                  isMute: false,
                ),
              ),
            ),
          ],
        ),

        // PK Timer
        Positioned(
          top: 0,
          child: PkTimerWidget(),
        ),

        // PK Countdown animation
        _buildPkCountdown(),

        Positioned(bottom: 0, child: PkTopGiftUserWidget()),
        _buildSuperPkAnimations(),
      ],
    );
  }

  // PK Countdown animation
  Widget _buildPkCountdown() {
    return GetBuilder<MultiLiveController>(
      id: "onChangePkTime",
      builder: (controller) => Visibility(
        visible: controller.pkCountTime < 11 && controller.pkCountTime != 0,
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 700),
            transitionBuilder: (child, animation) {
              return ScaleTransition(
                scale: animation,
                child: FadeTransition(
                  opacity: animation,
                  child: child,
                ),
              );
            },
            child: Text(
              controller.pkCountTime.toString(),
              key: ValueKey<int>(controller.pkCountTime),
              style: AppFontStyle.styleW900(AppColor.white, 75),
            ),
          ),
        ),
      ),
    );
  }

  // PK Super Animations
  Widget _buildSuperPkAnimations() {
    return Obx(
      () => Visibility(
        visible: controller.isShowSuperPkAnimation.value,
        child: Positioned.fill(
          child: Container(
            width: double.infinity,
            height: double.infinity,
            child: Lottie.asset(
              AppAsset.lottieSuperPkCoins,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover, // Use cover for true full screen
              repeat: false,
              animate: controller.isShowSuperPkAnimation.value,
              alignment: Alignment.center,
            ),
          ),
        ),
      ),
    );
  }

  // Header with user info and viewers count
  Widget _buildHeader(BuildContext context) {
    return Container(
      width: Get.width,
      padding: EdgeInsets.only(right: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildUserInfoCard(context),
              const SizedBox(width: 3),
              _buildViewersCounter(context),
              controller.totalGiftUserData.isEmpty ? 0.height : const SizedBox(width: 3),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // _buildTopGifter(),
              5.width,
              GetBuilder<MultiLiveController>(
                id: "onUpdateMultiLive",
                builder: (controller) {
                  // bool isUserInRequestedList = controller.requestedList?.any((element) => element.userId == Database.loginUserId) ?? false;
                  return CircleIconButtonUi(
                    circleSize: 38,
                    color: AppColor.black.withValues(alpha:0.5),
                    icon: AppAsset.icClose,
                    iconColor: AppColor.white,
                    callback: () {
                      final isHost = controller.isHost;

                      if (isHost) {
                        ExitLiveStreamingDialogUi.onShow(
                          onClickStop: () {
                            Get.close(2);
                          },
                        );
                      } else {
                        ExitLiveStreamingDialogUi.onShow(
                          onClickStop: () {
                            Get.close(2);
                          },
                        );
                      }
                    },
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
// These methods would be part of your MultiLivePageView class

  Widget _buildTopRightActions() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        5.height,
        GetBuilder<MultiLiveController>(
          id: "onUpdateMultiLive",
          builder: (controller) {
            return Visibility(
              visible: (controller.liveUserObject?.isPkMode == false && controller.isHost),
              child: CircleIconButtonUi(
                circleSize: 38,
                iconSize: 20,
                gradient: AppColor.primaryLinearGradient,
                icon: AppAsset.icVs,
                iconColor: AppColor.white,
                callback: () {
                  InviteUserForPkBottomSheet.show(
                    context: Get.context!,
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

                      await 50.milliseconds.delay();
                      Get.back();
                      await 50.milliseconds.delay();
                      Utils.showLog("Pk Event => Host1 Close Invite For Pk BS");

                      SendingPkRequestBottomSheet.onShow(
                        context: Get.context!,
                        h1Name: controller.host1Name,
                        h1Image: controller.host1Image,
                        h2Name: controller.host2Name,
                        h2Image: controller.host2Image,
                        callback: () {
                          Get.back();
                          SocketServices.onCancelPkRequest(host1Id: controller.host1Id, host2Id: controller.host2Id);
                        },
                      );
                    },
                  );
                },
              ),
            );
          },
        ),
        10.height,
        controller.isHost || controller.isCoHost
            ? 0.height
            : GestureDetector(
                onTap: () => ReportBottomSheetUi.show(context: context, eventId: '', eventType: 2),
                child: Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(gradient: AppColor.primaryLinearGradient, shape: BoxShape.circle),
                  child: Icon(
                    Icons.more_vert_rounded,
                    color: AppColor.white.withValues(alpha: 0.7),
                    size: 26,
                  ),
                ),
              ),
        5.height,
        10.height,
      ],
    );
  }

  Widget _buildCommentsList() {
    return GetBuilder<MultiLiveController>(
      id: "onUpdateTextField",
      builder: (controller) {
        final double inputHeight = controller.showEmojiPicker
            ? Get.height * 0.4 + 60
            : controller.bottomInset > 0.0
                ? 60
                : 70;

        return Positioned(
          left: 0,
          bottom: inputHeight,
          child: Container(
            height: Get.height / 3.5,
            width: Get.width,
            child: Obx(
              () => SocketServices.mainLiveComments.isEmpty
                  ? const SizedBox.shrink()
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Flexible(
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: SocketServices.mainLiveComments.length,
                            // ❌ reverse: true — remove
                            controller: SocketServices.scrollController,
                            padding: const EdgeInsets.only(top: 8),
                            itemBuilder: (context, index) {
                              final data = SocketServices.mainLiveComments[index];
                              return CommentItemUi(
                                title: data["userName"],
                                subTitle: data["commentText"],
                                leading: data["userImage"],
                              );
                            },
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomControls(BuildContext context) {
    // Get the screen width to provide bounded constraints

    return GetBuilder<MultiLiveController>(
      id: "onUpdateMultiLive",
      builder: (controller) {
        return Container(
          width: Get.width, // This provides the bounded width constraint
          padding: EdgeInsets.symmetric(horizontal: 14),

          child: Row(
            children: [
              Expanded(
                child: GetBuilder<MultiLiveController>(
                  builder: (controller) => CommentTextFieldUi(
                    controller: controller.commentController,
                    callback: () => controller.onSendComment(),
                  ),
                ),
              ),
              SizedBox(width: 10), // Replace 10.width with SizedBox
              GetBuilder<MultiLiveController>(
                id: "onUpdateMultiLive",
                builder: (controller) {
                  return Visibility(
                    visible: controller.isHost == false,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: LabeledCircleIconButton(
                        label: "Gift",
                        circleSize: 50,
                        iconSize: 48,
                        color: AppColor.black.withValues(alpha:0.3),
                        icon: AppAsset.icGiftLive,
                        callback: () {
                          FakeSendGiftBottomSheetWidget.show(
                            context: context,
                            function: (data) {
                              if ((CustomFetchUserCoin.coin.value == 0 || CustomFetchUserCoin.coin.value < (data.coin ?? 0))) {
                                Utils.showToast(
                                    EnumLocal.txtYouDonHaveSufficientCoinsToSendTheGift.name.tr, AppColor.colorTextDarkGrey.withValues(alpha:0.85));
                              } else {
                                if (controller.liveUserObject?.isPkMode ?? false) {
                                  SocketServices.onPkSendGift(
                                    coin: data.coin ?? 0,
                                    giftType: data.type ?? 0,
                                    giftUrl: data.image ?? "",
                                    giftId: data.id ?? "",
                                    senderUserId: Database.loginUserId,
                                    receiverUserIds: [controller.liveUserObject?.userId ?? ""],
                                    liveHistoryId: controller.liveUserObject?.liveHistoryId ?? "",
                                    senderName: Database.fetchLoginUserProfileModel?.user?.name ?? "",
                                    senderImage: Database.fetchLoginUserProfileModel?.user?.image ?? "",
                                    senderUniqueId: Database.fetchLoginUserProfileModel?.user?.uniqueId ?? "",
                                    senderProfilePicBanned: Database.fetchLoginUserProfileModel?.user?.isProfileImageBanned ?? false,
                                  );
                                } else {
                                  SocketServices.onLiveSendGift(
                                    coin: data.coin ?? 0,
                                    giftType: data.type ?? 0,
                                    giftUrl: data.image ?? "",
                                    giftId: data.id ?? "",
                                    senderUserId: Database.loginUserId,
                                    receiverUserId: [controller.liveUserObject?.userId ?? ""],
                                    liveHistoryId: controller.liveUserObject?.liveHistoryId ?? "",
                                    svgaUrl: '',
                                    senderUserName: '',
                                    liveUserObjId: '',
                                    senderName: Database.fetchLoginUserProfileModel?.user?.name ?? "",
                                    senderImage: Database.fetchLoginUserProfileModel?.user?.image ?? "",
                                    senderUniqueId: Database.fetchLoginUserProfileModel?.user?.uniqueId ?? "",
                                    senderProfilePicBanned: Database.fetchLoginUserProfileModel?.user?.isProfileImageBanned ?? false,
                                  );
                                }
                              }
                            },
                          );

                          // if (controller.liveType == 3) {
                          //   Utils.showLog("isOpenSuperTimer =>  ${controller.isOnSuperTimer.value}");
                          //
                          //   SendGiftBottomSheetUi.show(
                          //     context: context,
                          //     liveRoomId: controller.roomID,
                          //     senderUserId: Database.loginUserId,
                          //     receiverUserId: controller.liveUserId,
                          //     mode: GiftDisplayMode.pk,
                          //     isOnSuperTimer: controller.isOnSuperTimer.value,
                          //     receiverUserName: controller.name,
                          //     // pkHostsData: controller.pkHostData,
                          //   );
                          // } else if (controller.liveType == 2) {
                          //   SendGiftBottomSheetUi.show(
                          //     context: context,
                          //     mode: GiftDisplayMode.multiLive,
                          //     liveUserObjId: controller.liveUserObjId,
                          //     liveRoomId: controller.roomID,
                          //     senderUserId: Database.loginUserId,
                          //     multiLiveUsers: controller.multiLiveHostList,
                          //   );
                          // } else {
                          //   print("/////////////// ${controller.liveUserId}");
                          //
                          //   SendGiftBottomSheetUi.show(
                          //     context: context,
                          //     liveRoomId: controller.roomID,
                          //     senderUserId: Database.loginUserId,
                          //     receiverUserId: controller.liveUserId,
                          //     receiverUserName: controller.name,
                          //     mode: GiftDisplayMode.live,
                          //   );
                          // }
                        },
                      ),
                    ),
                  );
                },
              ),

              GetBuilder<MultiLiveController>(
                id: "onSwitchMic",
                builder: (logic) {
                  bool isUserInRequestedList = logic.requestedList?.any((element) => element.userId == Database.loginUserId) ?? false;
                  bool showMuteMicButton = logic.isHost || isUserInRequestedList;

                  return Visibility(
                    visible: showMuteMicButton,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: LabeledCircleIconButton(
                        circleSize: 40,
                        // iconSize: 20,
                        // gradient: AppColor.primaryLinearGradient,
                        iconColor: AppColor.white,

                        icon: logic.isMuteMic ? AppAsset.icMicOnLive : AppAsset.icMicOffLive,
                        // iconColor: AppColor.white,
                        callback: logic.onSwitchMic,
                        label: "Mic",
                      ),
                    ),
                  );
                },
              ),

              GetBuilder<MultiLiveController>(
                id: "onSwitchCamera",
                builder: (logic) {
                  // bool isUserInRequestedList = logic.requestedList?.any((element) => element.userId == Database.loginUserId) ?? false;
                  // // bool showCameraButton = (logic.isHost || isUserInRequestedList) && logic.liveType != 3;
                  // bool showCameraButton = (logic.isHost || isUserInRequestedList);

                  return Visibility(
                    visible: logic.isHost,
                    child: LabeledCircleIconButton(
                      circleSize: 20,
                      iconSize: 23,
                      gradient: AppColor.primaryLinearGradient,
                      icon: AppAsset.icRotateCamera,
                      iconColor: AppColor.white,
                      callback: logic.onSwitchCamera,
                      label: 'Camera',
                    ),
                  );
                },
              ),
              SizedBox(width: 6), // Replace 6.width with SizedBox

              GetBuilder<MultiLiveController>(
                id: "idShare",
                builder: (logic) {
                  return LabeledCircleIconButton(
                    circleSize: 40,
                    iconSize: 25,
                    icon: AppAsset.icShareLive,
                    iconColor: AppColor.white,
                    callback: logic.onShareLink,
                    label: "Share",
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCommentInputArea(BuildContext context) {
    return GetBuilder<MultiLiveController>(
      builder: (controller) => Row(
        children: [
          Expanded(
            child: Container(
              height: 50,
              padding: const EdgeInsets.only(left: 15, right: 5),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColor.white,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    height: 22,
                    width: 22,
                    AppAsset.icCommentGradiant,
                  ),
                  5.width,
                  VerticalDivider(
                    indent: 12,
                    endIndent: 12,
                    color: AppColor.coloGreyText.withValues(alpha:0.3),
                  ),
                  5.width,
                  GetBuilder<MultiLiveController>(
                    builder: (logic) => Expanded(
                      child: TextFormField(
                        focusNode: logic.textFieldFocusNode,
                        controller: controller.commentController,
                        cursorColor: AppColor.colorTextGrey,
                        maxLines: 1,
                        onTap: () {
                          // When text field is tapped, hide emoji picker
                          if (logic.showEmojiPicker) {
                            logic.showEmojiPicker = false;
                            logic.update(["onUpdateEmojiPicker", "onUpdateTextField"]);
                          }
                        },
                        onEditingComplete: () {
                          FocusManager.instance.primaryFocus?.unfocus();
                        },
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.only(bottom: 3),
                          hintText: EnumLocal.txtTypeComment.name.tr,
                          hintStyle: AppFontStyle.styleW400(AppColor.coloGreyText, 15),
                        ),
                      ),
                    ),
                  ),
                  GetBuilder<MultiLiveController>(
                    builder: (logic) {
                      return IconButton(
                          icon: Icon(
                            Icons.emoji_emotions,
                            color: logic.showEmojiPicker
                                ? AppColor.primary // Highlight when active
                                : AppColor.coloGreyText,
                          ),
                          onPressed: () {
                            Utils.showLog("Emoji Picker Tapped");

                            if (logic.showEmojiPicker) {
                              // If emoji picker is showing → hide picker, show keyboard
                              logic.showEmojiPicker = false;
                              logic.update(["onUpdateEmojiPicker"]);

                              // Directly request focus, no delay needed
                              logic.textFieldFocusNode.requestFocus();
                            } else {
                              // Hide keyboard
                              FocusManager.instance.primaryFocus?.unfocus();
                              logic.textFieldFocusNode.unfocus();

                              // After keyboard is definitely closed, show emoji picker
                              Future.delayed(Duration(milliseconds: 150), () {
                                // Check if keyboard is still open

                                if (MediaQuery.of(context).viewInsets.bottom > 0) {
                                  FocusManager.instance.primaryFocus?.unfocus();
                                  // logic.textFieldFocusNode.unfocus();
                                }
                                logic.showEmojiPicker = true;
                                logic.update(["onUpdateEmojiPicker"]);
                              });
                            }

                            logic.update(["onUpdateTextField"]);
                          });
                    },
                  ),
                  GestureDetector(
                    onTap: () => controller.onSendComment(),
                    child: Container(
                      height: 40,
                      width: 40,
                      color: AppColor.transparent,
                      child: Center(
                        child: Image.asset(width: 26, AppAsset.icSend),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfoCard(BuildContext context) {
    return GetBuilder<MultiLiveController>(
        id: "onUpdateMultiLive",
        builder: (controller) => GestureDetector(
                child: Container(
              height: 50,
              width: controller.isHost ? 150 : 170,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(56),
                border: Border.all(color: AppColor.colorBorder.withValues(alpha:0.3)),
                color: AppColor.black.withValues(alpha:0.45),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  5.width,
                  GestureDetector(
                    onTap: () => Database.loginUserId == widget.userId
                        ? controller.showOwnProfile()
                        : PreviewProfileBottomSheetUi.show(context: context, userId: controller.host1Id),
                    child: Container(
                      height: 40,
                      width: 40,
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
                            child: PreviewNetworkImageUi(image: controller.image),
                          ),
                          Visibility(
                            visible: controller.isProfileImageBanned,
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: Container(
                                clipBehavior: Clip.antiAlias,
                                decoration: BoxDecoration(shape: BoxShape.circle),
                                child: BlurryContainer(
                                  blur: 3,
                                  borderRadius: BorderRadius.circular(50),
                                  color: AppColor.black.withValues(alpha:0.3),
                                  child: Offstage(),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  5.width,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 75,
                          child: Text(
                            controller.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppFontStyle.styleW600(AppColor.white, 14),
                          ),
                        ),
                        Stack(
                          // mainAxisAlignment: MainAxisAlignment.start,
                          // crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Positioned(
                              left: -10,
                              child: Lottie.asset(AppAsset.lottieWaveAnimation, fit: BoxFit.cover, height: 20, width: 15),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 18, top: 2.5),
                              child: SizedBox(
                                width: 60,
                                child: Text(
                                  controller.userName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppFontStyle.styleW500(AppColor.white, 9),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (controller.isHost == false)
                    GetBuilder<MultiLiveController>(
                      id: "onClickFollow",
                      builder: (controller) => GestureDetector(
                        onTap: controller.onClickFollow,
                        child: Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: controller.isFollow ? AppColor.greyGradient : AppColor.primaryLinearGradient,
                          ),
                          child: Center(
                            child: Image.asset(
                              controller.isFollow ? AppAsset.icFollowing : AppAsset.icFollow,
                              height: 22,
                              width: 22,
                              color: AppColor.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  5.width,
                ],
              ),
            )
                // child: Container(
                //   padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                //   decoration: BoxDecoration(
                //     borderRadius: BorderRadius.circular(56),
                //     border: Border.all(color: AppColor.colorBorder.withValues(alpha:0.3)),
                //   ),
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.spaceAround,
                //     children: [
                //       Container(
                //         height: 35,
                //         width: 35,
                //         clipBehavior: Clip.antiAlias,
                //         decoration: const BoxDecoration(shape: BoxShape.circle),
                //         child: Stack(
                //           children: [
                //             AspectRatio(
                //               aspectRatio: 1,
                //               child: Image.asset(AppAsset.icProfilePlaceHolder),
                //             ),
                //             AspectRatio(
                //               aspectRatio: 1,
                //               child: PreviewNetworkImageUi(image: controller.image),
                //             ),
                //             Visibility(
                //               visible: controller.isProfileImageBanned,
                //               child: AspectRatio(
                //                 aspectRatio: 1,
                //                 child: Container(
                //                   clipBehavior: Clip.antiAlias,
                //                   decoration: BoxDecoration(shape: BoxShape.circle),
                //                   child: BlurryContainer(
                //                     blur: 3,
                //                     borderRadius: BorderRadius.circular(50),
                //                     color: AppColor.black.withValues(alpha:0.3),
                //                     child: Offstage(),
                //                   ),
                //                 ),
                //               ),
                //             ),
                //           ],
                //         ),
                //       ),
                //       8.width,
                //       Column(
                //         crossAxisAlignment: CrossAxisAlignment.start,
                //         mainAxisAlignment: MainAxisAlignment.center,
                //         children: [
                //           GetBuilder<MultiLiveController>(
                //             builder: (logic) => SizedBox(
                //               width: logic.isHost ? Get.width * 0.18 : Get.width * 0.18,
                //               child: Text(
                //                 controller.name,
                //                 maxLines: 1,
                //                 overflow: TextOverflow.ellipsis,
                //                 style: AppFontStyle.styleW600(AppColor.white, 14),
                //               ),
                //             ),
                //           ),
                //           Stack(
                //             children: [
                //               Positioned(
                //                 left: -10,
                //                 child: Lottie.asset(AppAsset.lottieWaveAnimation, fit: BoxFit.cover, height: 20, width: 15),
                //               ),
                //               Padding(
                //                 padding: const EdgeInsets.only(left: 18, top: 2.5),
                //                 child: SizedBox(
                //                   width: 50,
                //                   child: Text(
                //                     controller.userName,
                //                     maxLines: 1,
                //                     overflow: TextOverflow.ellipsis,
                //                     style: AppFontStyle.styleW500(AppColor.white, 9),
                //                   ),
                //                 ),
                //               ),
                //             ],
                //           ),
                //         ],
                //       ),
                //       Visibility(
                //         visible: controller.isHost,
                //         child: GetBuilder<MultiLiveController>(
                //           id: "onClickFollow",
                //           builder: (controller) => GestureDetector(
                //             onTap: controller.onClickFollow,
                //             child: Container(
                //               decoration: BoxDecoration(gradient: AppColor.primaryLinearGradient, borderRadius: BorderRadius.circular(18)),
                //               child: Padding(
                //                 padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 6.0),
                //                 child: Row(
                //                   children: [
                //                     Image.asset(
                //                       controller.isFollow ? AppAsset.icFollowing : AppAsset.icFollow,
                //                       height: 20,
                //                       width: 20,
                //                       color: AppColor.white,
                //                     ),
                //                     // 4.width,
                //                     // Text(
                //                     //   controller.isFollow ? EnumLocal.txtFollowing.name.tr : EnumLocal.txtFollow.name.tr,
                //                     //   style: AppFontStyle.styleW500(AppColor.white, 14),
                //                     // )
                //                   ],
                //                 ),
                //               ),
                //             ),
                //           ),
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
                ));
  }

  void _insertEmojiIntoTextField(MultiLiveController controller, String emoji) {
    final TextEditingController textController = controller.commentController;
    final String currentText = textController.text;
    final int cursorPosition = textController.selection.start;

    if (cursorPosition == -1) {
      // If no cursor position, append to end
      textController.text = currentText + emoji;
      textController.selection = TextSelection.fromPosition(
        TextPosition(offset: textController.text.length),
      );
    } else {
      // Insert at cursor position
      final String newText = currentText.replaceRange(
        cursorPosition,
        cursorPosition,
        emoji,
      );
      textController.text = newText;
      textController.selection = TextSelection.fromPosition(
        TextPosition(offset: cursorPosition + emoji.length),
      );
    }
  }

  Widget _buildViewersCounter(BuildContext context) {
    return Obx(
      () => GestureDetector(
        onTap: () {
          // showEmojiPickerModalBottomSheet(
          //   context: context,
          //   isScrollControlled: true,
          //   backgroundColor: Colors.transparent,
          //   builder: (context) => ViewersBottomSheet(
          //     initialIndex: 0,
          //   ),
          // );
          // Utils.showLog("User ==> ${SocketServices.liveViewers}");
          // UserViewListBottomSheet.show(context: context, title: "User Viewers", list: SocketServices.liveViewers, topGifter: controller.totalGiftUserData);
        },
        child: SizedBox(
          height: 50,
          child: Center(
            child: Container(
              height: 25,

              // width: 55,
              margin: EdgeInsets.only(left: 15),
              padding: EdgeInsets.symmetric(horizontal: 12),

              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColor.black.withValues(alpha:0.3),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(AppAsset.icView, width: 16),
                  8.width,
                  Text(
                    CustomFormatNumber.convert(SocketServices.userWatchCount.value),
                    maxLines: 1,
                    style: AppFontStyle.styleW700(AppColor.white, 12),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CommentTextFieldUi extends StatelessWidget {
  const CommentTextFieldUi({
    super.key,
    this.callback,
    this.controller,
  });

  final Callback? callback;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.only(left: 15, right: 5),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            height: 22,
            width: 22,
            AppAsset.icCommentGradiant,
          ),
          5.width,
          VerticalDivider(
            indent: 12,
            endIndent: 12,
            color: AppColor.coloGreyText.withValues(alpha:0.3),
          ),
          5.width,
          GetBuilder<MultiLiveController>(
            builder: (logic) => Expanded(
              child: TextFormField(
                controller: controller,
                cursorColor: AppColor.colorTextGrey,
                maxLines: 1,
                onEditingComplete: () {
                  FocusManager.instance.primaryFocus?.unfocus();
                },
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.only(bottom: 3),
                  hintText: EnumLocal.txtTypeComment.name.tr,
                  hintStyle: AppFontStyle.styleW400(AppColor.coloGreyText, 15),
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: callback,
            child: Container(
              height: 40,
              width: 40,
              color: AppColor.transparent,
              child: Center(
                child: Image.asset(width: 26, AppAsset.icSend),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
