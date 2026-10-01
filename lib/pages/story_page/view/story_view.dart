import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_typedefs/rx_typedefs.dart';
import 'package:shortie/main.dart';
import 'package:shortie/pages/story_page/controller/story_controller.dart' as con;
import 'package:shortie/pages/story_page/widget/story_data_format.dart';
import 'package:shortie/ui/circle_icon_button_ui.dart';
import 'package:shortie/ui/preview_network_image_ui.dart';
import 'package:shortie/utils/asset.dart';
import 'package:shortie/utils/color.dart';
import 'package:shortie/utils/database.dart';
import 'package:shortie/utils/enums.dart';
import 'package:shortie/utils/font_style.dart';
import 'package:shortie/utils/utils.dart';
import 'package:story_view/story_view.dart';

class OwnStoryView extends GetView<con.StoryController> {
  const OwnStoryView({super.key});

  @override
  Widget build(BuildContext context) {
    Utils.onChangeStatusBar(brightness: Brightness.light, delay: 300);

    return Scaffold(
      body: Stack(
        children: [
          GestureDetector(
            onVerticalDragStart: (details) => controller.onHandleDragStart(details: details),
            onVerticalDragUpdate: (details) => controller.onHandleDragUpdate(details: details, context: context, isOwnStory: true),
            child: SizedBox(
              height: Get.height,
              child: StoryView(
                storyItems: controller.ownStoryItems,
                controller: controller.ownStoryController,
                onComplete: () => controller.onComplete(isOwnStory: true),
                onStoryShow: (storyItem, index) => controller.onStoryShow(index: index, isOwnStory: true),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).viewPadding.top + 20,
            child: Container(
              height: 70,
              width: Get.width,
              padding: EdgeInsets.only(left: 8, right: 15),
              decoration: BoxDecoration(
                color: Colors.transparent,
              ),
              child: Row(
                children: [
                  Container(
                    height: 40,
                    width: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColor.transparent,
                    ),
                    child: GestureDetector(
                      onTap: () => controller.onClickClose(),
                      child: Image.asset(
                        width: 25,
                        AppAsset.icBack,
                        color: AppColor.white,
                      ),
                    ),
                  ),
                  5.width,
                  Container(
                    height: 55,
                    width: 55,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColor.transparent,
                    ),
                    child: PreviewProfileImageWidget(
                      image: Database.fetchLoginUserProfileModel?.user?.image ?? "",
                      isBanned: Database.fetchLoginUserProfileModel?.user?.isProfileImageBanned ?? false,
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
                              fit: FlexFit.loose,
                              child: Text(
                                Database.fetchLoginUserProfileModel?.user?.name ?? "",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppFontStyle.styleW700(AppColor.white, 15),
                              ),
                            ),
                            5.width,
                            GetBuilder<con.StoryController>(
                              builder: (controller) => Text(
                                StoryDataFormat.onFormat(controller.ownStoryList[controller.storyIndex].createdAt ?? ""),
                                style: AppFontStyle.styleW400(AppColor.white, 12),
                              ),
                            ),
                          ],
                        ),
                        GetBuilder<con.StoryController>(
                          builder: (controller) => controller.ownStoryList[controller.storyIndex].backgroundSong?.id != null
                              ? Container(
                                  width: Get.width,
                                  margin: EdgeInsets.only(top: 2),
                                  child: Row(
                                    children: [
                                      Image.asset(
                                        AppAsset.icMusic,
                                        width: 10,
                                      ),
                                      5.width,
                                      Expanded(
                                        child: Text(
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          "${controller.ownStoryList[controller.storyIndex].backgroundSong?.songTitle ?? ""} • ${controller.ownStoryList[controller.storyIndex].backgroundSong?.singerName ?? ""}",
                                          style: AppFontStyle.styleW400(AppColor.white, 12),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : Offstage(),
                        ),
                      ],
                    ),
                  ),
                  10.width,
                  Container(
                    height: 40,
                    width: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColor.white.withValues(alpha: 0.2),
                    ),
                    child: GestureDetector(
                      onTap: () => controller.onDeleteStory(),
                      child: Image.asset(
                        width: 22,
                        AppAsset.icDelete,
                        color: AppColor.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: MediaQuery.of(context).viewPadding.bottom + 20,
            child: Container(
              width: Get.width,
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(AppAsset.icView, width: 22, color: AppColor.white),
                  8.width,
                  GetBuilder<con.StoryController>(
                    id: "onStoryShow",
                    builder: (controller) => Text(
                      "${controller.ownStoryList[controller.storyIndex].viewsCount ?? 0} Views",
                      style: AppFontStyle.styleW700(AppColor.white, 14),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OtherStoryView extends GetView<con.StoryController> {
  const OtherStoryView({super.key});

  @override
  Widget build(BuildContext context) {
    Utils.onChangeStatusBar(brightness: Brightness.light, delay: 300);

    controller.onChangeKeyboardVisibility(context);
    return Scaffold(
      backgroundColor: AppColor.black,
      body: PageView.builder(
        itemCount: controller.otherStoryItems.length,
        controller: controller.pageController,
        onPageChanged: (value) => controller.onPageChange(value),
        itemBuilder: (context, index) {
          return Stack(
            children: [
              SizedBox(
                height: Get.height,
                child: SingleChildScrollView(
                  physics: NeverScrollableScrollPhysics(),
                  child: GestureDetector(
                    onVerticalDragStart: (details) => controller.onHandleDragStart(details: details),
                    onVerticalDragUpdate: (details) => controller.onHandleDragUpdate(details: details, context: context, isOwnStory: false),
                    child: SizedBox(
                      height: Get.height,
                      width: Get.width,
                      child: StoryView(
                        storyItems: controller.otherStoryItems[index],
                        controller: controller.otherStoryController,
                        onComplete: () => controller.onComplete(isOwnStory: false),
                        onStoryShow: (storyItem, i) => controller.onStoryShow(
                          index: i,
                          isOwnStory: false,
                          isView: controller.otherStoryList[index].stories?[i].isView ?? false,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 0,
                child: Container(
                  height: Get.height / 4,
                  width: Get.width,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColor.black.withValues(alpha: 0.8),
                        AppColor.transparent,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).viewPadding.top + 20,
                child: Container(
                  height: 70,
                  width: Get.width,
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                  ),
                  child: Row(
                    children: [
                      Container(
                        height: 55,
                        width: 55,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColor.transparent,
                        ),
                        child: PreviewProfileImageWidget(
                          image: controller.otherStoryList[index].user?.image ?? "",
                          isBanned: controller.otherStoryList[index].user?.isProfileImageBanned ?? false,
                        ),
                      ),
                      10.width,
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GetBuilder<con.StoryController>(
                              id: "onStoryShow",
                              builder: (controller) => Row(
                                children: [
                                  Flexible(
                                    fit: FlexFit.loose,
                                    child: Text(
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      controller.otherStoryList[index].user?.name ?? "",
                                      style: AppFontStyle.styleW700Shadow(AppColor.white, 15, [Shadow(color: AppColor.black.withValues(alpha: 0.5), offset: Offset(0, 1), blurRadius: 2)]),
                                    ),
                                  ),
                                  5.width,
                                  Text(
                                    StoryDataFormat.onFormat(controller.otherStoryList[index].stories?[controller.storyIndex].createdAt ?? ""),
                                    style: AppFontStyle.styleW400Shadow(AppColor.white, 12, [Shadow(color: AppColor.black.withValues(alpha: 0.5), offset: Offset(0, 1), blurRadius: 2)]),
                                  ),
                                ],
                              ),
                            ),
                            GetBuilder<con.StoryController>(
                              builder: (controller) => controller.otherStoryList[index].stories?[controller.storyIndex].backgroundSong?.id != null
                                  ? Container(
                                      width: Get.width,
                                      margin: EdgeInsets.only(top: 2),
                                      child: Row(
                                        children: [
                                          Image.asset(
                                            AppAsset.icMusic,
                                            width: 10,
                                          ),
                                          5.width,
                                          Expanded(
                                            child: Text(
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              "${controller.otherStoryList[index].stories?[controller.storyIndex].backgroundSong?.songTitle ?? ""} • ${controller.otherStoryList[index].stories?[controller.storyIndex].backgroundSong?.singerName ?? ""}",
                                              style: AppFontStyle.styleW400Shadow(AppColor.white, 12, [Shadow(color: AppColor.black.withValues(alpha: 0.5), offset: Offset(0, 1), blurRadius: 2)]),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : Offstage(),
                            ),
                          ],
                        ),
                      ),
                      10.width,
                      Container(
                        height: 40,
                        width: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColor.transparent,
                        ),
                        child: GestureDetector(
                          onTap: () => controller.onClickClose(),
                          child: Image.asset(
                            width: 25,
                            AppAsset.icClose,
                            color: AppColor.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: MediaQuery.of(context).viewPadding.bottom + 20,
                child: Container(
                  width: Get.width,
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: Row(
                    children: [
                      Expanded(
                        child: CommentTextFieldUi(
                          controller: controller.commentController,
                          callback: () => controller.onClickSendComment(isSingleStory: false),
                          onTap: () => controller.otherStoryController.pause(),
                          onComplete: () => controller.otherStoryController.play(),
                        ),
                      ),
                      10.width,
                      CircleIconButtonUi(
                        circleSize: 50,
                        iconSize: 45,
                        color: AppColor.white,
                        icon: AppAsset.icEmoji,
                        callback: () => controller.onClickReaction(context: context, isSingleStory: false),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class SingleStoryView extends GetView<con.StoryController> {
  const SingleStoryView({super.key});

  @override
  Widget build(BuildContext context) {
    controller.onChangeKeyboardVisibility(context);
    return Scaffold(
      backgroundColor: AppColor.black,
      body: Stack(
        children: [
          SizedBox(
            height: Get.height,
            child: SingleChildScrollView(
              physics: NeverScrollableScrollPhysics(),
              child: GestureDetector(
                onVerticalDragStart: (details) => controller.onHandleDragStart(details: details),
                onVerticalDragUpdate: (details) => controller.onHandleDragUpdate(details: details, context: context, isOwnStory: false),
                child: SizedBox(
                  height: Get.height,
                  width: Get.width,
                  child: StoryView(
                    storyItems: controller.singleStoryItems,
                    controller: controller.singleStoryController,
                    onComplete: () => controller.onComplete(isOwnStory: false, isSingleStory: true),
                    onStoryShow: (storyItem, index) {},
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).viewPadding.top + 20,
            child: Container(
              height: 70,
              width: Get.width,
              padding: EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.transparent,
              ),
              child: Row(
                children: [
                  Container(
                    height: 55,
                    width: 55,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColor.transparent,
                    ),
                    child: PreviewProfileImageWidget(
                      image: controller.chatObject?.storyOwnerId?.image ?? "",
                      isBanned: controller.chatObject?.storyOwnerId?.isProfileImageBanned ?? false,
                    ),
                  ),
                  10.width,
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GetBuilder<con.StoryController>(
                          id: "onStoryShow",
                          builder: (controller) => Row(
                            children: [
                              Flexible(
                                fit: FlexFit.loose,
                                child: Text(
                                  controller.chatObject?.storyOwnerId?.name ?? "",
                                  style: AppFontStyle.styleW700(AppColor.white, 15),
                                ),
                              ),
                              5.width,
                              Text(
                                StoryDataFormat.onFormat(controller.chatObject?.storyId?.createdAt ?? ""),
                                style: AppFontStyle.styleW400(AppColor.white, 12),
                              ),
                            ],
                          ),
                        ),
                        GetBuilder<con.StoryController>(
                          builder: (controller) => controller.chatObject?.storyId?.backgroundSong?.id != null
                              ? Container(
                                  width: Get.width,
                                  margin: EdgeInsets.only(top: 2),
                                  child: Row(
                                    children: [
                                      Image.asset(
                                        AppAsset.icMusic,
                                        width: 10,
                                      ),
                                      5.width,
                                      Expanded(
                                        child: Text(
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          "${controller.chatObject?.storyId?.backgroundSong?.songTitle ?? ""} • ${controller.chatObject?.storyId?.backgroundSong?.singerName ?? ""}",
                                          style: AppFontStyle.styleW400(AppColor.white, 12),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : Offstage(),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 40,
                    width: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColor.transparent,
                    ),
                    child: GestureDetector(
                      onTap: () => controller.onClickClose(),
                      child: Image.asset(
                        width: 25,
                        AppAsset.icClose,
                        color: AppColor.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: MediaQuery.of(context).viewPadding.bottom + 20,
            child: Container(
              width: Get.width,
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                children: [
                  Expanded(
                    child: CommentTextFieldUi(
                      controller: controller.commentController,
                      callback: () => controller.onClickSendComment(isSingleStory: true),
                      onTap: () => controller.singleStoryController.pause(),
                      onComplete: () => controller.singleStoryController.play(),
                    ),
                  ),
                  10.width,
                  CircleIconButtonUi(
                    circleSize: 50,
                    iconSize: 45,
                    color: AppColor.white,
                    icon: AppAsset.icEmoji,
                    callback: () => controller.onClickReaction(context: context, isSingleStory: true),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CommentTextFieldUi extends StatelessWidget {
  const CommentTextFieldUi({
    super.key,
    this.callback,
    this.controller,
    this.onTap,
    this.onComplete,
  });

  final Callback? callback;
  final Callback? onTap;
  final Callback? onComplete;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.only(left: 15, right: 5),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            height: 22,
            width: 22,
            AppAsset.icCommentGradiant,
          ),
          5.width,
          VerticalDivider(
            indent: 12,
            endIndent: 12,
            color: AppColor.coloGreyText.withValues(alpha: 0.3),
          ),
          5.width,
          Expanded(
            child: TextFormField(
              controller: controller,
              cursorColor: AppColor.colorTextGrey,
              maxLines: 1,
              onTap: onTap,
              onFieldSubmitted: (value) => onComplete?.call(),
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: const EdgeInsets.only(bottom: 3),
                hintText: EnumLocal.txtTypeComment.name.tr,
                hintStyle: AppFontStyle.styleW400(AppColor.coloGreyText, 15),
              ),
            ),
          ),
          GestureDetector(
            onTap: callback,
            child: Container(
              height: 40,
              width: 40,
              color: AppColor.transparent,
              child: Center(
                child: Image.asset(width: 26, AppAsset.icSend),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
