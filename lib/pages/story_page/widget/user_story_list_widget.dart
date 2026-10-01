import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_typedefs/rx_typedefs.dart';
import 'package:shortie/main.dart';
import 'package:shortie/pages/story_page/controller/story_controller.dart';
import 'package:shortie/pages/story_page/shimmer/user_story_list_shimmer_widget.dart';
import 'package:shortie/ui/preview_network_image_ui.dart';
import 'package:shortie/ui/story_picker_bottom_sheet_ui.dart';
import 'package:shortie/utils/asset.dart';
import 'package:shortie/utils/color.dart';
import 'package:shortie/utils/database.dart';
import 'package:shortie/utils/font_style.dart';

class UserStoryListWidget extends StatelessWidget {
  const UserStoryListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<StoryController>(
      id: "onFetchStories",
      builder: (controller) => Container(
        height: 110,
        width: Get.width,
        alignment: Alignment.centerLeft,
        color: AppColor.transparent,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: 5),
          scrollDirection: Axis.horizontal,
          child: controller.isLoading
              ? UserStoryListShimmerWidget()
              : ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: controller.otherStoryList.length + 1,
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    if (controller.otherStoryList.isNotEmpty) {
                      final indexData = controller.otherStoryList[index == 0 ? 0 : index - 1];

                      final i = (index - 1);
                      return index == 0
                          ? YourStoryCircleWidget(
                              image: Database.fetchLoginUserProfileModel?.user?.image ?? "",
                              isBanned: Database.fetchLoginUserProfileModel?.user?.isProfileImageBanned ?? false,
                              callback: () {
                                if (controller.ownStoryList.isEmpty || controller.ownStoryItems.isEmpty) {
                                  StoryPickerBottomSheetUi.show(context: context);
                                } else {
                                  controller.onClickOwnStoryCircle();
                                }
                              },
                              onClickAdd: () => StoryPickerBottomSheetUi.show(context: context),
                            )
                          : OtherStoryCircleWidget(
                              name: indexData.user?.name ?? "",
                              image: indexData.user?.image ?? "",
                              isBanned: indexData.user?.isProfileImageBanned ?? false,
                              callback: () => controller.onClickOtherStoryCircle(index: i),
                              isViewed: (indexData.stories?.any((story) => story.isView == true)) ?? false,
                            );
                    } else {
                      return YourStoryCircleWidget(
                        image: Database.fetchLoginUserProfileModel?.user?.image ?? "",
                        isBanned: Database.fetchLoginUserProfileModel?.user?.isProfileImageBanned ?? false,
                        callback: () {
                          if (controller.ownStoryList.isEmpty || controller.ownStoryItems.isEmpty) {
                            StoryPickerBottomSheetUi.show(context: context);
                          } else {
                            controller.onClickOwnStoryCircle();
                          }
                        },
                        onClickAdd: () => StoryPickerBottomSheetUi.show(context: context),
                      );
                    }
                  },
                ),
        ),
      ),
    );
  }
}

class YourStoryCircleWidget extends StatelessWidget {
  const YourStoryCircleWidget({
    super.key,
    required this.image,
    required this.isBanned,
    required this.callback,
    required this.onClickAdd,
  });

  final String image;
  final bool isBanned;
  final Callback callback;
  final Callback onClickAdd;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: callback,
      child: Container(
        color: Colors.transparent,
        height: 100,
        width: 85,
        alignment: Alignment.center,
        margin: EdgeInsets.only(left: 10),
        child: Column(
          children: [
            Container(
              height: 75,
              width: 75,
              decoration: BoxDecoration(shape: BoxShape.circle, gradient: AppColor.primaryLinearGradient),
              padding: EdgeInsets.all(2),
              child: Container(
                height: 75,
                width: 75,
                decoration: BoxDecoration(shape: BoxShape.circle, color: AppColor.white),
                padding: EdgeInsets.all(2),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      height: 75,
                      width: 75,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColor.white,
                      ),
                      child: CustomPreviewImage(image: image, isBanned: isBanned),
                    ),
                    Positioned(
                      bottom: -10,
                      right: -15,
                      child: GestureDetector(
                        onTap: onClickAdd,
                        child: Container(
                          height: 45,
                          width: 45,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColor.transparent,
                            shape: BoxShape.circle,
                          ),
                          child: Container(
                            height: 25,
                            width: 25,
                            decoration: BoxDecoration(
                              color: AppColor.white,
                              shape: BoxShape.circle,
                              gradient: AppColor.primaryLinearGradient,
                              border: Border.all(color: AppColor.white, width: 2),
                            ),
                            alignment: Alignment.center,
                            child: Image.asset(
                              AppAsset.icAdd,
                              color: AppColor.white,
                              width: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            4.height,
            Text(
              "Your Story",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppFontStyle.styleW500(AppColor.black, 13),
            ),
          ],
        ),
      ),
    );
  }
}

class OtherStoryCircleWidget extends StatelessWidget {
  const OtherStoryCircleWidget({
    super.key,
    required this.name,
    required this.image,
    required this.callback,
    required this.isBanned,
    required this.isViewed,
  });

  final String name;
  final String image;
  final bool isBanned;
  final bool isViewed;
  final Callback callback;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: callback,
      child: Container(
        color: Colors.transparent,
        height: 100,
        width: 85,
        alignment: Alignment.center,
        margin: EdgeInsets.only(left: 10),
        child: Column(
          children: [
            Container(
              height: 75,
              width: 75,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: isViewed ? null : AppColor.primaryLinearGradient,
                color: AppColor.colorTextGrey,
              ),
              padding: EdgeInsets.all(2),
              child: Container(
                height: 75,
                width: 75,
                decoration: BoxDecoration(shape: BoxShape.circle, color: AppColor.white),
                padding: EdgeInsets.all(2),
                child: Container(
                  height: 75,
                  width: 75,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColor.white,
                  ),
                  child: CustomPreviewImage(image: image, isBanned: isBanned),
                ),
              ),
            ),
            4.height,
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppFontStyle.styleW500(AppColor.black, 13),
            ),
          ],
        ),
      ),
    );
  }
}
