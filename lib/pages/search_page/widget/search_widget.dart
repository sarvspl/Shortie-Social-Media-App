import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_typedefs/rx_typedefs.dart';
import 'package:shortie/custom/custom_check_string_is_text_or_emoji.dart';
import 'package:shortie/custom/custom_format_number.dart';
import 'package:shortie/main.dart';
import 'package:shortie/pages/search_page/controller/search_controller.dart' as controller;
import 'package:shortie/pages/story_page/model/fetch_story_model.dart';
import 'package:shortie/routes/app_routes.dart';
import 'package:shortie/shimmer/hash_tag_shimmer_ui.dart';
import 'package:shortie/shimmer/user_list_shimmer_ui.dart';
import 'package:shortie/ui/no_data_found_ui.dart';
import 'package:shortie/ui/preview_network_image_ui.dart';
import 'package:shortie/ui/preview_profile_bottom_sheet_ui.dart';
import 'package:shortie/utils/asset.dart';
import 'package:shortie/utils/color.dart';
import 'package:shortie/utils/enums.dart';
import 'package:shortie/utils/font_style.dart';

class SearchAppBar extends StatelessWidget {
  const SearchAppBar({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            color: AppColor.transparent,
            margin: const EdgeInsets.only(top: 10),
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Center(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      height: 50,
                      width: 50,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColor.transparent,
                      ),
                      child: Center(child: Image.asset(AppAsset.icBack, width: 25)),
                    ),
                  ),
                  Expanded(
                    child: GetBuilder<controller.SearchController>(
                      id: "onSearching",
                      builder: (controller) => SearchFieldUi(
                        controller: controller.searchFieldController,
                        isShowClearIcon: controller.isSearching,
                        onChanged: (value) {
                          controller.onSearching();
                        },
                        onClickClear: () {
                          controller.searchFieldController.clear();
                          controller.onSearching();
                        },
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Get.toNamed(AppRoutes.scanQrCodePage),
                    child: Container(
                      height: 50,
                      width: 50,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColor.transparent,
                      ),
                      child: Center(child: Image.asset(AppAsset.icQr, width: 26)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const TabBarUi(),
        ],
      ),
    );
  }
}

class TabBarUi extends StatelessWidget {
  const TabBarUi({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColor.transparent,
        border: Border(bottom: BorderSide(color: AppColor.colorBorder)),
      ),
      child: GetBuilder<controller.SearchController>(
        id: "onChangeTabBar",
        builder: (logic) => Row(
          children: [
            tabItemUi(
              title: EnumLocal.txtSearch.name.tr,
              onTap: () => logic.onChangeTabBar(0),
              isSelected: logic.selectedTabIndex == 0,
            ),
            tabItemUi(
              title: EnumLocal.txtHashTag.name.tr,
              onTap: () => logic.onChangeTabBar(1),
              isSelected: logic.selectedTabIndex == 1,
            ),
          ],
        ),
      ),
    );
  }
}

Widget tabItemUi({required String title, required Callback onTap, required bool isSelected}) {
  return Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        height: 55,
        color: AppColor.transparent,
        child: Center(
          child: Text(
            title,
            style: AppFontStyle.styleW500(isSelected ? AppColor.primary : AppColor.coloGreyText, 17),
          ),
        ),
      ),
    ),
  );
}

class SearchUserTabUi extends StatelessWidget {
  const SearchUserTabUi({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<controller.SearchController>(
      id: "onSearching",
      builder: (logic) => logic.isSearching
          ? GetBuilder<controller.SearchController>(
              id: "onSearchUser",
              builder: (controller) => controller.isSearchingUser
                  ? UserListShimmerUi()
                  : controller.searchUsers.isEmpty
                      ? NoDataFoundUi(iconSize: 160, fontSize: 19)
                      : SingleChildScrollView(
                          padding: EdgeInsets.zero,
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: controller.searchUsers.length,
                            itemBuilder: (context, index) => UserListTile(
                              userStory: controller.searchUsers[index].stories,
                              userId: controller.searchUsers[index].id ?? "",
                              title: controller.searchUsers[index].name ?? "",
                              subTitle: controller.searchUsers[index].userName ?? "",
                              leading: controller.searchUsers[index].image ?? "",
                              isVerified: controller.searchUsers[index].isVerified ?? false,
                              isProfileImageBanned: controller.searchUsers[index].isProfileImageBanned ?? false,
                              callback: () => PreviewProfileBottomSheetUi.show(context: context, userId: controller.searchUsers[index].id ?? ""),
                            ),
                          ),
                        ),
            )
          : GetBuilder<controller.SearchController>(
              id: "onGetUser",
              builder: (controller) => controller.isLoadingUser
                  ? UserListShimmerUi()
                  : controller.userCollection.isEmpty
                      ? NoDataFoundUi(iconSize: 160, fontSize: 19)
                      : SingleChildScrollView(
                          padding: EdgeInsets.zero,
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: controller.userCollection.length,
                            itemBuilder: (context, index) => UserListTile(
                              userId: controller.userCollection[index].id ?? '',
                              userStory: controller.userCollection[index].stories,
                              title: controller.userCollection[index].name ?? "",
                              subTitle: controller.userCollection[index].userName ?? "",
                              leading: controller.userCollection[index].image ?? "",
                              isVerified: controller.userCollection[index].isVerified ?? false,
                              isProfileImageBanned: controller.userCollection[index].isProfileImageBanned ?? false,
                              callback: () => PreviewProfileBottomSheetUi.show(context: context, userId: controller.userCollection[index].id ?? ""),
                            ),
                          ),
                        ),
            ),
    );
  }
}

class HashTagTabUi extends StatelessWidget {
  const HashTagTabUi({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<controller.SearchController>(
      id: "onSearching",
      builder: (logic) => logic.isSearching
          ? GetBuilder<controller.SearchController>(
              id: "onSearchHashTag",
              builder: (controller) => controller.isSearchingHashTag
                  ? HashTagShimmerUi()
                  : controller.searchHashTags.isEmpty
                      ? NoDataFoundUi(iconSize: 160, fontSize: 19)
                      : SingleChildScrollView(
                          padding: EdgeInsets.zero,
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: controller.searchHashTags.length,
                            itemBuilder: (context, index) => HashTagItemUi(
                              leading: controller.searchHashTags[index].hashTagIcon ?? "",
                              title: controller.searchHashTags[index].hashTag ?? "",
                              video: CustomFormatNumber.convert(controller.searchHashTags[index].totalVideo ?? 0),
                              post: CustomFormatNumber.convert(controller.searchHashTags[index].totalPost ?? 0),
                              image: controller.searchHashTags[index].hashTagBanner ?? "",
                              onTap: () {
                                Get.toNamed(
                                  AppRoutes.previewHashTagPage,
                                  arguments: {"id": controller.searchHashTags[index].id, "name": controller.searchHashTags[index].hashTag},
                                );
                              },
                            ),
                          ),
                        ),
            )
          : GetBuilder<controller.SearchController>(
              id: "onGetHashTag",
              builder: (controller) => controller.isLoadingHashTag
                  ? HashTagShimmerUi()
                  : controller.hashTagCollection.isEmpty
                      ? NoDataFoundUi(iconSize: 160, fontSize: 19)
                      : SingleChildScrollView(
                          padding: EdgeInsets.zero,
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: controller.hashTagCollection.length,
                            itemBuilder: (context, index) => HashTagItemUi(
                              leading: controller.hashTagCollection[index].hashTagIcon ?? "",
                              title: controller.hashTagCollection[index].hashTag ?? "",
                              video: CustomFormatNumber.convert(controller.hashTagCollection[index].totalVideo ?? 0),
                              post: CustomFormatNumber.convert(controller.hashTagCollection[index].totalPost ?? 0),
                              image: controller.hashTagCollection[index].hashTagBanner ?? "",
                              onTap: () {
                                Get.toNamed(
                                  AppRoutes.previewHashTagPage,
                                  arguments: {"id": controller.hashTagCollection[index].id, "name": controller.hashTagCollection[index].hashTag},
                                );
                              },
                            ),
                          ),
                        ),
            ),
    );
  }
}

class HashTagItemUi extends StatelessWidget {
  const HashTagItemUi({
    super.key,
    required this.leading,
    required this.title,
    required this.video,
    required this.post,
    required this.image,
    required this.onTap,
  });

  final String leading;
  final String title;
  final String video;
  final String post;
  final String image;
  final Callback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        width: Get.width,
        decoration: BoxDecoration(
          color: AppColor.colorBorder.withValues(alpha: 0.1),
          border: Border(bottom: BorderSide(color: AppColor.colorBorder.withValues(alpha: 0.5))),
        ),
        child: Column(
          children: [
            Container(
              height: 65,
              width: Get.width,
              color: AppColor.transparent,
              alignment: Alignment.center,
              child: Row(
                children: [
                  Container(
                    height: 45,
                    width: 45,
                    clipBehavior: Clip.antiAlias,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(color: AppColor.colorBorder, shape: BoxShape.circle),
                    child: leading == "" && title.isNotEmpty
                        ? Text(
                            CustomCheckStringIsTextOrEmoji.onCheck(title[0]) ? title[0] : "#",
                            style: AppFontStyle.styleW700(AppColor.black, 24),
                          )
                        : Stack(
                            children: [
                              AspectRatio(
                                aspectRatio: 1,
                                child: Image.asset(AppAsset.icProfilePlaceHolder),
                              ),
                              AspectRatio(
                                aspectRatio: 1,
                                child: PreviewNetworkImageUi(image: leading),
                              ),
                            ],
                          ),
                  ),
                  15.width,
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          style: AppFontStyle.styleW700(AppColor.black, 16.5),
                        ),
                        Row(
                          children: [
                            Text(
                              "$video ${EnumLocal.txtVideos.name.tr} ,",
                              maxLines: 1,
                              style: AppFontStyle.styleW500(AppColor.colorIconGrey, 13),
                            ),
                            2.width,
                            Text(
                              "$post ${EnumLocal.txtPost.name.tr}",
                              maxLines: 1,
                              style: AppFontStyle.styleW500(AppColor.colorIconGrey, 13),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Text(
                    EnumLocal.txtViewAll.name.tr,
                    maxLines: 1,
                    style: AppFontStyle.styleW500(AppColor.coloGreyText, 14),
                  ),
                  5.width,
                  Image.asset(
                    width: 20,
                    AppAsset.icArrowRight,
                    color: AppColor.colorIconGrey,
                  ),
                ],
              ),
            ),
            Visibility(
              visible: image != "",
              child: Container(
                height: 176,
                width: Get.width,
                margin: EdgeInsets.only(bottom: 15),
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: AppColor.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: AppColor.colorBorder,
                      blurRadius: 0,
                      spreadRadius: 1.5,
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  fit: StackFit.expand,
                  children: [
                    Center(child: Image.asset(AppAsset.icImagePlaceHolder, width: 100)),
                    AspectRatio(
                      aspectRatio: 1,
                      child: PreviewNetworkImageUi(image: image),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class UserListTile extends StatefulWidget {
  const UserListTile({
    super.key,
    required this.title,
    required this.subTitle,
    required this.leading,
    required this.callback,
    required this.isVerified,
    required this.isProfileImageBanned,
    required this.userId,
    required this.userStory,
  });

  final String title;
  final String subTitle;
  final String leading;
  final String userId;
  final Callback callback;
  final bool isVerified;
  final bool isProfileImageBanned;
  final List<Stories>? userStory;

  @override
  State<UserListTile> createState() => _UserListTileState();
}

class _UserListTileState extends State<UserListTile> {
  // List<Stories> convertToStoriesList(List<fetch_post_model.Story> stories) {
  //   return stories.map((story) {
  //     BackgroundSong? convertedSong;
  //     if (story.backgroundSong != null) {
  //       convertedSong = BackgroundSong(
  //         id: story.backgroundSong?.id,
  //         songTitle: story.backgroundSong?.songTitle,
  //         songImage: story.backgroundSong?.songImage,
  //         singerName: story.backgroundSong?.singerName,
  //         songTime: story.backgroundSong?.songTime,
  //         songLink: story.backgroundSong?.songLink,
  //       );
  //     }
  //
  //     return Stories(
  //       id: story.id,
  //       mediaImageUrl: story.mediaImageUrl,
  //       mediaVideoUrl: story.mediaVideoUrl,
  //       viewsCount: story.viewsCount,
  //       reactionsCount: story.reactionsCount,
  //       isView: false,
  //       backgroundSong: story.backgroundSong,
  //       storyType: story.storyType,
  //       duration: story.duration,
  //       isFake: false,
  //       createdAt: story.createdAt?.toIso8601String(),
  //     );
  //   }).toList();
  // }

  @override
  Widget build(BuildContext context) {
    // final bool hasStories = widget.userStory.isNotEmpty;

    return GestureDetector(
      onTap: widget.callback,
      child: Container(
        height: 70,
        width: Get.width,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(
          color: AppColor.transparent,
          border: Border(
            bottom: BorderSide(color: AppColor.colorBorder.withValues(alpha: 0.5)),
          ),
        ),
        child: Row(
          children: [
            // GestureDetector(
            //   onTap: () async {
            //     // 1) Convert API model -> viewer model
            //     final List<Stories> stories = convertToStoriesList(widget.userStory);
            //
            //     if (stories.isEmpty) return; // no stories, no-op
            //
            //     if (widget.userId == Database.loginUserId) {
            //       // 2) Your own stories -> openOwn (shows viewers/deletes etc.)
            //       await StoryViewer.openOwn(stories: stories, initialIndex: 0);
            //     } else {
            //       // 3) Others' stories -> single group with proper user header
            //       final StoryGroup group = StoryGroup(
            //         user: User(
            //           id: widget.userId,
            //           name: widget.title, // display name
            //           userName: widget.subTitle, // if your header wants it
            //           image: widget.leading,
            //           isProfileImageBanned: widget.isProfileImageBanned,
            //         ),
            //         stories: stories, // <— IMPORTANT: all stories in ONE group
            //       );
            //
            //       await StoryViewer.openOthers(groups: [group], initialGroupIndex: 0);
            //     }
            //   },
            //   child: Container(
            //     height: 44,
            //     width: 44,
            //     decoration: BoxDecoration(
            //       shape: BoxShape.circle,
            //       gradient: hasStories ? AppColor.primaryLinearGradient : null,
            //       color: hasStories ? AppColor.colorTextGrey : AppColor.transparent,
            //     ),
            //     padding: EdgeInsets.all(2),
            //     child: Container(
            //       height: 44,
            //       width: 44,
            //       decoration: BoxDecoration(shape: BoxShape.circle, color: hasStories ? AppColor.white : AppColor.transparent),
            //       padding: EdgeInsets.all(2),
            //       child: Container(
            //         height: 44,
            //         width: 44,
            //         clipBehavior: Clip.antiAlias,
            //         decoration: BoxDecoration(
            //           shape: BoxShape.circle,
            //           color: AppColor.white,
            //         ),
            //         child: CustomPreviewImage(image: widget.leading, isBanned: widget.isProfileImageBanned),
            //       ),
            //     ),
            //   ),
            // ),
            GetBuilder<controller.SearchController>(builder: (controller) {
              return GestureDetector(
                onTap: () async => controller.onGetStory(
                  userId: widget.userId,
                  title: widget.title,
                  subTitle: widget.subTitle,
                  leading: widget.leading,
                  isProfileImageBanned: widget.isProfileImageBanned,
                  userStory: widget.userStory,
                ),
                child: Container(
                  height: 50,
                  width: 50,
                  padding: EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: widget.userStory?.isNotEmpty ?? true ? AppColor.primaryLinearGradient : null,
                  ),
                  child: Container(
                    height: 46,
                    width: 46,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(color: AppColor.shimmer, shape: BoxShape.circle, border: Border.all(color: AppColor.white)),
                    child: Stack(
                      children: [
                        AspectRatio(
                          aspectRatio: 1,
                          child: Image.asset(AppAsset.icProfilePlaceHolder),
                        ),
                        AspectRatio(
                          aspectRatio: 1,
                          child: ClipRRect(borderRadius: BorderRadius.circular(50), child: PreviewNetworkImageUi(image: widget.leading)),
                        ),
                        Visibility(
                          visible: widget.isProfileImageBanned,
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: Container(
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(shape: BoxShape.circle),
                              child: BlurryContainer(
                                blur: 3,
                                borderRadius: BorderRadius.circular(50),
                                color: AppColor.black.withValues(alpha: 0.3),
                                child: Offstage(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
            12.width,
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
                          widget.title,
                          maxLines: 1,
                          style: AppFontStyle.styleW700(AppColor.black, 14.5),
                        ),
                      ),
                      Visibility(
                        visible: widget.isVerified,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 3),
                          child: Image.asset(AppAsset.icBlueTick, width: 18),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    widget.subTitle,
                    maxLines: 1,
                    style: AppFontStyle.styleW400(AppColor.colorDarkGrey, 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SearchFieldUi extends StatelessWidget {
  const SearchFieldUi({
    super.key,
    required this.onClickClear,
    required this.controller,
    required this.onChanged,
    required this.isShowClearIcon,
  });

  final Callback onClickClear;
  final TextEditingController controller;
  final Function(String value) onChanged;
  final bool isShowClearIcon;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.only(left: 15, right: 12),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColor.colorUnselectedIcon.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColor.colorBorder.withValues(alpha: 0.8)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            height: 20,
            width: 20,
            AppAsset.icSearch,
            color: AppColor.black,
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
              onChanged: onChanged,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.only(top: 0),
                border: InputBorder.none,
                hintText: EnumLocal.txtSearchHintText.name.tr,
                hintStyle: AppFontStyle.styleW400(AppColor.coloGreyText, 17),
              ),
            ),
          ),
          Visibility(
            visible: isShowClearIcon,
            child: GestureDetector(
              onTap: onClickClear,
              child: Container(
                height: 30,
                width: 30,
                color: AppColor.transparent,
                child: Center(
                  child: Image.asset(
                    height: 20,
                    width: 20,
                    AppAsset.icClose,
                    color: AppColor.black,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
