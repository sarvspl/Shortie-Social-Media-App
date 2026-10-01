import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_typedefs/rx_typedefs.dart';
import 'package:shortie/main.dart';
import 'package:shortie/pages/story_page/api/fetch_story_viewer_api.dart';
import 'package:shortie/pages/story_page/model/fetch_story_viewer_model.dart';
import 'package:shortie/pages/story_page/widget/story_data_format.dart';
import 'package:shortie/ui/loading_ui.dart';
import 'package:shortie/ui/no_data_found_ui.dart';
import 'package:shortie/ui/preview_network_image_ui.dart';
import 'package:shortie/utils/asset.dart';
import 'package:shortie/utils/color.dart';
import 'package:shortie/utils/font_style.dart';
import 'package:shortie/utils/utils.dart';

class ViewersBottomSheetUi {
  static bool isBottomSheetOpen = false;

  static RxBool isLoading = false.obs;
  static FetchStoryViewerModel? fetchStoryViewerModel;
  static List<Viewers> viewerList = [];

  static Callback? function;

  static Future<void> onFetchViewers({required String storyId}) async {
    isLoading.value = true;
    fetchStoryViewerModel = await FetchStoryViewerApi.callApi(storyId: storyId);
    viewerList = fetchStoryViewerModel?.viewers ?? [];
    isLoading.value = false;
  }

  static void show({
    required BuildContext context,
    required String storyId,
    required Callback callback,
  }) {
    Utils.showLog("Selected Story Id => $storyId");
    function = callback;
    onFetchViewers(storyId: storyId);

    isBottomSheetOpen = true;

    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      backgroundColor: AppColor.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadiusDirectional.only(
          topEnd: Radius.circular(25),
          topStart: Radius.circular(25),
        ),
      ),
      builder: (context) => Container(
        height: 450,
        width: Get.width,
        clipBehavior: Clip.antiAlias,
        decoration: const BoxDecoration(
          color: AppColor.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Column(
          children: [
            Container(
              height: 65,
              decoration: const BoxDecoration(gradient: AppColor.primaryLinearGradient),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  45.width,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 4,
                          width: 35,
                          decoration: BoxDecoration(
                            color: AppColor.white.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        10.height,
                        Text(
                          "Viewers",
                          style: AppFontStyle.styleW700(AppColor.white, 17),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      height: 30,
                      width: 30,
                      margin: EdgeInsets.only(right: 15),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColor.transparent,
                        border: Border.all(color: AppColor.white),
                      ),
                      child: Center(
                        child: Image.asset(width: 15, AppAsset.icClose, color: AppColor.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Obx(
                () => isLoading.value
                    ? LoadingUi()
                    : viewerList.isEmpty
                        ? NoDataFoundUi(iconSize: 160, fontSize: 19)
                        : ListView.builder(
                            itemCount: viewerList.length,
                            itemBuilder: (context, index) {
                              final indexData = viewerList[index];
                              return ViewerUserListTile(
                                title: indexData.name ?? "",
                                subTitle: indexData.userName ?? "",
                                reaction: indexData.reaction ?? "",
                                time: StoryDataFormat.onFormat(indexData.viewedAt ?? ""),
                                leading: indexData.image ?? "",
                                callback: () {},
                                isVerified: false,
                                isProfileImageBanned: indexData.isProfileImageBanned ?? false,
                              );
                            },
                          ),
              ),
            ),
          ],
        ),
      ),
    ).then(
      (value) {
        isBottomSheetOpen = false;
        function?.call();
      },
    );
  }
}

class ViewerUserListTile extends StatelessWidget {
  const ViewerUserListTile({
    super.key,
    required this.title,
    required this.subTitle,
    required this.time,
    required this.leading,
    required this.reaction,
    required this.callback,
    required this.isVerified,
    required this.isProfileImageBanned,
  });

  final String title;
  final String subTitle;
  final String time;
  final String leading;
  final String reaction;
  final Callback callback;
  final bool isVerified;
  final bool isProfileImageBanned;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: callback,
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
            Container(
              height: 46,
              width: 46,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(color: AppColor.shimmer, shape: BoxShape.circle),
              child: Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 1,
                    child: Image.asset(AppAsset.icProfilePlaceHolder),
                  ),
                  AspectRatio(
                    aspectRatio: 1,
                    child: PreviewNetworkImageUi(image: leading),
                  ),
                  Visibility(
                    visible: isProfileImageBanned,
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
                          title,
                          maxLines: 1,
                          style: AppFontStyle.styleW700(AppColor.black, 15),
                        ),
                      ),
                      5.width,
                      Text(
                        "• ${time}",
                        maxLines: 1,
                        style: AppFontStyle.styleW400(AppColor.colorGreyDarkText, 12),
                      ),
                    ],
                  ),
                  Text(
                    subTitle,
                    maxLines: 1,
                    style: AppFontStyle.styleW400(AppColor.colorIconGrey, 12),
                  ),
                ],
              ),
            ),
            10.width,
            Visibility(
              visible: reaction.trim().isNotEmpty,
              child: SizedBox(
                height: 40,
                width: 40,
                child: PreviewProfileImageWidget(
                  image: reaction,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
