import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortie/pages/bottom_bar_page/controller/bottom_bar_controller.dart';
import 'package:shortie/pages/feed_page/controller/feed_controller.dart';
import 'package:shortie/pages/feed_page/widget/feed_widget.dart';
import 'package:shortie/pages/story_page/widget/user_story_list_widget.dart';
import 'package:shortie/shimmer/feed_shimmer_ui.dart';
import 'package:shortie/ui/no_data_found_ui.dart';
import 'package:shortie/utils/color.dart';

class FeedView extends GetView<FeedController> {
  const FeedView({super.key});

  @override
  Widget build(BuildContext context) {
    controller.init();
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        Get.find<BottomBarController>().onChangeBottomBar(0);
      },
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 60,
          automaticallyImplyLeading: false,
          backgroundColor: AppColor.white,
          elevation: 1,
          shadowColor: AppColor.colorBorder.withValues(alpha: 0.5),
          surfaceTintColor: AppColor.transparent,
          flexibleSpace: const FeedAppBarView(),
        ),
        body: GetBuilder<FeedController>(
          id: "onGetPost",
          builder: (controller) => controller.isLoadingPost
              ? FeedShimmerUi()
              : RefreshIndicator(
                  color: AppColor.primary,
                  onRefresh: () async => await controller.init(),
                  child: SingleChildScrollView(
                    controller: controller.scrollController,
                    physics: AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        UserStoryListWidget(),
                        controller.mainPost.isEmpty
                            ? SizedBox(height: (Get.width), child: const NoDataFoundUi(iconSize: 160, fontSize: 19))
                            : ListView.builder(
                                shrinkWrap: true,
                                itemCount: controller.mainPost.length,
                                physics: NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  final post = controller.mainPost[index];

                                  debugPrint("Post index: $index, Post ID: ${post.id}");

                                  for (var i = 0; i < (post.userImage?.length ?? 0); i++) {
                                    debugPrint("Image[$i]: ${post.userImage?[i]}");
                                  }

                                  return PostView(
                                    id: post.id ?? "",
                                    userId: post.userId ?? "",
                                    profileImage: post.userImage ?? "",
                                    postImages: post.postImage ?? [],
                                    title: post.name ?? "",
                                    subTitle: post.userName ?? "",
                                    isLike: post.isLike ?? false,
                                    isFollow: post.isFollow ?? false,
                                    isVerified: post.isVerified ?? false,
                                    description: post.caption ?? "",
                                    hastTag: post.hashTag ?? [],
                                    time: post.time ?? "",
                                    likes: post.totalLikes ?? 0,
                                    comments: post.totalComments ?? 0,
                                    isFakeUser: post.isFake ?? false,
                                    isProfileImageBanned: post.isProfileImageBanned ?? false,
                                    userStory: post.stories ?? [],
                                  );
                                },
                              ),
                        // SizedBox(height: AppConstant.bottomBarSize.toDouble()), // Use For Last Element Proper Show...
                      ],
                    ),
                  ),
                ),
        ),
        bottomNavigationBar: GetBuilder<FeedController>(
          id: "onPagination",
          builder: (controller) => Visibility(
            visible: controller.isPaginationLoading,
            child: LinearProgressIndicator(color: AppColor.primary),
          ),
        ),
      ),
    );
  }
}
