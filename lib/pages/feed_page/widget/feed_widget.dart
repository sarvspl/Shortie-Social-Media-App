import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:readmore/readmore.dart';
import 'package:shortie/custom/custom_format_number.dart';
import 'package:shortie/custom/preview_full_screen_image_widget.dart';
import 'package:shortie/deep_link/services/deep_link_services.dart';
import 'package:shortie/deep_link/share_manager/share_manager.dart';
import 'package:shortie/main.dart';
import 'package:shortie/pages/bottom_bar_page/controller/bottom_bar_controller.dart';
import 'package:shortie/pages/connection_page/api/follow_unfollow_api.dart';
import 'package:shortie/pages/feed_page/api/post_like_dislike_api.dart';
import 'package:shortie/pages/feed_page/api/post_share_api.dart';
import 'package:shortie/pages/feed_page/controller/feed_controller.dart';
import 'package:shortie/pages/feed_page/model/fetch_post_model.dart' as fetch_post_model;
import 'package:shortie/pages/feed_page/model/post_image_model.dart';
import 'package:shortie/pages/profile_page/controller/profile_controller.dart';
import 'package:shortie/pages/story_page/model/fetch_story_model.dart';
import 'package:shortie/routes/app_routes.dart';
import 'package:shortie/ui/comment_bottom_sheet_ui.dart';
import 'package:shortie/ui/delete_post_dialog_ui.dart';
import 'package:shortie/ui/gradient_text_ui.dart';
import 'package:shortie/ui/loading_ui.dart';
import 'package:shortie/ui/preview_network_image_ui.dart';
import 'package:shortie/ui/preview_profile_bottom_sheet_ui.dart';
import 'package:shortie/ui/report_bottom_sheet_ui.dart';
import 'package:shortie/utils/api.dart';
import 'package:shortie/utils/asset.dart';
import 'package:shortie/utils/color.dart';
import 'package:shortie/utils/database.dart';
import 'package:shortie/utils/double_tap_detector.dart';
import 'package:shortie/utils/enums.dart';
import 'package:shortie/utils/font_style.dart';
import 'package:shortie/utils/like_animation_service.dart';
import 'package:shortie/utils/utils.dart';

import '../../../utils/constant.dart';
import '../../story_page/widget/simple_story_viewer.dart';

class PostView extends StatefulWidget {
  const PostView(
      {super.key,
      required this.id,
      required this.userId,
      required this.profileImage,
      required this.postImages,
      required this.title,
      required this.subTitle,
      required this.time,
      required this.description,
      required this.hastTag,
      required this.isLike,
      required this.isFollow,
      required this.isVerified,
      required this.likes,
      required this.comments,
      required this.isFakeUser,
      required this.isProfileImageBanned,
      required this.userStory,
      this.isProfileTap = true});

  final String id;
  final String userId;
  final String profileImage;
  final bool isProfileImageBanned;
  final List<PostImage> postImages;
  final String title;
  final String subTitle;
  final String time;
  final String description;

  final List hastTag;

  final bool isLike;
  final bool isProfileTap;
  final bool isVerified;
  final bool isFollow;
  final bool isFakeUser;
  final List<fetch_post_model.Story> userStory;

  final int likes;
  final int comments;

  @override
  State<PostView> createState() => _PostViewState();
}

class _PostViewState extends State<PostView> {
  RxBool isLike = false.obs;
  RxBool isFollow = false.obs;

  RxInt likes = 0.obs;
  RxInt comments = 0.obs;
  final GlobalKey likeKey = GlobalKey();

  RxBool isShowLikeIconAnimation = false.obs;

  @override
  void initState() {
    isLike.value = widget.isLike;
    isFollow.value = widget.isFollow;

    likes.value = widget.likes;
    comments.value = widget.comments;
    super.initState();
  }

  Future<void> onClickLike() async {
    if (isLike.value) {
      isLike.value = false;
      likes--;
    } else {
      isLike.value = true;
      likes++;
    }
    await likeAnimation();
    await PostLikeDislikeApi.callApi(loginUserId: Database.loginUserId, postId: widget.id);
  }

  Future<void> likeAnimation() async {
    isShowLikeIconAnimation.value = true;
    await 500.milliseconds.delay();
    isShowLikeIconAnimation.value = false;
  }

  Future<void> onClickFollow() async {
    if (Database.loginUserId != widget.userId) {
      isFollow.value = !isFollow.value;
      await FollowUnfollowApi.callApi(loginUserId: Database.loginUserId, userId: widget.userId);
    } else {
      Utils.showToast(EnumLocal.txtYouCantFollowYourOwnAccount.name.tr);
    }
  }

  List<Stories> convertToStoriesList(List<fetch_post_model.Story> stories) {
    return stories.map((story) {
      BackgroundSong? convertedSong;
      if (story.backgroundSong != null) {
        convertedSong = BackgroundSong(
          id: story.backgroundSong?.id,
          songTitle: story.backgroundSong?.songTitle,
          songImage: story.backgroundSong?.songImage,
          singerName: story.backgroundSong?.singerName,
          songTime: story.backgroundSong?.songTime,
          songLink: story.backgroundSong?.songLink,
        );
      }

      return Stories(
        id: story.id,
        mediaImageUrl: story.mediaImageUrl,
        mediaVideoUrl: story.mediaVideoUrl,
        viewsCount: story.viewsCount,
        reactionsCount: story.reactionsCount,
        isView: false,
        backgroundSong: convertedSong,
        storyType: story.storyType,
        duration: story.duration,
        isFake: false,
        createdAt: story.createdAt?.toIso8601String(),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final bool hasStories = widget.userStory.isNotEmpty;

    return Container(
      padding: const EdgeInsets.only(bottom: 10),
      margin: const EdgeInsets.only(bottom: 5),
      decoration: BoxDecoration(
        border: Border.symmetric(
          horizontal: BorderSide(color: AppColor.colorBorderGrey.withValues(alpha: 0.4)),
        ),
        color: AppColor.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              if (widget.userId != Database.loginUserId) {
                if (widget.isProfileTap) PreviewProfileBottomSheetUi.show(context: context, userId: widget.userId);
              } else {
                final bottomBarController = Get.find<BottomBarController>();
                bottomBarController.onChangeBottomBar(4);
              }
            },
            child: Container(
              padding: const EdgeInsets.only(
                top: 10,
                left: 15,
                right: 8,
                bottom: 10,
              ),
              color: AppColor.colorTextGrey.withValues(alpha: 0.12),
              // color: AppColor.colorGreyBg,
              width: Get.width,
              child: Row(
                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () async {
                      if (widget.userStory.isEmpty) {
                        if (widget.userId != Database.loginUserId) {
                          if (widget.isProfileTap) {
                            PreviewProfileBottomSheetUi.show(context: context, userId: widget.userId);
                          }
                        } else {
                          final bottomBarController = Get.find<BottomBarController>();
                          bottomBarController.onChangeBottomBar(4);
                        }
                        return;
                      }

                      List<Stories> stories = convertToStoriesList(widget.userStory);

                      if (widget.userId == Database.loginUserId) {
                        await StoryViewer.openOwn(stories: stories, initialIndex: 0);
                      } else {
                        StoryGroup group = StoryGroup(
                          user: User(
                            id: widget.userId,
                            name: widget.title,
                            userName: widget.subTitle,
                            image: widget.profileImage,
                            isProfileImageBanned: widget.isProfileImageBanned,
                          ),
                          stories: stories,
                        );

                        await StoryViewer.openOthers(groups: [group], initialGroupIndex: 0);
                      }
                    },
                    child: Container(
                      height: 44,
                      width: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: hasStories ? AppColor.primaryLinearGradient : null,
                        color: hasStories ? AppColor.colorTextGrey : AppColor.transparent,
                      ),
                      padding: const EdgeInsets.all(2),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: hasStories ? AppColor.white : AppColor.transparent,
                        ),
                        padding: const EdgeInsets.all(2),
                        child: Container(
                          clipBehavior: Clip.antiAlias,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                          child: CustomPreviewImage(
                            image: widget.profileImage,
                            isBanned: widget.isProfileImageBanned,
                          ),
                        ),
                      ),
                    ),
                  ),
                  10.width,
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                widget.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppFontStyle.styleW700(
                                  AppColor.black,
                                  14,
                                ),
                              ),
                            ),
                            if (widget.isVerified)
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 2,
                                ),
                                child: Image.asset(
                                  AppAsset.icBlueTick,
                                  width: 18,
                                  height: 18,
                                ),
                              ),
                          ],
                        ),
                        Text(
                          widget.subTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppFontStyle.styleW500(
                            AppColor.colorGreyDarkText,
                            11,
                          ),
                        )
                      ],
                    ),
                  ),
                  if (widget.userId != Database.loginUserId)
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: GestureDetector(
                        onTap: onClickFollow,
                        child: Obx(
                          () => Container(
                            constraints: const BoxConstraints(
                              minWidth: 70,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: isFollow.value ? AppColor.primary : AppColor.white,
                              borderRadius: BorderRadius.circular(
                                20,
                              ),
                              border: Border.all(
                                color: isFollow.value ? AppColor.transparent : AppColor.colorBorderGrey,
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset(
                                  isFollow.value ? AppAsset.icFollowing : AppAsset.icFollow,
                                  width: 16,
                                  color: isFollow.value ? AppColor.white : null,
                                ),
                                4.width,
                                Flexible(
                                  child: Text(
                                    isFollow.value ? EnumLocal.txtFollowing.name.tr : EnumLocal.txtFollow.name.tr,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppFontStyle.styleW500(
                                      isFollow.value ? AppColor.white : AppColor.primary,
                                      12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  GestureDetector(
                    onTap: () {
                      if (Database.loginUserId == widget.userId) {
                        final contoller = Get.find<ProfileController>();
                        // Own post — show delete option
                        DeletePostDialogUi.onShow(callBack: () => contoller.onDeletePost(postId: widget.id));
                      } else {
                        // Others post — show report option
                        ReportBottomSheetUi.show(
                          context: context,
                          eventId: widget.id,
                          eventType: 2,
                        );
                      }
                    },
                    child: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(color: AppColor.transparent, shape: BoxShape.circle),
                      child: Icon(
                        Icons.more_vert_rounded,
                        color: AppColor.black.withValues(alpha: 0.5),
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                15.height,
                SizedBox(
                  height: Get.width / 2,
                  child: ListView.builder(
                    itemCount: widget.postImages.length,
                    padding: EdgeInsets.zero,
                    scrollDirection: Axis.horizontal,
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return DoubleTapDetector(
                        onTap: () => Get.to(PreviewFullScreenImageWidget(posts: widget.postImages, initialIndex: index)),
                        onDoubleTap: (details) {
                          LikeAnimationService.instance.like(
                            details,
                            likeKey: likeKey,
                            context: context,
                            endSize: 24,
                            startSize: 50,
                            onLike: () async => isLike.value ? await likeAnimation() : await onClickLike(),
                            leftRightPosition: 0,
                          );
                        },
                        child: Container(
                          clipBehavior: Clip.antiAlias,
                          height: Get.width / 2,
                          width: 160,
                          margin: const EdgeInsets.only(right: 10),
                          decoration: BoxDecoration(
                            color: AppColor.colorTextGrey.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: CustomPreviewImage(
                            image: widget.postImages[index].url,
                            isBanned: widget.postImages[index].isBanned,
                            isProfileImage: false,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                widget.description.trim().isEmpty
                    ? Offstage()
                    : Column(
                        children: [
                          10.height,
                          ReadMoreText(
                            widget.description,
                            trimMode: TrimMode.Line,
                            trimLines: 3,
                            style: AppFontStyle.styleW500(AppColor.black, 15),
                            colorClickableText: AppColor.primary,
                            trimCollapsedText: ' Show more',
                            trimExpandedText: ' Show less',
                            moreStyle: AppFontStyle.styleW500(AppColor.primary, 15),
                          ),
                        ],
                      ),
                widget.hastTag.isEmpty
                    ? Offstage()
                    : Column(
                        children: [
                          8.height,
                          Wrap(
                            spacing: 8.0, // gap between adjacent chips
                            runSpacing: 4.0, // gap between lines
                            children: <Widget>[
                              for (int index = 0; index < widget.hastTag.length; index++)
                                Container(
                                  padding: const EdgeInsets.only(left: 12, right: 12, bottom: 2),
                                  margin: EdgeInsets.only(bottom: 3),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: AppColor.colorBorderGrey, width: 1),
                                  ),
                                  child: Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text: '# ',
                                          style: AppFontStyle.styleW500(AppColor.primary, 15),
                                        ),
                                        TextSpan(
                                          text: widget.hastTag[index],
                                          style: AppFontStyle.styleW500(AppColor.colorGreyHasTagText, 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                5.height,
                Text(
                  widget.time,
                  style: AppFontStyle.styleW500(AppColor.colorGreyHasTagText.withValues(alpha: 0.8), 12),
                ),
                8.height,
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: onClickLike,
                      child: Obx(
                        () => Container(
                          height: 30,
                          color: AppColor.transparent,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              AnimatedContainer(
                                key: likeKey,
                                duration: Duration(milliseconds: 300),
                                height: isShowLikeIconAnimation.value ? 12 : 30,
                                alignment: Alignment.center,
                                child: Image.asset(
                                  AppAsset.icLike,
                                  color: isLike.value ? AppColor.colorRedContainer : AppColor.colorUnselectedIcon,
                                  width: 24,
                                ),
                              ),
                              5.width,
                              Text(
                                CustomFormatNumber.convert(likes.value),
                                style: AppFontStyle.styleW700(AppColor.black, 15),
                              ),
                              5.width
                            ],
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        comments.value = await CommentBottomSheetUi.show(
                          context: context,
                          commentType: 1, // Comment Type 1 Means Post...
                          commentTypeId: widget.id,
                          totalComments: comments.value,
                        );
                      },
                      child: Obx(
                        () => Container(
                          height: 30,
                          color: AppColor.transparent,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image.asset(
                                AppAsset.icComment,
                                color: AppColor.colorUnselectedIcon,
                                width: 24,
                              ),
                              5.width,
                              Text(
                                CustomFormatNumber.convert(comments.value),
                                style: AppFontStyle.styleW700(AppColor.black, 15),
                              ),
                              8.width
                            ],
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        Get.dialog(const LoadingUi(), barrierDismissible: false); // Start Loading...

                        await ShareManager.shareContent(
                          id: widget.id,
                          title: widget.description,
                          imageUrl: (widget.postImages[0].url?.startsWith("https") ?? false) ? (widget.postImages[0].url ?? "") : (Api.baseUrl + (widget.postImages[0].url ?? "")),
                          shareType: ShareType.withImage,
                          // Choose your preferred type
                          pageRoutes: DeepLinkServices.feed,
                        );

                        Get.back(); // Stop Loading...

                        await PostShareApi.callApi(loginUserId: Database.loginUserId, postId: widget.id);
                      },
                      child: Container(
                        height: 30,
                        width: 38,
                        color: AppColor.transparent,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset(
                              AppAsset.icShare,
                              color: AppColor.colorUnselectedIcon,
                              width: 24,
                            ),
                          ],
                        ),
                      ),
                    ),
                    // GestureDetector(
                    //   onTap: () {
                    //
                    //   },
                    //   child: Container(
                    //     height: 30,
                    //     width: 50,
                    //     color: AppColor.transparent,
                    //     child: Row(
                    //       mainAxisAlignment: MainAxisAlignment.start,
                    //       crossAxisAlignment: CrossAxisAlignment.center,
                    //       children: [
                    //         Image.asset(
                    //           AppAsset.icMore,
                    //           color: AppColor.colorUnselectedIcon,
                    //           width: 24,
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // ),
                    const Spacer(),
                    Visibility(
                      visible: (widget.userId != Database.loginUserId),
                      child: GestureDetector(
                        onTap: () {
                          if (widget.isFakeUser) {
                            Get.toNamed(
                              AppRoutes.fakeChatPage,
                              arguments: {
                                "id": widget.userId,
                                "name": widget.title,
                                "userName": widget.subTitle,
                                "image": widget.profileImage,
                                "isBlueTik": widget.isVerified,
                                "isProfileImageBanned": widget.isProfileImageBanned,
                              },
                            );
                          } else {
                            Get.toNamed(
                              AppRoutes.chatPage,
                              arguments: {
                                "id": widget.userId,
                                "name": widget.title,
                                "userName": widget.subTitle,
                                "image": widget.profileImage,
                                "isBlueTik": widget.isVerified,
                                "isProfileImageBanned": widget.isProfileImageBanned,
                              },
                            );
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            gradient: AppColor.primaryLinearGradient,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(AppAsset.icSayHey, width: 20),
                              Text(
                                ' ${EnumLocal.txtSayHi.name.tr}',
                                style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  color: AppColor.white,
                                  fontFamily: AppConstant.appFontBold,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget iconView({
  String? countText,
  required String image,
  Color? color,
}) {
  return Row(
    children: [
      Image.asset(image, color: color ?? AppColor.colorUnselectedIcon, width: 24),
      5.width,
      countText != null
          ? Text(
              countText,
              style: AppFontStyle.styleW700(AppColor.black, 15),
            )
          : const Offstage(),
    ],
  );
}

class FeedAppBarView extends GetView<FeedController> {
  const FeedAppBarView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            children: [
              GradientTextUi(
                gradient: AppColor.primaryLinearGradientText,
                EnumLocal.txtFeeds.name.tr,
                style: AppFontStyle.appBarStyle(),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () => Get.toNamed(AppRoutes.searchPage),
                    child: Container(
                      height: 42,
                      width: 42,
                      decoration: const BoxDecoration(gradient: AppColor.primaryLinearGradient, shape: BoxShape.circle),
                      child: Center(child: Image.asset(AppAsset.icSearch, width: 20)),
                    ),
                  ),
                  10.width,
                  GestureDetector(
                    onTap: () => controller.onPickPost(context),
                    child: Container(
                      height: 42,
                      width: 100,
                      decoration: BoxDecoration(gradient: AppColor.primaryLinearGradient, borderRadius: BorderRadius.circular(24)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(AppAsset.icCreatePlus, width: 24),
                          5.width,
                          Text(
                            EnumLocal.txtCreate.name.tr,
                            style: AppFontStyle.styleW600(AppColor.white, 15),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void showDeleteBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) => Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 5,
              margin: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            ListTile(
              leading: const Icon(
                Icons.delete_outline_rounded,
                color: Colors.red,
                size: 22,
              ),
              title: Text(
                "Delete Post",
                style: AppFontStyle.styleW700(AppColor.colorRedContainer, 16),
              ),
              onTap: () {},
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    ),
  );
}
