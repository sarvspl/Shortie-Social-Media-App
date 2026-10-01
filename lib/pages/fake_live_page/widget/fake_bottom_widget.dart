import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_typedefs/rx_typedefs.dart';
import 'package:shortie/main.dart';
import 'package:shortie/pages/fake_live_page/controller/fake_live_controller.dart';
import 'package:shortie/pages/fake_live_page/widget/fake_send_gift_bottom_sheet_widget.dart';
import 'package:shortie/ui/circle_icon_button_ui.dart';
import 'package:shortie/utils/asset.dart';
import 'package:shortie/utils/color.dart';
import 'package:shortie/utils/database.dart';
import 'package:shortie/utils/enums.dart';
import 'package:shortie/utils/font_style.dart';

class FakeBottomWidget extends GetView<FakeLiveController> {
  const FakeBottomWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 75,
      width: Get.width,
      color: Colors.transparent,
      padding: EdgeInsets.all(15),
      child: Row(
        children: [
          Expanded(
            child: CommentTextFieldUi(
              controller: controller.commentController,
              callback: () => controller.onSendComment(),
              isDarkMode: controller.isPkMode == false,
            ),
          ),
          15.width,
          GestureDetector(
            onTap: () => FakeSendGiftBottomSheetWidget.show(
              context: context,
              function: (Data) {
                controller.onSendGift(
                  senderImage: Database.fetchLoginUserProfileModel?.user?.image ?? "",
                  senderName: Database.fetchLoginUserProfileModel?.user?.name ?? "",
                  senderUniqueId: Database.fetchLoginUserProfileModel?.user?.uniqueId ?? "",
                  senderProfilePicBanned: Database.fetchLoginUserProfileModel?.user?.isProfileImageBanned ?? false,
                  gift: Data,
                );
              },
            ),
            child: Container(
              height: 45,
              width: 45,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: controller.isPkMode == true ? AppColor.white.withValues(alpha: 0.3) : AppColor.white,
              ),
              child: Image.asset(AppAsset.icGiftLive, width: 35),
            ),
          ),
          15.width,
          LabeledCircleIconButton(
            circleSize: 40,
            iconSize: 25,
            icon: AppAsset.icShareLive,
            iconColor: AppColor.white,
            callback: controller.onShareLink,
            label: "Share",
          ),
        ],
      ),
    );
  }
}

class CommentTextFieldUi extends StatelessWidget {
  const CommentTextFieldUi({super.key, this.callback, this.controller, required this.isDarkMode});

  final Callback? callback;

  final TextEditingController? controller;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45,
      padding: const EdgeInsets.only(left: 15, right: 5),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isDarkMode ? AppColor.white : AppColor.white.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            height: 22,
            width: 22,
            AppAsset.icCommentGradiant,
            color: isDarkMode ? null : AppColor.white,
          ),
          5.width,
          VerticalDivider(
            indent: 12,
            endIndent: 12,
            color: isDarkMode ? AppColor.coloGreyText.withValues(alpha:0.3) : AppColor.white.withValues(alpha:0.3),
          ),
          5.width,
          Expanded(
            child: TextFormField(
              controller: controller,
              cursorColor: AppColor.colorTextGrey,
              maxLines: 1,
              style: AppFontStyle.styleW700(isDarkMode ? AppColor.black : AppColor.white, 14),
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: const EdgeInsets.only(bottom: 5),
                hintText: EnumLocal.txtTypeComment.name.tr,
                hintStyle: AppFontStyle.styleW400(isDarkMode ? AppColor.coloGreyText : AppColor.white, 14),
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
                child: Image.asset(
                  width: 26,
                  AppAsset.icSend,
                  color: isDarkMode ? null : AppColor.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
