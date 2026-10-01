import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_typedefs/rx_typedefs.dart';
import 'package:shortie/main.dart';
import 'package:shortie/pages/story_page/api/fetch_reaction_api.dart';
import 'package:shortie/pages/story_page/api/send_reaction_to_story_api.dart';
import 'package:shortie/pages/story_page/model/fetch_reaction_model.dart';
import 'package:shortie/ui/loading_ui.dart';
import 'package:shortie/ui/preview_network_image_ui.dart';
import 'package:shortie/utils/asset.dart';
import 'package:shortie/utils/color.dart';
import 'package:shortie/utils/database.dart';
import 'package:shortie/utils/enums.dart';
import 'package:shortie/utils/font_style.dart';
import 'package:shortie/utils/utils.dart';

class ReactionBottomSheetUi {
  static bool isBottomSheetOpen = false;

  static RxBool isLoading = false.obs;
  static FetchReactionModel? fetchReactionModel;
  static List<ReactionData> reactionList = [];

  static Callback? function;

  static Future<void> onFetchReaction() async {
    if (reactionList.isEmpty) {
      isLoading.value = true;
      fetchReactionModel = await FetchReactionApi.callApi();
      reactionList = fetchReactionModel?.data ?? [];
      isLoading.value = false;
    }
  }

  static Future<void> onSendReaction({required String storyId, required String reaction}) async {
    Get.back(); // Close Bottom Sheet

    Utils.showToast("Sending Reaction....");

    await SendReactionToStoryApi.callApi(
      loginUserId: Database.loginUserId,
      storyId: storyId,
      reaction: reaction,
    );

    if (SendReactionToStoryApi.sendReactionToStoryModel?.status == true) {
      Utils.showToast("Send Reaction To Story");
    }
  }

  static void show({
    required BuildContext context,
    required String storyId,
    required Callback callback,
  }) {
    Utils.showLog("Selected Story Id => $storyId");
    function = callback;
    onFetchReaction();

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
                        15.height,
                        Text(
                          "Send Reaction",
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
                    : GridView.builder(
                        itemCount: reactionList.length,
                        padding: const EdgeInsets.all(12),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.88,
                        ),
                        itemBuilder: (context, index) => Container(
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            color: AppColor.white,
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(color: AppColor.colorBorder),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              5.height,
                              Expanded(child: PreviewPostImageWidget(image: reactionList[index].image ?? "")),
                              8.height,
                              GestureDetector(
                                onTap: () {
                                  onSendReaction(reaction: reactionList[index].image ?? "", storyId: storyId);
                                },
                                child: Container(
                                  height: 35,
                                  width: Get.width,
                                  decoration: const BoxDecoration(
                                    gradient: AppColor.primaryLinearGradient,
                                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
                                  ),
                                  child: Center(
                                    child: Text(
                                      EnumLocal.txtSend.name.tr,
                                      style: AppFontStyle.styleW600(AppColor.white, 16),
                                    ),
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
      ),
    ).then(
      (value) {
        isBottomSheetOpen = false;
        function?.call();
      },
    );
  }
}
