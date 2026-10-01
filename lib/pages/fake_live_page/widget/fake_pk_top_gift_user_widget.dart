import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortie/main.dart';
import 'package:shortie/pages/fake_live_page/controller/fake_live_controller.dart';
import 'package:shortie/pages/fake_live_page/widget/preview_fake_top_gifter_bottom_sheet_widget.dart';
import 'package:shortie/ui/preview_network_image_ui.dart';
import 'package:shortie/utils/asset.dart';
import 'package:shortie/utils/color.dart';
import 'package:shortie/utils/font_style.dart';
import 'package:shortie/utils/utils.dart';

class FakePkTopGiftUserWidget extends StatefulWidget {
  const FakePkTopGiftUserWidget({super.key});

  @override
  State<FakePkTopGiftUserWidget> createState() => _PkTopGiftUserWidgetState();
}

class _PkTopGiftUserWidgetState extends State<FakePkTopGiftUserWidget> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<FakeLiveController>(
      id: "onUpdateMultiLive",
      builder: (controller) => Container(
        height: 50,
        width: Get.width,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColor.blue.withValues(alpha: 0.5),
              AppColor.black,
              AppColor.pink.withValues(alpha: 0.9),
            ],
          ),
        ),
        child: Row(
          children: [
            // 10.width,
            // Image.asset(AppAsset.icArrowLeft, width: 18, color: AppColor.white),
            15.width,
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: GestureDetector(
                  onTap: () {
                    PreviewFakeTopGifterBottomSheetWidget.show(context: context, title: "Top Gifter", topGifter: controller.host1TopGiftUsers);
                  },
                  child: Container(
                    color: Colors.transparent,
                    child: ListView.builder(
                      itemCount: 3,
                      // itemCount: (controller.host1TopGiftUsers.length ?? 0) < 10 ? 3 : controller.host1TopGiftUsers.length,
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,

                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        final isAvailable = (controller.host1TopGiftUsers.length) > index;
                        final indexData = isAvailable ? controller.host1TopGiftUsers[index] : null;
                        return Container(
                          height: 35,
                          width: 35,
                          margin: EdgeInsets.only(right: 10),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColor.white),
                          ),
                          child: Container(
                            height: 35,
                            width: 35,
                            alignment: Alignment.center,
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColor.transparent,
                            ),
                            child: isAvailable == false
                                ? Image.asset(AppAsset.icSeat, width: 20)
                                : Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      SizedBox(
                                        height: 35,
                                        width: 35,
                                        child: PreviewProfileImageWidget(
                                          image: indexData?.userId?.image,
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.bottomCenter,
                                        child: Container(
                                          height: 28,
                                          width: 28,
                                          alignment: Alignment.center,
                                          padding: EdgeInsets.only(bottom: 10),
                                          margin: EdgeInsets.only(top: 28),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: AppColor.primary,
                                          ),
                                          child: Text(
                                            "${index + 1}",
                                            style: AppFontStyle.styleW600(AppColor.white, 7),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            40.width,
            Expanded(
              child: Align(
                alignment: AlignmentDirectional.centerEnd,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: GestureDetector(
                    onTap: () {
                      PreviewFakeTopGifterBottomSheetWidget.show(context: context, title: "Top Gifter", topGifter: controller.host2TopGiftUsers);
                    },
                    child: ListView.builder(
                      itemCount: 3,
                      reverse: true,
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        final isAvailable = (controller.host2TopGiftUsers.length) > index;

                        final indexData = isAvailable ? controller.host2TopGiftUsers[index] : null;
                        return GestureDetector(
                          onTap: () => Utils.showLog("******$index"),
                          child: Container(
                            height: 35,
                            width: 35,
                            margin: EdgeInsets.only(right: 10),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColor.white),
                            ),
                            child: Container(
                              height: 35,
                              width: 35,
                              alignment: Alignment.center,
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColor.transparent,
                              ),
                              child: isAvailable == false
                                  ? Image.asset(AppAsset.icSeat, width: 20)
                                  : Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        SizedBox(
                                          height: 35,
                                          width: 35,
                                          child: CustomPreviewImage(image: indexData?.userId?.image),
                                        ),
                                        Align(
                                          alignment: Alignment.bottomCenter,
                                          child: Container(
                                            height: 28,
                                            width: 28,
                                            alignment: Alignment.center,
                                            padding: EdgeInsets.only(bottom: 10),
                                            margin: EdgeInsets.only(top: 28),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: AppColor.primary,
                                            ),
                                            child: Text(
                                              "${index + 1}",
                                              style: AppFontStyle.styleW600(AppColor.white, 7),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            // Image.asset(AppAsset.icArrowRight, width: 18, color: AppColor.white),
            // 10.width,
          ],
        ),
      ),
    );
  }
}
