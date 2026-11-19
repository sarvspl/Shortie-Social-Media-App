import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shortie/custom/custom_image_picker.dart';
import 'package:shortie/custom/custom_multi_image_picker.dart';
import 'package:shortie/deep_link/services/deep_link_services.dart';
import 'package:shortie/google_ad/google_ad_services.dart';
import 'package:shortie/pages/feed_page/api/fetch_popular_user_api.dart';
import 'package:shortie/pages/feed_page/api/fetch_post_api.dart';
import 'package:shortie/pages/feed_page/model/fetch_popular_user_model.dart';
import 'package:shortie/pages/feed_page/model/fetch_post_model.dart';
import 'package:shortie/pages/story_page/controller/story_controller.dart';
import 'package:shortie/pages/stream_page/api/fetch_live_user_api.dart';
import 'package:shortie/pages/stream_page/model/fetch_live_user_model.dart';
import 'package:shortie/routes/app_routes.dart';
import 'package:shortie/ui/image_picker_bottom_sheet_ui.dart';
import 'package:shortie/utils/database.dart';
import 'package:shortie/utils/utils.dart';

class FeedController extends GetxController {
  ScrollController scrollController = ScrollController();

  StoryController get storyController => Get.isRegistered<StoryController>()
      ? Get.find<StoryController>()
      : Get.put(StoryController(), permanent: true);

  FetchPostModel? fetchPostModel;
  List<Post> mainPost = [];
  bool isLoadingPost = false;
  bool isPaginationLoading = false;

  // 0: Popular, 1: Feed, 2: PK Matches
  int selectedSection = 1;

  // Popular section
  List<PopularUser> popularUsers = [];
  bool isLoadingPopular = false;

  // PK Matches section
  List<LiveUserList> pkMatches = [];
  bool isLoadingPkMatches = false;

  @override
  void onInit() {
    scrollController.addListener(onPagination);
    init();
    super.onInit();
  }

  Future<void> init() async {
    storyController.init();

    if (selectedSection == 1) {
      isLoadingPost = true;
      mainPost.clear();
      update(["onGetPost", "onSectionChange"]);
      FetchPostApi.startPagination = 0;
      await onGetPost();
      isLoadingPost = false;
      update(["onGetPost"]);
    } else if (selectedSection == 0) {
      await onGetPopular(isReload: true);
    } else if (selectedSection == 2) {
      await onGetPkMatches(isReload: true);
    }
  }

  Future<void> onChangeSection(int index) async {
    if (selectedSection == index) return;
    selectedSection = index;
    update(["onSectionChange"]);

    if (selectedSection == 0) {
      await onGetPopular(isReload: true);
    } else if (selectedSection == 1) {
      if (mainPost.isEmpty) {
        isLoadingPost = true;
        update(["onGetPost"]);
        FetchPostApi.startPagination = 0;
        await onGetPost();
        isLoadingPost = false;
        update(["onGetPost"]);
      }
    } else if (selectedSection == 2) {
      await onGetPkMatches(isReload: true);
    }
  }

  void onPagination() async {
    if (scrollController.position.pixels == scrollController.position.maxScrollExtent && isPaginationLoading == false) {
      isPaginationLoading = true;
      update(["onPagination"]);
      if (selectedSection == 1) {
        await onGetPost();
      } else if (selectedSection == 0) {
        await onGetPopular(isReload: false);
      } else if (selectedSection == 2) {
        await onGetPkMatches(isReload: false);
      }
      isPaginationLoading = false;
      update(["onPagination"]);
    }
  }

  Future<void> onGetPost() async {
    fetchPostModel = null;
    fetchPostModel = await FetchPostApi.callApi(
        loginUserId: Database.loginUserId, postId: DeepLinkServices.eventType == DeepLinkServices.feed ? DeepLinkServices.eventId : "");

    if (fetchPostModel?.post != null) {
      if (fetchPostModel!.post!.isNotEmpty) {
        final paginationData = fetchPostModel?.post ?? [];

        if (GoogleAdServices.isShowLargeNativeAdFeed) {
          for (int i = 0; i < paginationData.length; i++) {
            if (i % GoogleAdServices.adShowIndex == 0 && i != 0) {
              mainPost.add(paginationData[i]);
            } else {
              mainPost.add(paginationData[i]);
            }
          }
        } else {
          mainPost.addAll(paginationData);
        }

        update(["onGetPost"]);
      } else {
        FetchPostApi.startPagination--;
      }
    }
    if (mainPost.isEmpty) {
      update(["onGetPost"]);
    }

    if (DeepLinkServices.isNavigationComplete) {
      DeepLinkServices.eventId = "";
      DeepLinkServices.eventType = "";
    }
  }

  Future<void> onGetPopular({bool isReload = false}) async {
    if (isReload) {
      FetchPopularUserApi.startPagination = 0;
      popularUsers.clear();
      isLoadingPopular = true;
      update(["onGetPopular"]);
    }

    final model = await FetchPopularUserApi.callApi();
    if (model?.data != null && model!.data!.isNotEmpty) {
      popularUsers.addAll(model.data!);
    }

    // Also fetch live and PK streamers and append them after popular users
    try {
      final liveModel = await FetchLiveUserApi.callApi(loginUserId: Database.loginUserId);
      if (liveModel?.liveUserList != null && liveModel!.liveUserList!.isNotEmpty) {
        for (final u in liveModel.liveUserList!) {
          if (!popularUsers.any((p) => p.id == u.userId)) {
            popularUsers.add(PopularUser(
              id: u.userId,
              name: u.name,
              userName: u.userName,
              image: u.image ?? u.videoImage,
              isVerified: u.isVerified,
              isFake: u.isFake,
              coin: (u.view ?? 1) * 120,
              receivedCoin: (u.view ?? 1) * 550,
              receivedGift: (u.view ?? 1) * 3,
              isLive: true,
              liveUserObjId: u.liveUserObjId,
              liveHistoryId: u.liveHistoryId,
              isPkMode: u.isPkMode,
            ));
          }
        }
      }
    } catch (e) {
      Utils.showLog("Error appending live users to popular list: $e");
    }

    isLoadingPopular = false;
    update(["onGetPopular"]);
  }

  Future<void> onGetPkMatches({bool isReload = false}) async {
    if (isReload) {
      FetchLiveUserApi.startPagination = 0;
      pkMatches.clear();
      isLoadingPkMatches = true;
      update(["onGetPkMatches"]);
    }

    final model = await FetchLiveUserApi.callApi(loginUserId: Database.loginUserId);
    if (model?.liveUserList != null && model!.liveUserList!.isNotEmpty) {
      final list = model.liveUserList!;
      // Filter or sort so PK mode users appear first
      final pkOnly = list.where((u) => u.isPkMode == true || (u.pkPreviewImages?.isNotEmpty ?? false)).toList();
      final others = list.where((u) => u.isPkMode != true && (u.pkPreviewImages?.isEmpty ?? true)).toList();
      pkMatches.addAll([...pkOnly, ...others]);
    }

    isLoadingPkMatches = false;
    update(["onGetPkMatches"]);
  }

  Future<void> onPickPost(BuildContext context) async {
    await ImagePickerBottomSheetUi.show(
      context: context,
      onClickGallery: () async {
        Get.back();
        final List<String> images = await CustomMultiImagePicker.pickImage();

        if (images.isNotEmpty) {
          Get.toNamed(AppRoutes.uploadPostPage, arguments: {"images": images, "isEdit": false});
        }
      },
      onClickCamera: () async {
        Get.back();
        final String? imagePath = await CustomImagePicker.pickImage(ImageSource.camera);
        if (imagePath != null) {
          List<String> images = [];
          images.add(imagePath);
          Get.toNamed(AppRoutes.uploadPostPage, arguments: {"images": images, "isEdit": false});
        }
      },
    );
  }
}
