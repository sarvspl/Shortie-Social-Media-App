import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shortie/custom/custom_image_picker.dart';
import 'package:shortie/custom/custom_multi_image_picker.dart';
import 'package:shortie/deep_link/services/deep_link_services.dart';
import 'package:shortie/google_ad/google_ad_services.dart';
import 'package:shortie/pages/feed_page/api/fetch_post_api.dart';
import 'package:shortie/pages/feed_page/model/fetch_post_model.dart';
import 'package:shortie/pages/story_page/controller/story_controller.dart';
import 'package:shortie/routes/app_routes.dart';
import 'package:shortie/ui/image_picker_bottom_sheet_ui.dart';
import 'package:shortie/utils/database.dart';

class FeedController extends GetxController {
  ScrollController scrollController = ScrollController();

  final storyController = Get.find<StoryController>();

  FetchPostModel? fetchPostModel;
  // List mainPost = []; // *** >>> Google Ad Code <<< ***
  List<Post> mainPost = [];
  bool isLoadingPost = false;
  bool isPaginationLoading = false;

  @override
  void onInit() {
    scrollController.addListener(onPagination);
    super.onInit();
  }

  Future<void> init() async {
    storyController.init();

    isLoadingPost = true;
    mainPost.clear();
    update(["onGetPost"]);
    FetchPostApi.startPagination = 0;
    await onGetPost();
    isLoadingPost = false;
  }

  void onPagination() async {
    if (scrollController.position.pixels == scrollController.position.maxScrollExtent && isPaginationLoading == false) {
      isPaginationLoading = true;
      update(["onPagination"]);
      await onGetPost();
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

        // <<< Code Start *** >>> Google Ad Code <<< ***
        if (GoogleAdServices.isShowLargeNativeAdFeed) {
          for (int i = 0; i < paginationData.length; i++) {
            if (i % GoogleAdServices.adShowIndex == 0 && i != 0) {
              // mainPost.add(null);
              mainPost.add(paginationData[i]);
            } else {
              mainPost.add(paginationData[i]);
            }
          }
        } else {
          mainPost.addAll(paginationData);
        }
        // *** >>> Google Ad Code <<< *** Code End >>>

        // mainPost.addAll(paginationData);

        update(["onGetPost"]);
      } else {
        FetchPostApi.startPagination--;
      }
    }
    if (mainPost.isEmpty) {
      update(["onGetPost"]);
    }

    if (DeepLinkServices.isNavigationComplete) {
      DeepLinkServices.eventId = ""; // Refresh Time Not Show Same Post On Top
      DeepLinkServices.eventType = ""; // Refresh Time Not Show Same Post On Top
    }
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
