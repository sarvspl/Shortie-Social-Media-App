import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortie/pages/bottom_bar_page/controller/bottom_bar_controller.dart';
import 'package:shortie/pages/feed_page/controller/feed_controller.dart';
import 'package:shortie/pages/feed_page/widget/feed_section_widget.dart';
import 'package:shortie/pages/feed_page/widget/feed_widget.dart';
import 'package:shortie/pages/story_page/widget/user_story_list_widget.dart';
import 'package:shortie/shimmer/feed_shimmer_ui.dart';
import 'package:shortie/shimmer/stream_shimmer_ui.dart';
import 'package:shortie/ui/no_data_found_ui.dart';
import 'package:shortie/utils/color.dart';

class FeedView extends StatelessWidget {
  const FeedView({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<FeedController>()) {
      Get.put(FeedController(), permanent: true);
    }
    final BottomBarController bottomBarController = Get.isRegistered<BottomBarController>()
        ? Get.find<BottomBarController>()
        : Get.put(BottomBarController(), permanent: true);

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        bottomBarController.onChangeBottomBar(0);
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
          id: "onSectionChange",
          builder: (controller) => RefreshIndicator(
            color: AppColor.primary,
            onRefresh: () async => await controller.init(),
            child: SingleChildScrollView(
              controller: controller.scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  const UserStoryListWidget(),
                  const FeedSectionTabBar(),
                  _buildSectionContent(controller),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: GetBuilder<FeedController>(
          id: "onPagination",
          builder: (controller) => Visibility(
            visible: controller.isPaginationLoading,
            child: const LinearProgressIndicator(color: AppColor.primary),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionContent(FeedController controller) {
    if (controller.selectedSection == 0) {
      // ── Popular Section ──────────────────────────────────────────────────
      return GetBuilder<FeedController>(
        id: "onGetPopular",
        builder: (c) {
          if (c.isLoadingPopular) {
            return const StreamShimmerUi();
          }
          if (c.popularUsers.isEmpty) {
            return SizedBox(
              height: Get.width,
              child: const NoDataFoundUi(iconSize: 140, fontSize: 18, text: "No popular users found"),
            );
          }
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              mainAxisExtent: 220,
            ),
            itemCount: c.popularUsers.length,
            itemBuilder: (context, index) {
              return PopularUserCard(user: c.popularUsers[index]);
            },
          );
        },
      );
    } else if (controller.selectedSection == 2) {
      // ── PK Matches Section ───────────────────────────────────────────────
      return GetBuilder<FeedController>(
        id: "onGetPkMatches",
        builder: (c) {
          if (c.isLoadingPkMatches) {
            return const StreamShimmerUi();
          }
          if (c.pkMatches.isEmpty) {
            return SizedBox(
              height: Get.width,
              child: const NoDataFoundUi(iconSize: 140, fontSize: 16, text: "No live PK matches right now"),
            );
          }
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              mainAxisExtent: 220,
            ),
            itemCount: c.pkMatches.length,
            itemBuilder: (context, index) {
              return PkMatchCard(liveData: c.pkMatches[index]);
            },
          );
        },
      );
    }

    // ── Default Feed Section ─────────────────────────────────────────────
    return GetBuilder<FeedController>(
      id: "onGetPost",
      builder: (c) {
        if (c.isLoadingPost) {
          return const FeedShimmerUi();
        }
        if (c.mainPost.isEmpty) {
          return SizedBox(
            height: Get.width,
            child: const NoDataFoundUi(iconSize: 160, fontSize: 19),
          );
        }
        return ListView.builder(
          shrinkWrap: true,
          itemCount: c.mainPost.length,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final post = c.mainPost[index];
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
        );
      },
    );
  }
}
