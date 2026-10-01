import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortie/pages/story_page/Dialog/delete_story_dialog_ui.dart';
import 'package:shortie/pages/story_page/api/create_view_story_history_api.dart';
import 'package:shortie/pages/story_page/api/delete_story_api.dart';
import 'package:shortie/pages/story_page/api/fetch_own_story_api.dart';
import 'package:shortie/pages/story_page/api/fetch_story_api.dart';
import 'package:shortie/pages/story_page/api/send_comment_to_story_api.dart';
import 'package:shortie/pages/story_page/api/upload_story_api.dart';
import 'package:shortie/pages/story_page/bottom_sheet/reaction_bottom_sheet_ui.dart';
import 'package:shortie/pages/story_page/bottom_sheet/viewers_bottom_sheet_ui.dart';
import 'package:shortie/pages/story_page/model/fetch_own_story_model.dart';
import 'package:shortie/pages/story_page/model/fetch_story_model.dart';
import 'package:shortie/pages/story_page/model/fetch_story_viewer_model.dart';
import 'package:shortie/pages/story_page/widget/simple_story_viewer.dart';
import 'package:shortie/pages/story_page/widget/story_item_widget.dart';
import 'package:shortie/ui/loading_ui.dart';
import 'package:shortie/utils/database.dart';
import 'package:shortie/utils/utils.dart';
import "package:story_view/story_view.dart" as story;
import 'package:story_view/story_view.dart';

import '../../chat_page/model/fetch_user_chat_model.dart';

class StoryController extends GetxController {
  TextEditingController commentController = TextEditingController();

  int pageIndex = 0;
  int storyIndex = 0;
  PageController pageController = PageController();

  FetchOwnStoryModel? fetchOwnStoryModel;

  List<Stories> ownStoryList = [];
  List<StoryItem> ownStoryItems = [];
  final story.StoryController ownStoryController = story.StoryController();

  FetchStoryModel? fetchStoryModel;
  List<StoryGroup> otherStoryList = [];
  List<List<StoryItem>> otherStoryItems = [];
  final story.StoryController otherStoryController = story.StoryController();

  Chat? chatObject;
  List<StoryItem> singleStoryItems = [];
  final story.StoryController singleStoryController = story.StoryController();

  bool isLoadingViewer = false;
  List<Viewers> viewerList = [];
  FetchStoryViewerModel? fetchStoryViewerModel;

  bool isLoading = false;

  double dragStartPosition = 0;

  bool isKeyboardVisible = false;

  int? previousPageIndex;

  @override
  void onInit() {
    init();
    super.onInit();
  }

  @override
  void onClose() {
    super.onClose();
  }

  Future<void> init() async {
    isLoading = true;
    update(["onFetchStories"]);

    onFetchOwnStories();
    await onFetchStories();

    isLoading = false;
    update(["onFetchStories"]);
  }

  Future<void> onClickSingleStory({required Chat indexData}) async {
    chatObject = indexData;

    // 1) Map Chat → Stories (your model)
    final singleStory = Stories(
      id: indexData.storyId?.id,
      mediaImageUrl: indexData.storyId?.mediaImageUrl,
      mediaVideoUrl: indexData.storyId?.mediaVideoUrl,
      createdAt: indexData.storyId?.createdAt,
      storyType: indexData.storyId?.storyType,
      reactionsCount: indexData.storyId?.reactionsCount,
      viewsCount: indexData.storyId?.viewsCount,
      isView: true,
      duration: indexData.storyId?.duration,
      backgroundSong: indexData.storyId?.backgroundSong,
    );

    singleStoryItems = [onStoryItem(controller: singleStoryController, itemData: singleStory)];

    // if (singleStoryItems.isNotEmpty) Get.to(() => SingleStoryView());

    if (singleStoryItems.isNotEmpty) await StoryViewer.openSingle(chat: chatObject!);
  }

  Future<void> onFetchOwnStories() async {
    fetchOwnStoryModel = await FetchOwnStoryApi.callApi(loginUserId: Database.loginUserId);
    ownStoryList = fetchOwnStoryModel?.storyGroup?.stories ?? [];
    onStoreOwnItem();
  }

  Future<void> onFetchStories() async {
    fetchStoryModel = await FetchStoryApi.callApi(loginUserId: Database.loginUserId);
    otherStoryList = fetchStoryModel?.storyGroup ?? [];
    onStoreOtherItem();
  }

  void onStoreOtherItem() {
    otherStoryItems.clear();
    for (int i = 0; i < otherStoryList.length; i++) {
      List<StoryItem> data = otherStoryList[i].stories?.map((item) => onStoryItem(controller: otherStoryController, itemData: item)).toList() ?? [];
      otherStoryItems.add(data);
    }
    Utils.showLog("Other Story Item Length => ${ownStoryItems.length}");
  }

  void onStoreOwnItem() {
    List<StoryItem> data = ownStoryList.map((item) => onStoryItem(controller: ownStoryController, itemData: item)).toList() ?? [];
    ownStoryItems = data;
    Utils.showLog("Own Story Item Length => ${ownStoryItems.length}");
  }

  void onComplete({required bool isOwnStory, bool? isSingleStory}) {
    if (isOwnStory) {
      Get.back();
    } else if (isSingleStory == true) {
      Get.back();
    } else {
      if (pageIndex == (otherStoryItems.length - 1)) {
        Get.back();
      } else {
        pageIndex++;
        pageController.animateToPage(pageIndex, duration: const Duration(milliseconds: 300), curve: Curves.linear);
      }
    }
  }

  void onClickOwnStoryCircle({String? storyId}) async {
    if (storyId?.trim().isNotEmpty == true) {
      // Get.to(() => OwnStoryView());
      await StoryViewer.openOwn(stories: fetchOwnStoryModel?.storyGroup?.stories ?? []);

      for (int i = 0; i < ownStoryList.length; i++) {
        if (storyIndex == 0) {
          for (int i = 0; i < ownStoryList.length; i++) {
            if (storyId == ownStoryList[i].id) {
              return;
            } else {
              ownStoryController.next();
              await 5.milliseconds.delay();
            }
          }
        } else {
          storyIndex--;
          ownStoryController.previous();
          await 5.milliseconds.delay();
        }
      }
    } else {
      storyIndex = 0;
      // Get.to(() => OwnStoryView());
      await StoryViewer.openOwn(stories: fetchOwnStoryModel?.storyGroup?.stories ?? []);
    }
  }

  void onClickOtherStoryCircle({required int index}) async {
    previousPageIndex = null;
    Utils.showLog("User Click Story Index => $index");
    storyIndex = 0;
    pageController = PageController(initialPage: index);
    pageIndex = index;
    // Get.to(() => OtherStoryView());
    await StoryViewer.openOthers(groups: fetchStoryModel?.storyGroup ?? [], initialGroupIndex: index);
  }

//  aatiyare aavi rite che OwnStoryView,OtherStoryView,SingleStoryView  and bathu controller thi manage thai che to su aapde ek view ma batdhu hender
  void onPageChange(int value) {
    storyIndex = 0;
    pageIndex = value;
  }

  void onClickClose() {
    Get.back();
  }

  void onClickSendComment({required bool isSingleStory}) async {
    if (commentController.text.trim().isNotEmpty) {
      Get.dialog(PopScope(canPop: false, child: const LoadingUi()), barrierDismissible: false); // Start Loading...

      await SendCommentToStoryApi.callApi(
        loginUserId: Database.loginUserId,
        storyId: isSingleStory ? chatObject?.storyId?.id ?? "" : otherStoryList[pageIndex].stories?[storyIndex].id ?? "",
        message: commentController.text.trim(),
      );

      Get.back(); // Stop Loading...

      FocusManager.instance.primaryFocus?.unfocus();

      if (SendCommentToStoryApi.sendCommentToStoryModel?.status == true) {
        commentController.clear();
        Utils.showToast("Comment Send To Story");
      }
    }
  }

  void onClickReaction({required BuildContext context, required bool isSingleStory}) async {
    otherStoryController.pause();

    ReactionBottomSheetUi.show(
      context: context,
      storyId: isSingleStory ? chatObject?.storyId?.id ?? "" : otherStoryList[pageIndex].stories?[storyIndex].id ?? "",
      callback: () => otherStoryController.play(),
    );
  }

  void onStoryShow({required bool isOwnStory, required int index, bool? isView}) async {
    Utils.showLog("Story View Index /////$previousPageIndex ***$pageIndex**** => $index");

    storyIndex = index;

    await 100.milliseconds.delay();

    if (previousPageIndex == pageIndex) {
      update();
    }

    if (isOwnStory) update();

    previousPageIndex = pageIndex;

    if (isOwnStory == false && isView == false) {
      onCreateViewHistory(index: pageIndex, storyIndex: storyIndex);
    }
  }

  void onOpenViewers({required BuildContext context}) {
    ownStoryController.pause();
    ViewersBottomSheetUi.show(
      context: context,
      storyId: ownStoryList[storyIndex].id ?? "",
      callback: () => ownStoryController.play(),
    );
  }

  void onCreateViewHistory({required int index, required int storyIndex}) async {
    Utils.showLog("Other User Story Page Index => $index Story Index => $storyIndex");

    if (otherStoryList[index].stories?[storyIndex].isView == false) {
      await CreateViewStoryHistoryApi.callApi(
        loginUserId: Database.loginUserId,
        storyId: otherStoryList[index].stories?[storyIndex].id ?? "",
      );
    }
  }

  void onDeleteStory() {
    ownStoryController.pause();

    DeleteStoryDialogUi.onShow(
      onDelete: () async {
        Get.dialog(PopScope(canPop: false, child: const LoadingUi()), barrierDismissible: false); // Start Loading...

        await DeleteStoryApi.callApi(loginUserId: Database.loginUserId, storyId: ownStoryList[storyIndex].id ?? "");

        Get.back(); // Stop Loading...

        Get.back(); // Close Dialog...

        if (DeleteStoryApi.deleteStoryModel?.status == true) {
          ownStoryList.removeAt(storyIndex);
          ownStoryItems.removeAt(storyIndex);

          if ((storyIndex + 1) < ownStoryItems.length) {
            ownStoryController.next();
            ownStoryController.previous();
          } else {
            onClickClose();
          }
        } else {
          ownStoryController.play();
        }
      },
      callback: () {
        ownStoryController.play();
      },
    );
  }

  void onHandleDragStart({required DragStartDetails details}) {
    try {
      dragStartPosition = details.globalPosition.dy;
    } catch (e) {
      Utils.showLog("onHandleDragStart Error => $e");
    }
  }

  void onHandleDragUpdate({
    required DragUpdateDetails details,
    required BuildContext context,
    required bool isOwnStory,
  }) {
    try {
      final currentPosition = details.globalPosition.dy;
      final delta = currentPosition - dragStartPosition;

      if (delta > 20) {
        Get.back();
      } else if (delta < -20 && ViewersBottomSheetUi.isBottomSheetOpen == false) {
        if (isOwnStory) onOpenViewers(context: context);
      }
    } catch (e) {
      Utils.showLog("onHandleDragUpdate Error => $e");
    }
  }

  void onChangeKeyboardVisibility(BuildContext context) {
    try {
      final bottomInset = MediaQuery.of(context).viewInsets.bottom;
      final newValue = bottomInset > 0.0;

      if (newValue != isKeyboardVisible) {
        if (isKeyboardVisible && newValue == false) {
          otherStoryController.play();
        }
        isKeyboardVisible = newValue;
      }
    } catch (e) {
      Utils.showLog("onChangeKeyboardVisibility Error => $e");
    }
  }

  Future<void> onUploadStoryForTesting() async {
    final List temp = [
      "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTOKZJp9Ny7vkpZsw5UcR6S0HZi2nx4cuy7ow&s",
      "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSgqGf-r5eX8YZoeB2uYUFZ2243bqvHHJxAdg&s",
      "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQqv6kzR4MIdlIxYj4ylLuahyxy3yAFuZQwzw&s",
      "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSGFEH1fCVLlGr1_9wssAmA2aYDV64hGzZB_w&s",
      "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSQBiCVHju6cwI4nt4ON4ILLefc4v7hRLIvXw&s",
      "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT6pozIHNapTrNyGNbC4rHHGLb1v8_Vu-_4yw&s",
      "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR-0EGJ4xSKgLbr6dx3PulKbu_JDfGEFJQJyw&s",
      "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT3eMw9xGk8OGSHVmZVyvbTG8aKoSAFL38bsA&s",
      "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS2pSkGwA6Y2Qv6DJxMkuQ-wzy9CVtLS7pM5Q&s",
      "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSbloncOEHbylpDE-8LWOrnncrUKZ6C4MpNwg&s",
      "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSKrlZqJuaj7_rjSv6SVCyu5EAHzusk9eVBLQ&s",
    ];

    final List video = [
      "https://videos.pexels.com/video-files/7233649/7233649-hd_1080_1920_25fps.mp4",
      "https://videos.pexels.com/video-files/9652738/9652738-uhd_1440_2732_25fps.mp4",
      "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSKrlZqJuaj7_rjSv6SVCyu5EAHzusk9eVBLQ&s",
      "https://videos.pexels.com/video-files/8263458/8263458-uhd_1440_2732_25fps.mp4",
      "https://videos.pexels.com/video-files/7233647/7233647-hd_1080_1920_25fps.mp4",
      "https://videos.pexels.com/video-files/7989394/7989394-uhd_1440_2732_25fps.mp4",
    ];
    try {
      Get.dialog(barrierDismissible: false, PopScope(canPop: false, child: const LoadingUi())); // Start Loading...
      UploadStoryApi.callApi(
        userId: Database.loginUserId,
        backgroundSong: "",
        // backgroundSong: "687e0f7622db584c8ad62286",
        isVideo: true,

        mediaImageUrl: temp[Random().nextInt(temp.length)],
        mediaVideoUrl: video[Random().nextInt(video.length)],

        // mediaImageUrl: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSKrlZqJuaj7_rjSv6SVCyu5EAHzusk9eVBLQ&s",
        // mediaVideoUrl: "https://videos.pexels.com/video-files/9652738/9652738-uhd_1440_2732_25fps.mp4",
        // mediaVideoUrl: "https://videos.pexels.com/video-files/7233643/7233643-hd_1080_1920_25fps.mp4",
        duration: 10,
      );

      Get.back(); // Stop Loading....

      Utils.showLog("✅ Upload Story Method Call Success");
    } catch (e) {
      Utils.showLog("❌ Upload Story Method Call Failed => $e");
    }
  }
}
