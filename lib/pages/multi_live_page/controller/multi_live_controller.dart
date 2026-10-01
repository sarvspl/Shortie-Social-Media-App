import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shortie/deep_link/services/deep_link_services.dart';
import 'package:shortie/pages/connection_page/api/follow_unfollow_api.dart';
import 'package:shortie/pages/go_live_page/model/create_live_user_model.dart';
import 'package:shortie/pages/multi_live_page/api/fetch_live_users_api.dart';
import 'package:shortie/pages/multi_live_page/model/fetch_live_users_model.dart';
import 'package:shortie/pages/multi_live_page/model/multi_live_users_model.dart';
import 'package:shortie/pages/multi_live_page/model/pk_gift_top_user_model.dart';
import 'package:shortie/pages/multi_live_page/model/update_live_type_model.dart';
import 'package:shortie/pages/stream_page/model/live_user_object_model.dart';
import 'package:shortie/ui/loading_ui.dart';
import 'package:shortie/utils/database.dart';
import 'package:shortie/utils/enums.dart';
import 'package:shortie/utils/socket_services.dart';
import 'package:shortie/utils/utils.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:zego_express_engine/zego_express_engine.dart';

import '../widget/confirm_guest_slots_dialog_ui.dart';

bool isMultiLiveScreen = false;

class MultiLiveController extends GetxController {
  RxBool isLoading = true.obs; // DEFAULT LOADING START (ZE_GO CAMERA)

  bool isFrontCamera = true;
  bool isFlashOn = false;
  bool showEmojiPicker = false;
  FocusNode textFieldFocusNode = FocusNode();
  double bottomInset = 0.0;
  String userId = "";
  String image = "";
  String name = "";
  String userName = "";
  bool isFollow = false;
  bool isProfileImageBanned = false;

  bool isHost = false;

  String roomID = "";

  Widget? liveScreen;
  int? localViewID;
  Widget? coHostLocalView;
  int? coHostLocalViewID;
  Widget? remoteView;
  int? remoteViewID;
  String liveUserObjId = '';
  String liveUserId = '';

  int countTime = 0;
  bool isLivePage = false;
  bool isCoHost = false;
  bool isShowRedDot = false;
  bool isCameraOn = true;
  bool isHostCameraOn = true;
  bool isEnableCoHost = true;
  List<Requested>? requestedList;
  int coHostRequestPosition = 0;

  bool isMuteMic = true;
  List<MultiLiveUsersModel> multiLiveRequestedList = [];
  List<MultiLiveUsersModel> joinMultiLiveUsers = [];
  List<dynamic> multiLiveHostList = [];
  Map<String, dynamic>? pkHostData;
  TextEditingController commentController = TextEditingController();
  String userLeftLiveId = "";

  /// >>>>>>>>>>>pk variables<<<<<<<<<<<
  // >>>>> Get Value From Argument <<<<<

  String host1Id = "";
  String host1Name = "";
  String host1UserName = "";
  String host1Image = "";
  String host1ChannelId = "";
  String host1RoomId = "";
  String host1Token = "";
  int host1WinnerPoint = 0;

  // >>>>>> For pk Camara view ON OFF
  String CamaraHostId = "";

  // >>>>> Get Value From Pk <<<<<

  String host2Id = "";
  String host2Name = "";
  String host2UserName = "";
  String host2Image = "";
  String host2ChannelId = "";
  String host2RoomId = "";
  String host2Token = "";
  int host2WinnerPoint = 0;

  int pkCountTime = 0;
  Timer? pkTimer;
  Timer? pkSuperTimer;
  int pkSuperCountTime = 0;
  int pkUntilSuperTime = 0;
  RxBool isShowPkAnimation = false.obs;
  RxBool isShowSuperPkAnimation = false.obs;
  RxBool isOnSuperTimer = false.obs;

  // >>>>> Pk Live User List <<<<<
  bool isRelaying = false;

  List<UserLiveList> liveUserList = [];
  bool isLoadingLiveUserList = false;
  FetchLiveUsersModel? fetchLiveUsersModel;
  CreateLiveUserModel? createLiveUserModel;
  int host1Rank = 0;
  int host2Rank = 0;
  List<PkGiftTopUserModel> host1TopGiftUsers = [];

  List<PkGiftTopUserModel> host2TopGiftUsers = [];

  List<PkGiftTopUserModel> totalGiftUserData = [];

  LiveUserObject? liveUserObject;

  int maxGuestSlots = 8; // Default to the maximum of 7 guest slots
  bool showGuestSlotsSelector = false;

// Add these fields
  bool isAcceptDeclineSheetOpen = false;
  bool _isSharing = false;
  bool isRequestInFlight = false;
  bool isPkInviteSheetOpen = false;
  bool isPkAnswerProcessing = false;

// Timestamp dedup guards
  DateTime? _lastRequestedUpdatedAt;
  DateTime? _lastPkInviteAt;
  DateTime? _lastPkAnswerAt;

// Call this from SocketServices before processing each event
  bool canProcessRequestedUpdated() {
    final now = DateTime.now();
    if (_lastRequestedUpdatedAt != null && now.difference(_lastRequestedUpdatedAt!).inMilliseconds < 500) {
      return false;
    }
    _lastRequestedUpdatedAt = now;
    return true;
  }

  bool canProcessPkInvite() {
    final now = DateTime.now();
    if (_lastPkInviteAt != null && now.difference(_lastPkInviteAt!).inMilliseconds < 3000) {
      return false;
    }
    _lastPkInviteAt = now;
    return true;
  }

  bool canProcessPkAnswer() {
    final now = DateTime.now();
    if (_lastPkAnswerAt != null && now.difference(_lastPkAnswerAt!).inMilliseconds < 1000) {
      return false;
    }
    _lastPkAnswerAt = now;
    return true;
  }

// Reset all guards — call from allVariableReset()
  void resetSocketGuards() {
    isAcceptDeclineSheetOpen = false;
    isRequestInFlight = false;
    isPkInviteSheetOpen = false;
    isPkAnswerProcessing = false;
    _lastRequestedUpdatedAt = null;
    _lastPkInviteAt = null;
    _lastPkAnswerAt = null;
  }

  void toggleGuestSlotsVisibility() {
    showGuestSlotsSelector = !showGuestSlotsSelector;
    // _isSlotUpdating = false; // Reset the updating state when toggling visibility
    update(['onUpdateMultiLive']);
  }

  // bool _isSlotUpdating = false;
  int counbter = 0;
  void setMaxGuestSlots(int slots, BuildContext context) {
    // Utils.showLog("Set Max Guest _isSlotUpdating $_isSlotUpdating");
    Utils.showLog("Set Max Guest _isSlotUpdating $slots");
    // if (_isSlotUpdating) return;
    // _isSlotUpdating = true;

    Utils.showLog("Set Max Guest Slots11 $slots");
    Utils.showLog("Set Max Guest Slots $counbter");
    // Don't do anything if the selected slots are the same as current
    if (slots == maxGuestSlots) return;

    // Check if we're reducing slots
    if (slots < maxGuestSlots) {
      // Count how many active guests would be removed
      int activeGuestsToRemove = 0;

      // Loop through guests that would be removed (those in positions > new slot count)
      for (int i = slots; i < maxGuestSlots && i < requestedList!.length; i++) {
        if (requestedList![i].isAccepted == true) {
          activeGuestsToRemove++;
        }
      }

      // Only show dialog if we're actually removing active guests
      if (activeGuestsToRemove > 0) {
        ConfirmGuestSlotsDialogUi.onShow(
          newSlots: slots,
          guestsToRemove: activeGuestsToRemove,
          onConfirm: () {
            Get.back(); // Close dialog
            _confirmSlotChange(slots); // Proceed with the change
          },
        );
        return; // Exit the function after showing dialog
      }
    }

    // No active guests will be removed, just update directly
    _confirmSlotChange(slots);
    // _isSlotUpdating = false;
  }

  // Helper method to actually apply the slot change
  void _confirmSlotChange(int slots) {
    // Limit between 1 and 8 guests
    log("Set Max Guest Slots $slots");
    SocketServices.emitRequestedCountModified(requestedCount: slots, liveHistoryId: roomID);
    maxGuestSlots = slots.clamp(1, 8);

    update(["onUpdateMultiLive"]); // Update the UI
  }

  @override
  void onInit() {
    isMultiLiveScreen = true;
    if (Get.arguments != null) {
      userId = Get.arguments["userId"];
      userName = Get.arguments["userName"];
      name = Get.arguments["name"];
      image = Get.arguments["image"];
    }
    Utils.showLog("MULTI LIVE CONTROLLER INIT SUCCESS");
    super.onInit();
  }

  Future<void> init({required bool isHost, required String userId, required String liveUserObjId, required String liveHistoryId}) async {
    Utils.showLog("MULTI LIVE INIT CALL => UserId => $userId LiveHistoryId => $liveHistoryId LiveUserObjId => $liveUserObjId isHost => $isHost");

    this.isHost = isHost;
    SocketServices.userWatchCount.value = 0;

    SocketServices.emitOnGetLiveHostInfo(liveHistoryId: liveHistoryId, liveUserObjId: liveUserObjId, liveUserId: Database.loginUserId);
    Utils.showLog("MULTI LIVE INIT CALL => UserId => 001");

    Utils.showLog("MULTI LIVE INIT CALL => UserId => 003");
  }

  void onGetLiveObject(dynamic data) async {
    if (data is Map<String, dynamic>) {
      liveUserObject = null;
      liveUserObject = LiveUserObject.fromJson(data);

      if (liveUserObject?.userId?.trim().isNotEmpty ?? false) {
        await getArguments(liveUserList: liveUserObject);

        if (liveUserObject?.isPkMode == true) onShowPkAnimation();

        await 1.seconds.delay();

        onStartListenEvent();
        onLoginRoom();
        if (liveUserObject?.isPkMode == true && Platform.isIOS) {
          await 2.delay();
          onStartRelay();
        }
        WakelockPlus.enable();
        // FetchGiftApi.callApi();
      }
    } else {
      Get.back(); // Close Live Page
      Utils.showToast(data);
    }
  }

  @override
  void onClose() {
    Utils.showLog("MULTI LIVE CONTROLLER DISPOSE SUCCESS");
    super.onClose();
  }

  void onDispose() {
    isLoading.value = true;

    onLogoutRoom();
    isMultiLiveScreen = false;
    if (isHost) {
      if (liveUserObject?.isPkMode == true) {
        onPkEnd(isManualMode: true);
        pkTimer?.cancel();
        pkSuperTimer?.cancel();
      } else {
        SocketServices.onLiveRoomExit(isHost: isHost, liveHistoryId: roomID, loginUserId: liveUserId);
      }
    } else {
      onStopListenEvent();
      pkTimer?.cancel();
      pkSuperTimer?.cancel();
    }
    isLivePage = false;
    allVariableReset();

    WakelockPlus.disable();

    SocketServices.mainLiveComments.clear();
  }

  void showOwnProfile() {
    Utils.showLog("You :: ${Database.loginUserId}");
    Utils.showLog("You :: ${userId}");
    Utils.showLog("You Can't View Own Profile ");
  }

  allVariableReset() {
    isCameraOn = true;
    isMuteMic = true;
    isHostCameraOn = true;
    isShowPkAnimation.value = false;
    isShowSuperPkAnimation.value = false;
    isEnableCoHost = true;
    isProfileImageBanned = false;
    multiLiveRequestedList = [];
    requestedList = [];
    isFrontCamera = true;
    liveUserId = "";

    host1Rank = 0;
    host2Rank = 0;
    host1Id = "";
    host1Name = "";
    host2Id = "";
    host2Name = "";
    host1TopGiftUsers = [];
    host2TopGiftUsers = [];
    totalGiftUserData = [];
  }

  /// >>>>>>>>>>>Get arguments<<<<<<<<<<<
  Future<void> getArguments({required LiveUserObject? liveUserList}) async {
    roomID = liveUserList?.liveHistoryId ?? "";
    liveUserId = liveUserList?.userId ?? "";
    liveUserObjId = liveUserList?.id ?? "";

    String streamID = '${Database.loginUserId}_call';

    image = liveUserList?.image ?? "";
    name = liveUserList?.name ?? "";
    userName = liveUserList?.userName ?? "";
    isFollow = liveUserList?.isFollow ?? false;
    isProfileImageBanned = liveUserList?.isProfileImageBanned ?? false;

    host1Id = liveUserList?.userId ?? "";
    host1Name = liveUserList?.name ?? "";
    host1UserName = liveUserList?.userName ?? "";
    host1Image = liveUserList?.image ?? "";
    host1RoomId = liveUserList?.liveHistoryId ?? "";

    // host1WinnerPoint = liveUserList?.host1WinnerPoint ?? 0;

    host1ChannelId = streamID;
    host2ChannelId = liveUserList?.host2Channel ?? "";
    // host2WinnerPoint = liveUserList?.host2WinnerPoint ?? 0;
    // isHostCameraOn = liveUserList?.isHostCameraEnabled ?? true;

    host1Token = "abc";
    // host1AgoraId = 0;
    update(["onUpdateMultiLive", "onUpdateRank"]);
  }

  /// >>>>>>>>>>>Switch Mic<<<<<<<<<<<
  Future<void> onSwitchMic() async {
    if (isMuteMic) {
      isMuteMic = false;
      update(["onSwitchMic"]);
      ZegoExpressEngine.instance.enableAudioCaptureDevice(isMuteMic);
    } else {
      isMuteMic = true;
      update(["onSwitchMic"]);
      ZegoExpressEngine.instance.enableAudioCaptureDevice(isMuteMic);
    }

    SocketServices().onEmitUpdateMuteStatus(
      userId: Database.loginUserId,
      liveHistoryId: roomID,
      liveUserObjId: liveUserObjId,
      isMute: isMuteMic,
      isCameraEnabled: isCameraOn,
      position: coHostRequestPosition,
    );

    Utils.showLog("USER CHANGE MIC STATE => IS MUTE : ${isMuteMic}");
    update(["onSwitchMic"]);
  }

  /// >>>>>>>>>>>Switch Co-Host<<<<<<<<<<<
  onSwitchToCoHost({required int liveType}) {
    // Check if host is trying to disable co-host (liveType 2 means disable)
    if (liveType == 1) {
      // Check if there are any active co-hosts in joinMultiLiveUsers
      bool hasActiveCoHosts = joinMultiLiveUsers.any((user) => user.userId != Database.loginUserId && user.isAccepted == true);

      if (hasActiveCoHosts) {
        Utils.showToast("Please first remove co-hosts before disabling co-host mode");
        return; // Exit without making changes
      }
    }
    // If no co-hosts or enabling co-host mode, proceed
    SocketServices().onEmitUpdateLiveTypeStatus(
      liveHistoryId: roomID,
      liveUserObjId: liveUserObjId,
      liveType: liveType,
    );
    isEnableCoHost = !isEnableCoHost;
  }

  Future<void> onStartCamera() async {
    isFrontCamera = true;
    ZegoExpressEngine.instance.useFrontCamera(isFrontCamera);
    applyMirrorMode();
  }

  /// >>>>>>>>>>>Switch Camera<<<<<<<<<<<
  Future<void> onSwitchCamera() async {
    Get.dialog(const LoadingUi(), barrierDismissible: false); // Start Loading...

    if (isFrontCamera) {
      ZegoExpressEngine.instance.useFrontCamera(isFrontCamera);
      isFrontCamera = !isFrontCamera;
      await 200.milliseconds.delay();
      ZegoExpressEngine.instance.useFrontCamera(isFrontCamera);
      ZegoExpressEngine.instance.setVideoMirrorMode(isFrontCamera ? ZegoVideoMirrorMode.BothMirror : ZegoVideoMirrorMode.NoMirror);

      Utils.showLog("isFrontCamera :: ${isFrontCamera}");
    } else {
      ZegoExpressEngine.instance.useFrontCamera(isFrontCamera);
      isFrontCamera = !isFrontCamera;
      await 200.milliseconds.delay();
      ZegoExpressEngine.instance.useFrontCamera(isFrontCamera);
      applyMirrorMode();

      Utils.showLog("isFrontCamera :: ${isFrontCamera}");
    }

    Get.back(); // Stop Loading...
  }

  /// >>>>>>>>>>>Enable Camera<<<<<<<<<<<
  Future<void> onCameraOnOff() async {
    Get.dialog(const LoadingUi(), barrierDismissible: false);

    isCameraOn = !isCameraOn;
    update(["onSwitchCamera"]);
    await ZegoExpressEngine.instance.enableCamera(isCameraOn);

    // Reapply mirror mode — camera re-enable can reset the ZEGO pipeline state
    if (isCameraOn) applyMirrorMode();

    Get.back();
    update();
  }

  /// >>>>>>>>>>>Switch Flash<<<<<<<<<<<
  Future<void> onSendComment() async {
    if (showEmojiPicker) {
      showEmojiPicker = false;
      update(["onUpdateEmojiPicker", "onUpdateTextField"]);
    }
    if (commentController.text.trim().isNotEmpty) {
      SocketServices.onLiveChat(
        loginUserId: Database.fetchLoginUserProfileModel?.user?.id ?? "",
        liveHistoryId: roomID,
        userName: Database.fetchLoginUserProfileModel?.user?.name ?? "",
        userImage: Database.fetchLoginUserProfileModel?.user?.image ?? "",
        commentText: commentController.text,
        giftUrl: "",
        svgaGiftUrl: "",
        isPkActive: liveUserObject?.isPkMode == true,
        receiversDisplay: "",
      );
      commentController.clear();
    }
  }

  /// >>>>>>>>>>>Share Link<<<<<<<<<<<

  Future<void> onShareLink() async {
    if (_isSharing) return;
    _isSharing = true;
    try {
      final link = DeepLinkServices.onGenerateLink(
        pageRoutes: DeepLinkServices.stream,
        id: userId,
        name: name,
        image: image,
        username: userName,
        roomId: roomID,
        liveUserId: liveUserId,
        liveUserObjId: liveUserObjId,
        liveType: liveUserObject?.isPkMode == true ? "3" : "1",
        isFollow: isFollow,
        isProfileImageBanned: isProfileImageBanned,
        host2Channel: host2ChannelId,
        host1WinnerPoint: host1WinnerPoint,
        host2WinnerPoint: host2WinnerPoint,
        requestedList: requestedList,
      );

      final result = await Share.share(
        'Join my live stream! $link',
        subject: 'Live Stream Invitation',
      );

      if (result.status == ShareResultStatus.success) {
        SocketServices.emitShareLiveStream(liveUserId: liveUserId, liveHistoryId: roomID);
      }
    } catch (e) {
      Utils.showLog("onShareLink error: $e");
    } finally {
      Future.delayed(const Duration(seconds: 1), () => _isSharing = false);
    }
  }

  /// >>>>>>>>>>>Click Follow<<<<<<<<<<<
  Future<void> onClickFollow() async {
    if (userId != Database.loginUserId) {
      isFollow = !isFollow;
      update(["onClickFollow"]);
      await FollowUnfollowApi.callApi(loginUserId: Database.loginUserId, userId: liveUserId);
    } else {
      Utils.showToast(EnumLocal.txtYouCantFollowYourOwnAccount.name.tr);
    }
  }

  /// >>>>>>>>>>>Change Time<<<<<<<<<<<
  String onConvertSecondToHMS(int totalSeconds) {
    Duration duration = Duration(seconds: totalSeconds);

    int hours = duration.inHours;
    int minutes = duration.inMinutes.remainder(60);
    int seconds = duration.inSeconds.remainder(60);

    String time = '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';

    return time;
  }

  String onConvertSecondOnly(int totalSeconds) {
    return '${totalSeconds.toString()}s';
  }

  /// >>>>>>>>>>>Check Host Is Live<<<<<<<<<<<
  checkHostIsLive() {
    if (!isHost) {
      Timer(
        Duration(seconds: 5),
        () {
          if (remoteView == null) {
            Get.back();
          }
        },
      );
    }
  }

  // handleLiveUserInfoResponse(data) {
  //   log("GetLiveUserInfo Socket Listen => $data");
  //
  //   List<LiveUserObject> users = <LiveUserObject>[];
  //
  //   if (data is Map<String, dynamic>) {
  //     // Single user case
  //     users = [LiveUserObject.fromJson(data)];
  //     // Process the user...
  //   } else if (data is List) {
  //     // Multiple users case
  //     users = data.map((userJson) => LiveUserObject.fromJson(userJson)).toList();
  //     // Process the users...
  //   } else {
  //     log("GetLiveUserInfo Socket Listen => Invalid data format: $data");
  //     return; // Exit if data is not in expected format
  //   }
  //
  //   // final List<LiveUserList> users = List<LiveUserList>.from(data.map((x) => LiveUserList.fromJson(x)));
  //
  //   // final List<LiveUserList> users = data.values.map((x) => LiveUserList.fromJson(x)).toList();
  //   // Example: Update the first one
  //   updatedLiveUserList = users.isNotEmpty ? users.first : null;
  //   log("GetLiveUserInfo Socket Listen => ${updatedLiveUserList?.toJson()}");
  //   update(["onUpdateMultiLive", "idShare"]);
  // }

  // handleLiveUserLeft(String liveHistoryId) {
  //   final controller = Get.put(streamController.StreamController());
  //   controller.liveUsers = removeLiveUserByHistoryId(liveHistoryId, controller.liveUsers) ?? [];
  //   controller.update(["onChangeLiveUsers"]);
  // }

  List<LiveUserObject>? removeLiveUserByHistoryId(String liveHistoryId, List<LiveUserObject>? liveUserList) {
    // Check if the list is valid
    if (liveUserList == null) {
      debugPrint("Input LiveUserList is null");
      return null;
    }

    try {
      // Create a copy of the list

      // Find the index of the user with matching liveHistoryId
      final index = liveUserList.indexWhere((user) => user.liveHistoryId == liveHistoryId);

      // If the user was found, remove it
      if (index != -1) {
        liveUserList.removeAt(index);
        debugPrint("Live user with liveHistoryId $liveHistoryId was removed");
        return liveUserList;
      } else {
        debugPrint("Live user with liveHistoryId $liveHistoryId was not found");
        return liveUserList; // Return the original list if ID not found
      }
    } catch (e) {
      debugPrint("Error removing live user: $e");
      return liveUserList;
    }
  }

  /// >>>>>>>>>>>Login Room for host<<<<<<<<<<<

  // Future<ZegoRoomLoginResult> loginRoom() async {
  //   final user = ZegoUser(localUserID, localUserName);
  //
  //   ZegoRoomConfig roomConfig = ZegoRoomConfig.defaultConfig()..isUserStatusNotify = true;
  //
  //   return ZegoExpressEngine.instance.loginRoom(roomID, user, config: roomConfig).then((ZegoRoomLoginResult loginRoomResult) {
  //     if (loginRoomResult.errorCode == 0) {
  //       if (isHost) {
  //         startPreview();
  //         startPublish();
  //         SocketServices.userWatchCount.value = 0;
  //         SocketServices.userChats.clear();
  //         SocketServices.onLiveRoomConnect(loginUserId: Database.loginUserId, liveHistoryId: roomID);
  //
  //         update(["onUpdateMultiLive"]);
  //       } else {
  //         SocketServices.userChats.clear();
  //         SocketServices.onAddView(loginUserId: Database.loginUserId, liveHistoryId: roomID);
  //       }
  //     }
  //     return loginRoomResult;
  //   });
  // }

  ///================>>>>>>>>>>>>>>>>>>>>>>>> Multi Live <<<<<<<<<<<<<<<<<<<<<<<<<<<<================

  /// >>>>>>>>>>>Update Multi Live<<<<<<<<<<<
  ///
  ///
  ///
  void onUpdateMultiLive(List<MultiLiveUsersModel> data) async {
    log("onUpdateMultiLive Update Multi Live Users => $data");
    multiLiveRequestedList = data;

    final value = multiLiveRequestedList.any((user) => user.isRequested == true && user.isAccepted == false);
    if (value) onChangeRedDot(true);

    update(["onUpdateMultiLive"]);
  }

  /// >>>>>>>>>>>Update Multi Live<<<<<<<<<<<
  void onUpdateRequested(List<Requested> data) async {
    log(" onUpdateRequested UpdateRequested>>>>>>}");
    requestedList = data;
    log("onUpdateRequested Requested List => $requestedList");
    // final value = multiLiveRequestedList.any((user) => user.userId != Database.loginUserId);
    update(["onUpdateMultiLive", "onSwitchCamera", "onSwitchMic", "onCameraOnOff", "onChangeRedDot"]);
  }

  /// >>>>>>>>>>>Join and Leave Multi Live<<<<<<<<<<<
  void onJoinAndLeaveMultiLive(List<MultiLiveUsersModel> data) async {
    Utils.showLog("Update Multi Live Users => $data");
    joinMultiLiveUsers = data;

    final isJoinMultiLive = joinMultiLiveUsers.any((user) => user.userId == Database.loginUserId);

    if (isJoinMultiLive) {
      await onChangeClientRole(isBroadcaster: true);
    } else {
      await onChangeClientRole(isBroadcaster: false);
    }
    update(["onUpdateMultiLive", "onSwitchMic"]);
  }

  onMultiGuestRequestList(dynamic data) {
    multiLiveHostList = data;
    log("onMultiGuestRequestList Host List => $multiLiveHostList");
    update(["onUpdateMultiLive"]);
  }

  onMultiPKHostList(dynamic data) {
    pkHostData = data;
    log("onMultiGuestRequestList Host List => $multiLiveHostList");
    update(["onUpdateMultiLive"]);
  }

  /// >>>>>>>>>>>Update Live Type<<<<<<<<<<<
  void onUpdateLiveType(UpdateLiveTypeModel updateLiveType) {
    // liveType = updateLiveType.liveType ?? 0;
    requestedList = updateLiveType.requested ?? [];

    // log("liveType>>>>>> $liveType");
    update(["onUpdateMultiLive", "onChangeRedDot", "onCameraOnOff"]);
  }

  /// >>>>>>>>>>>Update Host Camera Status<<<<<<<<<<<
  void onUpdateHostCameraStatus(bool isHostCamera) {
    isHostCameraOn = isHostCamera;

    update(["onUpdateMultiLive"]);
  }

  void applyMirrorMode() {
    ZegoExpressEngine.instance.setVideoMirrorMode(
      isFrontCamera ? ZegoVideoMirrorMode.BothMirror : ZegoVideoMirrorMode.NoMirror,
    );
  }

  /// >>>>>>>>>>>Change Client Role (User to co-host)<<<<<<<<<<<
  Future<void> onChangeClientRole({
    required bool isBroadcaster,
  }) async {
    Get.dialog(const LoadingUi(), barrierDismissible: false); // Show Loading

    try {
      if (isBroadcaster) {
        // Enable camera and mic for co-host
        await ZegoExpressEngine.instance.enableCamera(isCameraOn);
        await ZegoExpressEngine.instance.enableAudioCaptureDevice(isMuteMic);

        // Start video preview for co-host
        await startPublishCoHost();
        await startPreviewCoHost();
        applyMirrorMode();
      } else {
        log("Co-host leaving - cleaning up resources");
        // New cleanup code
        // await ZegoExpressEngine.instance.stopPublishingStream(); // Stop publishing
        if (coHostLocalViewID != null) {
          log("Co-host leaving - cleaning up resources");
          ZegoExpressEngine.instance.stopPreview();
          await ZegoExpressEngine.instance.destroyCanvasView(coHostLocalViewID!);
          ZegoExpressEngine.instance.stopPublishingStream();
        }
      }

      // Update UI
      update(["onUpdateMultiLive"]);
    } catch (e) {
      Utils.showLog("Error changing client role: $e");
    } finally {
      Get.back(); // Hide Loading
    }
  }

  /// >>>>>>>>>>For show co host request  <<<<<<<<<
  void onChangeRedDot(bool value) {
    isShowRedDot = value;

    update(["onChangeRedDot"]);
  }

  /// >>>>>>>>>>>Send Multi Live(co-Host) Request On Socket<<<<<<<<<<<
  Future<void> onSendMultiLiveRequestOnSocket() async {
    String liveStreamId = "${Database.loginUserId}_call";
    SocketServices().onEmitCallJoinRequest(
      userId: Database.loginUserId,
      liveHistoryId: roomID,
      liveUserObjId: liveUserObjId,
      name: Database.fetchLoginUserProfileModel?.user?.name ?? "",
      userName: Database.fetchLoginUserProfileModel?.user?.userName ?? "",
      image: Database.fetchLoginUserProfileModel?.user?.image ?? "",
      country: Database.fetchLoginUserProfileModel?.user?.country ?? "",
      isVerified: Database.fetchLoginUserProfileModel?.user?.isVerified ?? false,
      countryFlagImage: Database.fetchLoginUserProfileModel?.user?.countryFlagImage ?? "",
      agoraUid: liveStreamId,
      isMute: isMuteMic,
      isCameraEnabled: isCameraOn,
      position: coHostRequestPosition,
      isSendrequestByHost: false,
    );
  }

  /// >>>>>>>>>>>Co-Host request to user join <<<<<<<<<<<
  Future<void> onSendMultiLiveRequestOnSocketForUser({
    userId,
    coHost,
    liveUserObjId,
    name,
    userName,
    image,
    country,
    isVerified,
    countryFlagImage,
    position,
    liveHistoryId,
  }) async {
    log("onSendMultiLiveRequestOnSocketForUser >>>>>>>> $userId ${Database.loginUserId} ");
    String liveStreamId = "${userId}_call";
    SocketServices().onEmitCallJoinRequest(
      userId: userId,
      liveHistoryId: liveHistoryId,
      liveUserObjId: liveUserObjId,
      name: name ?? "",
      userName: userName ?? "",
      image: image ?? "",
      country: country,
      isVerified: isVerified ?? false,
      countryFlagImage: countryFlagImage ?? "",
      agoraUid: liveStreamId,
      isMute: isMuteMic,
      isCameraEnabled: true,
      position: position,
      isSendrequestByHost: true,
    );
  }

  /// >>>>>>>>>>>Start Publish For co Host<<<<<<<<<<<
  Future<void> startPublishCoHost() async {
    String streamID = '${Database.loginUserId}_call';
    log('message>>>>>>>>>>>>  startPublishCoHost streamID: $streamID');
    return ZegoExpressEngine.instance.startPublishingStream(streamID);
  }

  /// >>>>>>>>>>>Start Preview For co Host<<<<<<<<<<<
  Future<void> startPreviewCoHost() async {
    await ZegoExpressEngine.instance.createCanvasView((viewID) {
      log(">>>>>>>>>startPreviewCoHost>>viewID $viewID");
      coHostLocalViewID = viewID;
      ZegoCanvas previewCanvas = ZegoCanvas(viewID, viewMode: ZegoViewMode.AspectFill);

      ZegoExpressEngine.instance.startPreview(canvas: previewCanvas);
    }).then((canvasViewWidget) {
      coHostLocalView = canvasViewWidget;
    });
  }

  /// >>>>>>>>>>>Left Multi Live On co Host<<<<<<<<<<<
  Future<void> onLeftMultiLiveOnSocket() async {
    // await onChangeClientRole(isBroadcaster: false);
    SocketServices().onEmitLeftParticipantOfCallJoin(
      userId: Database.loginUserId,
      liveHistoryId: roomID,
      liveUserObjId: liveUserObjId,
      isMute: isMuteMic,
      position: coHostRequestPosition,
      isCameraEnabled: isCameraOn,
    );
  }

  ///================>>>>>>>>>>>>>>>>>>>>>>>> Pk Live <<<<<<<<<<<<<<<<<<<<<<<<<<<<================

  /// >>>>>>>>>>>Get Live User List<<<<<<<<<<<
  void onGetLiveUserList() async {
    isLoadingLiveUserList = true;
    update(["onGetLiveUserList"]);
    fetchLiveUsersModel = await FetchLiveUsersApi.callApi(loginUserId: Database.loginUserId);

    liveUserList.clear();
    liveUserList.addAll(fetchLiveUsersModel?.liveUserList ?? []);
    isLoadingLiveUserList = false;
    update(["onGetLiveUserList"]);
  }

  void onChangePkTime({
    required bool isPkRequestUser,
    required int time,
  }) {
    Utils.showLog("Pk Battle Time =>>> $isPkRequestUser => $time");

    pkTimer?.cancel();
    // pkSuperTimer?.cancel();

    pkCountTime = time;

    // int superDuration = Utils.isShowActionSecond - Utils.isShowEndActionSecond;
    // pkSuperCountTime = superDuration;
    // pkUntilSuperTime = pkCountTime - Utils.isShowActionSecond;

    // bool superTimerStarted = false;
    // bool superTimerEnded = false;
    // int animationCounter = 0;

    pkTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (pkCountTime > 0) {
          pkCountTime--;

          update(['onUpdateMultiLive']);
        } else {
          pkCountTime = 0;
          pkTimer?.cancel();

          log("PK Battle Ended");

          if (isHost && isPkRequestUser) {
            onPkEnd(isManualMode: false);
          }
        }
      },
    );
  }

  void onPkEnd({required bool isManualMode}) {
    SocketServices.onPkEnd(
      userId: host1Id,
      liveHistoryId: host1RoomId,
      isPkTimeOut: false,
      isManualMode: isManualMode,
    );
    host2ChannelId = "";
    update(["onUpdateMultiLive"]);
    applyMirrorMode();
  }

  void onPkResultDeclared() {
    log("onPkResultDeclared  >>${host1Name}>>host1Id>>>>$host1Id");
    log("onPkResultDeclared  >>${host1Name}>>host1RoomId>>>>$host1RoomId");
    log("onPkResultDeclared  >>${userName}>>liveUserId>>>>$liveUserId");
    log("onPkResultDeclared  >>${userName}>>userId>>>>$userId");
    SocketServices.onPkResultDeclared(
      userId: host1Id,
      liveHistoryId: host1RoomId,
    );
    liveUserObject?.isPkMode = false; // ← ADD: keep in sync with onPkEnd
    applyMirrorMode();
    update(["onUpdateMultiLive"]);
  }

  // void onStartPkTime({int? time}) {
  //   final isDefaultCase = time == null;
  //   if (isDefaultCase) {
  //     pkCountTime = 300;
  //   } else {
  //     onShowPkAnimation();
  //     pkCountTime = time;
  //   }
  //
  //   pkTimer = Timer.periodic(
  //     const Duration(seconds: 1),
  //     (timer) async {
  //       if (pkCountTime > 0) {
  //         pkCountTime--;
  //         update(["onChangePkTime"]);
  //         Utils.showLog("Pk Battle Time => ${onConvertSecondToHMS(pkCountTime)}");
  //       } else {
  //         if (isDefaultCase) {
  //           SocketServices.onPkEnd(
  //             liveHistoryId: host1roomId,
  //             isPkTimeOut: true,
  //             isManualMode: false,
  //           );
  //         } else {
  //           pkTimer?.cancel();
  //           update(["onChangePkTime"]);
  //         }
  //       }
  //     },
  //   );
  // }

  void onShowPkAnimation() async {
    await 1000.milliseconds.delay();
    isShowPkAnimation.value = true;
    await 1500.milliseconds.delay();
    isShowPkAnimation.value = false;
  }

  Future<void> onStartRelay() async {
    Utils.showLog("On Start Relay Method Call Success");

    liveUserObject?.isPkMode = true;

    onShowPkAnimation();

    requestedList = [];

    update(["onUpdateMultiLive", "onChangeRedDot", "onCameraOnOff"]);

    // SocketServices().onEmitUpdateLiveTypeStatus(
    //   liveHistoryId: roomID,
    //   liveUserObjId: liveUserObjId,
    //   liveType: 3,
    // );
    await 300.milliseconds.delay(); // ← ADD
    applyMirrorMode();
    ZegoExpressEngine.instance.useFrontCamera(isFrontCamera);
  }

  Future<void> onRestart() async {
    log("On Start Restart Method Call Success");
    // SocketServices().onEmitUpdateLiveTypeStatus(liveHistoryId: liveHistoryId, liveUserObjId: liveUserObjId, liveType: liveType);
  }

  void onChangeRank(int rank1, int rank2) {
    log("Change Rank Host >>>>>>$rank1>>>>>>>>>>$rank2");
    log("Change Rank Host >>>>>>$host1Rank>>>>>>>>>>$host2Rank");

    host1Rank = rank1;
    host2Rank = rank2;

    update(["onUpdateRank"]);
  }

  // ****************************************************** LIVE STEAMING METHOD ******************************************************

  void onStartListenEvent() {
    try {
      ZegoExpressEngine.onRoomUserUpdate = (roomID, updateType, List<ZegoUser> userList) {
        debugPrint('onRoomUserUpdate: roomID: $roomID, updateType: ${updateType.name}, userList: ${userList.map((e) => e.userID)}');
        if (updateType == ZegoUpdateType.Delete) {
          for (var user in userList) {
            if (user.userID == liveUserId && !isHost) {
              Utils.showLog("Host Disconnected from Room! Exiting Live...");
              Utils.showToast("Live ended");
              Get.back();
            }
          }
        }
      };
      ZegoExpressEngine.onRoomStreamUpdate = (roomID, updateType, List<ZegoStream> streamList, extendedData) {
        debugPrint(
            'onRoomStreamUpdate: roomID: $roomID, updateType: $updateType, streamList: ${streamList.map((e) => e.streamID)}, extendedData: $extendedData');
        if (updateType == ZegoUpdateType.Add) {
          for (final stream in streamList) {
            Utils.showLog("*********** STREAM_ID *********** ${stream.streamID}");
            if (remoteView == null) {
              onStartPlayStream(stream.streamID);
            }
          }
        }
      };
      Utils.showLog("✅ START LISTEN EVENT SUCCESS");
    } catch (e) {
      Utils.showLog("❌ START LISTEN EVENT FAILED => $e");
    }
  }

  Future<void> onLoginRoom() async {
    try {
      final localUserID = Database.fetchLoginUserProfileModel?.user?.id ?? "";
      final localUserName = Database.fetchLoginUserProfileModel?.user?.name ?? "";

      final user = ZegoUser(localUserID, localUserName);

      final roomID = this.roomID;

      ZegoRoomConfig roomConfig = ZegoRoomConfig.defaultConfig()..isUserStatusNotify = true;

      ZegoExpressEngine.instance.loginRoom(roomID, user, config: roomConfig).then((ZegoRoomLoginResult loginRoomResult) {
        debugPrint('loginRoom: errorCode:${loginRoomResult.errorCode}, extendedData:${loginRoomResult.extendedData}');
        if (loginRoomResult.errorCode == 0) {
          if (isHost) {
            onStartPreview();
            onStartPublish();
            SocketServices.userChats.clear();
            SocketServices.onLiveRoomConnect(loginUserId: Database.loginUserId, liveHistoryId: roomID);
          } else {
            SocketServices.userChats.clear();
            SocketServices.onAddView(loginUserId: Database.loginUserId, liveHistoryId: roomID);
          }
        }
      });
      Utils.showLog("✅ LOGIN SUCCESS");
    } catch (e) {
      Utils.showLog("❌ LOGIN FAILED => $e");
    }
  }

  Future<void> onStartPreview() async {
    try {
      applyMirrorMode();
      await ZegoExpressEngine.instance.createCanvasView((viewID) {
        localViewID = viewID;
        ZegoCanvas previewCanvas = ZegoCanvas(viewID, viewMode: ZegoViewMode.AspectFill);
        ZegoExpressEngine.instance.startPreview(canvas: previewCanvas);
      }).then((canvasViewWidget) {
        liveScreen = canvasViewWidget;
        isLoading.value = false;
        update(["onUpdateMultiLive"]);
      });
      Utils.showLog("✅ START PREVIEW SUCCESS");
    } catch (e) {
      Utils.showLog("❌ START PREVIEW FAILED => $e");
    }
  }

  Future<void> onStartPublish() async {
    try {
      String streamID = '${Database.loginUserId}_call';
      ZegoExpressEngine.instance.startPublishingStream(streamID);
      applyMirrorMode();

      Utils.showLog("✅ START PUBLISH SUCCESS");
    } catch (e) {
      Utils.showLog("❌ START START PUBLISH FAILED => $e");
    }
  }

  Future<void> onStartPlayStream(String streamID) async {
    try {
      await ZegoExpressEngine.instance.createCanvasView((viewID) {
        remoteViewID = viewID;
        ZegoCanvas canvas = ZegoCanvas(viewID, viewMode: ZegoViewMode.AspectFill);
        ZegoExpressEngine.instance.startPlayingStream(streamID, canvas: canvas);
      }).then((canvasViewWidget) {
        remoteView = canvasViewWidget;
        isLoading.value = false;
        update(["OnUpdateMultiLive"]);
        Utils.showLog("✅ START PLAY STREAM SUCCESS");
      });
    } catch (e) {
      Utils.showLog("❌ START PLAY STREAM FAILED => $e");
    }
  }

  Future<void> onLogoutRoom() async {
    try {
      onStopPreview();
      onStopPublish();
      await ZegoExpressEngine.instance.logoutRoom(this.roomID);
      Utils.showLog("✅ LOGOUT SUCCESS");
    } catch (e) {
      Utils.showLog("❌ LOGOUT FAILED => $e");
    }
  }

  Future<void> onStopPreview() async {
    try {
      ZegoExpressEngine.instance.stopPreview();
      if (localViewID != null) {
        await ZegoExpressEngine.instance.destroyCanvasView(localViewID!);
        localViewID = null;
        liveScreen = null;
      }
      Utils.showLog("✅ STOP PREVIEW SUCCESS");
    } catch (e) {
      Utils.showLog("❌ STOP PREVIEW FAILED => $e");
    }
  }

  Future<void> onStopPublish() async {
    try {
      await ZegoExpressEngine.instance.stopPublishingStream();
      Utils.showLog("✅ STOP PUBLISH SUCCESS");
    } catch (e) {
      Utils.showLog("❌ STOP PUBLISH FAILED => $e");
    }
  }

  Future<void> onStopPlayStream(String streamID) async {
    try {
      await ZegoExpressEngine.instance.stopPlayingStream(streamID);

      if (remoteViewID != null) {
        ZegoExpressEngine.instance.destroyCanvasView(remoteViewID!);
        remoteViewID = null;
        remoteView = null;
        update(["OnUpdateMultiLive"]);
      }
      Utils.showLog("✅ STOP PLAY STREAM SUCCESS");
    } catch (e) {
      Utils.showLog("❌ STOP PLAY STREAM FAILED => $e");
    }
  }

  void onStopListenEvent() {
    try {
      SocketServices.onLessView(loginUserId: Database.loginUserId, liveHistoryId: roomID);
      remoteView = null;
      ZegoExpressEngine.onRoomUserUpdate = null;
      ZegoExpressEngine.onRoomStreamUpdate = null;
      ZegoExpressEngine.onRoomStateUpdate = null;
      ZegoExpressEngine.onPublisherStateUpdate = null;
      Utils.showLog("✅ STOP LISTEN EVENT SUCCESS");
    } catch (e) {
      Utils.showLog("❌ STOP LISTEN EVENT FAILED => $e");
    }
  }
}
