import 'dart:async';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shortie/deep_link/services/deep_link_services.dart';
import 'package:shortie/pages/connection_page/api/follow_unfollow_api.dart';
import 'package:shortie/pages/profile_page/api/fetch_profile_api.dart';
import 'package:shortie/pages/fake_live_page/widget/fake_comment_data.dart';
import 'package:shortie/pages/fake_live_page/widget/fake_send_gift_bottom_sheet_widget.dart';
import 'package:shortie/pages/multi_live_page/model/pk_gift_top_user_model.dart';
import 'package:shortie/pages/multi_live_page/widget/show_received_gift.dart';
import 'package:shortie/pages/splash_screen_page/model/fetch_gift_model.dart';
import 'package:shortie/utils/database.dart';
import 'package:shortie/utils/enums.dart';
import 'package:shortie/utils/utils.dart';
import 'package:video_player/video_player.dart';

class FakeLiveController extends GetxController {
  RxBool isShowPkAnimation = false.obs;

  Timer? time;
  Timer? liveTimer;
  Timer? pkTimer;
  Timer? giftTimer;

  String userId = "";
  String image = "";
  String name = "";
  String userName = "";
  bool isFollow = false;
  String videoUrl = "";
  int countTime = 0;
  bool isLivePage = false;
  bool _isSharing = false;

  bool isPkMode = false;

  int pkCountTime = 120;

  String host2VideoUrl = "";
  String host2Image = "";

  int h1Rank = 0;
  int h2Rank = 0;

  ScrollController scrollController = ScrollController();
  TextEditingController commentController = TextEditingController();

  VideoPlayerController? videoPlayerController;
  VideoPlayerController? host2VideoPlayerController;

  bool isVideoLoading = true;
  bool host2IsVideoLoading = true;

  List<PkGiftTopUserModel> host1TopGiftUsers = [
    PkGiftTopUserModel(
      id: "1",
      userId: UserId(
        image: "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=200&q=80",
        id: "1",
        name: "Emma Johnson",
        coin: 3200,
        isProfilePicBanned: false,
      ),
    ),
    PkGiftTopUserModel(
      id: "2",
      userId: UserId(
        image: "https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=200&q=80",
        id: "2",
        name: "Sophia Williams",
        coin: 2900,
        isProfilePicBanned: false,
      ),
    ),
    PkGiftTopUserModel(
      id: "3",
      userId: UserId(
        image: "https://images.unsplash.com/photo-1554151228-14d9def656e4?w=200&q=80",
        id: "3",
        name: "Olivia Brown",
        coin: 2700,
        isProfilePicBanned: false,
      ),
    ),
    PkGiftTopUserModel(
      id: "4",
      userId: UserId(
        image: "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200&q=80",
        id: "4",
        name: "Ava Jones",
        coin: 2600,
        isProfilePicBanned: false,
      ),
    ),
    PkGiftTopUserModel(
      id: "5",
      userId: UserId(
        image: "https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=200&q=80",
        id: "5",
        name: "Isabella Garcia",
        coin: 2500,
        isProfilePicBanned: false,
      ),
    ),
    PkGiftTopUserModel(
      id: "6",
      userId: UserId(
        image: "https://images.unsplash.com/photo-1508214751196-bcfd4ca60f91?w=200&q=80",
        id: "6",
        name: "Mia Miller",
        coin: 2400,
        isProfilePicBanned: false,
      ),
    ),
    PkGiftTopUserModel(
      id: "7",
      userId: UserId(
        image: "https://images.unsplash.com/photo-1517841905240-472988babdf9?w=200&q=80",
        id: "7",
        name: "Charlotte Davis",
        coin: 2300,
        isProfilePicBanned: false,
      ),
    ),
    PkGiftTopUserModel(
      id: "8",
      userId: UserId(
        image: "https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?w=200&q=80",
        id: "8",
        name: "Amelia Rodriguez",
        coin: 2200,
        isProfilePicBanned: false,
      ),
    ),
    PkGiftTopUserModel(
      id: "9",
      userId: UserId(
        image: "https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=200&q=80",
        id: "9",
        name: "Harper Martinez",
        coin: 2100,
        isProfilePicBanned: false,
      ),
    ),
    PkGiftTopUserModel(
      id: "10",
      userId: UserId(
        image: "https://images.unsplash.com/photo-1542206395-9feb3edaa68d?w=200&q=80",
        id: "10",
        name: "Evelyn Hernandez",
        coin: 2000,
        isProfilePicBanned: false,
      ),
    ),
  ];
  List<PkGiftTopUserModel> host2TopGiftUsers = [
    PkGiftTopUserModel(
      id: "11",
      userId: UserId(
        image: "https://images.unsplash.com/photo-1531123897727-8f129e1688ce?w=200&q=80",
        id: "11",
        name: "Abigail Lopez",
        coin: 1900,
        isProfilePicBanned: false,
      ),
    ),
    PkGiftTopUserModel(
      id: "12",
      userId: UserId(
        image: "https://images.unsplash.com/photo-1524502397800-2eeaad7c3fe5?w=200&q=80",
        id: "12",
        name: "Emily Gonzalez",
        coin: 1800,
        isProfilePicBanned: false,
      ),
    ),
    PkGiftTopUserModel(
      id: "13",
      userId: UserId(
        image: "https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?w=200&q=80",
        id: "13",
        name: "Elizabeth Wilson",
        coin: 1700,
        isProfilePicBanned: false,
      ),
    ),
    PkGiftTopUserModel(
      id: "14",
      userId: UserId(
        image: "https://images.unsplash.com/photo-1517841905240-472988babdf9?w=200&q=80",
        id: "14",
        name: "Sofia Anderson",
        coin: 1600,
        isProfilePicBanned: false,
      ),
    ),
    PkGiftTopUserModel(
      id: "15",
      userId: UserId(
        image: "https://images.unsplash.com/photo-1542206395-9feb3edaa68d?w=200&q=80",
        id: "15",
        name: "Avery Thomas",
        coin: 1500,
        isProfilePicBanned: false,
      ),
    ),
    PkGiftTopUserModel(
      id: "16",
      userId: UserId(
        image: "https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=200&q=80",
        id: "16",
        name: "Ella Taylor",
        coin: 1400,
        isProfilePicBanned: false,
      ),
    ),
    PkGiftTopUserModel(
      id: "17",
      userId: UserId(
        image: "https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?w=200&q=80",
        id: "17",
        name: "Scarlett Moore",
        coin: 1300,
        isProfilePicBanned: false,
      ),
    ),
    PkGiftTopUserModel(
      id: "18",
      userId: UserId(
        image: "https://images.unsplash.com/photo-1517841905240-472988babdf9?w=200&q=80",
        id: "18",
        name: "Victoria Jackson",
        coin: 1200,
        isProfilePicBanned: false,
      ),
    ),
    PkGiftTopUserModel(
      id: "19",
      userId: UserId(
        image: "https://images.unsplash.com/photo-1524502397800-2eeaad7c3fe5?w=200&q=80",
        id: "19",
        name: "Madison Martin",
        coin: 1100,
        isProfilePicBanned: false,
      ),
    ),
    PkGiftTopUserModel(
      id: "20",
      userId: UserId(
        image: "https://images.unsplash.com/photo-1531123897727-8f129e1688ce?w=200&q=80",
        id: "20",
        name: "Luna Lee",
        coin: 1000,
        isProfilePicBanned: false,
      ),
    ),
  ];
  Future<void> onShareLink() async {
    if (_isSharing) return;
    _isSharing = true;
    try {
      Utils.showLog("123456789");
      final link = DeepLinkServices.onGenerateLink(
          pageRoutes: DeepLinkServices.live, id: userId, name: name, image: image, username: userName, roomId: userId, liveUserId: userId);

      /*final result =*/ await Share.share(
        'Join my live stream! $link',
        subject: 'Live Stream Invitation',
      );
      Utils.showLog("123456789");
    } catch (e) {
      Utils.showLog("onShareLink error: $e");
    } finally {
      Future.delayed(const Duration(seconds: 1), () => _isSharing = false);
    }
  }

  @override
  void onInit() {
    FakeSendGiftBottomSheetWidget.onGetGift();

    addFakeComment();
    onChangePkTime();
    onChangeGiftTime();
    Utils.showLog("Selected Plan => ${Get.arguments}");
    if (Get.arguments != null) {
      userId = Get.arguments["userId"];
      userName = Get.arguments["userName"];
      name = Get.arguments["name"];
      image = Get.arguments["image"];
      videoUrl = Get.arguments["videoUrl"];
      host2Image = Get.arguments["host2Image"];
      host2VideoUrl = Get.arguments["host2VideoUrl"];
      isPkMode = Get.arguments["isPkMode"];
      isFollow = Get.arguments["isFollow"] ?? false;
      initFollowState();
    }
    super.onInit();
  }

  addFakeComment() {
    time = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      addItems();

      Utils.showLog("COMMENT TIMER RUNNING");
    });
  }

  void onDispose() {
    isLivePage = false;

    time?.cancel();
    giftTimer?.cancel();
    pkTimer?.cancel();
    scrollController.dispose();
    onDisposeVideoPlayer();
    onDisposeVideoHost2();

    Utils.showLog("Fake Live Controller Dispose Success");
  }

  @override
  void onClose() {
    super.onClose();
  }

  void onChangePkTime() {
    pkTimer = Timer.periodic(
      Duration(seconds: 1),
      (timer) {
        if (pkCountTime > 0) {
          pkCountTime--;

          h1Rank = Random().nextInt(1000);
          h2Rank = Random().nextInt(1000);

          update(['onChangePkTime']);
        } else {
          pkCountTime = 120;
          pkTimer?.cancel();
          Future.delayed(Duration(seconds: 1), () => onChangePkTime());
          update(['onChangePkTime']);
          Utils.showLog('pkCountTime --> $pkCountTime');
        }
        Utils.showLog("PK TIMER RUNNING");
      },
    );
  }

  void onChangeGiftTime() {
    Future.delayed(
      Duration(seconds: 5),
      () {
        if (FakeSendGiftBottomSheetWidget.giftCollection.isNotEmpty) {
          onSendGift(
            senderName: host1TopGiftUsers[Random().nextInt(host1TopGiftUsers.length)].userId?.name ?? "",
            senderImage: host1TopGiftUsers[Random().nextInt(host1TopGiftUsers.length)].userId?.image ?? "",
            senderUniqueId: (98765432 + Random().nextInt(8)).toString(),
            senderProfilePicBanned: false,
            gift: FakeSendGiftBottomSheetWidget.giftCollection[Random().nextInt(FakeSendGiftBottomSheetWidget.giftCollection.length)],
          );
        }
      },
    );

    giftTimer = Timer.periodic(
      Duration(seconds: 20),
      (timer) {
        h1Rank = Random().nextInt(1000);
        h2Rank = Random().nextInt(1000);

        update(['onChangePkTime', 'onUpdateRank']);

        if (FakeSendGiftBottomSheetWidget.giftCollection.isNotEmpty) {
          onSendGift(
            senderName: host1TopGiftUsers[Random().nextInt(host1TopGiftUsers.length)].userId?.name ?? "",
            senderImage: host1TopGiftUsers[Random().nextInt(host1TopGiftUsers.length)].userId?.image ?? "",
            senderUniqueId: (98765432 + Random().nextInt(8)).toString(),
            senderProfilePicBanned: false,
            gift: FakeSendGiftBottomSheetWidget.giftCollection[Random().nextInt(FakeSendGiftBottomSheetWidget.giftCollection.length)],
          );
        }

        Utils.showLog("GIFT TIMER RUNNING");
      },
    );
  }

  Future<void> initializeVideoPlayer() async {
    try {
      print("Video Url =>'${videoUrl}'");
      videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(videoUrl),
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
      );
      videoPlayerController?.initialize().then((_) {
        videoPlayerController?.setLooping(true);
        videoPlayerController?.play();
        update(["initializeVideoPlayer"]);
      });
    } catch (e) {
      onDisposeVideoPlayer();
      Utils.showLog("Reels Video Initialization Failed !!! => $e");
    }
  }

  Future<void> initializeVideoHost2() async {
    if (isPkMode) {
      try {
        print("Video Url =>'${videoUrl}'");

        host2VideoPlayerController = VideoPlayerController.networkUrl(
          Uri.parse(host2VideoUrl),
          videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
        );
        host2VideoPlayerController?.initialize().then((_) {
          host2VideoPlayerController?.setLooping(true);
          host2VideoPlayerController?.play();
          update(["initializeVideoPlayer"]);
        });
      } catch (e) {
        onDisposeVideoHost2();
        Utils.showLog("Reels Video Initialization Failed !!! => $e");
      }
    }
  }

  void onDisposeVideoPlayer() {
    try {
      videoPlayerController?.pause();
      videoPlayerController?.dispose();
      videoPlayerController = null;
    } catch (e) {
      Utils.showLog(">>>> On Dispose VideoPlayer Error => $e");
    }
  }

  void onDisposeVideoHost2() {
    try {
      host2VideoPlayerController?.pause();
      host2VideoPlayerController?.dispose();
      host2VideoPlayerController = null;
    } catch (e) {
      Utils.showLog(">>>> On Dispose VideoPlayer Error => $e");
    }
  }

  void addItems() {
    fakeHostCommentList.shuffle();
    print("object::::  1${fakeHostCommentList.first.message}");

    fakeHostCommentListBlank.add(fakeHostCommentList.first);
    scrollController.animateTo(scrollController.position.maxScrollExtent, duration: const Duration(milliseconds: 50), curve: Curves.easeOut);
    update(["onChangeComment"]);
  }

  Future<void> onSendComment() async {
    if (commentController.text.trim().isNotEmpty) {
      fakeHostCommentListBlank.add(HostComment(
        message: commentController.text.toString(),
        user: Database.fetchLoginUserProfileModel?.user?.name ?? "",
        image: (Database.fetchLoginUserProfileModel?.user?.image ?? ""),
      ));
    }
    commentController.clear();
  }

  Future<void> initFollowState() async {
    try {
      if (userId.isNotEmpty) {
        final fetchProfileModel = await FetchProfileApi.callApi(loginUserId: Database.loginUserId, otherUserId: userId);
        final user = fetchProfileModel?.userProfileData?.user;
        if (user != null) {
          if (user.isFollow != null) {
            isFollow = user.isFollow!;
          }
          if (user.image != null && user.image!.isNotEmpty) {
            image = user.image!;
          }
          if (user.name != null && user.name!.isNotEmpty) {
            name = user.name!;
          }
          if (user.userName != null && user.userName!.isNotEmpty) {
            userName = user.userName!;
          }
          update(["onClickFollow", "updateProfile"]);
          Utils.showLog("FakeLiveController dynamically resolved profile details => isFollow: $isFollow, image: $image");
        }
      }
    } catch (e) {
      Utils.showLog("FakeLiveController dynamic fetch profile error => $e");
    }
  }

  Future<void> onClickFollow() async {
    if (userId != Database.loginUserId) {
      isFollow = !isFollow;
      update(["onClickFollow"]);
      await FollowUnfollowApi.callApi(loginUserId: Database.loginUserId, userId: userId);
    } else {
      Utils.showToast(EnumLocal.txtYouCantFollowYourOwnAccount.name.tr);
    }
  }

  void onChangeTime() {
    isLivePage = true;

    liveTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (isLivePage) {
          countTime++;
          Utils.showLog("Live Streaming Time => ${onConvertSecondToHMS(countTime)}");
          update(["onChangeTime"]);
        } else {
          liveTimer?.cancel();
          countTime = 0;
          update(["onChangeTime"]);
        }
      },
    );
  }

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

  void onShowPkAnimation() async {
    await 1000.milliseconds.delay();
    isShowPkAnimation.value = true;
    await 1500.milliseconds.delay();
    isShowPkAnimation.value = false;
  }

  void onSendGift({
    Data? gift,
    required String senderName,
    required String senderImage,
    required String senderUniqueId,
    required bool senderProfilePicBanned,
  }) async {
    ShowReceivedGift.onGetNewGift(
      GiftModel(
        giftUrl: gift?.image ?? "",
        giftType: gift?.type ?? 0,
        giftCount: 1,
        senderName: senderName,
        senderImage: senderImage,
        senderUniqueId: senderUniqueId,
        senderProfilePicBanned: senderProfilePicBanned,
        receiverName: "",
        isFake: true,
      ),
    );

    // Get.back();
  }
}
