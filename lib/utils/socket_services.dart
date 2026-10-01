import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortie/pages/chat_page/model/fetch_user_chat_model.dart';
import 'package:shortie/pages/multi_live_page/bottom_sheet/invite_user_for_pk_bottom_sheet.dart';
import 'package:shortie/pages/multi_live_page/bottom_sheet/join_multi_live_bottom_sheet_widget.dart';
import 'package:shortie/pages/multi_live_page/bottom_sheet/pk_invitation_bottom_sheet.dart';
import 'package:shortie/pages/multi_live_page/bottom_sheet/pk_result_bottom_sheet_ui.dart';
import 'package:shortie/pages/multi_live_page/bottom_sheet/sending_pk_request_bottom_sheet.dart';
import 'package:shortie/pages/multi_live_page/controller/multi_live_controller.dart';
import 'package:shortie/pages/multi_live_page/model/multi_live_users_model.dart';
import 'package:shortie/pages/multi_live_page/model/pk_gift_top_user_model.dart';
import 'package:shortie/pages/multi_live_page/model/update_live_type_model.dart';
import 'package:shortie/pages/stream_page/model/live_user_object_model.dart';
import 'package:shortie/utils/api.dart';
import 'package:shortie/utils/database.dart';
import 'package:shortie/utils/utils.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../pages/multi_live_page/widget/show_received_gift.dart';

io.Socket? socket;

class SocketServices {
  io.Socket? getSocket() => socket;

  // This is use to When the live user exits the streaming page, the viewing user exits automatically...
  static bool isLiveRunning = false;

  // This is use to how many users see the live user...
  static RxInt userWatchCount = 0.obs;

  // This is use to live user send comment...
  static RxList mainLiveComments = [].obs;

  static RxList liveViewers = [].obs;

  // This is use to if get new message/comment then auto scroll down list...
  static ScrollController scrollController = ScrollController();

  // This is use to chat between two user...

  static List<Chat> userChats = [];
  static RxBool onChangeChats = false.obs; // This variable is used for Update only (true/false not matter)
  static String? lastVisitChatUserId;

  static bool isBusyUser = false;
  static String? busyWithUserId;

  static int pkDuration = 0;

  static Future<void> socketConnect() async {
    // ✅ Guard: already connected — nothing to do
    if (socket != null && socket!.connected) {
      Utils.showLog("Socket already connected, skipping reconnect.");
      return;
    }

    // ✅ Clean slate: tear down any stale socket before creating a new one.
    // This removes ALL listeners registered on it, preventing duplication.
    disposeSocket();

    try {
      socket = io.io(
        Api.baseUrl,
        io.OptionBuilder().setTransports(['websocket']).setQuery({"globalRoom": "globalRoom:${Database.loginUserId}"}).build(),
      );

      socket!.connect();
      userWatchCount.value = 0;

      socket!.onConnect((data) {
        Utils.showLog("Socket Listen => Socket Connected : ${socket?.id}");
        onConnect();
      });

      socket!.once(
        "connect",
        (data) {
          // >>>>> >>>>> >>>>> >>>>> Socket Listen Method <<<<< <<<<< <<<<< <<<<<

          // ************************************************************************************************************************************************************************************************************************

          socket?.on("liveRoomConnect", (data) {
            Utils.showLog("SOCKET LIVE EVENT => Socket Listen => liveRoomConnect : $data");
          });

          socket?.on("endLive", (endLive) {
            userWatchCount.value = 0;
            Utils.showLog("SOCKET LIVE EVENT => Socket Listen => endLive : $data");

            if (isLiveRunning) {
              isLiveRunning = false;
              Get.back();

              if (PkResultBottomSheetUi.isOpenBottomSheet) Get.back();
            }
          });

          socket?.on("addView", (data) async {
            userWatchCount.value = data;
            Utils.showLog("SOCKET LIVE EVENT => Socket Listen => addView : $data");
          });

          socket?.on("lessView", (data) {
            userWatchCount.value = data;
            Utils.showLog("SOCKET LIVE EVENT => Socket Listen => lessView : $data");
          });

          socket?.on("gift", (data) async {
            Utils.showLog("SOCKET LIVE EVENT => Socket Listen => gift : $data");
            onGetNewGift(gift: data);
          });

          socket?.on("liveChat", (data) async {
            Utils.showLog("SOCKET LIVE EVENT => Socket Listen => liveChat : $data");

            final Map response = await jsonDecode(data);

            if (response["giftUrl"] != null && response["giftUrl"] != "" || response["svgaGiftUrl"] != null && response["svgaGiftUrl"] != "") {
              if (response["userId"] != Database.loginUserId && response["receiversDisplay"] != Database.fetchLoginUserProfileModel!.user!.userName) {
                response["commentText"] = "${response["userName"]} sent ${response["receiversDisplay"]} ${response['coin']} coins";
              } else if (response["userId"] == Database.loginUserId) {
                response["commentText"] = "You sent ${response['coin']} coins to ${response["receiversDisplay"]} ";
              } else {
                response["commentText"] = "${response["userName"]} sent you ${response['coin']} coins";
              }
            }

            onGetNewComment(message: response);
          });

          // ************************************************************************************************************************************************************************************************************************

          // ************************************************************************************************************************************************************************************************************************

          socket!.on("messageRequest", (messageRequest) {
            Utils.showLog("Socket Listen => Get New Message Request : ${messageRequest}");

            if (messageRequest["messageId"] != null) {
              Utils.showLog("Socket Listen => Get New Message Id : ${messageRequest["messageId"]}");
            }

            final Map response = jsonDecode(messageRequest["data"]);

            // If User Send Message(Text) Then Get Message Id In Outside Of message["data"] else Send Image/Audio Then Get Message Id In message["data"]

            // if ((response["messageType"] == 2 || response["messageType"] == 3) && response["messageId"] != null) {
            //   onReadMessage(senderUserId: response["senderUserId"], messageId: response["messageId"]);
            // } else if (messageRequest["messageId"] != null) {
            //   onReadMessage(senderUserId: response["senderUserId"], messageId: messageRequest["messageId"]);
            // }

            onGetNewMessage(message: response, messageId: messageRequest["messageId"]?.toString());
          });

          socket!.on("message", (message) {
            Utils.showLog("Socket Listen => Get New Message : ${message}");

            if (message["messageId"] != null) {
              Utils.showLog("Socket Listen => Get New Message Id : ${message["messageId"]}");
            }

            final Map response = jsonDecode(message["data"]);

            // If User Send Message(Text) Then Get Message Id In Outside Of message["data"] else Send Image/Audio Then Get Message Id In message["data"]

            if ((response["messageType"] == 2 || response["messageType"] == 3) && response["messageId"] != null) {
              onReadMessage(senderUserId: response["senderUserId"], messageId: response["messageId"]);
            } else if (message["messageId"] != null) {
              onReadMessage(senderUserId: response["senderUserId"], messageId: message["messageId"]);
            }

            onGetNewMessage(message: response, messageId: message["messageId"]?.toString());
            // try {
            //   final bottomBarController = Get.find<BottomBarController>();
            //   if (bottomBarController.selectedTabIndex == 3) {
            //     // Call Only User Current On Message Page..
            //     if (Get.isRegistered<MessageController>()) {
            //       final messageController = Get.find<MessageController>();
            //       messageController.init();
            //     } else {
            //       final messageController = Get.put(MessageController());
            //       messageController.init();
            //     }
            //   }
            // } catch (e) {
            //   Utils.showLog("Get New Message Listen Error => $e");
            // }
          });

          socket!.on(
            "messageRead",
            (messageRead) async {
              Utils.showLog("Socket Listen => New Message Read : $messageRead");
            },
          );
        },
      );
      // >>>>> >>>>> >>>>> MULTI LIVE VIDEO CALL <<<<< <<<<< <<<<<

      socket?.on("getLiveHostInfo", (data) async {
        Utils.showLog("SOCKET LIVE EVENT => Socket Listen => getLiveHostInfo : $data");
        onLiveUserInfoResponse(data);
      });

      socket!.on("liveUserLeft", (data) async {
        Utils.showLog("Socket Listen => liveUserLeft : $data");
        onLiveUserLeft(data);
      });

      socket!.on("requestedUpdated", (data) async {
        Utils.showLog("Socket Listen => CALL REQUEST UPDATE : ${data}");

        onListenRequestedUpdated(data);
      });

      socket!.on("updateCallJoinInvite", (data) async {
        Utils.showLog("Socket Listen => UPDATE CALL JOIN REQUEST : $data");
        onListenUpdateCallJoinInvite(data);
      });

      socket!.on("multiGuestRequestList", (data) async {
        Utils.showLog("Socket Listen => MULTI GUEST REQUEST : $data");

        onListenMultiGuestRequestList(data);
      });
      socket!.on("pkHostsInfo", (data) async {
        Utils.showLog("Socket Listen => PK HOSTS INFO : $data");
        onListenPkHostList(data);
      });

      socket!.on("participantsUpdated", (data) async {
        Utils.showLog("Socket Listen => PARTICIPANT UPDATE : $data");
        onListenParticipantUpdated(data);
      });

      socket!.on("updateLiveType", (data) async {
        Utils.showLog("Socket Listen => Update Live Type   : $data");
        onListenUpdateLiveType(data);
      });

      socket!.on("updateHostCameraStatus", (data) async {
        onListenUpdateHostCameraStatus(data);
        Utils.showLog("Socket Listen => UPDATE HOST CAMERA  : $data");
      });

      //********************************* PK EVENT ***********************************

      socket?.on("pkInviteIncoming", (data) {
        Utils.showLog("SOCKET PK EVENT => Socket Listen => pkInviteIncoming => ${data}");
        onListenPkRequest(data);
      });

      socket?.on("pkRequestResponse", (data) {
        Utils.showLog("SOCKET PK EVENT => Socket Listen => pkRequestResponse => ${data}");
        onListenPkAnswer(data);
      });

      socket?.on("refreshPkRankings", (data) {
        Utils.showLog("SOCKET PK EVENT => Socket Listen => refreshPkRankings => ${data}");
        onUpdatePkRanking(data);
      });

      // socket!.on(
      //   "updateTopGifterStats",
      //   (data) {
      //     Utils.showLog("Socket Listen => Update Top Gifter Stats : $data");
      //     onUpdateTopGifterStats(data);
      //   },
      // );

      socket!.on(
        "hostGifterStatsUpdated",
        (data) {
          Utils.showLog("Socket Listen => Host Gifter Stats Updated : $data");
          onHostGifterStatsUpdated(data);
        },
      );

      socket?.on("submitPkBattleGift", (data) {
        Utils.showLog("SOCKET PK EVENT => Socket Listen => submitPkBattleGift => ${data}");
        onGetPkGift(gift: data);
      });

      socket!.on(
        "pkMatchEnded",
        (data) {
          Utils.showLog("Socket Listen => pk Match Ended : $data");
          onListenPkMatchEnded(data);
        },
      );
      socket?.on(
        "pkEndedByDisconnect",
        (data) {
          Utils.showLog("Socket Listen => pk Match Ended pkEndedByDisconnect : $data");
          onListenPkEndedByDisconnect(data);
        },
      );

      socket?.on("terminatePkBattle", (data) {
        Utils.showLog("SOCKET PK EVENT => Socket Listen => terminatePkBattle => ${data}");
        onListenPkEnd(data);
      });

      socket!.on(
        "pkEndToPkEndUser",
        (data) {
          Utils.showLog("Socket Listen => Pk End To Pk End User : $data");

          bool isManualMode = data["isManualMode"];
          if (isManualMode == false) {
            // onListenPkEnd(data);
          }
        },
      );
      socket!.on(
        "listLiveViewers",
        (data) async {
          Utils.showLog("Socket Listen => listLiveViewers : $data");
          liveViewers.value = data;
          Utils.showLog("Socket Listen => listLiveViewers : $liveViewers");
          // final String joinComment = liveViewers.isNotEmpty ? "${liveViewers.last['userName']} has joined the room." : "User has joined the room";
          //
          // await onLiveChat(
          //   loginUserId: liveViewers.last['userId'],
          //   liveHistoryId: liveViewers.last['liveHistoryId'],
          //   userName: liveViewers.last['userName'],
          //   userImage: Api.baseUrl + liveViewers.last['image'],
          //   commentText: joinComment,
          //   isPkActive: false,
          // );
        },
      );

      //-----------------------------------------------

      socket?.on("updateTopGiftContributors", (data) {
        Utils.showLog("SOCKET PK EVENT => Socket Listen => updateTopGiftContributors => ${data}");
        onUpdateTopGifterStats(data);
      });

      socket!.on("error", (error) {
        Utils.showLog("Socket Listen => Socket Error : $error");
      });

      socket!.on("connect_error", (error) {
        Utils.showLog("Socket Listen => Socket Connection Error : $error");
      });

      socket!.on("connect_timeout", (timeout) {
        Utils.showLog("Socket Listen => Socket Connection Timeout : $timeout");
      });

      socket!.on("disconnect", (reason) {
        Utils.showLog("Socket Listen => Socket Disconnected : $reason");
        if (Get.isRegistered<MultiLiveController>()) {
          MultiLiveController controller = Get.find<MultiLiveController>();

          if (controller.liveUserObject?.isPkMode == true) {
            Utils.showLog("Resetting PK State due to Socket Disconnect...");
            controller.liveUserObject?.isPkMode = false;
            controller.host2ChannelId = "";
            controller.host1Rank = 0;
            controller.host2Rank = 0;
            controller.host1WinnerPoint = 0;
            controller.host2WinnerPoint = 0;
            controller.pkTimer?.cancel();
            controller.pkSuperTimer?.cancel();
            controller.host1TopGiftUsers.clear();
            controller.host2TopGiftUsers.clear();
            controller.update(["onUpdateMultiLive", "onUpdateRank", "onChangePkTime", "onCameraOnOff", "onSwitchCamera", "onSwitchMic"]);
          } else {
            controller.update(["onCameraOnOff", "onSwitchCamera", "onSwitchMic"]);
          }
        }
      });

      Utils.showLog("Socket Listen => Socket Connected : ${socket?.connected}");
    } catch (e) {
      Utils.showLog("Socket Listen => Socket Connection Error: $e");
    }
  }

  static void disposeSocket() {
    if (socket == null) return;
    try {
      // removes ALL .on() listeners at once
      socket!.dispose(); // closes underlying connection + cleans up
    } catch (e) {
      Utils.showLog("Socket dispose error: $e");
    }
    socket = null;
  }

  // >>>>> >>>>> >>>>> >>>>> Socket Emit Method <<<<< <<<<< <<<<< <<<<<
  static Future<void> onConnect() async {
    if (isMultiLiveScreen) {
      final controller = Get.find<MultiLiveController>();

      await 10.seconds.delay();
      onLiveRoomConnect(loginUserId: Database.loginUserId, liveHistoryId: controller.roomID);
      Utils.showLog("Reconnect Live Steaming...");
    }
  }

  // >>>>> >>>>> >>>>> >>>>> Socket Emit Method <<<<< <<<<< <<<<< <<<<<

  static void onListenPkRequest(dynamic data) {
    if (!Get.isRegistered<MultiLiveController>()) return;
    final controller = Get.find<MultiLiveController>();

    final Map jsonResponse = jsonDecode(data);
    final bool instantCut = bool.parse(jsonResponse["InstantCutRequestByHost"].toString());

    // ── CANCEL PATH ──────────────────────────────────────────────────────────
    // InstantCutRequestByHost=true means the requester cancelled their PK invite.
    // Close our invitation sheet if it is open, then stop.
    if (instantCut) {
      Utils.showLog("pkInviteIncoming — InstantCut: requester cancelled PK request");
      if (PkInvitationBottomSheet.isOpenBottomSheet) {
        Utils.showLog("pkInviteIncoming — closing PkInvitationBottomSheet (cancelled by requester)");
        controller.isPkInviteSheetOpen = false;
        Get.back();
      }
      return;
    }

    // ── INVITE PATH ───────────────────────────────────────────────────────────
    // InstantCutRequestByHost=false → this is a new incoming PK invitation.

    // Guard 1: sheet is already visible (flag is set synchronously before showModalBottomSheet)
    if (PkInvitationBottomSheet.isOpenBottomSheet) {
      Utils.showLog("pkInviteIncoming — PkInvitationBottomSheet already open, skipped");
      return;
    }

    // Guard 2: timestamp dedup — blocks rapid duplicate events within 3 seconds
    if (!controller.canProcessPkInvite()) {
      Utils.showLog("pkInviteIncoming — duplicate skipped (within dedup window)");
      return;
    }

    // Guard 3: controller-level flag (belt & suspenders)
    if (controller.isPkInviteSheetOpen) {
      Utils.showLog("pkInviteIncoming — isPkInviteSheetOpen=true, skipped");
      return;
    }

    if (PkResultBottomSheetUi.isOpenBottomSheet) Get.back();
    if (InviteUserForPkBottomSheet.isOpenBottomSheet) Get.back();

    controller.isPkInviteSheetOpen = true;

    PkInvitationBottomSheet.show(
      host1Image: jsonResponse["host1Image"],
      host1Name: jsonResponse["host1Name"],
    ).then((_) {
      controller.isPkInviteSheetOpen = false; // reset when sheet is dismissed
    });

    controller.host2Id = jsonResponse["host1Id"];
    controller.host2RoomId = jsonResponse["host1RoomId"];
    controller.host2ChannelId = jsonResponse["host1ChannelId"];
    controller.host2Token = jsonResponse["host1Token"];
    controller.host2Name = jsonResponse["host1Name"];
    controller.host2UserName = jsonResponse["host1UserName"];
    controller.host2Image = jsonResponse["host1Image"];
  }

  static Future<void> onGetPkGift({required Map gift}) async {
    final controller = Get.find<MultiLiveController>();
    log("message onGetPkGift>>>>>>>>");
    log("message onGetPkGift>>>>>>>> Check $gift");

    controller.onChangeRank(gift["response"]["pkConfig"]["localRank"] ?? 0, gift["response"]["pkConfig"]["remoteRank"] ?? 0);

    ShowReceivedGift.onGetNewGift(
      GiftModel(
        giftType: gift["giftData"]["giftType"],
        giftUrl: gift["giftData"]["giftUrl"],
        giftCount: 1,
        senderName: gift["giftData"]["senderName"],
        senderImage: gift["giftData"]["senderImage"],
        senderUniqueId: gift["giftData"]["senderUniqueId"],
        senderProfilePicBanned: gift["giftData"]["senderProfilePicBanned"],
        receiverName: "",
        isFake: false,
      ),
    );
  }

  static void onListenRequestedUpdated(dynamic data) {
    if (!Get.isRegistered<MultiLiveController>()) return;
    final controller = Get.find<MultiLiveController>();

    // ← dedup guard
    if (!controller.canProcessRequestedUpdated()) {
      Utils.showLog("requestedUpdated — duplicate skipped");
      return;
    }

    final jsonList = data as List<dynamic>;
    final multiLiveUsers = jsonList.map((json) => MultiLiveUsersModel.fromJson(json)).toList();

    controller.onUpdateRequested(jsonList.map((json) => Requested.fromJson(json)).toList());

    final targetUser = multiLiveUsers.firstWhereOrNull(
      (u) => u.isRequested == true && u.isAccepted == false && u.isSendRequestByHost == true,
    );

    if (targetUser != null) {
      if (!controller.isHost && (targetUser.agoraUid?.contains(Database.loginUserId) ?? false) && !controller.isAcceptDeclineSheetOpen) {
        // ← sheet guard

        controller.isAcceptDeclineSheetOpen = true;

        AcceptDeclineBottomSheet.show(
          userImage: targetUser.image ?? "",
          userName: targetUser.userName ?? "",
          userModel: targetUser,
        ).then((_) {
          controller.isAcceptDeclineSheetOpen = false;
        });

        controller.update(["onUpdateMultiLive", "onSwitchCamera", "onSwitchMic", "onCameraOnOff", "onChangeRedDot"]);
      }
    } else {
      controller.onUpdateMultiLive(multiLiveUsers);
    }
  }

  static void onListenUpdateCallJoinInvite(dynamic data) {}

  static void onListenParticipantUpdated(dynamic data) {
    Utils.showLog("HRK Socket Listen => PARTICIPANT UPDATE : $data");
    final controller = Get.find<MultiLiveController>();
    final jsonList = data as List<dynamic>;
    controller.onJoinAndLeaveMultiLive(jsonList.map((json) => MultiLiveUsersModel.fromJson(json)).toList());
  }

  static void onListenMultiGuestRequestList(dynamic data) {
    final controller = Get.find<MultiLiveController>();
    controller.onMultiGuestRequestList(data);
  }

  static void onListenPkHostList(dynamic data) {
    final controller = Get.find<MultiLiveController>();
    controller.onMultiPKHostList(data);
  }

  static void onListenUpdateLiveType(dynamic data) {
    final controller = Get.find<MultiLiveController>();

    final updateLiveType = UpdateLiveTypeModel.fromJson(data);
    controller.onUpdateLiveType(updateLiveType);
  }

  static void onListenUpdateHostCameraStatus(dynamic data) {
    final controller = Get.find<MultiLiveController>();
    Utils.showLog("HOSTLY CAMARA ==> $data");
    controller.onUpdateHostCameraStatus(data);
  }

  static void onListenPkEnd(dynamic data) async {
    if (Get.isRegistered<MultiLiveController>()) {
      // if (PkRoundOverBottomSheetUi.isOpenBottomSheet) Get.back();

      int winType = data["data"]["pkConfig"]["isWinner"] ?? 0; // 0=>Tie 1=>Lose 2=>Win

      Utils.showLog("END********************** ${data["data"]["pkConfig"]["host1Name"]}");

      final String h1Name = data["data"]["pkConfig"]["host1Name"] ?? "";
      final String h1Image = data["data"]["pkConfig"]["host1Image"] ?? "";
      final String h2Name = data["data"]["pkConfig"]["host2Name"] ?? "";
      final String h2Image = data["data"]["pkConfig"]["host2Image"] ?? "";

      final int host1WinnerPoint = 0;
      final int host2WinnerPoint = 0;
      final int localRankTotal = data["data"]["pkConfig"]["localRank"] ?? 0;
      final int remoteRankTotal = data["data"]["pkConfig"]["remoteRank"] ?? 0;
      final int totalPkRounds = 0;

      final String winUserId = data["winner"]["userId"] ?? "";

      Utils.showLog("Socket Listen => Win Type => $winType");

      final controller = Get.find<MultiLiveController>();

      bool isWin = controller.host1Id == winUserId;

      controller.liveUserObject?.isPkMode = false;

      controller.update(["onUpdateMultiLive"]);

      SocketServices().onEmitUpdateLiveTypeStatus(liveHistoryId: controller.host1RoomId, liveUserObjId: controller.liveUserObjId, liveType: 1);

      Utils.showLog("IS Win => $isWin");

      Utils.showLog("########### =>${data["isManualMode"]} ***** ${data["pkEndUserId"]} ------ ${controller.liveUserObject?.userId}");

      if (data["isManualMode"] == true && data["pkEndUserId"] == controller.liveUserObject?.userId) {
        Utils.showLog("5555555555555555555");
        Get.back(); // Stop Live Steaming
      }

      if (data["isManualMode"] == false || data["pkEndUserId"] != controller.host1Id) {
        if (PkResultBottomSheetUi.isOpenBottomSheet == false)
          PkResultBottomSheetUi.show(
            result: winType == 2
                ? PKResult.win
                : winType == 1
                    ? PKResult.lose
                    : PKResult.tie,
            h1Name: h1Name,
            h1Image: h1Image,
            h2Name: h2Name,
            h2Image: h2Image,
            host1WinnerPoint: host1WinnerPoint,
            host2WinnerPoint: host2WinnerPoint,
            h1RankTotal: localRankTotal,
            h2RankTotal: remoteRankTotal,
            totalPkRounds: totalPkRounds,
          );
      }

      controller.host1Rank = 0;
      controller.host2Rank = 0;

      controller.host1WinnerPoint = 0;
      controller.host2WinnerPoint = 0;

      controller.pkTimer?.cancel();
      controller.pkSuperTimer?.cancel();
      controller.host1TopGiftUsers.clear();
      controller.host2TopGiftUsers.clear();
    }
  }

  static void onListenPkMatchEnded(dynamic data) async {
    if (Get.isRegistered<MultiLiveController>()) {
      final controller = Get.find<MultiLiveController>();
      int winType = data["data"]["pkConfig"]["isWinner"]; // 0=>Tie 1=>Lose 2=>Win

      final int localRank = data["data"]["pkConfig"]["localRank"];
      final int remoteRank = data["data"]["pkConfig"]["remoteRank"];

      // final String h1Name = data["data"]["pkConfig"]["host1Name"];
      // final String h1Image = data["data"]["pkConfig"]["host1Image"];
      controller.host1WinnerPoint = data["data"]["pkConfig"]["host1WinnerPoint"];
      controller.host2WinnerPoint = data["data"]["pkConfig"]["host2WinnerPoint"];
      // final String h2Name = data["data"]["pkConfig"]["host2Name"];
      // final String h2Image = data["data"]["pkConfig"]["host2Image"];

      // final String winUserId = data["winner"]["userId"];

      Utils.showLog("Socket Listen => localRank => $localRank");
      Utils.showLog("Socket Listen => remoteRank => $remoteRank");
      Utils.showLog("Socket Listen => Win Type => $winType");
      controller.update(["onUpdateMultiLive", "onChangePoint"]);
      if (data["pkEndUserId"] != controller.host1Id) {
        // Use the unified bottom sheet for all cases

        if (controller.isHost == true) {
          // PkRoundOverBottomSheetUi.show(
          //   h1Name: h1Name,
          //   h1Image: h1Image,
          //   h2Name: h2Name,
          //   h2Image: h2Image,
          //   winType: winType,
          //   currentUserId: controller.host1Id,
          //   winnerUserId: winUserId,
          //   h1Rank: localRank,
          //   h2Rank: remoteRank,
          // );
        }
      }

      controller.host1Rank = 0;
      controller.host2Rank = 0;

      controller.host1TopGiftUsers.clear();
      controller.host2TopGiftUsers.clear();
    }
    log("Socket  onListenPkMatchEnded>>>>>>>> $data");
  }

  static void onListenPkEndedByDisconnect(dynamic data) {
    if (Get.isRegistered<MultiLiveController>()) {
      final controller = Get.find<MultiLiveController>();

      if (controller.isHost) {
        Utils.showToast("PK ended due to disconnect");
      }

      controller.liveUserObject?.isPkMode = false;
      controller.host2ChannelId = "";

      controller.host1Rank = 0;
      controller.host2Rank = 0;
      controller.host1WinnerPoint = 0;
      controller.host2WinnerPoint = 0;

      controller.pkTimer?.cancel();
      controller.pkSuperTimer?.cancel();
      controller.host1TopGiftUsers.clear();
      controller.host2TopGiftUsers.clear();

      controller.update(["onUpdateMultiLive", "onUpdateRank", "onChangePkTime"]);

      if (controller.isHost) {
        SocketServices().onEmitUpdateLiveTypeStatus(liveHistoryId: controller.host1RoomId, liveUserObjId: controller.liveUserObjId, liveType: 1);
      }
    }
  }

  static Future<void> onLiveRoomConnect({required String loginUserId, required String liveHistoryId}) async {
    if (loginUserId.trim().isNotEmpty && liveHistoryId.trim().isNotEmpty) {
      final data = jsonEncode({"userId": loginUserId, "liveHistoryId": liveHistoryId});

      if (socket != null && socket!.connected) {
        socket?.emit("liveRoomConnect", data);
        Utils.showLog("SOCKET LIVE EVENT => Socket Emit => liveRoomConnect => $data");
      } else {
        Utils.showLog("Socket Not Connected !!");
      }
    }
  }

  static Future<void> onLiveRoomExit({required String liveHistoryId, required bool isHost, required String loginUserId}) async {
    if (loginUserId.trim().isNotEmpty && liveHistoryId.trim().isNotEmpty) {
      if (isHost) {
        final data = jsonEncode({"liveHistoryId": liveHistoryId, "userId": loginUserId});
        if (socket != null && socket!.connected) {
          socket?.emit("endLive", data);
          Utils.showLog("SOCKET LIVE EVENT => Socket Emit => endLive => $data");
        } else {
          Utils.showLog("Socket Not Connected !!");
        }
      }
    }
  }

  static Future<void> onAddView({required String loginUserId, required String liveHistoryId}) async {
    if (loginUserId.trim().isNotEmpty && liveHistoryId.trim().isNotEmpty) {
      isLiveRunning = true;

      final data = jsonEncode({"userId": loginUserId, "liveHistoryId": liveHistoryId});

      if (socket != null && socket!.connected) {
        socket?.emit("addView", data);
        Utils.showLog("SOCKET LIVE EVENT => Socket Emit => addView => $data");
      } else {
        Utils.showLog("Socket Not Connected !!");
      }
    }
  }

  static Future<void> onLessView({required String loginUserId, required String liveHistoryId}) async {
    if (loginUserId.trim().isNotEmpty && liveHistoryId.trim().isNotEmpty) {
      final data = jsonEncode({"userId": loginUserId, "liveHistoryId": liveHistoryId});

      if (socket != null && socket!.connected) {
        socket?.emit("lessView", data);
        Utils.showLog("SOCKET LIVE EVENT => Socket Emit => lessView => $data");
      } else {
        Utils.showLog("Socket Not Connected !!");
      }
    }
  }

  static Future<void> onLiveChat({
    required String loginUserId,
    required String liveHistoryId,
    required String userName,
    required String userImage,
    required String commentText,
    required String giftUrl,
    required String svgaGiftUrl,
    required bool isPkActive,
    required String receiversDisplay,
    int? coin = 0, // Add this parameter for coin amount
  }) async {
    final data = jsonEncode({
      "userName": userName,
      "userImage": userImage,
      "commentText": commentText,
      "userId": loginUserId,
      "liveHistoryId": liveHistoryId,
      "isPkActive": isPkActive,
      "giftUrl": giftUrl,
      "svgaGiftUrl": svgaGiftUrl,
      "receiversDisplay": receiversDisplay,
      "coin": coin ?? 0, // Use the coin parameter or default to 0
    });

    if (socket != null && socket!.connected) {
      socket!.emit("liveChat", data);
      Utils.showLog("SOCKET LIVE EVENT => Socket Emit => liveChat => $data");
    } else {
      Utils.showLog("Socket Not Connected !!");
    }
  }

  static Future<void> onLiveSendGift({
    required int coin,
    required int giftType,
    required String giftUrl,
    required String svgaUrl,
    required String giftId,
    required String senderUserId,
    required String senderName,
    required String senderImage,
    required String senderUniqueId,
    required bool senderProfilePicBanned,
    required List<String> receiverUserId,
    required String liveHistoryId,
    required String senderUserName,
    required String liveUserObjId,
  }) async {
    final gift = jsonEncode(
      {
        "giftUrl": giftUrl,
        "svgaUrl": svgaUrl,
        "giftType": giftType,
        "coin": coin,
        "giftId": giftId,
        "senderUserId": senderUserId,
        "senderName": senderName,
        "senderImage": senderImage,
        "senderUniqueId": senderUniqueId,
        "senderProfilePicBanned": senderProfilePicBanned,
        "receiverUserId": receiverUserId,
        "liveHistoryId": liveHistoryId,
        "liveUserObjId": liveUserObjId,
      },
    );

    if (socket != null && socket!.connected) {
      socket!.emit("gift", gift);
      Utils.showLog("SOCKET LIVE EVENT => Socket Emit => gift => $gift");
    } else {
      Utils.showLog("Socket Not Connected!!");
    }
  }
/*  static Future<void> onLiveSendGift({
    required int coin,
    required int giftType,
    required String giftUrl,
    required String giftId,
    required String senderUserId,
    required List<String> receiverUserId,
    required String liveHistoryId,
  }) async {
    final gift = jsonEncode(
      {
        "giftUrl": giftUrl,
        "giftType": giftType,
        "coin": coin,
        "giftId": giftId,
        "senderUserId": senderUserId,
        "receiverUserId": receiverUserId,
        "liveHistoryId": liveHistoryId,
      },
    );

    if (socket != null && socket!.connected) {
      socket!.emit("gift", gift);
      Utils.showLog("Socket Emit => User Send Gift $gift");
    } else {
      Utils.showLog("Socket Not Connected !!");
    }
  }*/

  static Future<void> onSendMessage({
    required String senderUserId,
    required String receiverUserId,
    required String chatTopicId,
    required int messageType,
    required String messageText,
    required String image,
    required String audio,
    required bool isChatMediaBanned,
    String? messageId,
  }) async {
    final message = jsonEncode(
      {
        "chatTopicId": chatTopicId,
        "senderUserId": senderUserId,
        "receiverUserId": receiverUserId,
        "messageType": messageType,
        "message": messageText,
        "image": image,
        "audio": audio,
        "createdAt": DateTime.now().toString(),
        "messageId": messageId,
        "isChatMediaBanned": isChatMediaBanned,
      },
    );

    if (socket != null && socket!.connected) {
      socket?.emit("message", message);
      Utils.showLog("Socket Emit => User Send Message");
    } else {
      Utils.showLog("Socket Not Connected !!");
    }
  }

  static Future<void> onReadMessage({
    required String senderUserId,
    required String messageId,
  }) async {
    Utils.showLog("On Read Message Method Calling...");

    final messageRead = jsonEncode({"messageId": messageId});

    if (socket != null && socket!.connected) {
      Utils.showLog("Login User Id => ${Database.loginUserId} >>> Last Chat UserId => $lastVisitChatUserId >>> Message Sender User Id $senderUserId");

      if (lastVisitChatUserId != null && Database.loginUserId != senderUserId && lastVisitChatUserId == senderUserId) {
        socket?.emit("messageRead", messageRead);

        Utils.showLog("New Message Read => True");

        Utils.showLog("Socket Emit => User Read Message");
      } else {
        Utils.showLog("New Message Read => False");
      }
    } else {
      Utils.showLog("Socket Not Connected !!");
    }
  }

  static Future<void> onReadMessageRequest({required String messageId}) async {
    Utils.showLog("On Read Message Request Method Calling...");

    final messageRead = jsonEncode({"messageId": messageId});

    if (socket != null && socket!.connected) {
      socket?.emit("messageRequestRead", messageRead);

      Utils.showLog("New Message Read => True");

      Utils.showLog("Socket Emit => Read Message Request");
    } else {
      Utils.showLog("Socket Not Connected !!");
    }
  }

  // >>>>> >>>>> >>>>> >>>>> Socket Listen Data Set Method <<<<< <<<<< <<<<< <<<<<

  static Future<void> onGetNewGift({required Map gift}) async {
    ShowReceivedGift.onGetNewGift(
      GiftModel(
          giftType: gift["giftData"]["giftType"],
          giftUrl: gift["giftData"]["giftUrl"],
          giftCount: 1,
          senderName: gift["giftData"]["senderName"],
          senderImage: gift["giftData"]["senderImage"],
          senderUniqueId: gift["giftData"]["senderUniqueId"],
          senderProfilePicBanned: gift["giftData"]["senderProfilePicBanned"],
          receiverName: "",
          isFake: false),
    );
  }

  static Future<void> onGetNewComment({required Map message}) async {
    mainLiveComments.add(message);
    await onScrollDown();
  }

  static Future<void> onGetNewMessage({required Map message, String? messageId}) async {
    try {
      final String? finalMessageId = messageId ?? message["messageId"] ?? message["_id"] ?? message["id"];

      // Check against recent messages to prevent duplicates from multi-socket triggers
      if (userChats.isNotEmpty) {
        // Look at the last 10 messages for any match
        final recentChats = userChats.reversed.take(10).toList();
        
        bool isDuplicate = recentChats.any((chat) {
          // 1. Match by ID if both have a valid ID
          if (finalMessageId != null && finalMessageId.isNotEmpty && chat.id != null && chat.id!.isNotEmpty) {
            if (chat.id == finalMessageId) return true;
          }
          
          // 2. Strict Content match fallback (useful if ID was somehow stripped or null)
          bool sameContent = chat.message == message["message"] &&
                             chat.image == message["image"] &&
                             chat.audio == message["audio"] &&
                             chat.senderUserId == message["senderUserId"] &&
                             chat.createdAt == message["createdAt"];
                             
          return sameContent;
        });

        if (isDuplicate) {
          Utils.showLog("Duplicate chat message found, ignoring... ID: $finalMessageId");
          return;
        }
      }

      userChats.add(
        Chat(
          id: finalMessageId,
          image: message["image"],
          audio: message["audio"],
          message: message["message"],
          createdAt: message["createdAt"],
          messageType: message["messageType"],
          senderUserId: message["senderUserId"],
          isChatMediaBanned: message["isChatMediaBanned"],
        ),
      );

      onUpdateChat();

      await onScrollDown();
    } catch (e) {
      Utils.showLog("New Message Get Filed => $e");
    }
  }

  static Future<void> onScrollDown() async {
    try {
      await 10.milliseconds.delay();
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: Duration(seconds: 1),
        curve: Curves.fastOutSlowIn,
      );
      await 10.milliseconds.delay();
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: Duration(seconds: 1),
        curve: Curves.fastOutSlowIn,
      );
    } catch (e) {
      Utils.showLog("Scroll Down Failed => $e");
    }
  }

  static Future<void> onUpdateChat() async {
    onChangeChats.value = !onChangeChats.value;
  }

  Future<void> onEmitCallJoinRequest({
    required String userId,
    required String liveHistoryId,
    required String liveUserObjId,
    required String name,
    required String userName,
    required String image,
    required String country,
    required bool isVerified,
    required String agoraUid,
    required String countryFlagImage,
    required bool isMute,
    required bool isCameraEnabled,
    required bool isSendrequestByHost,
    required int position,
  }) async {
    Utils.showLog("Socket Emit => Call Join Request");
    final data = jsonEncode({
      "userId": userId,
      "liveHistoryId": liveHistoryId,
      "liveUserObjId": liveUserObjId,
      "name": name,
      "userName": userName,
      "image": image,
      "country": country,
      "isVerified": isVerified,
      "agoraUid": agoraUid,
      "isMute": isMute,
      "isCameraEnabled": isCameraEnabled,
      "position": position,
      "countryFlagImage": countryFlagImage,
      "isSendrequestByHost": isSendrequestByHost,
    });
    if (socket?.connected == true) {
      socket!.emit("callJoinRequest", data);

      Utils.showLog("Socket Emit => CAll JOIN REQUEST => $data");
    } else {
      Utils.showLog("Socket Not Connected !!");
    }
  }

  Future<void> onEmitRemoveCallJoinRequest({
    required String userId,
    required String liveHistoryId,
    required String liveUserObjId,
    required int coHostRequestPosition,
    required bool isMute,
    required bool isCameraEnabled,
  }) async {
    final data = jsonEncode({
      "userId": userId,
      "liveHistoryId": liveHistoryId,
      "liveUserObjId": liveUserObjId,
      "position": coHostRequestPosition,
      "isMute": isMute,
      "isCameraEnabled": isCameraEnabled,
    });

    if (socket?.connected == true) {
      socket!.emit("removeCallJoinRequest", data);
      Utils.showLog("Socket Emit => REMOVE CAll JOIN REQUEST => $data");
    } else {
      Utils.showLog("Socket Not Connected !!");
    }
  }

  Future<void> onEmitLeftParticipantOfCallJoin({
    required String userId,
    required String liveHistoryId,
    required String liveUserObjId,
    required bool isCameraEnabled,
    required bool isMute,
    required int position,
  }) async {
    final data = jsonEncode({
      "userId": userId,
      "liveHistoryId": liveHistoryId,
      "liveUserObjId": liveUserObjId,
      "isCameraEnabled": isCameraEnabled,
      "isMute": isMute,
      "position": position,
    });

    if (socket?.connected == true) {
      socket!.emit("leftParticipantOfCallJoin", data);
      Utils.showLog("Socket Emit => LEFT PARTICIPANT OF CALL JOIN => $data");
    } else {
      Utils.showLog("Socket Not Connected !!");
    }
  }

  Future<void> onEmitUpdateMuteStatus({
    required String userId,
    required String liveHistoryId,
    required String liveUserObjId,
    required bool isMute,
    required bool isCameraEnabled,
    required int position,
  }) async {
    final data = jsonEncode({
      "userId": userId,
      "liveHistoryId": liveHistoryId,
      "liveUserObjId": liveUserObjId,
      "isMute": isMute,
      "isCameraEnabled": isCameraEnabled,
      "position": position,
    });

    if (socket?.connected == true) {
      socket!.emit("updateMuteStatus", data);
      Utils.showLog("Socket Emit => UPDATE MUTE CALL STATUS => $data");
    } else {
      Utils.showLog("Socket Not Connected !!");
    }
  }

  Future<void> onEmitUpdateCameraStatus({
    required String userId,
    required String liveHistoryId,
    required String liveUserObjId,
    required bool isMute,
    required bool isCameraEnabled,
    required int position,
  }) async {
    final data = jsonEncode({
      "userId": userId,
      "liveHistoryId": liveHistoryId,
      "liveUserObjId": liveUserObjId,
      "isCameraEnabled": isCameraEnabled,
      "isMute": isMute,
      "position": position,
    });

    if (socket?.connected == true) {
      socket!.emit("updateCameraStatus", data);
      Utils.showLog("Socket Emit => UPDATE Camera CALL STATUS => $data");
    } else {
      Utils.showLog("Socket Not Connected !!");
    }
  }

  Future<void> onEmitUpdateLiveTypeStatus({
    required String liveHistoryId,
    required String liveUserObjId,
    required int liveType,
  }) async {
    final data = jsonEncode({
      "liveHistoryId": liveHistoryId,
      "liveUserObjId": liveUserObjId,
      "liveType": liveType,
    });

    if (socket?.connected == true) {
      socket!.emit("updateLiveType", data);
      Utils.showLog("Socket Emit => UPDATE LiveType CALL STATUS => $data");
    } else {
      Utils.showLog("Socket Not Connected !!");
    }
  }

  Future<void> onEmitUpdateHostCameraStatusStatus({
    required String liveHistoryId,
    required String liveUserObjId,
    required bool isCameraEnabled,
  }) async {
    final data = jsonEncode({
      "liveHistoryId": liveHistoryId,
      "liveUserObjId": liveUserObjId,
      "isHostCameraEnabled": isCameraEnabled,
    });

    if (socket?.connected == true) {
      socket!.emit("updateHostCameraStatus", data);
      Utils.showLog("Socket Emit => UPDATE LiveType CALL STATUS HOST=> $data");
    } else {
      Utils.showLog("Socket Not Connected !!");
    }
  }

  Future<void> onEmitAddParticipantToCallJoin({
    required String userId,
    required String liveHistoryId,
    required String liveUserObjId,
    required String agoraUid,
    required bool isCameraEnabled,
    required bool isMute,
    required int position,
  }) async {
    final data = jsonEncode({
      "userId": userId,
      "liveHistoryId": liveHistoryId,
      "liveUserObjId": liveUserObjId,
      "agoraUid": agoraUid,
      "isCameraEnabled": isCameraEnabled,
      "position": position,
      "isMute": isMute,
    });

    if (socket?.connected == true) {
      socket!.emit("addParticipantToCallJoin", data);
      Utils.showLog("Socket Emit => ADD PARTICIPANT TO CALL JOIN => $data");
    } else {
      Utils.showLog("Socket Not Connected !!");
    }
  }

  static Future<void> onSendPkRequest({
    required String host2Id,
    required String host2Token,
    required String host2RoomId,
    required String host2ChannelId,
    required String host1Token,
    required String host1RoomId,
    required String host1ChannelId,
  }) async {
    isBusyUser = true;
    busyWithUserId = host2Id;

    final data = jsonEncode(
      {
        "InstantCutRequestByHost": false,
        "host1RoomId": host1RoomId,
        "host1Token": host1Token,
        "host1ChannelId": host1ChannelId,
        "host1Name": Database.fetchLoginUserProfileModel?.user?.name ?? "",
        "host1UserName": Database.fetchLoginUserProfileModel?.user?.userName ?? "",
        "host1Id": Database.fetchLoginUserProfileModel?.user?.id ?? "",
        "host1Image": Database.fetchLoginUserProfileModel?.user?.image ?? "",
        "host2Id": host2Id,
        "host2Token": host2Id,
        "host2RoomId": host2RoomId,
        "host2ChannelId": host2ChannelId,
      },
    );

    if (socket != null && socket!.connected) {
      socket!.emit("initiatePkRequest", data);
      Utils.showLog("SOCKET PK EVENT => Socket Emit => initiatePkRequest => ${data}");
    } else {
      Utils.showLog("Socket Not Connected !!");
    }
  }

  static Future<void> onPkAnswer({required bool isAccept, required bool isPkRound}) async {
    if (Get.isRegistered<MultiLiveController>()) {
      final controller = Get.find<MultiLiveController>();

      final data = jsonEncode(
        {
          "HOST_1_AGORA_ID": 0,
          "HOST_2_AGORA_ID": 1,
          "HOST_1_ID": controller.host1Id,
          "HOST_2_ID": controller.host2Id,
          "HOST_1_CHANNEL": controller.host1ChannelId,
          "HOST_2_CHANNEL": controller.host2ChannelId,
          "HOST_1_IMAGE": controller.host1Image,
          "HOST_2_IMAGE": controller.host2Image,
          "HOST_1_NAME": controller.host1Name,
          "HOST_2_NAME": controller.host2Name,
          "HOST_1_LIVEID": controller.host1RoomId,
          "HOST_2_LIVEID": controller.host2RoomId,
          "isAccept": isAccept,
          "isPkRound": isPkRound,
        },
      );

      if (socket != null && socket!.connected) {
        socket!.emit("pkRequestResponse", data);
        Utils.showLog("SOCKET PK EVENT => Socket Emit => pkRequestResponse => ${data}");
      } else {
        Utils.showLog("Socket Not Connected !!");
      }
    }
  }

  static Future<void> onPkSendGift({
    required int coin,
    required int giftType,
    required String giftUrl,
    required String giftId,
    required String senderUserId,
    required String senderName,
    required String senderImage,
    required String senderUniqueId,
    required bool senderProfilePicBanned,
    required List<String> receiverUserIds,
    required String liveHistoryId,
  }) async {
    final data = jsonEncode(
      {
        "giftId": giftId,
        "senderUserId": senderUserId,
        "senderName": senderName,
        "senderImage": senderImage,
        "senderUniqueId": senderUniqueId,
        "senderProfilePicBanned": senderProfilePicBanned,
        "receiverUserId": receiverUserIds,
        "giftUrl": giftUrl,
        "giftType": giftType,
        "coin": coin,
        "liveHistoryId": liveHistoryId,
      },
    );

    if (socket != null && socket!.connected) {
      socket!.emit("submitPkBattleGift", data);

      Utils.showLog("SOCKET PK EVENT => Socket Emit => submitPkBattleGift => ${data}");
    } else {
      Utils.showLog("Socket Not Connected !!");
    }
  }

  static Future<void> onCancelPkRequest({required String host1Id, required String host2Id}) async {
    isBusyUser = false;
    busyWithUserId = null;

    final data = jsonEncode(
      {
        "host1Id": host1Id,
        "host2Id": host2Id,
        "InstantCutRequestByHost": true,
      },
    );

    if (socket != null && socket!.connected) {
      socket!.emit("initiatePkRequest", data);
      Utils.showLog("SOCKET PK EVENT => Socket Emit => initiatePkRequest => ${data}");
    } else {
      Utils.showLog("Socket Not Connected !!");
    }
  }

  static Future<void> onPkResultDeclared({
    required String liveHistoryId,
    required String userId,
  }) async {
    final pkResultDeclared = jsonEncode(
      {
        "liveHistoryId": liveHistoryId,
        "userId": userId,
      },
    );
    if (socket != null && socket!.connected) {
      socket?.emit("pkResultDeclared", pkResultDeclared);
      Utils.showLog("Socket Emit => pk1 Result Declared => $pkResultDeclared");
    } else {
      Utils.showLog("Socket Not Connected !!");
    }
  }

  static Future<void> onPkEnd({
    required String liveHistoryId,
    required bool isPkTimeOut,
    required bool isManualMode,
    required String userId,
  }) async {
    final data = jsonEncode(
      {
        "liveHistoryId": liveHistoryId,
        "userId": userId,
        "pkEndUserId": userId,
        "isPkTimeOut": isPkTimeOut,
        "isManualMode": isManualMode,
      },
    );
    if (socket != null && socket!.connected) {
      socket?.emit("terminatePkBattle", data);
      Utils.showLog("SOCKET PK EVENT => Socket Emit => terminatePkBattle => ${data}");
    } else {
      Utils.showLog("Socket Not Connected !!");
    }
  }

  static void onListenPkAnswer(dynamic data) async {
    if (!Get.isRegistered<MultiLiveController>()) return;
    final controller = Get.find<MultiLiveController>();

    // ← dedup + processing guard
    if (!controller.canProcessPkAnswer() || controller.isPkAnswerProcessing) {
      Utils.showLog("pkRequestResponse — duplicate skipped");
      return;
    }

    controller.isPkAnswerProcessing = true;

    try {
      final Map jsonResponseData = jsonDecode(data["data"]);
      pkDuration = data["response"]["duration"] ?? 0;

      if (PkResultBottomSheetUi.isOpenBottomSheet) Get.back();

      final bool isAccept = bool.parse(jsonResponseData["isAccept"].toString());
      if (SendingPkRequestBottomSheet.isOpenBottomSheet) Get.back();

      if (isAccept) {
        if (controller.host1RoomId == jsonResponseData["HOST_2_LIVEID"]) {
          controller.host2Id = jsonResponseData["HOST_1_ID"] ?? "";
          controller.host2Name = jsonResponseData["HOST_1_NAME"] ?? "";
          controller.host2Image = jsonResponseData["HOST_1_IMAGE"] ?? "";
          controller.host2ChannelId = jsonResponseData["HOST_1_CHANNEL"] ?? "";
        }
        controller.onStartRelay();
        controller.onChangePkTime(
          isPkRequestUser: controller.host1RoomId == jsonResponseData["HOST_2_LIVEID"],
          time: pkDuration,
        );
      }
    } finally {
      await Future.delayed(const Duration(seconds: 2));
      controller.isPkAnswerProcessing = false;
    }
  }

  static onUpdatePkRanking(dynamic data) async {
    if (Get.isRegistered<MultiLiveController>()) {
      final controller = Get.find<MultiLiveController>();

      final local = data["pkConfig"]["localRank"];
      final remote = data["pkConfig"]["remoteRank"];

      controller.host1Rank = local;
      controller.host2Rank = remote;

      Utils.showLog("hostRank NEW 1 local => $local");
      Utils.showLog("hostRank NEW 2 remote => $remote");

      controller.update(["onUpdateMultiLive", "onUpdateRank"]);

      pkDuration = data["duration"] ?? 0;
      if (pkDuration != 0 && controller.isHost == false)
        controller.onChangePkTime(
          isPkRequestUser: false,
          time: pkDuration,
        );
    }
  }

  static onHostGifterStatsUpdated(dynamic data) async {
    if (Get.isRegistered<MultiLiveController>()) {
      final controller = Get.find<MultiLiveController>();

      List<dynamic> topGiftersHost1 = data["topGiftersHost1"];
      List<dynamic> topGiftersHost2 = data["topGiftersHost2"];

      List<PkGiftTopUserModel> host1 = topGiftersHost1.map((json) => PkGiftTopUserModel.fromJson(json)).toList();
      List<PkGiftTopUserModel> host2 = topGiftersHost2.map((json) => PkGiftTopUserModel.fromJson(json)).toList();

      controller.host1TopGiftUsers = host1;
      controller.host2TopGiftUsers = host2;

      controller.update(["onUpdateMultiLive"]);
    }
  }

  static onUpdateTopGifterStats(dynamic data) async {
    if (Get.isRegistered<MultiLiveController>()) {
      final controller = Get.find<MultiLiveController>();

      String liveHistoryId = data["liveHistoryId"] ?? "";
      List<dynamic> response = data["topGifters"] ?? [];

      List<PkGiftTopUserModel> TopGift = response.map((json) => PkGiftTopUserModel.fromJson(json)).toList();

      if (controller.liveUserObject?.liveHistoryId == liveHistoryId) {
        controller.host1TopGiftUsers = TopGift;
      } else {
        controller.host2TopGiftUsers = TopGift;
      }
      // controller.totalGiftUserData = users;
      controller.update(["onUpdateMultiLive"]);
    }
  }

  static Future<void> emitOnGetLiveHostInfo({
    required String liveHistoryId,
    required String liveUserObjId,
    required String liveUserId,
  }) async {
    final data = jsonEncode({
      "liveHistoryId": liveHistoryId,
      "liveUserObjId": liveUserObjId,
      "liveUserId": liveUserId,
    });

    if (socket != null && socket!.connected) {
      socket?.emit("getLiveHostInfo", data);
      Utils.showLog("SOCKET LIVE EVENT => Socket Emit => getLiveHostInfo => $data");
    } else {
      Utils.showLog("Socket Not Connected !!");
    }
  }

  static Future<void> emitShareLiveStream({
    required String liveUserId,
    required String liveHistoryId,
  }) async {
    final data = jsonEncode({
      "liveUserId": liveUserId,
      "liveHistoryId": liveHistoryId,
    });

    if (socket != null && socket!.connected) {
      socket!.emit("shareLiveStream", data);
      Utils.showLog("Share Live Stream Socket Emit => shareLiveStream => $data");
    } else {
      Utils.showLog("Socket Not Connected !!");
    }
  }

  static Future<void> emitRequestedCountModified({
    required int requestedCount,
    required String liveHistoryId,
  }) async {
    final data = jsonEncode({
      "requestedCount": requestedCount,
      "liveHistoryId": liveHistoryId,
    });

    if (socket != null && socket!.connected) {
      socket!.emit("requestedCountModified", data);
      Utils.showLog(" Socket Emit => requestedCountModified => $data");
    } else {
      Utils.showLog("Socket Not Connected !!");
    }
  }

  static void onLiveUserInfoResponse(dynamic data) {
    final controller = Get.isRegistered<MultiLiveController>() ? Get.find<MultiLiveController>() : Get.put(MultiLiveController());
    controller.onGetLiveObject(data);
  }

  static void onLiveUserLeft(dynamic data) {
    // final controller = Get.find<MultiLiveController>();
    // controller.handleLiveUserLeft(data['liveHistoryId']);
  }
}
