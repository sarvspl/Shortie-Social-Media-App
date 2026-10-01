import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortie/main.dart';
import 'package:shortie/pages/fake_live_page/controller/fake_live_controller.dart';
import 'package:shortie/pages/fake_live_page/widget/fake_comment_data.dart';
import 'package:shortie/ui/preview_network_image_ui.dart';
import 'package:shortie/ui/scroll_fade_effect_widget.dart';
import 'package:shortie/utils/color.dart';
import 'package:shortie/utils/font_style.dart';

class FakeCommentsWidget extends StatelessWidget {
  const FakeCommentsWidget({super.key, required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FakeLiveController>(
      id: "initializeVideoPlayer",
      builder: (controller) => GetBuilder<FakeLiveController>(
        id: "onChangeComment",
        builder: (controller) {
          return SingleChildScrollView(
            physics: NeverScrollableScrollPhysics(),
            child: Container(
              height: height,
              width: Get.width / 1.8,
              color: AppColor.transparent,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: ScrollFadeEffectWidget(
                  axis: Axis.vertical,
                  child: SingleChildScrollView(
                    controller: controller.scrollController,
                    child: ListView.builder(
                      itemCount: fakeHostCommentListBlank.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      itemBuilder: (context, index) {
                        return CommentItemUi(
                          title: fakeHostCommentListBlank[index].user,
                          subTitle: fakeHostCommentListBlank[index].message,
                          leading: fakeHostCommentListBlank[index].image,
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class CommentItemUi extends StatelessWidget {
  const CommentItemUi({
    super.key,
    required this.title,
    required this.subTitle,
    required this.leading,
  });

  final String title;
  final String subTitle;
  final String leading;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Get.width / 2,
      padding: EdgeInsets.symmetric(horizontal: 15),
      margin: EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(color: AppColor.transparent),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 38,
                width: 38,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(shape: BoxShape.circle, color: AppColor.colorBorder.withValues(alpha: 0.8)),
                child: CustomPreviewImage(image: leading),
              ),
            ],
          ),
          10.width,
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  style: AppFontStyle.styleW700Shadow(AppColor.white, 14, [Shadow(color: AppColor.black.withValues(alpha: 0.5), offset: Offset(0, 1), blurRadius: 2)]),
                ),
                2.height,
                Text(
                  subTitle,
                  style: AppFontStyle.styleW600(AppColor.white, 13.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
