import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_typedefs/rx_typedefs.dart';
import 'package:shortie/custom/custom_format_number.dart';
// App deps
import 'package:shortie/main.dart';
import 'package:shortie/pages/connection_page/api/follow_unfollow_api.dart';
import 'package:shortie/pages/profile_page/api/fetch_profile_api.dart';
import 'package:shortie/pages/profile_page/model/fetch_profile_model.dart' hide User; // hide to avoid name clash
import 'package:shortie/pages/story_page/model/fetch_story_model.dart';
import 'package:shortie/pages/story_page/widget/simple_story_viewer.dart';
import 'package:shortie/routes/app_routes.dart';
import 'package:shortie/shimmer/preview_profile_bottom_sheet_shimmer_ui.dart';
// import 'package:shortie/ui/app_button_ui.dart';
// UI bits
import 'package:shortie/ui/preview_country_flag_ui.dart';
import 'package:shortie/ui/preview_network_image_ui.dart';
import 'package:shortie/utils/asset.dart';
import 'package:shortie/utils/color.dart';
import 'package:shortie/utils/database.dart';
import 'package:shortie/utils/enums.dart';
import 'package:shortie/utils/font_style.dart';
import 'package:shortie/utils/utils.dart';

class PreviewProfileBottomSheetUi {
  static bool isCallOnComplete = false;

  static FetchProfileModel? fetchProfileModel;
  static RxBool isLoadingProfile = false.obs;
  static RxBool isFollow = false.obs;
  static Function(bool isFollow)? onFollowChange;

  static Future<void> onGetProfile(String userId) async {
    try {
      isLoadingProfile.value = true;

      fetchProfileModel = await FetchProfileApi.callApi(
        loginUserId: Database.loginUserId,
        otherUserId: userId,
      );

      final user = fetchProfileModel?.userProfileData?.user;
      if (user != null) {
        isFollow.value = user.isFollow ?? false;
        onFollowChange?.call(isFollow.value);
      }
    } catch (_) {
      // optional: show toast or log
    } finally {
      isLoadingProfile.value = false;
    }
  }

  static Future<void> onClickFollow(String userId) async {
    if (userId == Database.loginUserId) {
      Utils.showToast(EnumLocal.txtYouCantFollowYourOwnAccount.name.tr);
      return;
    }
    // optimistic toggle
    isFollow.value = !isFollow.value;
    onFollowChange?.call(isFollow.value);
    try {
      await FollowUnfollowApi.callApi(loginUserId: Database.loginUserId, userId: userId);
    } catch (e) {
      // revert on failure
      isFollow.value = !isFollow.value;
      onFollowChange?.call(isFollow.value);
      // Utils.showToast(EnumLocal.txtWentWrong.name.tr);
    }
  }

  static void show({
    required String userId,
    required BuildContext context,
    Callback? onComplete,
    Function(bool isFollow)? onFollowChange,
  }) {
    PreviewProfileBottomSheetUi.onFollowChange = onFollowChange;
    isCallOnComplete = true;

    // fire & forget; Obx will rebuild when data arrives
    onGetProfile(userId);

    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      backgroundColor: AppColor.transparent,
      builder: (_) {
        return Container(
          height: 320,
          width: Get.width,
          clipBehavior: Clip.antiAlias,
          decoration: const BoxDecoration(
            color: AppColor.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(18),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                height: 45,
                color: AppColor.grey_100,
                child: Row(
                  children: [
                    const Spacer(),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Container(
                        //   height: 4,
                        //   width: 35,
                        //   decoration: BoxDecoration(
                        //     color: AppColor.colorTextDarkGrey,
                        //     borderRadius: BorderRadius.circular(10),
                        //   ),
                        // ),
                        // 10.height,
                        Text(
                          EnumLocal.txtViewProfile.name.tr,
                          style: AppFontStyle.styleW700(AppColor.black, 17),
                        ),
                      ],
                    ).paddingOnly(left: 50),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        height: 26,
                        width: 26,
                        margin: const EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColor.transparent,
                          border: Border.all(color: AppColor.black),
                        ),
                        child: Center(
                          child: Image.asset(AppAsset.icClose, width: 18, color: AppColor.black),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Body
              Expanded(
                child: Obx(() {
                  // ✅ compute inside Obx so values stay fresh
                  final profile = fetchProfileModel?.userProfileData?.user;
                  final bool hasStories = (fetchProfileModel?.stories?.isNotEmpty ?? false);

                  if (isLoadingProfile.value) {
                    return PreviewProfileBottomSheetShimmerUi();
                  }

                  return SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                      child: Column(
                        children: [
                          // Top Row: Avatar + Details + Arrow Button
                          Row(
                            children: [
                              // Avatar with story ring
                              GestureDetector(
                                onTap: () async {
                                  Get.back();
                                  if (!hasStories) return;
                                  final stories = (fetchProfileModel?.stories ?? [])
                                      .map<Stories>((s) => Stories.fromJson({
                                            "_id": s.id,
                                            "storyType": s.storyType,
                                            "mediaImageUrl": s.mediaImageUrl,
                                            "mediaVideoUrl": s.mediaVideoUrl,
                                            "duration": s.duration,
                                            "viewsCount": s.viewsCount,
                                            "reactionsCount": s.reactionsCount,
                                            "createdAt": s.createdAt?.toIso8601String(),
                                            "backgroundSong": s.backgroundSong == null
                                                ? null
                                                : {
                                                    "_id": s.backgroundSong?.id,
                                                    "songTitle": s.backgroundSong?.songTitle,
                                                    "songImage": s.backgroundSong?.songImage,
                                                    "singerName": s.backgroundSong?.singerName,
                                                    "songTime": s.backgroundSong?.songTime, // already double
                                                    "songLink": s.backgroundSong?.songLink,
                                                  },
                                          }))
                                      .toList();
                                  if (userId == Database.loginUserId) {
                                    await StoryViewer.openOwn(stories: stories, initialIndex: 0);
                                  } else {
                                    final group = StoryGroup(
                                      user: User(
                                        id: userId,
                                        name: profile?.name ?? "",
                                        userName: profile?.userName ?? "",
                                        image: profile?.image ?? "",
                                        isProfileImageBanned: profile?.isProfileImageBanned ?? false,
                                      ),
                                      stories: stories,
                                    );
                                    await StoryViewer.openOthers(groups: [group], initialGroupIndex: 0);
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: hasStories ? AppColor.primaryLinearGradient : null,
                                    color: AppColor.white,
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColor.white,
                                    ),
                                    child: Container(
                                      height: 80,
                                      width: 80,
                                      clipBehavior: Clip.antiAlias,
                                      decoration: const BoxDecoration(shape: BoxShape.circle),
                                      child: Stack(
                                        fit: StackFit.expand,
                                        children: [
                                          Image.asset(AppAsset.icProfilePlaceHolder, fit: BoxFit.cover),
                                          PreviewNetworkImageUi(image: profile?.image),
                                          if (profile?.isProfileImageBanned ?? false)
                                            BlurryContainer(
                                              blur: 3,
                                              color: AppColor.black.withValues(alpha: 0.3),
                                              borderRadius: BorderRadius.circular(40),
                                              child: const Offstage(),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              15.width,
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            profile?.name ?? "",
                                            overflow: TextOverflow.ellipsis,
                                            style: AppFontStyle.styleW700(AppColor.black, 18),
                                          ),
                                        ),
                                        Visibility(
                                          visible: profile?.isVerified ?? false,
                                          child: Padding(
                                            padding: const EdgeInsets.only(left: 3),
                                            child: Image.asset(AppAsset.icBlueTick, width: 18),
                                          ),
                                        ),
                                      ],
                                    ),
                                    2.height,
                                    Text(
                                      profile?.userName != null ? "${profile!.userName!}" : "",
                                      overflow: TextOverflow.ellipsis,
                                      style: AppFontStyle.styleW400(AppColor.colorGreyHasTagText, 13),
                                    ),
                                    8.height,
                                    Row(
                                      children: [
                                        (profile?.isFake ?? false)
                                            ? (profile?.countryFlagImage != null && profile!.countryFlagImage!.isNotEmpty)
                                                ? Image.network(profile.countryFlagImage!, width: 22)
                                                : const Offstage()
                                            : SizedBox(
                                                width: 20,
                                                child: PreviewCountryFlagUi.show(profile?.countryFlagImage),
                                              ),
                                        8.width,
                                        Container(
                                          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                                          decoration: BoxDecoration(
                                            color: AppColor.primary.withValues(alpha: 0.08),
                                            border: Border.all(color: AppColor.primary.withValues(alpha: 0.6), width: 0.8),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Image.asset(
                                                (profile?.gender ?? '').toLowerCase().trim() == "male" ? AppAsset.icMale : AppAsset.icFemale,
                                                width: 12,
                                                color: AppColor.primary,
                                              ),
                                              5.width,
                                              Text(
                                                (profile?.gender ?? '').toLowerCase().trim() == "male" ? EnumLocal.txtMale.name.tr : EnumLocal.txtFemale.name.tr,
                                                style: AppFontStyle.styleW600(AppColor.primary, 11),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              5.width,
                              GestureDetector(
                                onTap: () {
                                  isCallOnComplete = false;
                                  Get.back();
                                  Get.toNamed(AppRoutes.previewUserProfilePage, arguments: userId);
                                },
                                child: Container(
                                  height: 34,
                                  width: 34,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColor.transparent,
                                    border: Border.all(color: AppColor.colorBorder),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.chevron_right_rounded,
                                      size: 28,
                                      color: AppColor.colorTextDarkGrey,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          18.height,
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: AppColor.colorBorder.withValues(alpha: 0.5)),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    children: [
                                      Text(
                                        CustomFormatNumber.convert(fetchProfileModel?.userProfileData?.totalLikesOfVideoPost ?? 0),
                                        style: AppFontStyle.styleW700(AppColor.black, 18),
                                      ),
                                      Text(
                                        EnumLocal.txtLikes.name.tr,
                                        style: AppFontStyle.styleW400(AppColor.colorGreyHasTagText, 12),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(width: 1, height: 32, color: AppColor.colorBorder.withValues(alpha: 0.5)),
                                Expanded(
                                  child: Column(
                                    children: [
                                      Text(
                                        CustomFormatNumber.convert(fetchProfileModel?.userProfileData?.totalFollowing ?? 0),
                                        style: AppFontStyle.styleW700(AppColor.black, 18),
                                      ),
                                      Text(
                                        EnumLocal.txtFollowing.name.tr,
                                        style: AppFontStyle.styleW400(AppColor.colorGreyHasTagText, 12),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(width: 1, height: 32, color: AppColor.colorBorder.withValues(alpha: 0.5)),
                                Expanded(
                                  child: Column(
                                    children: [
                                      Text(
                                        CustomFormatNumber.convert(fetchProfileModel?.userProfileData?.totalFollowers ?? 0),
                                        style: AppFontStyle.styleW700(AppColor.black, 18),
                                      ),
                                      Text(
                                        EnumLocal.txtFollowers.name.tr,
                                        style: AppFontStyle.styleW400(AppColor.colorGreyHasTagText, 12),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          20.height,
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    isCallOnComplete = false;
                                    final args = {
                                      "id": userId,
                                      "name": profile?.name ?? "",
                                      "userName": profile?.userName ?? "",
                                      "image": profile?.image ?? "",
                                      "isBlueTik": profile?.isVerified ?? false,
                                      "isProfileImageBanned": profile?.isProfileImageBanned ?? false,
                                    };
                                    if (profile?.isFake == true) {
                                      Get.toNamed(AppRoutes.fakeChatPage, arguments: args)?.then((_) => Get.back());
                                    } else {
                                      Get.toNamed(AppRoutes.chatPage, arguments: args)?.then((_) => Get.back());
                                    }
                                  },
                                  child: Container(
                                    height: 52,
                                    decoration: BoxDecoration(
                                      color: AppColor.white,
                                      borderRadius: BorderRadius.circular(100),
                                      border: Border.all(color: AppColor.primary, width: 1.2),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      EnumLocal.txtMessage.name.tr,
                                      style: TextStyle(
                                        color: AppColor.primary,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: AppFontStyle.styleW600(AppColor.primary, 16).fontFamily,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              12.width,
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => onClickFollow(userId),
                                  child: Obx(
                                    () => Container(
                                      height: 52,
                                      decoration: BoxDecoration(
                                        gradient: isFollow.value ? null : AppColor.primaryLinearGradient,
                                        color: isFollow.value ? AppColor.colorBorder.withValues(alpha: 0.1) : null,
                                        borderRadius: BorderRadius.circular(100),
                                        border: isFollow.value ? Border.all(color: AppColor.colorBorder.withValues(alpha: 0.6), width: 1) : null,
                                      ),
                                      alignment: Alignment.center,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Image.asset(
                                            isFollow.value ? AppAsset.icFollowing : AppAsset.icFollow,
                                            height: 16,
                                            color: isFollow.value ? AppColor.primary : AppColor.white,
                                          ),
                                          8.width,
                                          Flexible(
                                            child: Text(
                                              isFollow.value ? EnumLocal.txtFollowing.name.tr : EnumLocal.txtFollow.name.tr,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                color: isFollow.value ? AppColor.primary : AppColor.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                fontFamily: AppFontStyle.styleW600(AppColor.primary, 16).fontFamily,
                                              ),
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
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        );
      },
    ).whenComplete(() => isCallOnComplete ? onComplete?.call() : null);
  }
}
