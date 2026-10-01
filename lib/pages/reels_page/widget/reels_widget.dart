import 'dart:developer';
import 'dart:io';

import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:readmore/readmore.dart';
import 'package:shortie/custom/custom_fetch_user_coin.dart';
import 'package:shortie/custom/custom_format_number.dart';
import 'package:shortie/custom/custom_icon_button.dart';
import 'package:shortie/deep_link/services/deep_link_services.dart';
import 'package:shortie/deep_link/share_manager/share_manager.dart';
import 'package:shortie/main.dart';
import 'package:shortie/pages/bottom_bar_page/controller/bottom_bar_controller.dart';
import 'package:shortie/pages/fake_live_page/widget/fake_send_gift_bottom_sheet_widget.dart';
import 'package:shortie/pages/reels_page/api/reels_like_dislike_api.dart';
import 'package:shortie/pages/reels_page/api/reels_share_api.dart';
import 'package:shortie/pages/reels_page/controller/reels_controller.dart';
import 'package:shortie/pages/fake_live_page/widget/fake_comment_data.dart';
// Reels API models (for Story in controller.mainReels[index].stories)
import 'package:shortie/pages/reels_page/model/fetch_reels_model.dart' show Story;
import 'package:shortie/pages/splash_screen_page/api/send_gift_api.dart';
// Story Viewer + models
import 'package:shortie/pages/story_page/model/fetch_story_model.dart' as Viewer;
import 'package:shortie/pages/story_page/widget/simple_story_viewer.dart';
import 'package:shortie/routes/app_routes.dart';
import 'package:shortie/ui/comment_bottom_sheet_ui.dart';
import 'package:shortie/ui/loading_ui.dart';
import 'package:shortie/ui/preview_network_image_ui.dart';
import 'package:shortie/ui/preview_profile_bottom_sheet_ui.dart';
import 'package:shortie/ui/report_bottom_sheet_ui.dart';
import 'package:shortie/ui/video_picker_bottom_sheet_ui.dart';
import 'package:shortie/utils/api.dart';
import 'package:shortie/utils/asset.dart';
import 'package:shortie/utils/color.dart';
import 'package:shortie/utils/constant.dart';
import 'package:shortie/utils/database.dart';
import 'package:shortie/utils/double_tap_detector.dart';
import 'package:shortie/utils/enums.dart';
import 'package:shortie/utils/font_style.dart';
import 'package:shortie/utils/like_animation_service.dart';
import 'package:shortie/utils/utils.dart';
import 'package:video_player/video_player.dart';

class PreviewReelsView extends StatefulWidget {
  const PreviewReelsView({super.key, required this.index, required this.currentPageIndex});

  final int index;
  final int currentPageIndex;

  @override
  State<PreviewReelsView> createState() => _PreviewReelsViewState();
}

class _PreviewReelsViewState extends State<PreviewReelsView> with SingleTickerProviderStateMixin {
  final controller = Get.find<ReelsController>();

  ChewieController? chewieController;
  VideoPlayerController? videoPlayerController;

  RxBool isPlaying = true.obs;
  RxBool isShowIcon = false.obs;

  RxBool isBuffering = false.obs;
  RxBool isVideoLoading = true.obs;

  RxBool isShowLikeAnimation = false.obs;
  RxBool isShowLikeIconAnimation = false.obs;

  RxBool isLike = false.obs;

  RxMap customChanges = {"like": 0, "comment": 0}.obs;

  AnimationController? _controller;
  late Animation<double> _animation;

  RxBool isReadMore = false.obs;

  @override
  void initState() {
    Utils.isCurrentlyVideoPage.value = true;

    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();

    _animation = Tween(begin: 0.0, end: 1.0).animate(_controller!);

    initializeVideoPlayer();
    customSetting();
    super.initState();
  }

  @override
  void dispose() {
    _controller?.dispose();
    onDisposeVideoPlayer();
    Utils.showLog("Dispose Method Called Success");
    super.dispose();
  }

  Future<void> initializeVideoPlayer() async {
    try {
      final videoPath = controller.mainReels[widget.index].videoUrl!;
      videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(videoPath));

      await videoPlayerController?.initialize();

      if (videoPlayerController != null && (videoPlayerController?.value.isInitialized ?? false)) {
        chewieController = ChewieController(
          videoPlayerController: videoPlayerController!,
          looping: true,
          allowedScreenSleep: false,
          allowMuting: false,
          showControlsOnInitialize: false,
          showControls: false,
          maxScale: 1,
        );

        if (chewieController != null) {
          isVideoLoading.value = false;
          if (widget.index == widget.currentPageIndex && Utils.isCurrentlyVideoPage.value) onPlayVideo();
        } else {
          isVideoLoading.value = true;
        }

        videoPlayerController?.addListener(() {
          isBuffering.value = videoPlayerController?.value.isBuffering ?? false;
          if (Utils.isCurrentlyVideoPage.value == false) onStopVideo();
        });
      }
    } catch (e) {
      onDisposeVideoPlayer();
      isVideoLoading.value = false;
      Utils.showLog("Reels Video Initialization Failed !!! ${widget.index} => $e");
    }
  }

  void onDisposeVideoPlayer() {
    try {
      onStopVideo();
      videoPlayerController?.dispose();
      chewieController?.dispose();
      chewieController = null;
      videoPlayerController = null;
      isVideoLoading.value = true;
    } catch (e) {
      Utils.showLog(">>>> On Dispose VideoPlayer Error => $e");
    }
  }

  void onStopVideo() {
    isPlaying.value = false;
    videoPlayerController?.pause();
  }

  void onPlayVideo() {
    isPlaying.value = true;
    videoPlayerController?.play();
  }

  void onAutoStopVideo() {
    Utils.isCurrentlyVideoPage.value = false;
    onStopVideo();
  }

  void onClickPlayPause() async {
    if (Utils.isCurrentlyVideoPage.value == false) {
      Utils.isCurrentlyVideoPage.value = true;
    }

    videoPlayerController!.value.isPlaying ? onStopVideo() : onPlayVideo();
  }

  void customSetting() {
    isLike.value = controller.mainReels[widget.index].isLike ?? false;
    customChanges["like"] = int.parse(controller.mainReels[widget.index].totalLikes.toString());
    int commentCount = int.parse(controller.mainReels[widget.index].totalComments.toString());
    if (commentCount == 0) {
      commentCount = fakeHostCommentListBlank.length;
    }
    customChanges["comment"] = commentCount;
  }

  void onClickVideo() async {
    if (!isVideoLoading.value) {
      videoPlayerController!.value.isPlaying ? onStopVideo() : onPlayVideo();
      isShowIcon.value = true;
      await 2.seconds.delay();
      isShowIcon.value = false;
    }
    if (Utils.isCurrentlyVideoPage.value == false) {
      Utils.isCurrentlyVideoPage.value = true;
    }
  }

  void onClickGift() async {
    if (controller.mainReels[widget.index].userId != Database.loginUserId) {
      onAutoStopVideo();

      FakeSendGiftBottomSheetWidget.show(
        context: context,
        onComplete: onClickPlayPause,
        function: (data) async {
          if (CustomFetchUserCoin.coin == 0 || CustomFetchUserCoin.coin < (data.coin ?? 0)) {
            Utils.showToast(
              EnumLocal.txtYouDonHaveSufficientCoinsToSendTheGift.name.tr,
              AppColor.colorTextDarkGrey.withValues(alpha: 0.85),
            );
          } else {
            FakeSendGiftBottomSheetWidget.isShowGift.value = true;
            data.type == 1 || data.type == 2 ? await 1500.milliseconds.delay() : await 8000.milliseconds.delay();
            FakeSendGiftBottomSheetWidget.isShowGift.value = false;

            if (mounted && widget.index == widget.currentPageIndex && Utils.isCurrentlyVideoPage.value) {
              onPlayVideo();
            }

            await SendGiftApi.callApi(
              loginUserId: Database.loginUserId,
              videoId: controller.mainReels[widget.index].id ?? "",
              giftId: data.id ?? "",
            );

            CustomFetchUserCoin.init();
          }
        },
      );
    } else {
      Utils.showToast(EnumLocal.txtYouCantSendGiftOwnVideo.name.tr);
    }
  }

  Future<void> onClickLike() async {
    if (isLike.value) {
      isLike.value = false;
      customChanges["like"]--;
    } else {
      isLike.value = true;
      customChanges["like"]++;
    }
    await onClickLikeAnimation();

    await ReelsLikeDislikeApi.callApi(
      loginUserId: Database.loginUserId,
      videoId: controller.mainReels[widget.index].id!,
    );
  }

  Future<void> onClickLikeAnimation() async {
    isShowLikeIconAnimation.value = true;
    log('isShowLikeIconAnimation.value --> ${isShowLikeIconAnimation.value}');

    await 500.milliseconds.delay();
    isShowLikeIconAnimation.value = false;
  }

  Future<void> onDoubleClick() async {
    if (isLike.value) {
      isLike.value = false;
      customChanges["like"]--;
    } else {
      isLike.value = true;
      customChanges["like"]++;
    }
    await onClickLikeAnimation();

    await ReelsLikeDislikeApi.callApi(
      loginUserId: Database.loginUserId,
      videoId: controller.mainReels[widget.index].id!,
    );
  }

  void onHorizontalDragEnd(details) {
    if ((details.primaryVelocity ?? 0.0) < 0) {
      onStopVideo();
      Get.toNamed(AppRoutes.previewUserProfilePage, arguments: controller.mainReels[widget.index].userId)?.then(
        (value) {
          onPlayVideo();
        },
      );
    }
  }

  Future<void> onClickComment() async {
    onAutoStopVideo();

    customChanges["comment"] = await CommentBottomSheetUi.show(
      context: context,
      commentType: 2,
      commentTypeId: controller.mainReels[widget.index].id!,
      totalComments: customChanges["comment"],
      onComplete: onClickPlayPause,
      showFakeComment: true,
    );
  }

  Future<void> onClickShare() async {
    onAutoStopVideo();

    Get.dialog(const LoadingUi(), barrierDismissible: false);

    try {
      final image = controller.mainReels[widget.index].videoImage ?? "";

      await ShareManager.shareContent(
        id: controller.mainReels[widget.index].id ?? "",
        title: controller.mainReels[widget.index].caption ?? "",
        imageUrl: (image?.startsWith("https") ?? false) ? (image ?? "") : (Api.baseUrl + (image ?? "")),
        shareType: ShareType.withImage,
        // Choose your preferred type
        pageRoutes: DeepLinkServices.reels,
      );

      await ReelsShareApi.callApi(
        loginUserId: Database.loginUserId,
        videoId: controller.mainReels[widget.index].id!,
      );
    } finally {
      Get.back();
      Utils.isCurrentlyVideoPage.value = true;
      onPlayVideo();
    }
  }

  void onClickMusic() async {
    onAutoStopVideo();

    if ((controller.mainReels[widget.index].songId ?? "").toString().isNotEmpty) {
      Get.toNamed(AppRoutes.audioWiseVideosPage, arguments: controller.mainReels[widget.index].songId);
    } else if (controller.mainReels[widget.index].userId != Database.loginUserId) {
      PreviewProfileBottomSheetUi.show(
        context: context,
        userId: controller.mainReels[widget.index].userId ?? "",
        onComplete: onClickPlayPause,
      );
    } else {
      final controller = Get.find<BottomBarController>();
      controller.onChangeBottomBar(4);
    }
  }

  void onClickProfile() async {
    onAutoStopVideo();
    if (controller.mainReels[widget.index].userId != Database.loginUserId) {
      PreviewProfileBottomSheetUi.show(
        context: context,
        userId: controller.mainReels[widget.index].userId ?? "",
        onComplete: onClickPlayPause,
      );
    } else {
      final controller = Get.find<BottomBarController>();
      controller.onChangeBottomBar(4);
    }
  }

  // =========================
  // Story Viewer integration
  // =========================

  Viewer.Stories _mapToViewerStory(Story s) {
    return Viewer.Stories(
      id: s.id,
      mediaImageUrl: s.mediaImageUrl,
      mediaVideoUrl: s.mediaVideoUrl,
      viewsCount: s.viewsCount,
      reactionsCount: s.reactionsCount,
      storyType: s.storyType,
      duration: s.duration,
      createdAt: s.createdAt?.toIso8601String(),
      backgroundSong: s.backgroundSong == null
          ? null
          : Viewer.BackgroundSong(
              id: s.backgroundSong!.id,
              songTitle: s.backgroundSong!.songTitle,
              songImage: s.backgroundSong!.songImage,
              singerName: s.backgroundSong!.singerName,
              songTime: s.backgroundSong!.songTime,
              songLink: s.backgroundSong!.songLink,
            ),
    );
  }

  Future<void> _openUserStoriesFromReel() async {
    final item = controller.mainReels[widget.index];
    final hasStories = (item.stories?.isNotEmpty ?? false);
    if (!hasStories) return;

    // 👇 force the generic + annotate variable type
    final List<Viewer.Stories> stories = item.stories!.map<Viewer.Stories>((s) => _mapToViewerStory(s)).toList();

    final group = Viewer.StoryGroup(
      user: Viewer.User(
        id: item.userId ?? item.id,
        name: item.name ?? "",
        userName: item.userName ?? "",
        image: item.userImage ?? "",
        isFake: item.userIsFake ?? false,
        isProfileImageBanned: item.isProfileImageBanned ?? false,
      ),
      stories: stories, // ✅ now List<Viewer.Stories>
    );

    await StoryViewer.openOthers(groups: [group], initialGroupIndex: 0);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.index == widget.currentPageIndex) {
      isReadMore.value = false;
      if (!isVideoLoading.value && Utils.isCurrentlyVideoPage.value) onPlayVideo();
    } else {
      if (!isVideoLoading.value) videoPlayerController?.seekTo(Duration.zero);
      onStopVideo();
    }

    final item = controller.mainReels[widget.index];
    final bool hasStories = (item.stories?.isNotEmpty ?? false);
    final GlobalKey likeKey = GlobalKey();
    return Scaffold(
      body: SizedBox(
        height: Get.height,
        width: Get.width,
        child: Stack(
          children: [
            DoubleTapDetector(
              onHorizontalDragEnd: (details) => onHorizontalDragEnd(details),
              onTap: onClickVideo,
              onDoubleTap: (details) {
                LikeAnimationService.instance.like(
                  details,
                  likeKey: likeKey,
                  context: context,
                  startSize: 50,
                  endSize: 45,
                  onLike: () async => isLike.value ? await onClickLikeAnimation() : await onDoubleClick(),
                  leftRightPosition: 0,
                );
              },
              child: Container(
                color: AppColor.black,
                height: (Get.height - AppConstant.bottomBarSize),
                width: Get.width,
                child: Stack(
                  children: [
                    Obx(
                      () => isVideoLoading.value
                          ? Container(
                              color: Colors.black,
                              child: Stack(
                                children: [
                                  if (item.videoImage != null)
                                    SizedBox(
                                      height: Get.height,
                                      width: Get.width,
                                      child: CachedNetworkImage(
                                        imageUrl: item.videoImage ?? '',
                                        fit: BoxFit.cover,
                                        errorWidget: (context, url, error) => Container(color: Colors.black),
                                      ),
                                    ),
                                  Center(
                                    child: Lottie.asset(
                                      AppAsset.lottieReelsLoader,
                                      width: 150,
                                      height: 150,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : SizedBox.expand(
                              child: FittedBox(
                                fit: BoxFit.cover,
                                child: SizedBox(
                                  width: videoPlayerController?.value.size.width ?? 0,
                                  height: videoPlayerController?.value.size.height ?? 0,
                                  child: Chewie(controller: chewieController!),
                                ),
                              ),
                            ),
                    ),
                    Obx(
                      () => isBuffering.value
                          ? Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: LinearProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(AppColor.primary),
                                backgroundColor: Colors.transparent,
                                minHeight: 2,
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ),

            // Watermark
            Positioned(
              top: MediaQuery.of(context).viewPadding.top + 15,
              left: 20,
              child: Visibility(
                visible: Utils.isShowWaterMark,
                child: CachedNetworkImage(
                  imageUrl: Utils.waterMarkIcon,
                  fit: BoxFit.contain,
                  imageBuilder: (context, imageProvider) => Image(
                    image: ResizeImage(imageProvider, width: Utils.waterMarkSize, height: Utils.waterMarkSize),
                    fit: BoxFit.contain,
                  ),
                  placeholder: (context, url) => const Offstage(),
                  errorWidget: (context, url, error) => const Offstage(),
                ),
              ),
            ),

            // Gift overlay
            Align(alignment: Alignment.center, child: FakeSendGiftBottomSheetWidget.onShowGift()),

            // // Like heart animation
            // Obx(
            //   () => Visibility(
            //     visible: isShowLikeAnimation.value,
            //     child: Align(
            //       alignment: Alignment.center,
            //       child: Lottie.asset(AppAsset.lottieLike, fit: BoxFit.cover, height: 300, width: 300),
            //     ),
            //   ),
            // ),

            // Play/Pause icon
            Obx(
              () => isShowIcon.value
                  ? Align(
                      alignment: Alignment.center,
                      child: GestureDetector(
                        onTap: onClickPlayPause,
                        child: Container(
                          height: 70,
                          width: 70,
                          padding: EdgeInsets.only(left: isPlaying.value ? 0 : 2),
                          decoration: BoxDecoration(color: AppColor.black.withValues(alpha: 0.2), shape: BoxShape.circle),
                          child: Center(
                            child: Image.asset(
                              isPlaying.value ? AppAsset.icPause : AppAsset.icPlay,
                              width: 30,
                              height: 30,
                              color: AppColor.white,
                            ),
                          ),
                        ),
                      ),
                    )
                  : const Offstage(),
            ),

            // Bottom gradient
            Positioned(
              bottom: 0,
              child: Obx(
                () => Visibility(
                  visible: (isVideoLoading == false),
                  child: Container(
                    height: Get.height / 4,
                    width: Get.width,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColor.transparent, AppColor.black.withValues(alpha: 0.7)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Top right actions
            Positioned(
              right: 0,
              child: Container(
                padding: Platform.isAndroid ? const EdgeInsets.only(top: 30) : const EdgeInsets.only(top: 46),
                height: Get.height,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomIconButton(
                      circleSize: 40,
                      iconSize: 25,
                      icon: AppAsset.icCreate,
                      callback: () {
                        onAutoStopVideo();
                        VideoPickerBottomSheetUi.show(context: context, onComplete: onClickPlayPause);
                      },
                    ),
                    5.width,
                    GestureDetector(
                      onTap: () {
                        onAutoStopVideo();
                        ReportBottomSheetUi.show(
                          context: context,
                          eventId: item.id ?? "",
                          eventType: 1,
                          onComplete: onClickPlayPause,
                        );
                      },
                      child: Container(
                        height: 40,
                        width: 40,
                        decoration: const BoxDecoration(shape: BoxShape.circle),
                        child: Icon(Icons.more_vert_rounded, color: AppColor.white, size: 30),
                      ),
                    ),
                    8.width,
                  ],
                ),
              ),
            ),

            // Right column actions (gift/like/comment/share/music)
            Positioned(
              right: 0,
              bottom: 5,
              child: Container(
                padding: const EdgeInsets.only(top: 30, bottom: 100),
                height: Get.height,
                child: Column(
                  children: [
                    const Spacer(),
                    GestureDetector(
                      onTap: onClickGift,
                      child: SizedBox(width: 65, child: Lottie.asset(AppAsset.lottieGift)),
                    ),
                    10.height,
                    SizedBox(
                      height: 45,
                      width: 45,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Obx(
                            () => AnimatedContainer(
                              key: likeKey,
                              duration: const Duration(milliseconds: 300),
                              height: isShowLikeIconAnimation.value ? 15 : 50,
                              width: isShowLikeIconAnimation.value ? 15 : 50,
                              alignment: Alignment.center,
                              child: CustomIconButton(
                                icon: AppAsset.icLike,
                                callback: onClickLike,
                                iconSize: 34,
                                iconColor: isLike.value ? AppColor.colorRedContainer : AppColor.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Obx(
                      () => Text(
                        CustomFormatNumber.convert(customChanges["like"]),
                        style: AppFontStyle.styleW700(AppColor.white, 14),
                      ),
                    ),
                    15.height,
                    CustomIconButton(icon: AppAsset.icComment, circleSize: 40, callback: onClickComment, iconSize: 34),
                    Obx(
                      () => Text(
                        CustomFormatNumber.convert(customChanges["comment"]),
                        style: AppFontStyle.styleW700(AppColor.white, 14),
                      ),
                    ),
                    15.height,
                    CustomIconButton(
                      circleSize: 40,
                      icon: AppAsset.icShare,
                      callback: onClickShare,
                      iconSize: 32,
                      iconColor: AppColor.white,
                    ),
                    const Text("", style: TextStyle(height: 0)),
                    GestureDetector(
                      onTap: onClickMusic,
                      child: SizedBox(
                        width: 50,
                        child: Stack(
                          alignment: Alignment.center,
                          clipBehavior: Clip.none,
                          children: [
                            RotationTransition(turns: _animation, child: Image.asset(AppAsset.icMusicCd)),
                            RotationTransition(
                              turns: _animation,
                              child: Container(
                                width: 30,
                                clipBehavior: Clip.antiAlias,
                                decoration: const BoxDecoration(shape: BoxShape.circle),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Image.asset(AppAsset.icProfilePlaceHolder),
                                    PreviewNetworkImageUi(image: item.userImage),
                                    if (item.isProfileImageBanned ?? false) const _BannedBlurCircle(),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(right: 4, bottom: -4, child: Image.asset(AppAsset.icMusic, width: 20)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ============================
            // Bottom-left: Avatar + meta
            // ============================
            Positioned(
              left: 15,
              bottom: 30,
              child: SizedBox(
                height: 400,
                width: Get.width / 1.5,
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Row: Avatar (tap -> stories if exist) + name/username (tap -> profile)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Avatar with gradient ring if stories exist
                            GestureDetector(
                              onTap: () async {
                                if (hasStories) {
                                  await _openUserStoriesFromReel();
                                } else {
                                  onClickProfile();
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(1),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: hasStories ? AppColor.primaryLinearGradient : null,

                                  // color: AppColor.white,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(1),
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    // color: AppColor.white,
                                  ),
                                  child: Container(
                                    height: 46,
                                    width: 46,
                                    clipBehavior: Clip.antiAlias,
                                    decoration: const BoxDecoration(shape: BoxShape.circle),
                                    child: Stack(
                                      children: [
                                        AspectRatio(aspectRatio: 1, child: Image.asset(AppAsset.icProfilePlaceHolder)),
                                        AspectRatio(aspectRatio: 1, child: PreviewNetworkImageUi(image: item.userImage)),
                                        if (item.isProfileImageBanned ?? false) const _BannedBlurCircle(),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            10.width,
                            // Name + username (tap -> profile bottom sheet)
                            GestureDetector(
                              onTap: onClickProfile,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: Get.width / 2,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            item.name ?? "",
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: AppFontStyle.styleW600(AppColor.white, 16.5),
                                          ),
                                        ),
                                        Visibility(
                                          visible: item.isVerified ?? false,
                                          child: Padding(
                                            padding: const EdgeInsets.only(left: 3),
                                            child: Image.asset(AppAsset.icBlueTick, width: 20),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    width: Get.width / 2,
                                    child: Text(
                                      item.userName ?? "",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppFontStyle.styleW500(AppColor.white, 13),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        10.height,

                        // Caption (read more)
                        Visibility(
                          visible: item.caption?.trim().isNotEmpty ?? false,
                          child: ReadMoreText(
                            item.caption ?? "",
                            trimMode: TrimMode.Line,
                            trimLines: 3,
                            style: AppFontStyle.styleW500(AppColor.white, 13),
                            colorClickableText: AppColor.primary,
                            trimCollapsedText: ' Show more',
                            trimExpandedText: ' Show less',
                            moreStyle: AppFontStyle.styleW500(AppColor.primary, 13.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BannedBlurCircle extends StatelessWidget {
  const _BannedBlurCircle();

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: const BoxDecoration(shape: BoxShape.circle),
        child: BlurryContainer(
          blur: 3,
          borderRadius: BorderRadius.circular(50),
          color: AppColor.black.withValues(alpha: 0.3),
          child: const Offstage(),
        ),
      ),
    );
  }
}
