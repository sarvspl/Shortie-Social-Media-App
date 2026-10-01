// import 'dart:async';
// import 'dart:convert';
// import 'dart:developer';
// import 'package:share_plus/share_plus.dart';
// import 'package:shortie/pages/bottom_bar_page/controller/bottom_bar_controller.dart';
// import 'package:shortie/pages/multi_live_page/view/multi_live_page_view.dart';
// import 'package:shortie/pages/stream_page/model/live_user_object_model.dart';
// import 'package:shortie/utils/api.dart';
// import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
// import 'package:get/get.dart';
// import 'package:shortie/utils/socket_services.dart';
// import 'package:shortie/utils/utils.dart';

// class BranchIoServices {
//   static BranchContentMetaData branchContentMetaData = BranchContentMetaData();
//   static BranchUniversalObject? branchUniversalObject;
//   static BranchLinkProperties branchLinkProperties = BranchLinkProperties();
//
//   static String eventId = "";
//   static String eventType = "";
//   static String referralCode = "";
//
//   // Additional fields for live streaming
//   static String roomId = "";
//   static String liveUserId = "";
//   static String liveUserObjId = "";
//   static String image = "";
//   static String name = "";
//   static String username = "";
//   static int liveType = 0;
//   static bool isHost = false;
//   static bool isFollow = false;
//   static bool isProfileImageBanned = false;
//   static String host2Channel = "";
//   static int host1WinnerPoint = 0;
//   static int host2WinnerPoint = 0;
//   static List<Requested> requestedList = [];
//
//   // Flag to track if we're handling a deep link
//   static bool _isHandlingDeepLink = false;
//
//   // Clear all live stream data
//   static void clearLiveStreamData() {
//     roomId = "";
//     liveUserId = "";
//     liveUserObjId = "";
//     image = "";
//     name = "";
//     username = "";
//     liveType = 0;
//     isHost = false;
//     isFollow = false;
//     isProfileImageBanned = false;
//     host2Channel = "";
//     host1WinnerPoint = 0;
//     host2WinnerPoint = 0;
//     requestedList.clear();
//     _isHandlingDeepLink = false;
//   }
//
//   static void onListenBranchIoLinks() async {
//     StreamController<String> streamController = StreamController<String>();
//     StreamSubscription<Map>? streamSubscription = FlutterBranchSdk.listSession().listen(
//       (data) async {
//         log('Click To Branch Io Link => $data');
//         streamController.sink.add((data.toString()));
//
//         if (data.containsKey('+clicked_branch_link') && data['+clicked_branch_link'] == true) {
//           log("Click To Branch Io Link Page Routes => ${data['pageRoutes']}");
//           log("Click To Branch Io Link Referral Code => ${data['referralCode']}");
//
//           // Clear previous data first
//           clearLiveStreamData();
//
//           eventId = data["id"] ?? "";
//           eventType = data['pageRoutes'] ?? "";
//           referralCode = data['referralCode'] ?? "";
//
//           // Handle live stream data if available
//           if (eventType == "LiveStream") {
//             _isHandlingDeepLink = true;
//
//             roomId = data['roomId'] ?? "";
//             liveUserId = data['liveUserId'] ?? "";
//             liveUserObjId = data['liveUserObjId'] ?? "";
//             name = data['name'] ?? "";
//             image = data['image'] ?? "";
//             username = data['username'] ?? "";
//             liveType = int.tryParse(data['liveType']?.toString() ?? "0") ?? 0;
//             isHost = (data['isHost']?.toString() ?? "false") == "true";
//             isFollow = (data['isFollow']?.toString() ?? "false") == "true";
//             isProfileImageBanned = (data['isProfileImageBanned']?.toString() ?? "false") == "true";
//             host2Channel = data['host2Channel'] ?? "";
//             host1WinnerPoint = int.tryParse(data['host1WinnerPoint']?.toString() ?? "0") ?? 0;
//             host2WinnerPoint = int.tryParse(data['host2WinnerPoint']?.toString() ?? "0") ?? 0;
//
//             // Process RequestedList if available
//             if (data.containsKey('requestedList')) {
//               try {
//                 final requestedListJson = data['requestedList'] as String?;
//                 log("requestedListJson>>>>>$requestedListJson");
//                 if (requestedListJson != null && requestedListJson.isNotEmpty) {
//                   log("requestedListJson>>>>>${requestedListJson.length}");
//
//                   // Properly parse the JSON list and convert each item to Requested object
//                   final List<dynamic> jsonList = jsonDecode(requestedListJson);
//                   log("jsonList length>>>>>${jsonList.length}");
//
//                   // Convert each item in the list to a Requested object
//                   requestedList = jsonList.map<Requested>((item) => Requested.fromJson(item)).toList();
//                   log("requestedList>>>requestedList>>${requestedList.length}");
//                 }
//               } catch (e) {
//                 log("Error parsing requestedList: $e");
//                 requestedList = []; // Ensure it's empty on error
//               }
//             }
//
//             log("Live Stream Data Parsed Successfully");
//             log("roomId: $roomId");
//             log("liveUserId: $liveUserId");
//             log("name: $name");
//             Utils.showLog("Handling Live Stream Deep Link");
//             Utils.showLog("roomId: ${BranchIoServices.roomId}");
//             Utils.showLog("liveUserId: ${BranchIoServices.liveUserId}");
//             Utils.showLog("Handling Live Stream Deep Link");
//             Utils.showLog("roomId: ${BranchIoServices.roomId}");
//             Utils.showLog("liveUserId: ${BranchIoServices.liveUserId}");
//
//             BottomBarController controller;
//             if (Get.isRegistered<BottomBarController>()) {
//               controller = Get.find<BottomBarController>();
//             } else {
//               // You would need to implement proper initialization here
//               // This is just an example - adapt to your app's architecture
//               controller = Get.put(BottomBarController());
//               Utils.showLog("MultiLiveController recreated for socket connection");
//             }
//
//             controller.onChangeBottomBar(1);
//
//             // Navigate to the streaming tab first
//
//             // Check if we have the required data for live stream navigation
//             if (BranchIoServices.hasPendingLiveStreamNavigation()) {
//               Utils.showLog("Has pending live stream navigation - proceeding");
//
//               // Wait a bit longer for the streaming tab to load
//               await Future.delayed(Duration(milliseconds: 1500));
//
//               // Navigate to the live stream
//               BranchIoServices.handleLiveStreamNavigation();
//             } else {
//               Utils.showLog("Missing live stream data or no pending navigation");
//               Utils.showLog("roomId empty: ${BranchIoServices.roomId.isEmpty}");
//               Utils.showLog("liveUserId empty: ${BranchIoServices.liveUserId.isEmpty}");
//             }
//           }
//
//           log("Event Id => $eventId");
//           log("Event Type => $eventType");
//           log("referralCode $referralCode");
//         }
//       },
//       onError: (error) {
//         log('Branch Io Listen Error => ${error.toString()}');
//       },
//     );
//     log("Stream Subscription => $streamSubscription");
//   }
//
//   // Check if we have pending live stream navigation
//   static bool hasPendingLiveStreamNavigation() {
//     return _isHandlingDeepLink && eventType == "LiveStream" && roomId.isNotEmpty && liveUserId.isNotEmpty;
//   }
//
//   // Handle navigation to live stream page
//   static void handleLiveStreamNavigation() {
//     log("handleLiveStreamNavigation called");
//     log("roomId: $roomId");
//     log("liveUserId: $liveUserId");
//     log("eventType: $eventType");
//     log("_isHandlingDeepLink: $_isHandlingDeepLink");
//
//     if (!_isHandlingDeepLink || eventType != "LiveStream") {
//       log("No pending live stream navigation");
//       return;
//     }
//
//     if (roomId.isEmpty || liveUserId.isEmpty) {
//       log("Missing required live stream data: roomId=$roomId, liveUserId=$liveUserId");
//       return;
//     }
//
//     log("requestedList>length>>>>>>>>${requestedList.length}");
//     log("TEST roomId>>>>>>>>>${roomId}");
//     log("TEST liveUserId>>>>>>>>>${liveUserId}");
//     log("TEST liveUserObjId>>>>>>>>>${liveUserObjId}");
//     log("TEST image>>>>>>>>>${image}");
//     log("TEST name>>>>>>>>>${name}");
//     log("TEST username>>>>>>>>>${username}");
//     log("TEST isFollow>>>>>>>>>${isFollow}");
//     log("TEST isHost>>>>>>>>>${isHost}");
//     log("TEST isProfileImageBanned>>>>>>>>>${isProfileImageBanned}");
//     log("TEST host2Channel>>>>>>>>>${host2Channel}");
//     log("TEST host1WinnerPoint>>>>>>>>>${host1WinnerPoint}");
//     log("TEST host2WinnerPoint>>>>>>>>>${host2WinnerPoint}");
//     log("TEST liveType>>>>>>>>>${liveType}");
//
//     try {
//       // Create LiveUserList object
//       final liveUserList = LiveUserObject(
//         // requested: requestedList,
//         liveHistoryId: roomId,
//         userId: liveUserId,
//         image: image,
//         name: name,
//         userName: username,
//         isFollow: isFollow,
//         id: liveUserObjId,
//         // liveType: liveType,
//         host2Channel: host2Channel,
//         // host1WinnerPoint: host1WinnerPoint,
//         // host2WinnerPoint: host2WinnerPoint,
//         isProfileImageBanned: isProfileImageBanned,
//         // isHostCameraEnabled: true,
//       );
//
//       log("Navigating to MultiLivePageView...");
//
//       // Clear the flag before navigation
//       _isHandlingDeepLink = false;
//
//       // Use Get.off to replace current page or Get.to to push new page
//       Get.to(
//         () => MultiLivePageView(
//           isHost: false, // Always false for deep link joins
//           userId: "",
//           liveHistoryId: "",
//           liveUserObjId: "",
//         ),
//       )?.then((value) {
//         log("Navigation completed successfully");
//         // Clear data after successful navigation
//         clearLiveStreamData();
//       }).catchError((error) {
//         log("Error navigating to MultiLivePageView: $error");
//         // Reset flag on error
//         _isHandlingDeepLink = false;
//       });
//     } catch (e) {
//       log("Exception in handleLiveStreamNavigation: $e");
//       _isHandlingDeepLink = false;
//     }
//   }
//
//   static Future<void> onCreateBranchIoLink({
//     required String pageRoutes,
//     required String id,
//     required String name,
//     required String image,
//     required String userId,
//     String? referralCode,
//     // Additional parameters for live streaming
//     String? roomId,
//     String? liveUserId,
//     String? liveUserObjId,
//     String? liveType,
//     bool? isHost,
//     bool? isFollow,
//     bool? isProfileImageBanned,
//     String? host2Channel,
//     String? username,
//     int? host1WinnerPoint,
//     int? host2WinnerPoint,
//     List<Requested>? requestedList,
//   }) async {
//     branchContentMetaData = BranchContentMetaData()
//       ..addCustomMetadata("pageRoutes", pageRoutes)
//       ..addCustomMetadata("id", id)
//       ..addCustomMetadata("name", name)
//       ..addCustomMetadata("image", image)
//       ..addCustomMetadata('userId', userId);
//
//     // Add referral code if provided
//     if (referralCode != null && referralCode.isNotEmpty) {
//       branchContentMetaData.addCustomMetadata('referralCode', referralCode);
//     }
//
//     // Add live streaming metadata if available
//     if (pageRoutes == "LiveStream") {
//       branchContentMetaData
//         ..addCustomMetadata('roomId', roomId ?? "")
//         ..addCustomMetadata('liveUserId', liveUserId ?? "")
//         ..addCustomMetadata('liveUserObjId', liveUserObjId ?? "")
//         ..addCustomMetadata('liveType', liveType?.toString() ?? "0")
//         ..addCustomMetadata('username', username ?? "")
//         ..addCustomMetadata('isHost', (isHost ?? false).toString())
//         ..addCustomMetadata('isFollow', (isFollow ?? false).toString())
//         ..addCustomMetadata('isProfileImageBanned', (isProfileImageBanned ?? false).toString())
//         ..addCustomMetadata('host2Channel', host2Channel ?? "")
//         ..addCustomMetadata('host1WinnerPoint', (host1WinnerPoint ?? 0).toString())
//         ..addCustomMetadata('host2WinnerPoint', (host2WinnerPoint ?? 0).toString());
//
//       if (requestedList != null && requestedList.isNotEmpty) {
//         try {
//           // Convert each Requested object to a map first, then to JSON
//           final List<Map<String, dynamic>> requestedListMaps = requestedList.map((r) => r.toJson()).toList();
//           final requestedListJson = jsonEncode(requestedListMaps);
//           branchContentMetaData.addCustomMetadata('requestedList', requestedListJson);
//           log("Added requestedList to branch metadata: ${requestedList.length} items");
//         } catch (e) {
//           log("Error encoding requestedList: $e");
//         }
//       }
//     }
//
//     branchUniversalObject = BranchUniversalObject(
//       canonicalIdentifier: 'flutter/branch/${pageRoutes.toLowerCase()}',
//       canonicalUrl: 'https://flutter.dev',
//       title: name,
//       imageUrl: Api.baseUrl + image,
//       contentDescription: pageRoutes == "LiveStream" ? "Join live stream with $name" : name,
//       contentMetadata: branchContentMetaData,
//       keywords: ['Plugin', 'Branch', 'Flutter', pageRoutes],
//       publiclyIndex: true,
//       locallyIndex: true,
//       expirationDateInMilliSec: DateTime.now().add(const Duration(days: 365)).millisecondsSinceEpoch,
//     );
//
//     branchLinkProperties = BranchLinkProperties(channel: 'app', feature: 'sharing', stage: 'new share', campaign: pageRoutes.toLowerCase())
//       ..addControlParam('\$uri_redirect_mode', '1')
//       ..addControlParam('\$ios_nativelink', true)
//       ..addControlParam('\$match_duration', 7200)
//       ..addControlParam('\$always_deeplink', true)
//       ..addControlParam('\$android_redirect_timeout', 750)
//       ..addControlParam('referring_user_id', userId);
//   }
//
//   static Future<String?> onGenerateLink() async {
//     if (branchUniversalObject == null) {
//       log("Branch Universal Object is null");
//       return null;
//     }
//
//     try {
//       BranchResponse response = await FlutterBranchSdk.getShortUrl(buo: branchUniversalObject!, linkProperties: branchLinkProperties);
//       if (response.success) {
//         log("Generated Branch Io Link => ${response.result}");
//         return response.result.toString();
//       } else {
//         log("Generating Branch Io Link Failed !! => ${response.errorCode} - ${response.errorMessage}");
//         return null;
//       }
//     } catch (e) {
//       log("Exception generating Branch Io Link: $e");
//       return null;
//     }
//   }
// }

// class LiveStreamShareManager {
//   // Share the current live stream
//   static Future<void> shareLiveStream({
//     required String id,
//     required String name,
//     required String image,
//     required String roomId,
//     required String liveUserId,
//     required String liveUserObjId,
//     required String liveType,
//     required bool isHost,
//     required bool isFollow,
//     required bool isProfileImageBanned,
//     required String host2Channel,
//     required int host1WinnerPoint,
//     required int host2WinnerPoint,
//     required String username,
//     List<Requested>? requestedList,
//   }) async {
//     Utils.showLog('shareLiveStream called with requestedList?.length>>>>${requestedList?.length}');
//
//     try {
//       await BranchIoServices.onCreateBranchIoLink(
//         username: username,
//         pageRoutes: "LiveStream",
//         id: id,
//         name: name,
//         userId: liveUserId, // Use liveUserId instead of id for consistency
//         image: image,
//         roomId: roomId,
//         liveUserId: liveUserId,
//         liveUserObjId: liveUserObjId,
//         liveType: liveType,
//         isHost: isHost,
//         isFollow: isFollow,
//         isProfileImageBanned: isProfileImageBanned,
//         host2Channel: host2Channel,
//         host1WinnerPoint: host1WinnerPoint,
//         host2WinnerPoint: host2WinnerPoint,
//         requestedList: requestedList,
//       );
//
//       final link = await BranchIoServices.onGenerateLink();
//       if (link != null) {
//         // await Share.share(
//         //   'Join my live stream! $link',
//         //   subject: 'Live Stream Invitation',
//         // ).then((value) {
//         //   log("Live Stream Shared Successfully !!");
//         //   SocketServices.emitShareLiveStream(liveUserId: liveUserId, liveHistoryId: roomId);
//         // });
//         ShareResult result = await Share.share(
//           'Join my live stream! $link',
//           subject: 'Live Stream Invitation',
//         );
//         if (result.status == ShareResultStatus.success) {
//           log("Live Stream Shared Successfully !!");
//           SocketServices.emitShareLiveStream(liveUserId: liveUserId, liveHistoryId: roomId);
//         }
//       } else {
//         Utils.showToast("Failed to generate sharing link");
//       }
//     } catch (e) {
//       Utils.showToast("Sharing failed: $e");
//       Utils.showLog("Sharing failed: $e");
//     }
//   }
// }
