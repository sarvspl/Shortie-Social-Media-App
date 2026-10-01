import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:shortie/custom/custom_image_picker.dart';
import 'package:shortie/pages/chat_page/model/fetch_user_chat_model.dart';
import 'package:shortie/ui/image_picker_bottom_sheet_ui.dart';
import 'package:shortie/utils/database.dart';
import 'package:shortie/utils/enums.dart';
import 'package:shortie/utils/utils.dart';

class FakeChatController extends GetxController {
  // Get Argument Variables...

  String receiverUserId = "";
  String receiverName = "";
  String receiverUserName = "";
  String receiverImage = "";
  bool receiverIsBlueTik = false;

  // Get Argument Variables...

  ScrollController scrollController = ScrollController();
  TextEditingController messageController = TextEditingController();
  FetchUserChatModel? fetchUserChatModel;
  List<Chat> userChats = [];
  bool isLoading = false;

  AudioRecorder audioRecorder = AudioRecorder();

  bool isRecordingAudio = false;

  RxBool isSendingAudioFile = false.obs;

  String currentPlayAudioId = ""; // This is use to one time only one play audio...

  Timer? timer;

  @override
  void onInit() {
    Utils.showLog("Chat Controller Initialize Success");

    receiverUserId = Get.arguments["id"] ?? "";
    receiverName = Get.arguments["name"] ?? "";
    receiverUserName = Get.arguments["userName"] ?? "";
    receiverImage = Get.arguments["image"] ?? "";
    receiverIsBlueTik = Get.arguments["isBlueTik"] ?? false;

    Utils.showLog("Receiver User Id => ${receiverUserId}");

    init();

    super.onInit();
  }

  Future<void> init() async {
    userChats.clear();
    isLoading = true;
    update(["onGetUserChats"]);

    userChats.addAll(fakeChatData);

    // ❌ REMOVE shuffle (this breaks order)
    // userChats.shuffle();

    await 1.seconds.delay();

    isLoading = false;
    update(["onGetUserChats"]);
    // scrollToBottomFully();
  }


  @override
  void onClose() {
    userChats.clear();
    Utils.showLog("Chat Controller Dispose Success");
    super.onClose();
  }


  ///
  bool showStickyHeader = false;
  Timer? _headerTimer;

  void onUserScroll() {
    showStickyHeader = true;

    _headerTimer?.cancel();
    _headerTimer = Timer(const Duration(seconds: 1), () {
      showStickyHeader = false;
      update(["stickyHeader"]);
    });
  }

  bool _scrollingToBottom = false;

  Future<void> scrollToBottomFully() async {
    if (_scrollingToBottom) return;
    if (!scrollController.hasClients) return;

    _scrollingToBottom = true;

    double lastMax = 0;

    while (true) {
      await Future.delayed(const Duration(milliseconds: 60));

      if (!scrollController.hasClients) break;

      final maxScroll = scrollController.position.maxScrollExtent;
      final current = scrollController.offset;

      // scroll only if not reached bottom
      if ((maxScroll - current).abs() < 2) {
        break;
      }

      // avoid infinite loop
      if (maxScroll == lastMax) {
        scrollController.jumpTo(maxScroll);
        break;
      }

      lastMax = maxScroll;

      await scrollController.animateTo(
        maxScroll,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
      );
    }

    _scrollingToBottom = false;
  }

  ///

  // >>>>> >>>>> >>>>> Get User Chat <<<<< <<<<< <<<<<

  void scrollToBottom1() {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> onScrollDown1() async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (scrollController.hasClients) {
      scrollController.jumpTo(scrollController.position.maxScrollExtent);
    }
  }

  Future<void> onInitScrollDown1() async {
    await Future.delayed(const Duration(seconds: 5));
    if (scrollController.hasClients) {
      scrollController.animateTo(scrollController.position.maxScrollExtent,duration: Duration(milliseconds: 100),curve: Curves.easeInOut);
    }
  }

  Future<void> onClickSend() async {
    if (messageController.text.trim().isNotEmpty) {
      final newMessage = Chat(
        id: (Random().nextInt(900000) + 100000).toString(),
        chatTopicId: "0001",
        createdAt: DateTime.now().toString(),
        senderUserId: Database.loginUserId,
        message: messageController.text.trim(),
        image: "",
        audio: "",
        isRead: true,
        messageType: 1,
        date: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      );

      userChats.add(newMessage);
      update(["onGetUserChats"]);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        scrollToBottomFully();
      });

      messageController.clear();
    }
  }

  Future<void> onClickImage(BuildContext context) async {
    FocusManager.instance.primaryFocus?.unfocus();

    await ImagePickerBottomSheetUi.show(
      context: context,
      onClickCamera: () async {
        final imagePath = await CustomImagePicker.pickImage(ImageSource.camera);

        if (imagePath != null) {
          onStaticInsertImage(imagePath);
        }
      },
      onClickGallery: () async {
        final imagePath = await CustomImagePicker.pickImage(ImageSource.gallery);

        if (imagePath != null) {
          onStaticInsertImage(imagePath);
        }
      },
    );
  }

  Future<void> onStaticInsertImage(String imagePath) async {
    userChats.add(
      Chat(
        id: (Random().nextInt(900000) + 100000).toString(),
        chatTopicId: "0001",
        messageType: 2,
        createdAt: DateTime.now().toString(),
        senderUserId: Database.loginUserId,
        message: "",
        image: imagePath,
        audio: "",
        isRead: true,
        date: "2024-08-01T10:10:00Z",
        updatedAt: "2024-08-01T10:10:00Z",
      ),
    ); // Static Show...
    update(["onGetUserChats"]);
    scrollToBottomFully();
  }

  Future<void> onStartAudioRecording() async {
    Utils.showLog("Audio Recording Start");
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String filePath = "${appDocDir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a";

    await audioRecorder.start(const RecordConfig(), path: filePath);
    isRecordingAudio = true;
    update(["onChangeAudioRecordingEvent"]);
    onChangeTimer();
  }

  Future<void> onLongPressStartMic() async {
    FocusManager.instance.primaryFocus?.unfocus();
    PermissionStatus status = await Permission.microphone.status;

    if (status.isDenied) {
      PermissionStatus request = await Permission.microphone.request();

      if (request == PermissionStatus.denied) {
        Utils.showToast(EnumLocal.txtPleaseAllowPermission.name.tr);
      }
    } else {
      Utils.showLog("Audio Recording Started...");
      onStartAudioRecording();
    }
  }

  Future<void> onLongPressEndMic() async {
    PermissionStatus status = await Permission.microphone.status;

    if (isRecordingAudio && status.isGranted) {
      onStopAudioRecording();
    }
  }

  Future<void> onStopAudioRecording() async {
    try {
      Utils.showLog("Audio Recording Stop");

      isSendingAudioFile.value = true;

      final audioPath = await audioRecorder.stop();

      isRecordingAudio = false;
      update(["onChangeAudioRecordingEvent"]);
      onChangeTimer();

      Utils.showLog("Recording Audio Path => $audioPath");

      if (audioPath != null) {
        userChats.add(
          Chat(
            id: (Random().nextInt(900000) + 100000).toString(),
            chatTopicId: "0001",
            messageType: 3,
            createdAt: DateTime.now().toString(),
            senderUserId: Database.loginUserId,
            message: "",
            image: "",
            audio: audioPath,
            isRead: true,
            date: "2024-08-01T10:10:00Z",
            updatedAt: "2024-08-01T10:10:00Z",
          ),
        ); // Static Show...

        update(["onGetUserChats"]);
        scrollToBottomFully();
      }
      isSendingAudioFile.value = false;
    } catch (e) {
      isSendingAudioFile.value = false;
      Utils.showLog("Audio Recording Stop Failed => $e");
    }
  }

  int countTime = 0;

  Future<void> onChangeTimer() async {
    if (isRecordingAudio && countTime == 0) {
      timer = Timer.periodic(
        const Duration(seconds: 1),
        (timer) async {
          countTime++;
          update(["onChangeAudioRecordingEvent"]);
          if (isRecordingAudio == false) {
            countTime = 0;
            this.timer?.cancel();
            update(["onChangeAudioRecordingEvent"]);
          }
        },
      );
    } else {
      countTime = 0;
      timer?.cancel();
      update(["onChangeAudioRecordingEvent"]);
    }
  }
  @override
  void onReady() {
    super.onReady();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollWhenControllerReady();
    });
  }

  Future<void> scrollWhenControllerReady() async {
    int retry = 0;

    while (retry < 20) {
      await Future.delayed(const Duration(milliseconds: 100));

      if (scrollController.hasClients) {
        await scrollToBottomFully();
        return;
      }

      retry++;
    }

    // last force attempt
    if (scrollController.hasClients) {
      scrollController.jumpTo(
        scrollController.position.maxScrollExtent,
      );
    }
  }



  // Future<void> onScrollDown() async {
  //   try {
  //     await 10.milliseconds.delay();
  //     scrollController.animateTo(
  //       scrollController.position.maxScrollExtent,
  //       duration: Duration(seconds: 1),
  //       curve: Curves.fastOutSlowIn,
  //     );
  //     await 10.milliseconds.delay();
  //     scrollController.animateTo(
  //       scrollController.position.maxScrollExtent,
  //       duration: Duration(seconds: 1),
  //       curve: Curves.fastOutSlowIn,
  //     );
  //   } catch (e) {
  //     Utils.showLog("Scroll Down Failed => $e");
  //   }
  // }

  // List<Chat> fakeChatData = [
  //   Chat(
  //     id: "1",
  //     chatTopicId: "201",
  //     senderUserId: "sender001",
  //     message: "Hello! How are you?",
  //     image: "https://images.pexels.com/photos/1642228/pexels-photo-1642228.jpeg",
  //     audio: "",
  //     isRead: true,
  //     date: "2024-08-01T10:00:00Z",
  //     messageType: 2,
  //     createdAt: "2024-08-01T10:00:00Z",
  //     updatedAt: "2024-08-01T10:00:00Z",
  //   ),
  //   Chat(
  //     id: "2",
  //     chatTopicId: "201",
  //     senderUserId: Database.loginUserId,
  //     message: "I'm good, thanks! What about you?",
  //     image: "https://images.pexels.com/photos/1642228/pexels-photo-1642228.jpeg",
  //     audio: "http://commondatastorage.googleapis.com/codeskulptor-assets/Evillaugh.ogg",
  //     isRead: false,
  //     date: "2024-08-01T10:05:00Z",
  //     messageType: 3,
  //     createdAt: "2024-08-01T10:05:00Z",
  //     updatedAt: "2024-08-01T10:05:00Z",
  //   ),
  //   Chat(
  //     id: "3",
  //     chatTopicId: "202",
  //     senderUserId: "sender002",
  //     message: "Let's catch up later.",
  //     image: "https://emoji.aranja.com/static/emoji-data/img-apple-160/1f917.png",
  //     audio: "",
  //     isRead: true,
  //     storyId: StoryId(mediaImageUrl: "https://images.pexels.com/photos/1642228/pexels-photo-1642228.jpeg"),
  //     date: "2024-08-01T10:10:00Z",
  //     messageType: 4,
  //     createdAt: "2024-08-01T10:10:00Z",
  //     updatedAt: "2024-08-01T10:10:00Z",
  //   ),
  //   Chat(
  //     id: "4",
  //     chatTopicId: "202",
  //     senderUserId: Database.loginUserId,
  //     message: "Sure, what time works for you?",
  //     image: "https://images.pexels.com/photos/1642228/pexels-photo-1642228.jpeg",
  //     audio: "",
  //     isRead: false,
  //     date: "2024-08-01T10:15:00Z",
  //     messageType: 5,
  //     storyId: StoryId(mediaImageUrl: "https://images.pexels.com/photos/1642228/pexels-photo-1642228.jpeg"),
  //     createdAt: "2024-08-01T10:15:00Z",
  //     updatedAt: "2024-08-01T10:15:00Z",
  //   ),
  //   Chat(
  //     id: "5",
  //     chatTopicId: "203",
  //     senderUserId: "sender003",
  //     message: "Are you coming to the meeting?",
  //     image: "https://images.pexels.com/photos/1642228/pexels-photo-1642228.jpeg",
  //     audio: "",
  //     isRead: true,
  //     date: "2024-08-01T10:20:00Z",
  //     messageType: 4,
  //     createdAt: "2024-08-01T10:20:00Z",
  //     updatedAt: "2024-08-01T10:20:00Z",
  //   ),
  // ];

  // List<Chat> fakeChatData = [
  //   Chat(
  //     id: "1",
  //     chatTopicId: "201",
  //     senderUserId: "sender001",
  //     message: "Hello! How are you?",
  //     image: "https://images.pexels.com/photos/1642228/pexels-photo-1642228.jpeg",
  //     audio: "",
  //     isRead: true,
  //     date: "2024-08-01T10:00:00Z",
  //     messageType: 2,
  //     createdAt: "2024-08-01T10:00:00Z",
  //     updatedAt: "2024-08-01T10:00:00Z",
  //   ),
  //   Chat(
  //     id: "2",
  //     chatTopicId: "201",
  //     senderUserId: Database.loginUserId,
  //     message: "I'm good, thanks! What about you?",
  //     image: "https://images.pexels.com/photos/674010/pexels-photo-674010.jpeg",
  //     audio: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3", // 8-second audio
  //     isRead: false,
  //     date: "2024-08-01T10:05:00Z",
  //     messageType: 3,
  //     createdAt: "2024-08-01T10:05:00Z",
  //     updatedAt: "2024-08-01T10:05:00Z",
  //   ),
  //   Chat(
  //     id: "3",
  //     chatTopicId: "202",
  //     senderUserId: "sender002",
  //     message: "Let's catch up later.",
  //     image: "https://emoji.aranja.com/static/emoji-data/img-apple-160/1f917.png",
  //     audio: "",
  //     isRead: true,
  //     storyId: StoryId(mediaImageUrl: "https://images.pexels.com/photos/1181263/pexels-photo-1181263.jpeg"),
  //     date: "2024-08-01T10:10:00Z",
  //     messageType: 4,
  //     createdAt: "2024-08-01T10:10:00Z",
  //     updatedAt: "2024-08-01T10:10:00Z",
  //   ),
  //   Chat(
  //     id: "4",
  //     chatTopicId: "202",
  //     senderUserId: Database.loginUserId,
  //     message: "Sure, what time works for you?",
  //     image: "https://images.pexels.com/photos/1559086/pexels-photo-1559086.jpeg",
  //     audio: "",
  //     isRead: false,
  //     date: "2024-08-01T10:15:00Z",
  //     messageType: 5,
  //     storyId: StoryId(mediaImageUrl: "https://images.pexels.com/photos/206359/pexels-photo-206359.jpeg"),
  //     createdAt: "2024-08-01T10:15:00Z",
  //     updatedAt: "2024-08-01T10:15:00Z",
  //   ),
  //   Chat(
  //     id: "5",
  //     chatTopicId: "203",
  //     senderUserId: "sender003",
  //     message: "Are you coming to the meeting?",
  //     image: "https://images.pexels.com/photos/1642228/pexels-photo-1642228.jpeg",
  //     audio: "",
  //     isRead: true,
  //     date: "2024-08-01T10:20:00Z",
  //     messageType: 4,
  //     createdAt: "2024-08-01T10:20:00Z",
  //     updatedAt: "2024-08-01T10:20:00Z",
  //   ),
  //   Chat(
  //     id: "6",
  //     chatTopicId: "203",
  //     senderUserId: Database.loginUserId,
  //     message: "Yes, I'll be there at 2pm",
  //     image: "",
  //     audio: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3", // 9-second audio
  //     isRead: false,
  //     date: "2024-08-01T10:25:00Z",
  //     messageType: 3,
  //     createdAt: "2024-08-01T10:25:00Z",
  //     updatedAt: "2024-08-01T10:25:00Z",
  //   ),
  //   Chat(
  //     id: "7",
  //     chatTopicId: "204",
  //     senderUserId: "sender004",
  //     message: "Check out this photo!",
  //     image: "https://images.pexels.com/photos/674010/pexels-photo-674010.jpeg",
  //     audio: "",
  //     isRead: true,
  //     date: "2024-08-01T10:30:00Z",
  //     messageType: 2,
  //     createdAt: "2024-08-01T10:30:00Z",
  //     updatedAt: "2024-08-01T10:30:00Z",
  //   ),
  //   Chat(
  //     id: "8",
  //     chatTopicId: "204",
  //     senderUserId: Database.loginUserId,
  //     message: "Beautiful! Where was this taken?",
  //     image: "",
  //     audio: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3", // 7-second audio
  //     isRead: false,
  //     date: "2024-08-01T10:35:00Z",
  //     messageType: 3,
  //     createdAt: "2024-08-01T10:35:00Z",
  //     updatedAt: "2024-08-01T10:35:00Z",
  //   ),
  //   Chat(
  //     id: "9",
  //     chatTopicId: "205",
  //     senderUserId: "sender005",
  //     message: "Can you send me the files?",
  //     image: "",
  //     audio: "",
  //     isRead: true,
  //     date: "2024-08-01T10:40:00Z",
  //     messageType: 1,
  //     createdAt: "2024-08-01T10:40:00Z",
  //     updatedAt: "2024-08-01T10:40:00Z",
  //   ),
  //   Chat(
  //     id: "10",
  //     chatTopicId: "205",
  //     senderUserId: Database.loginUserId,
  //     message: "Just sent them to your email",
  //     image: "https://emoji.aranja.com/static/emoji-data/img-apple-160/1f4e7.png",
  //     audio: "",
  //     isRead: false,
  //     date: "2024-08-01T10:45:00Z",
  //     messageType: 4,
  //     createdAt: "2024-08-01T10:45:00Z",
  //     updatedAt: "2024-08-01T10:45:00Z",
  //   ),
  //   Chat(
  //     id: "11",
  //     chatTopicId: "206",
  //     senderUserId: "sender006",
  //     message: "Happy birthday! 🎉",
  //     image: "https://emoji.aranja.com/static/emoji-data/img-apple-160/1f382.png",
  //     audio: "",
  //     isRead: true,
  //     storyId: StoryId(mediaImageUrl: "https://images.pexels.com/photos/1181263/pexels-photo-1181263.jpeg"),
  //     date: "2024-08-01T10:50:00Z",
  //     messageType: 4,
  //     createdAt: "2024-08-01T10:50:00Z",
  //     updatedAt: "2024-08-01T10:50:00Z",
  //   ),
  //   Chat(
  //     id: "12",
  //     chatTopicId: "206",
  //     senderUserId: Database.loginUserId,
  //     message: "Thank you so much!",
  //     image: "",
  //     audio: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3", // 6-second audio
  //     isRead: false,
  //     date: "2024-08-01T10:55:00Z",
  //     messageType: 3,
  //     createdAt: "2024-08-01T10:55:00Z",
  //     updatedAt: "2024-08-01T10:55:00Z",
  //   ),
  //   Chat(
  //     id: "13",
  //     chatTopicId: "207",
  //     senderUserId: "sender007",
  //     message: "Did you see the news?",
  //     image: "",
  //     audio: "",
  //     isRead: true,
  //     date: "2024-08-01T11:00:00Z",
  //     messageType: 1,
  //     createdAt: "2024-08-01T11:00:00Z",
  //     updatedAt: "2024-08-01T11:00:00Z",
  //   ),
  //   Chat(
  //     id: "14",
  //     chatTopicId: "207",
  //     senderUserId: Database.loginUserId,
  //     message: "Yes, it's unbelievable!",
  //     image: "https://images.pexels.com/photos/1559086/pexels-photo-1559086.jpeg",
  //     audio: "",
  //     isRead: false,
  //     date: "2024-08-01T11:05:00Z",
  //     messageType: 5,
  //     storyId: StoryId(mediaImageUrl: "https://images.pexels.com/photos/206359/pexels-photo-206359.jpeg"),
  //     createdAt: "2024-08-01T11:05:00Z",
  //     updatedAt: "2024-08-01T11:05:00Z",
  //   ),
  //   Chat(
  //     id: "15",
  //     chatTopicId: "208",
  //     senderUserId: "sender008",
  //     message: "Can we reschedule?",
  //     image: "",
  //     audio: "",
  //     isRead: true,
  //     date: "2024-08-01T11:10:00Z",
  //     messageType: 1,
  //     createdAt: "2024-08-01T11:10:00Z",
  //     updatedAt: "2024-08-01T11:10:00Z",
  //   ),
  //   Chat(
  //     id: "16",
  //     chatTopicId: "208",
  //     senderUserId: Database.loginUserId,
  //     message: "Sure, how about tomorrow?",
  //     image: "",
  //     audio: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-5.mp3", // 5-second audio
  //     isRead: false,
  //     date: "2024-08-01T11:15:00Z",
  //     messageType: 3,
  //     createdAt: "2024-08-01T11:15:00Z",
  //     updatedAt: "2024-08-01T11:15:00Z",
  //   ),
  //   Chat(
  //     id: "17",
  //     chatTopicId: "209",
  //     senderUserId: "sender009",
  //     message: "Look at this view!",
  //     image: "https://images.pexels.com/photos/206359/pexels-photo-206359.jpeg",
  //     audio: "",
  //     isRead: true,
  //     date: "2024-08-01T11:20:00Z",
  //     messageType: 2,
  //     createdAt: "2024-08-01T11:20:00Z",
  //     updatedAt: "2024-08-01T11:20:00Z",
  //   ),
  //   Chat(
  //     id: "18",
  //     chatTopicId: "209",
  //     senderUserId: Database.loginUserId,
  //     message: "Stunning! Where is this?",
  //     image: "",
  //     audio: "",
  //     isRead: false,
  //     date: "2024-08-01T11:25:00Z",
  //     messageType: 1,
  //     createdAt: "2024-08-01T11:25:00Z",
  //     updatedAt: "2024-08-01T11:25:00Z",
  //   ),
  //   Chat(
  //     id: "19",
  //     chatTopicId: "210",
  //     senderUserId: "sender010",
  //     message: "Can you call me?",
  //     image: "https://emoji.aranja.com/static/emoji-data/img-apple-160/1f4de.png",
  //     audio: "",
  //     isRead: true,
  //     date: "2024-08-01T11:30:00Z",
  //     messageType: 4,
  //     createdAt: "2024-08-01T11:30:00Z",
  //     updatedAt: "2024-08-01T11:30:00Z",
  //   ),
  //   Chat(
  //     id: "20",
  //     chatTopicId: "210",
  //     senderUserId: Database.loginUserId,
  //     message: "Calling you now",
  //     image: "",
  //     audio: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-6.mp3", // 4-second audio
  //     isRead: false,
  //     date: "2024-08-01T11:35:00Z",
  //     messageType: 3,
  //     createdAt: "2024-08-01T11:35:00Z",
  //     updatedAt: "2024-08-01T11:35:00Z",
  //   ),
  //   Chat(
  //     id: "6",
  //     chatTopicId: "203",
  //     senderUserId: Database.loginUserId,
  //     message: "Yes, I'll be there.",
  //     image: "",
  //     audio: "",
  //     isRead: false,
  //     date: "2024-08-01T10:25:00Z",
  //     messageType: 1,
  //     createdAt: "2024-08-01T10:25:00Z",
  //     updatedAt: "2024-08-01T10:25:00Z",
  //   ),
  //   Chat(
  //     id: "7",
  //     chatTopicId: "204",
  //     senderUserId: "sender004",
  //     message: "Can you review this document?",
  //     image: "",
  //     audio: "",
  //     isRead: true,
  //     date: "2024-08-01T10:30:00Z",
  //     messageType: 1,
  //     createdAt: "2024-08-01T10:30:00Z",
  //     updatedAt: "2024-08-01T10:30:00Z",
  //   ),
  //   Chat(
  //     id: "8",
  //     chatTopicId: "204",
  //     senderUserId: Database.loginUserId,
  //     message: "I'll look at it and get back to you.",
  //     image: "",
  //     audio: "",
  //     isRead: false,
  //     date: "2024-08-01T10:35:00Z",
  //     messageType: 1,
  //     createdAt: "2024-08-01T10:35:00Z",
  //     updatedAt: "2024-08-01T10:35:00Z",
  //   ),
  //   Chat(
  //     id: "9",
  //     chatTopicId: "205",
  //     senderUserId: "sender005",
  //     message: "Lunch at 12?",
  //     image: "",
  //     audio: "",
  //     isRead: true,
  //     date: "2024-08-01T10:40:00Z",
  //     messageType: 1,
  //     createdAt: "2024-08-01T10:40:00Z",
  //     updatedAt: "2024-08-01T10:40",
  //   ),
  //   Chat(
  //     id: "10",
  //     chatTopicId: "205",
  //     senderUserId: "receiver005",
  //     message: "Sounds good. See you then!",
  //     image: "",
  //     audio: "",
  //     isRead: false,
  //     date: "2024-08-01T10:45:00Z",
  //     messageType: 1,
  //     createdAt: "2024-08-01T10:45:00Z",
  //     updatedAt: "2024-08-01T10:45:00Z",
  //   ),
  //   Chat(
  //     id: "11",
  //     chatTopicId: "206",
  //     senderUserId: "sender006",
  //     message: "Don't forget the deadline tomorrow.",
  //     image: "",
  //     audio: "",
  //     isRead: true,
  //     date: "2024-08-01T10:50:00Z",
  //     messageType: 1,
  //     createdAt: "2024-08-01T10:50:00Z",
  //     updatedAt: "2024-08-01T10:50:00Z",
  //   ),
  //   Chat(
  //     id: "12",
  //     chatTopicId: "206",
  //     senderUserId: Database.loginUserId,
  //     message: "Thanks for the reminder!",
  //     image: "",
  //     audio: "",
  //     isRead: false,
  //     date: "2024-08-01T10:55:00Z",
  //     messageType: 1,
  //     createdAt: "2024-08-01T10:55:00Z",
  //     updatedAt: "2024-08-01T10:55:00Z",
  //   ),
  //   Chat(
  //     id: "13",
  //     chatTopicId: "207",
  //     senderUserId: "sender007",
  //     message: "Are we still on for tonight?",
  //     image: "",
  //     audio: "",
  //     isRead: true,
  //     date: "2024-08-01T11:00:00Z",
  //     messageType: 1,
  //     createdAt: "2024-08-01T11:00:00Z",
  //     updatedAt: "2024-08-01T11:00:00Z",
  //   ),
  //   Chat(
  //     id: "14",
  //     chatTopicId: "207",
  //     senderUserId: Database.loginUserId,
  //     message: "Yes, see you at 7 PM.",
  //     image: "",
  //     audio: "",
  //     isRead: false,
  //     date: "2024-08-01T11:05:00Z",
  //     messageType: 1,
  //     createdAt: "2024-08-01T11:05:00Z",
  //     updatedAt: "2024-08-01T11:05:00Z",
  //   ),
  //   Chat(
  //     id: "15",
  //     chatTopicId: "208",
  //     senderUserId: "sender008",
  //     message: "Can you send me the report?",
  //     image: "",
  //     audio: "",
  //     isRead: true,
  //     date: "2024-08-01T11:10:00Z",
  //     messageType: 1,
  //     createdAt: "2024-08-01T11:10:00Z",
  //     updatedAt: "2024-08-01T11:10:00Z",
  //   ),
  //   Chat(
  //     id: "16",
  //     chatTopicId: "208",
  //     senderUserId: Database.loginUserId,
  //     message: "Sure, I'll email it to you.",
  //     image: "",
  //     audio: "",
  //     isRead: false,
  //     date: "2024-08-01T11:15:00Z",
  //     messageType: 1,
  //     createdAt: "2024-08-01T11:15:00Z",
  //     updatedAt: "2024-08-01T11:15:00Z",
  //   ),
  //   Chat(
  //     id: "17",
  //     chatTopicId: "209",
  //     senderUserId: "sender009",
  //     message: "Please update the document.",
  //     image: "",
  //     audio: "",
  //     isRead: true,
  //     date: "2024-08-01T11:20:00Z",
  //     messageType: 1,
  //     createdAt: "2024-08-01T11:20:00Z",
  //     updatedAt: "2024-08-01T11:20:00Z",
  //   ),
  //   Chat(
  //     id: "18",
  //     chatTopicId: "209",
  //     senderUserId: Database.loginUserId,
  //     message: "I will do that today.",
  //     image: "",
  //     audio: "",
  //     isRead: false,
  //     date: "2024-08-01T11:25:00Z",
  //     messageType: 1,
  //     createdAt: "2024-08-01T11:25:00Z",
  //     updatedAt: "2024-08-01T11:25",
  //   ),
  //   Chat(
  //     id: "19",
  //     chatTopicId: "210",
  //     senderUserId: "sender010",
  //     message: "Did you finish the task?",
  //     image: "",
  //     audio: "",
  //     isRead: true,
  //     date: "2024-08-01T11:30:00Z",
  //     messageType: 1,
  //     createdAt: "2024-08-01T11:30:00Z",
  //     updatedAt: "2024-08-01T11:30:00Z",
  //   ),
  //   Chat(
  //     id: "20",
  //     chatTopicId: "210",
  //     senderUserId: Database.loginUserId,
  //     message: "Yes, I just completed it.",
  //     image: "",
  //     audio: "",
  //     isRead: false,
  //     date: "2024-08-01T11:35:00Z",
  //     messageType: 1,
  //     createdAt: "2024-08-01T11:35:00Z",
  //     updatedAt: "2024-08-01T11:35:00Z",
  //   ),
  // ];

  List<Chat> fakeChatData = [
    // Message Type 1 (30 messages)

    Chat(
      id: "1",
      chatTopicId: "201",
      senderUserId: "sender001",
      message: "Hi there! How are you doing today?",
      image: "",
      audio: "",
      isRead: true,
      date: "2024-08-01T10:00:00Z",
      messageType: 1,
      createdAt: "2024-08-01T10:00:00Z",
      updatedAt: "2024-08-01T10:00:00Z",
    ),
    Chat(
      id: "2",
      chatTopicId: "201",
      senderUserId: Database.loginUserId,
      message: "I'm doing great, thanks for asking!",
      image: "",
      audio: "",
      isRead: false,
      date: "2024-08-01T10:02:00Z",
      messageType: 1,
      createdAt: "2024-08-01T10:02:00Z",
      updatedAt: "2024-08-01T10:02:00Z",
    ),
    Chat(
      id: "3",
      chatTopicId: "201",
      senderUserId: "sender002",
      message: "What are your plans for the weekend?",
      image: "",
      audio: "",
      isRead: true,
      date: "2024-08-01T10:05:00Z",
      messageType: 1,
      createdAt: "2024-08-01T10:05:00Z",
      updatedAt: "2024-08-01T10:05:00Z",
    ),
    Chat(
      id: "4",
      chatTopicId: "201",
      senderUserId: Database.loginUserId,
      message: "I'm thinking of going hiking. Want to join?",
      image: "",
      audio: "",
      isRead: false,
      date: "2024-08-01T10:07:00Z",
      messageType: 1,
      createdAt: "2024-08-01T10:07:00Z",
      updatedAt: "2024-08-01T10:07:00Z",
    ),
    Chat(
      id: "5",
      chatTopicId: "202",
      senderUserId: "sender003",
      message: "Did you see the latest episode last night?",
      image: "",
      audio: "",
      isRead: true,
      date: "2024-08-01T11:15:00Z",
      messageType: 1,
      createdAt: "2024-08-01T11:15:00Z",
      updatedAt: "2024-08-01T11:15:00Z",
    ),
    Chat(
      id: "6",
      chatTopicId: "202",
      senderUserId: Database.loginUserId,
      message: "Yes! That plot twist was amazing!",
      image: "",
      audio: "",
      isRead: true,
      date: "2024-08-01T11:18:00Z",
      messageType: 1,
      createdAt: "2024-08-01T11:18:00Z",
      updatedAt: "2024-08-01T11:18:00Z",
    ),
    Chat(
      id: "7",
      chatTopicId: "203",
      senderUserId: "sender004",
      message: "Can you help me with the project deadline?",
      image: "",
      audio: "",
      isRead: false,
      date: "2024-08-01T12:30:00Z",
      messageType: 1,
      createdAt: "2024-08-01T12:30:00Z",
      updatedAt: "2024-08-01T12:30:00Z",
    ),
    Chat(
      id: "8",
      chatTopicId: "203",
      senderUserId: Database.loginUserId,
      message: "Sure! When do you need it completed?",
      image: "",
      audio: "",
      isRead: false,
      date: "2024-08-01T12:32:00Z",
      messageType: 1,
      createdAt: "2024-08-01T12:32:00Z",
      updatedAt: "2024-08-01T12:32:00Z",
    ),
    Chat(
      id: "9",
      chatTopicId: "201",
      senderUserId: "sender001",
      message: "That sounds like a great plan!",
      image: "",
      audio: "",
      isRead: true,
      date: "2024-08-01T13:45:00Z",
      messageType: 1,
      createdAt: "2024-08-01T13:45:00Z",
      updatedAt: "2024-08-01T13:45:00Z",
    ),
    Chat(
      id: "10",
      chatTopicId: "204",
      senderUserId: "sender005",
      message: "Happy birthday! Hope you have a wonderful day!",
      image: "",
      audio: "",
      isRead: true,
      date: "2024-08-01T14:00:00Z",
      messageType: 1,
      createdAt: "2024-08-01T14:00:00Z",
      updatedAt: "2024-08-01T14:00:00Z",
    ),
    Chat(
      id: "11",
      chatTopicId: "204",
      senderUserId: Database.loginUserId,
      message: "Thank you so much! Really appreciate it 🎉",
      image: "",
      audio: "",
      isRead: true,
      date: "2024-08-01T14:02:00Z",
      messageType: 1,
      createdAt: "2024-08-01T14:02:00Z",
      updatedAt: "2024-08-01T14:02:00Z",
    ),
    Chat(
      id: "12",
      chatTopicId: "205",
      senderUserId: "sender006",
      message: "The weather is perfect for a picnic today!",
      image: "",
      audio: "",
      isRead: false,
      date: "2024-08-01T15:20:00Z",
      messageType: 1,
      createdAt: "2024-08-01T15:20:00Z",
      updatedAt: "2024-08-01T15:20:00Z",
    ),
    Chat(
      id: "13",
      chatTopicId: "205",
      senderUserId: Database.loginUserId,
      message: "I agree! Let's pack some sandwiches and go to the park.",
      image: "",
      audio: "",
      isRead: false,
      date: "2024-08-01T15:22:00Z",
      messageType: 1,
      createdAt: "2024-08-01T15:22:00Z",
      updatedAt: "2024-08-01T15:22:00Z",
    ),
    Chat(
      id: "14",
      chatTopicId: "202",
      senderUserId: "sender003",
      message: "I can't wait for next week's episode!",
      image: "",
      audio: "",
      isRead: true,
      date: "2024-08-01T16:10:00Z",
      messageType: 1,
      createdAt: "2024-08-01T16:10:00Z",
      updatedAt: "2024-08-01T16:10:00Z",
    ),
    Chat(
      id: "15",
      chatTopicId: "206",
      senderUserId: "sender007",
      message: "Good morning! Ready for another productive day?",
      image: "",
      audio: "",
      isRead: true,
      date: "2024-08-02T08:00:00Z",
      messageType: 1,
      createdAt: "2024-08-02T08:00:00Z",
      updatedAt: "2024-08-02T08:00:00Z",
    ),
    Chat(
      id: "16",
      chatTopicId: "206",
      senderUserId: Database.loginUserId,
      message: "Absolutely! Let's make today count.",
      image: "",
      audio: "",
      isRead: true,
      date: "2024-08-02T08:03:00Z",
      messageType: 1,
      createdAt: "2024-08-02T08:03:00Z",
      updatedAt: "2024-08-02T08:03:00Z",
    ),
    Chat(
      id: "17",
      chatTopicId: "203",
      senderUserId: "sender004",
      message: "By Friday afternoon would be perfect.",
      image: "",
      audio: "",
      isRead: false,
      date: "2024-08-02T09:15:00Z",
      messageType: 1,
      createdAt: "2024-08-02T09:15:00Z",
      updatedAt: "2024-08-02T09:15:00Z",
    ),
    Chat(
      id: "18",
      chatTopicId: "207",
      senderUserId: "sender008",
      message: "Don't forget about the meeting at 3 PM today.",
      image: "",
      audio: "",
      isRead: true,
      date: "2024-08-02T10:30:00Z",
      messageType: 1,
      createdAt: "2024-08-02T10:30:00Z",
      updatedAt: "2024-08-02T10:30:00Z",
    ),
    Chat(
      id: "19",
      chatTopicId: "207",
      senderUserId: Database.loginUserId,
      message: "Thanks for the reminder! I'll be there.",
      image: "",
      audio: "",
      isRead: true,
      date: "2024-08-02T10:32:00Z",
      messageType: 1,
      createdAt: "2024-08-02T10:32:00Z",
      updatedAt: "2024-08-02T10:32:00Z",
    ),
    Chat(
      id: "20",
      chatTopicId: "208",
      senderUserId: "sender009",
      message: "The new restaurant downtown has amazing reviews!",
      image: "",
      audio: "",
      isRead: false,
      date: "2024-08-02T12:00:00Z",
      messageType: 1,
      createdAt: "2024-08-02T12:00:00Z",
      updatedAt: "2024-08-02T12:00:00Z",
    ),
    Chat(
      id: "21",
      chatTopicId: "208",
      senderUserId: Database.loginUserId,
      message: "Let's try it this weekend! What kind of cuisine?",
      image: "",
      audio: "",
      isRead: false,
      date: "2024-08-02T12:05:00Z",
      messageType: 1,
      createdAt: "2024-08-02T12:05:00Z",
      updatedAt: "2024-08-02T12:05:00Z",
    ),
    Chat(
      id: "22",
      chatTopicId: "201",
      senderUserId: "sender002",
      message: "Count me in for the hiking trip!",
      image: "",
      audio: "",
      isRead: true,
      date: "2024-08-02T13:20:00Z",
      messageType: 1,
      createdAt: "2024-08-02T13:20:00Z",
      updatedAt: "2024-08-02T13:20:00Z",
    ),
    Chat(
      id: "23",
      chatTopicId: "209",
      senderUserId: "sender010",
      message: "Did you finish reading that book I recommended?",
      image: "",
      audio: "",
      isRead: true,
      date: "2024-08-02T14:45:00Z",
      messageType: 1,
      createdAt: "2024-08-02T14:45:00Z",
      updatedAt: "2024-08-02T14:45:00Z",
    ),
    Chat(
      id: "24",
      chatTopicId: "209",
      senderUserId: Database.loginUserId,
      message: "Almost done! It's such a page-turner.",
      image: "",
      audio: "",
      isRead: true,
      date: "2024-08-02T14:47:00Z",
      messageType: 1,
      createdAt: "2024-08-02T14:47:00Z",
      updatedAt: "2024-08-02T14:47:00Z",
    ),
    Chat(
      id: "25",
      chatTopicId: "208",
      senderUserId: "sender009",
      message: "It's Italian! They have handmade pasta.",
      image: "",
      audio: "",
      isRead: false,
      date: "2024-08-02T15:30:00Z",
      messageType: 1,
      createdAt: "2024-08-02T15:30:00Z",
      updatedAt: "2024-08-02T15:30:00Z",
    ),
    Chat(
      id: "26",
      chatTopicId: "210",
      senderUserId: "sender011",
      message: "The concert last night was incredible!",
      image: "",
      audio: "",
      isRead: true,
      date: "2024-08-02T16:00:00Z",
      messageType: 1,
      createdAt: "2024-08-02T16:00:00Z",
      updatedAt: "2024-08-02T16:00:00Z",
    ),
    Chat(
      id: "27",
      chatTopicId: "210",
      senderUserId: Database.loginUserId,
      message: "I'm so jealous! Wish I could have been there.",
      image: "",
      audio: "",
      isRead: true,
      date: "2024-08-02T16:02:00Z",
      messageType: 1,
      createdAt: "2024-08-02T16:02:00Z",
      updatedAt: "2024-08-02T16:02:00Z",
    ),
    Chat(
      id: "28",
      chatTopicId: "205",
      senderUserId: "sender006",
      message: "The picnic was such a great idea!",
      image: "",
      audio: "",
      isRead: false,
      date: "2024-08-02T17:15:00Z",
      messageType: 1,
      createdAt: "2024-08-02T17:15:00Z",
      updatedAt: "2024-08-02T17:15:00Z",
    ),
    Chat(
      id: "29",
      chatTopicId: "203",
      senderUserId: Database.loginUserId,
      message: "I can definitely help you meet that deadline!",
      image: "",
      audio: "",
      isRead: false,
      date: "2024-08-02T18:00:00Z",
      messageType: 1,
      createdAt: "2024-08-02T18:00:00Z",
      updatedAt: "2024-08-02T18:00:00Z",
    ),
    Chat(
      id: "30",
      chatTopicId: "211",
      senderUserId: "sender012",
      message: "Thanks for being such a great friend!",
      image: "",
      audio: "",
      isRead: true,
      date: "2024-08-02T19:30:00Z",
      messageType: 1,
      createdAt: "2024-08-02T19:30:00Z",
      updatedAt: "2024-08-02T19:30:00Z",
    ),

    Chat(
      id: "1",
      chatTopicId: "201",
      senderUserId: "sender001",
      message: "Hi there! How are you doing today?",
      image: "",
      audio: "",
      isRead: true,
      date: "2024-08-01T10:00:00Z",
      messageType: 1,
      createdAt: "2024-08-01T10:00:00Z",
      updatedAt: "2024-08-01T10:00:00Z",
    ),
    Chat(
      id: "2",
      chatTopicId: "201",
      senderUserId: Database.loginUserId,
      message: "I'm doing great, thanks for asking!",
      image: "",
      audio: "",
      isRead: false,
      date: "2024-08-01T10:02:00Z",
      messageType: 1,
      createdAt: "2024-08-01T10:02:00Z",
      updatedAt: "2024-08-01T10:02:00Z",
    ),
    Chat(
      id: "3",
      chatTopicId: "202",
      senderUserId: "sender002",
      message: "Can we meet tomorrow for coffee?",
      image: "",
      audio: "",
      isRead: true,
      date: "2024-08-01T10:04:00Z",
      messageType: 1,
      createdAt: "2024-08-01T10:04:00Z",
      updatedAt: "2024-08-01T10:04:00Z",
    ),
    // Continue with 27 more type 1 messages...
    // Sample additional type 1 messages
    Chat(
      id: "4",
      chatTopicId: "202",
      senderUserId: Database.loginUserId,
      message: "Sure, what time works for you?",
      image: "",
      audio: "",
      isRead: false,
      date: "2024-08-01T10:06:00Z",
      messageType: 1,
      createdAt: "2024-08-01T10:06:00Z",
      updatedAt: "2024-08-01T10:06:00Z",
    ),
    Chat(
      id: "5",
      chatTopicId: "203",
      senderUserId: "sender003",
      message: "How about 2pm at the usual place?",
      image: "",
      audio: "",
      isRead: true,
      date: "2024-08-01T10:08:00Z",
      messageType: 1,
      createdAt: "2024-08-01T10:08:00Z",
      updatedAt: "2024-08-01T10:08:00Z",
    ),
    // ... (add more type 1 messages until you reach 30 total)

    // Message Type 2 (5 messages - Image messages)

    // Message Type 3 (5 messages - Audio messages)
    Chat(
      id: "36",
      chatTopicId: "213",
      senderUserId: "sender013",
      message: "Listen to this cute voice note!",
      image: "",
      audio: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-7.mp3", // 8-second audio
      isRead: true,
      date: "2024-08-01T11:10:00Z",
      messageType: 3,
      createdAt: "2024-08-01T11:10:00Z",
      updatedAt: "2024-08-01T11:10:00Z",
    ),

    // Message Type 4 (5 messages - Story messages)

    Chat(
      id: "45",
      chatTopicId: "218",
      senderUserId: "sender018",
      message: "Dance recital today!",
      image: "https://emoji.aranja.com/static/emoji-data/img-apple-160/1f483.png", // Dancer emoji
      audio: "",
      isRead: true,
      storyId: StoryId(mediaImageUrl: "https://img.freepik.com/free-photo/stunning-natural-landscape_23-2151893598.jpg?semt=ais_hybrid&w=740&q=80"),
      date: "2024-08-01T11:28:00Z",
      messageType: 4,
      createdAt: "2024-08-01T11:28:00Z",
      updatedAt: "2024-08-01T11:28:00Z",
    ),

    // Message Type 5 (5 messages - Special Story messages)

    Chat(
      id: "50",
      chatTopicId: "221",
      senderUserId: "sender021",
      message: "First day of kindergarten!",
      image: "https://images.pexels.com/photos/4145153/pexels-photo-4145153.jpeg",
      audio: "",
      isRead: true,
      date: "2024-08-01T11:38:00Z",
      messageType: 5,
      storyId: StoryId(mediaImageUrl: "https://img.freepik.com/free-photo/nature-landscape-with-starry-clear-sky_23-2151683127.jpg?w=360"),
      createdAt: "2024-08-01T11:38:00Z",
      updatedAt: "2024-08-01T11:38:00Z",
    ),

    Chat(
      id: "31",
      chatTopicId: "210",
      senderUserId: "sender010",
      message: "Look at this cute photo!",

      image: "https://a.storyblok.com/f/191576/2400x1260/fe4f41c12b/enhance_photo_og_image.webp", // Young girl image
      audio: "",
      isRead: true,
      date: "2024-08-01T11:00:00Z",
      messageType: 2,
      createdAt: "2024-08-01T11:00:00Z",
      updatedAt: "2024-08-01T11:00:00Z",
    ),

    Chat(
      id: "31",
      chatTopicId: "210",
      senderUserId: Database.loginUserId,
      message: "Look at this cute photo!",

      image: "https://img.freepik.com/premium-photo/photo-portrait-happy-joyful-beautiful-little-kid_1077802-144228.jpg", // Young girl image
      audio: "",
      isRead: true,
      date: "2024-08-01T11:00:00Z",
      messageType: 2,
      createdAt: "2024-08-01T11:00:00Z",
      updatedAt: "2024-08-01T11:00:00Z",
    ),
  ];
}
