// import 'dart:math';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:get/get.dart';
// import 'package:get/get_rx/src/rx_typedefs/rx_typedefs.dart';
// import 'package:shortie/pages/bottom_bar_page/controller/bottom_bar_controller.dart';
// import 'package:shortie/pages/profile_page/controller/profile_controller.dart';
// import 'package:shortie/routes/app_routes.dart';
// import 'package:shortie/utils/database.dart';
// import 'package:shortie/utils/utils.dart';
//
// class NotificationServices {
//   static Callback callback = () {};
//
//   static FirebaseMessaging messaging = FirebaseMessaging.instance;
//
//   static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
//
//   static Future<void> init() async {
//     // This Method Call in Main...
//     var androidInitializationSettings = const AndroidInitializationSettings('@mipmap/shortie_notification_icon');
//
//     final DarwinInitializationSettings initializationSettingsDarwin = DarwinInitializationSettings();
//
//     final initializationSettings = InitializationSettings(android: androidInitializationSettings, iOS: initializationSettingsDarwin);
//
//     await _flutterLocalNotificationsPlugin.initialize(
//       initializationSettings,
//       onDidReceiveNotificationResponse: (payload) {
//         callback.call();
//       },
//     );
//
//     await messaging.requestPermission(
//       alert: true,
//       announcement: false,
//       badge: true,
//       carPlay: false,
//       criticalAlert: false,
//       provisional: false,
//       sound: true,
//     );
//   }
//
//   static Future<void> showNotification(RemoteMessage message) async {
//     AndroidNotificationChannel channel = AndroidNotificationChannel(
//       Random.secure().nextInt(100000).toString(),
//       "High Importance Notification",
//       importance: Importance.max,
//     );
//
//     AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
//       playSound: true,
//       channel.id,
//       channel.name,
//       channelDescription: "your channel description",
//       // importance: Importance.high,
//       priority: Priority.high,
//       ticker: "ticker",
//       enableVibration: true,
//       icon: "@mipmap/shortie_notification_icon",
//     );
//
//     DarwinNotificationDetails darwinNotificationDetails = const DarwinNotificationDetails(
//       presentAlert: true,
//       presentBadge: true,
//       presentSound: true,
//     );
//
//     NotificationDetails notificationDetails = NotificationDetails(
//       android: androidNotificationDetails,
//       iOS: darwinNotificationDetails,
//     );
//
//     _flutterLocalNotificationsPlugin.show(
//       Random.secure().nextInt(100000),
//       message.notification?.title.toString(),
//       message.notification?.body.toString(),
//       notificationDetails,
//     );
//   }
//
//   static Future<void> firebaseInit() async {
//     // This Method Call in Main...
//     FirebaseMessaging.onMessage.listen(
//       (message) {
//         Utils.showLog("Local Notification => Is Show Notification => ${Database.isShowNotification} => Is App Open => ${Utils.isAppOpen}");
//         Utils.showLog("Notification => ${message.data}");
//         Utils.showLog("Notification Title => ${message.notification?.title.toString()}");
//         Utils.showLog("Notification Body => ${message.notification?.body.toString()}");
//
//         if (Database.isShowNotification && Utils.isAppOpen.value) {
//           showNotification(message);
//           callback = () async {
//             try {
//               if (message.data["type"] == "CHAT") {
//                 debugPrint("Click To Chat Notification");
//                 Get.offAllNamed(AppRoutes.bottomBarPage);
//                 await 1.seconds.delay();
//                 final bottomBarController = Get.find<BottomBarController>();
//                 bottomBarController.onChangeBottomBar(3); // Go To Chat Page...
//               } else if (message.data["type"] == "VIDEOLIKE") {
//                 debugPrint("Click To Video Like Notification");
//                 Get.offAllNamed(AppRoutes.bottomBarPage);
//                 await 1.seconds.delay();
//                 final bottomBarController = Get.find<BottomBarController>();
//                 bottomBarController.onChangeBottomBar(4); // Go To Profile Page...
//               } else if (message.data["type"] == "LIVE") {
//                 debugPrint("Click To Live Notification");
//                 Get.offAllNamed(AppRoutes.bottomBarPage);
//                 await 1.seconds.delay();
//                 final bottomBarController = Get.find<BottomBarController>();
//                 bottomBarController.onChangeBottomBar(1); // Go To Stream Page...
//               } else if (message.data["type"] == "FOLLOW") {
//                 debugPrint("Click To Follow Notification");
//                 Get.offAllNamed(AppRoutes.bottomBarPage);
//                 await 1.seconds.delay();
//                 final bottomBarController = Get.find<BottomBarController>();
//                 bottomBarController.onChangeBottomBar(4); // Go To Profile Page...
//               } else if (message.data["type"] == "GIFT") {
//                 debugPrint("Click To Gift Notification");
//                 Get.offAllNamed(AppRoutes.bottomBarPage);
//                 await 1.seconds.delay();
//                 final bottomBarController = Get.find<BottomBarController>();
//                 bottomBarController.onChangeBottomBar(4); // Go To Profile Page...
//                 final profileController = Get.find<ProfileController>();
//                 await 1.seconds.delay();
//                 profileController.tabController?.index = 2;
//               }
//             } catch (e) {
//               Utils.showLog("Notification Change Routes Failed => ${e}");
//             }
//           };
//         }
//       },
//     );
//   }
//
//   static Future<void> onShowBackgroundNotification(RemoteMessage message) async {
//     Utils.showLog("Background Notification => Is Show Notification => ${Database.isShowNotification} => Is App Open => ${Utils.isAppOpen} => ${message.messageId}");
//     // if (Database.isShowNotification && Utils.isAppOpen.value == false) {
//     //   showNotification(message);
//     // }
//   }
//
//   static Future<void> showUploadProgressNotification({
//     required int notificationId,
//     required String title,
//     required String body,
//     required int progress,
//     required bool isCompleted,
//   }) async {
//     const String channelId = 'upload_progress';
//     const String channelName = 'Upload Progress';
//
//     const AndroidNotificationChannel channel = AndroidNotificationChannel(
//       channelId,
//       channelName,
//       importance: Importance.max,
//       playSound: true,
//       enableVibration: true,
//     );
//
//     await _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);
//
//     final AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
//       channelId,
//       channelName,
//       channelDescription: 'Video Upload Process',
//       importance: Importance.max,
//       audioAttributesUsage: AudioAttributesUsage.notificationRingtone,
//       category: AndroidNotificationCategory.event,
//       enableVibration: true,
//       ticker: "Test",
//       visibility: NotificationVisibility.public,
//       priority: Priority.high,
//       onlyAlertOnce: true,
//       showProgress: true,
//       progress: progress.clamp(0, 100),
//       maxProgress: 100,
//       ongoing: !isCompleted,
//       autoCancel: isCompleted,
//       playSound: true,
//       icon: '@mipmap/shortie_notification_icon',
//     );
//
//     final DarwinNotificationDetails darwinNotificationDetails = DarwinNotificationDetails(
//       presentAlert: true,
//       presentBadge: true,
//       presentSound: true,
//       sound: 'notification_sound.aiff', // iOS sound file
//       subtitle: 'Upload Progress', // Subtitle
//       threadIdentifier: 'video-upload', // Thread ID
//       badgeNumber: isCompleted ? 1 : null, // Badge when complete
//       attachments: null,
//       interruptionLevel: isCompleted ? InterruptionLevel.timeSensitive : InterruptionLevel.passive,
//     );
//
//     final NotificationDetails notificationDetails = NotificationDetails(
//       android: androidNotificationDetails,
//       iOS: darwinNotificationDetails,
//     );
//
//     await _flutterLocalNotificationsPlugin.show(
//       notificationId,
//       title,
//       body,
//       notificationDetails,
//     );
//   }
//
//   static Future<void> cancelUploadNotification(int notificationId) async {
//     await _flutterLocalNotificationsPlugin.cancel(notificationId);
//   }
// }

import 'dart:math';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_typedefs/rx_typedefs.dart';
import 'package:shortie/pages/bottom_bar_page/controller/bottom_bar_controller.dart';
import 'package:shortie/pages/profile_page/controller/profile_controller.dart';
import 'package:shortie/routes/app_routes.dart';
import 'package:shortie/utils/database.dart';
import 'package:shortie/utils/utils.dart';

class NotificationServices {
  static Callback callback = () {};

  static FirebaseMessaging messaging = FirebaseMessaging.instance;

  static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  // Chat notification channel માટે separate channel ID
  static const String _chatChannelId = 'chat_notifications';
  static const String _generalChannelId = 'general_notifications';

  static Future<void> init() async {
    // Android Initialization Settings
    var androidInitializationSettings = const AndroidInitializationSettings('@mipmap/shortie_notification_icon');

    // iOS Initialization Settings
    final DarwinInitializationSettings initializationSettingsDarwin = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    final initializationSettings = InitializationSettings(
      android: androidInitializationSettings,
      iOS: initializationSettingsDarwin,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) {
        debugPrint('Notification clicked: ${notificationResponse.payload}');
        callback.call();
      },
    );

    // Firebase Messaging Permission Request
    await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    // Notification channels create કરવા
    await _createNotificationChannels();
  }

  // Notification channels create કરવા માટે
  static Future<void> _createNotificationChannels() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
    _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      // Chat notifications માટે channel
      final AndroidNotificationChannel chatChannel = AndroidNotificationChannel(
        _chatChannelId,
        'Chat Messages',
        description: 'Notifications for new chat messages',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
        showBadge: true,
      );

      // General notifications માટે channel
      final AndroidNotificationChannel generalChannel = AndroidNotificationChannel(
        _generalChannelId,
        'General Notifications',
        description: 'General app notifications',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
        showBadge: true,
      );

      await androidImplementation.createNotificationChannel(chatChannel);
      await androidImplementation.createNotificationChannel(generalChannel);
    }
  }

  static Future<void> showNotification(RemoteMessage message) async {
    // Message type check કરીને appropriate channel use કરવું
    String channelId = _generalChannelId;
    String channelName = 'General Notifications';

    if (message.data['type'] == 'CHAT') {
      channelId = _chatChannelId;
      channelName = 'Chat Messages';
    }

    AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: message.data['type'] == 'CHAT'
          ? 'New chat message received'
          : 'Your channel description',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'ticker',
      enableVibration: true,
      playSound: true,
      icon: '@mipmap/shortie_notification_icon',
      styleInformation: message.data['type'] == 'CHAT'
          ? BigTextStyleInformation(
        message.notification?.body ?? '',
        contentTitle: message.notification?.title,
        summaryText: 'New Message',
      )
          : null,
      category: AndroidNotificationCategory.message,
      visibility: NotificationVisibility.public,
    );

    DarwinNotificationDetails darwinNotificationDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      badgeNumber: 1,
      subtitle: message.data['type'] == 'CHAT' ? 'New Message' : null,
      threadIdentifier: message.data['type'] == 'CHAT' ? 'chat-thread' : 'general-thread',
      interruptionLevel: InterruptionLevel.timeSensitive,
    );

    NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: darwinNotificationDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      Random.secure().nextInt(100000),
      message.notification?.title ?? 'New Notification',
      message.notification?.body ?? '',
      notificationDetails,
      payload: message.data['type'] ?? 'GENERAL',
    );
  }

  static Future<void> firebaseInit() async {
    // Foreground messages handle કરવા માટે
    FirebaseMessaging.onMessage.listen(
          (RemoteMessage message) {
        Utils.showLog("Local Notification => Is Show Notification => ${Database.isShowNotification} => Is App Open => ${Utils.isAppOpen}");
        Utils.showLog("Notification Data => ${message.data}");
        Utils.showLog("Notification Title => ${message.notification?.title}");
        Utils.showLog("Notification Body => ${message.notification?.body}");
        Utils.showLog("Notification Type => ${message.data['type']}");

        // નોટિફિકેશન show કરવું - condition remove કરી દીધી
        // હવે chat messages માટે પણ notification show થશે
        bool shouldShowNotification = Database.isShowNotification;

        // Chat message હોય તો always show કરવું
        if (message.data['type'] == 'CHAT') {
          shouldShowNotification = true;
          Utils.showLog("Chat notification - forcing display");
        }

        if (shouldShowNotification) {
          showNotification(message);

          // Callback setup કરવું
          callback = () async {
            try {
              await _handleNotificationClick(message);
            } catch (e) {
              Utils.showLog("Notification Navigation Failed => $e");
            }
          };
        }
      },
    );

    // Background/Terminated notification clicks handle કરવા માટે
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      Utils.showLog("Notification opened from background: ${message.data}");
      _handleNotificationClick(message);
    });

    // Check if app was opened from terminated state via notification
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        Utils.showLog("App opened from terminated state: ${message.data}");
        Future.delayed(const Duration(seconds: 2), () {
          _handleNotificationClick(message);
        });
      }
    });
  }

  // Notification click handling માટે separate method
  static Future<void> _handleNotificationClick(RemoteMessage message) async {
    try {
      String notificationType = message.data['type'] ?? '';

      Utils.showLog("Handling notification click: $notificationType");

      switch (notificationType) {
        case 'CHAT':
          debugPrint("Click To Chat Notification");
          Get.offAllNamed(AppRoutes.bottomBarPage);
          await 1.seconds.delay();
          final bottomBarController = Get.find<BottomBarController>();
          bottomBarController.onChangeBottomBar(3); // Go To Chat Page

          // જો specific chat ID હોય તો એ chat open કરો
          if (message.data.containsKey('chatId')) {
            String chatId = message.data['chatId'];
            // Chat page પર specific chat open કરવા માટે
            // તમારા chat controller માં method call કરો
            debugPrint("Opening chat: $chatId");
          }
          break;

        case 'VIDEOLIKE':
          debugPrint("Click To Video Like Notification");
          Get.offAllNamed(AppRoutes.bottomBarPage);
          await 1.seconds.delay();
          final bottomBarController = Get.find<BottomBarController>();
          bottomBarController.onChangeBottomBar(4); // Go To Profile Page
          break;

        case 'LIVE':
          debugPrint("Click To Live Notification");
          Get.offAllNamed(AppRoutes.bottomBarPage);
          await 1.seconds.delay();
          final bottomBarController = Get.find<BottomBarController>();
          bottomBarController.onChangeBottomBar(1); // Go To Stream Page
          break;

        case 'FOLLOW':
          debugPrint("Click To Follow Notification");
          Get.offAllNamed(AppRoutes.bottomBarPage);
          await 1.seconds.delay();
          final bottomBarController = Get.find<BottomBarController>();
          bottomBarController.onChangeBottomBar(4); // Go To Profile Page
          break;

        case 'GIFT':
          debugPrint("Click To Gift Notification");
          Get.offAllNamed(AppRoutes.bottomBarPage);
          await 1.seconds.delay();
          final bottomBarController = Get.find<BottomBarController>();
          bottomBarController.onChangeBottomBar(4); // Go To Profile Page
          await 1.seconds.delay();
          final profileController = Get.find<ProfileController>();
          profileController.tabController?.index = 2;
          break;

        default:
          debugPrint("Unknown notification type: $notificationType");
          Get.offAllNamed(AppRoutes.bottomBarPage);
          break;
      }
    } catch (e) {
      Utils.showLog("Notification Click Handler Failed => $e");
    }
  }

  static Future<void> onShowBackgroundNotification(RemoteMessage message) async {
    Utils.showLog("Background Notification => Message ID: ${message.messageId}");
    Utils.showLog("Background Notification Type => ${message.data['type']}");

    // Background માં પણ notification show કરવું (optional)
    // જો તમે background માં local notification show કરવા માંગો તો uncomment કરો
    // await showNotification(message);
  }

  // Chat notification માટે specific method
  static Future<void> showChatNotification({
    required String title,
    required String body,
    required String senderId,
    required String chatId,
  }) async {
    AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
      _chatChannelId,
      'Chat Messages',
      channelDescription: 'New chat message received',
      importance: Importance.high,
      priority: Priority.high,
      enableVibration: true,
      playSound: true,
      icon: '@mipmap/shortie_notification_icon',
      styleInformation: BigTextStyleInformation(
        body,
        contentTitle: title,
        summaryText: 'New Message',
      ),
      category: AndroidNotificationCategory.message,
      visibility: NotificationVisibility.public,
    );

    DarwinNotificationDetails darwinNotificationDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      badgeNumber: 1,
      subtitle: 'New Message',
      threadIdentifier: 'chat-thread',
      interruptionLevel: InterruptionLevel.timeSensitive,
    );

    NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: darwinNotificationDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      Random.secure().nextInt(100000),
      title,
      body,
      notificationDetails,
      payload: 'CHAT:$chatId',
    );
  }

  static Future<void> showUploadProgressNotification({
    required int notificationId,
    required String title,
    required String body,
    required int progress,
    required bool isCompleted,
  }) async {
    const String channelId = 'upload_progress';
    const String channelName = 'Upload Progress';

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      channelId,
      channelName,
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    );

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    final AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: 'Video Upload Process',
      importance: Importance.max,
      audioAttributesUsage: AudioAttributesUsage.notificationRingtone,
      category: AndroidNotificationCategory.event,
      enableVibration: true,
      ticker: "Test",
      visibility: NotificationVisibility.public,
      priority: Priority.high,
      onlyAlertOnce: true,
      showProgress: true,
      progress: progress.clamp(0, 100),
      maxProgress: 100,
      ongoing: !isCompleted,
      autoCancel: isCompleted,
      playSound: true,
      icon: '@mipmap/shortie_notification_icon',
    );

    final DarwinNotificationDetails darwinNotificationDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'notification_sound.aiff',
      subtitle: 'Upload Progress',
      threadIdentifier: 'video-upload',
      badgeNumber: isCompleted ? 1 : null,
      attachments: null,
      interruptionLevel: isCompleted ? InterruptionLevel.timeSensitive : InterruptionLevel.passive,
    );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: darwinNotificationDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      notificationId,
      title,
      body,
      notificationDetails,
    );
  }

  static Future<void> cancelUploadNotification(int notificationId) async {
    await _flutterLocalNotificationsPlugin.cancel(notificationId);
  }

  // All notifications cancel કરવા માટે
  static Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  // Badge count update કરવા માટે (iOS)
  static Future<void> updateBadgeCount(int count) async {
    if (GetPlatform.isIOS) {
      await messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }
}