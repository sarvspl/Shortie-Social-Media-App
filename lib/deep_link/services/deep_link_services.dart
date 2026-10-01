import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:get/get.dart';
import 'package:shortie/deep_link/config/easy_deep_links.dart';
import 'package:shortie/pages/bottom_bar_page/controller/bottom_bar_controller.dart';
import 'package:shortie/pages/multi_live_page/view/multi_live_page_view.dart';
import 'package:shortie/pages/stream_page/model/live_user_object_model.dart';
import 'package:shortie/routes/app_routes.dart';
import 'package:shortie/utils/api.dart';
import 'package:shortie/utils/database.dart';
import 'package:shortie/utils/utils.dart';

class DeepLinkServices {
  // static const String videoKey = "video";
  // static const String postKey = "post";
  // static const String profileKey = "profile";
  // static const String referralKey = "referral";
  // static const String liveStreamKey = "LiveStream";
  static const String pageRoutesKey = "pageRoute";
  static const String idKey = "id";
  static const String referralCodeKey = "referralCode";
// For Web
  static const String reels = "reels";
  static const String live = "live";
  static const String stream = "stream";
  static const String feed = "feed";
  static const String user_profile = "user-profile";
  static String roomId = "";
  static String liveUserId = "";
  static String liveUserObjId = "";
  static String image = "";
  static String name = "";
  static String username = "";
  static int liveType = 0;
  static bool isFollow = false;
  static bool isProfileImageBanned = false;
  static String host2Channel = "";
  static int host1WinnerPoint = 0;
  static int host2WinnerPoint = 0;
  static List<Requested> requestedList = [];

  static String eventId = "";
  static String eventType = "";
  static String referralCode = "";

  static bool isNavigationComplete = false;

  // Call In Main...
  static Future<void> onInitDeepLinks() async {
    try {
      await EasyDeepLinks.initialize(EasyDeepLinkConfig(domain: Api.domain, customScheme: 'myapplication', debug: true));

      EasyDeepLinks.linkStream.listen((linkInfo) {
        Utils.showLog("✅ DEEP LINK LISTEN => ${linkInfo.queryParams[pageRoutesKey]}");

        isNavigationComplete = false;

        eventId = linkInfo.queryParams[idKey] ?? "";
        eventType = linkInfo.queryParams[pageRoutesKey] ?? "";
        referralCode = linkInfo.queryParams[referralCodeKey] ?? "";
        if (eventType == stream) {
          roomId = linkInfo.queryParams['roomId'] ?? "";
          liveUserId = linkInfo.queryParams['liveUserId'] ?? "";
          liveUserObjId = linkInfo.queryParams['liveUserObjId'] ?? "";
          name = linkInfo.queryParams['name'] ?? "";
          image = linkInfo.queryParams['image'] ?? "";
          username = linkInfo.queryParams['username'] ?? "";
          liveType = int.tryParse(linkInfo.queryParams['liveType'] ?? "0") ?? 0;
          isFollow = (linkInfo.queryParams['isFollow'] ?? "false") == "true";
          isProfileImageBanned = (linkInfo.queryParams['isProfileImageBanned'] ?? "false") == "true";
          host2Channel = linkInfo.queryParams['host2Channel'] ?? "";
          host1WinnerPoint = int.tryParse(linkInfo.queryParams['host1WinnerPoint'] ?? "0") ?? 0;
          host2WinnerPoint = int.tryParse(linkInfo.queryParams['host2WinnerPoint'] ?? "0") ?? 0;

          try {
            final requestedListJson = linkInfo.queryParams['requestedList'];
            if (requestedListJson != null && requestedListJson.isNotEmpty) {
              final List<dynamic> jsonList = jsonDecode(requestedListJson);
              requestedList = jsonList.map<Requested>((item) => Requested.fromJson(item)).toList();
            }
          } catch (e) {
            requestedList = [];
            log("Error parsing requestedList: $e");
          }
        }
      });

      Utils.showLog("✅ DEEP LINK INITIALIZE SUCCESS");
    } catch (e) {
      Utils.showLog("❌ DEEP LINK INITIALIZE FAILED => $e");
    }
  }

  static String onGenerateLink({
    String? id,
    String? pageRoutes,
    String? referralCode,
    String? roomId,
    String? name,
    String? image,
    String? liveUserId,
    String? liveUserObjId,
    String? liveType,
    bool? isFollow,
    bool? isProfileImageBanned,
    String? host2Channel,
    String? username,
    int? host1WinnerPoint,
    int? host2WinnerPoint,
    List<Requested>? requestedList,
  }) {
    final Map<String, String> params = {
      pageRoutesKey: pageRoutes ?? "",
      idKey: liveUserId ?? "",
      referralCodeKey: referralCode ?? "",
    };
    if (pageRoutes == stream) {
      params['roomId'] = roomId ?? "";
      params['liveUserId'] = liveUserId ?? "";
      params['liveUserObjId'] = liveUserObjId ?? "";
      params['liveType'] = liveType ?? "0";
      params['username'] = username ?? "";
      params['name'] = name ?? "";
      params['image'] = image ?? "";
      params['isFollow'] = (isFollow ?? false).toString();
      params['isProfileImageBanned'] = (isProfileImageBanned ?? false).toString();
      params['host2Channel'] = host2Channel ?? "";
      params['host1WinnerPoint'] = (host1WinnerPoint ?? 0).toString();
      params['host2WinnerPoint'] = (host2WinnerPoint ?? 0).toString();

      if (requestedList != null && requestedList.isNotEmpty) {
        try {
          params['requestedList'] = jsonEncode(requestedList.map((r) => r.toJson()).toList());
        } catch (e) {
          log("Error encoding requestedList: $e");
        }
      }
    }
    final link = EasyDeepLinks.generateLink("/share", params);

    Utils.showLog("✅ DEEP LINK GENERATE => $link");
    return link;
  }

  // Call In Bottom Bar Controller...
  static Future<void> onChangeRoutes({required bool isBottomBarRoutes}) async {
    Utils.showLog("Deep Link => EventType => $eventType => EventId => $eventId => IsBottomBar => $isBottomBarRoutes");

    if (eventType.isEmpty || eventId.isEmpty && eventType != stream) return;

    isBottomBarRoutes ? await 500.milliseconds.delay() : await 0.milliseconds.delay();

    bool isInitialize = Get.isRegistered<BottomBarController>();

    if (isInitialize && !isNavigationComplete) {
      Utils.showLog("Deep Link Navigation => EventType => $eventType => EventId => $eventId => IsBottomBar => $isBottomBarRoutes");

      isNavigationComplete = true;

      final bottomBarController = Get.find<BottomBarController>();

      switch (eventType) {
        case feed:
          if (Get.isRegistered<BottomBarController>()) {
            bottomBarController.onChangeBottomBar(2);
            Utils.showLog("Deep Link Navigation => POST => $eventType => EventId => $eventId");
          }
          break;
        case reels:
          if (Get.isRegistered<BottomBarController>()) {
            // bottomBarController.onChangeBottomBar(0);
          }
          // if (Get.isRegistered<FeedController>()) {
          //   final controller = Get.find<FeedController>();
          //   controller.onChangeTab(1);
          // }
          break;

        case user_profile:
          if (Get.isRegistered<BottomBarController>()) {
            if (Database.loginUserId == eventId) {
              if (Get.isRegistered<BottomBarController>()) {
                bottomBarController.onChangeBottomBar(4);
              }
            } else {
              bottomBarController.onChangeBottomBar(2);
              Get.toNamed(AppRoutes.previewUserProfilePage, arguments: eventId);
            }
            Utils.showLog("Deep Link Navigation => PROFILE => $eventType => EventId => $eventId");
          }
          break;
        case stream:
          if (roomId.isNotEmpty && liveUserId.isNotEmpty) {
            bottomBarController.onChangeBottomBar(1); // streaming tab
            Utils.showLog("Calling THis ${liveUserId}  Z ${roomId}  ${liveUserObjId}");
            await Future.delayed(const Duration(milliseconds: 1500));

            Get.to(
              () => MultiLivePageView(
                isHost: false,
                userId: liveUserId,
                liveHistoryId: roomId,
                liveUserObjId: liveUserObjId,
              ),
            );
          }
          break;
      }
    }
  }
}
