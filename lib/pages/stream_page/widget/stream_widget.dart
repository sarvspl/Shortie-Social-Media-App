import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:shortie/custom/custom_format_number.dart';
import 'package:shortie/main.dart';
import 'package:shortie/pages/stream_page/controller/stream_controller.dart';
import 'package:shortie/pages/stream_page/model/fetch_live_user_model.dart';
import 'package:shortie/routes/app_routes.dart';
import 'package:shortie/ui/gradient_text_ui.dart';
import 'package:shortie/ui/preview_network_image_ui.dart';
import 'package:shortie/utils/asset.dart';
import 'package:shortie/utils/color.dart';
import 'package:shortie/utils/enums.dart';
import 'package:shortie/utils/font_style.dart';

import '../../multi_live_page/view/multi_live_page_view.dart';

class StreamAppBarUi extends StatelessWidget {
  const StreamAppBarUi({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GradientTextUi(
                gradient: AppColor.primaryLinearGradientText,
                EnumLocal.txtLiveStreaming.name.tr,
                style: AppFontStyle.appBarStyle(),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () {
                      Get.toNamed(AppRoutes.searchPage);
                    },
                    child: Container(
                      height: 40,
                      width: 40,
                      decoration: const BoxDecoration(gradient: AppColor.primaryLinearGradient, shape: BoxShape.circle),
                      child: Center(child: Image.asset(AppAsset.icSearch, width: 20)),
                    ),
                  ),
                  5.width,
                  GestureDetector(
                    onTap: () {
                      Get.toNamed(AppRoutes.goLivePage);
                    },
                    child: Container(
                      height: 40,
                      width: 72,
                      decoration: BoxDecoration(gradient: AppColor.primaryLinearGradient, borderRadius: BorderRadius.circular(24)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            AppAsset.icTopStreaming,
                            height: 20,
                          ),
                          5.width,
                          Text(
                            EnumLocal.txtLive.name.tr,
                            style: AppFontStyle.styleW600(AppColor.white, 14.0),
                          ),
                        ],
                      ),
                    ),
                  ),
                  5.width,
                  GestureDetector(
                    onTap: () => Get.toNamed(AppRoutes.scanQrCodePage),
                    child: Container(
                      height: 40,
                      width: 40,
                      decoration: const BoxDecoration(gradient: AppColor.primaryLinearGradient, shape: BoxShape.circle),
                      child: Center(child: Image.asset(AppAsset.icQr, color: AppColor.white, width: 20)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LiveUserUi extends StatelessWidget {
  const LiveUserUi({super.key, required this.indexData});

  final LiveUserList indexData;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final controller = Get.find<StreamController>();

        if (indexData.isFake == true) {
          final List pkImages = indexData.pkPreviewImages ?? [];
          final List pkVideoUrl = indexData.pkMediaSources ?? [];

          Get.toNamed(AppRoutes.fakeLivePage, arguments: {
            "isHost": false,
            "isFollow": indexData.isFollow ?? false,
            "roomId": indexData.liveHistoryId ?? "",
            "userId": indexData.userId ?? "",
            "userName": indexData.userName ?? "",
            "name": indexData.name ?? "",
            "image": pkImages.isNotEmpty ? pkImages[0] : indexData.videoImage ?? "",
            "videoUrl": pkVideoUrl.isNotEmpty ? pkVideoUrl[0] : indexData.videoUrl ?? "",
            "host2Image": pkImages.length == 2 ? pkImages[1] : indexData.videoImage ?? "",
            "host2VideoUrl": pkVideoUrl.length == 2 ? pkVideoUrl[1] : indexData.videoUrl ?? "",
            "isPkMode": false, // THIS IS NOT STATIC VALUE
          })?.then(
            (value) {
              controller.init();
            },
          );
        } else {
          Get.to(
            MultiLivePageView(
              userId: indexData.userId ?? "",
              liveUserObjId: indexData.liveUserObjId ?? "",
              liveHistoryId: indexData.liveHistoryId ?? "",
              isHost: false,
            ),
          )?.then((value) {
            controller.init();
          });
        }
      },
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColor.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColor.colorBorder),
        ),
        child: Column(
          children: [
            SizedBox(
              height: 180,
              child: Stack(
                children: [
                  Container(
                      height: 180,
                      width: Get.width,
                      clipBehavior: Clip.antiAlias,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15),
                        ),
                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        alignment: Alignment.center,
                        children: [
                          Container(
                            clipBehavior: Clip.antiAlias,
                            height: Get.width / 2,
                            width: Get.width / 2.4,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(15),
                                topRight: Radius.circular(15),
                              ),
                            ),
                            child: CustomPreviewImage(
                              image: indexData.image,
                              isBanned: indexData.isProfileImageBanned ?? false,
                              isProfileImage: false,
                              placeHolderPadding: EdgeInsets.only(top: 20),
                            ),
                          ),
                        ],
                      )),
                  Positioned(
                    top: 12,
                    left: 10,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(AppAsset.icView, width: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: Text(
                            CustomFormatNumber.convert(indexData.view ?? 0),
                            style: AppFontStyle.styleW700(AppColor.white, 10.0),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 10,
                    child: Container(
                      height: 20,
                      width: 45,
                      decoration: BoxDecoration(
                        color: AppColor.black.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColor.white, width: 0.3),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Positioned(
                          //   left: -5,
                          //   child: Lottie.asset(AppAsset.lottieWaveAnimation, fit: BoxFit.cover, height: 20, width: 15),
                          // ),
                          Positioned(
                            left: 0,
                            bottom: 2,
                            child: Lottie.asset(
                              AppAsset.lottiePulsingDot,
                              fit: BoxFit.cover,
                              height: 20,
                              width: 20,
                            ),
                          ),
                          Positioned(
                            right: 7,
                            child: Text(
                              EnumLocal.txtLive.name.tr,
                              style: AppFontStyle.styleW600(AppColor.white, 10),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: [
                    Container(
                      clipBehavior: Clip.antiAlias,
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      child: CustomPreviewImage(
                        image: indexData.image,
                        isBanned: indexData.isProfileImageBanned,
                      ),
                    ),
                    2.width,
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          LayoutBuilder(
                            builder: (context, constraints) {
                              return Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Expanded(
                                    child: Text(
                                      indexData.name ?? "",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      softWrap: false,
                                      style: AppFontStyle.styleW700(
                                        AppColor.black,
                                        12,
                                      ),
                                    ),
                                  ),
                                  if (indexData.isVerified ?? false) const SizedBox(width: 2),
                                  if (indexData.isVerified ?? false)
                                    SizedBox(
                                      width: 15,
                                      height: 15,
                                      child: Image.asset(
                                        AppAsset.icBlueTick,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                ],
                              );
                            },
                          ),
                          Text(
                            indexData.userName ?? "",
                            maxLines: 1,
                            softWrap: false,
                            overflow: TextOverflow.ellipsis,
                            style: AppFontStyle.styleW400(
                              AppColor.black,
                              10,
                            ),
                          ),
                        ],
                      ),
                    ),
                    2.width,
                    SizedBox(
                      width: 24,
                      child: Center(
                        child: indexData.isFake ?? false
                            ? Image.network(
                                indexData.countryFlagImage ?? "",
                                width: 20,
                                height: 20,
                              )
                            : Text(
                                indexData.countryFlagImage ?? "",
                                maxLines: 1,
                                overflow: TextOverflow.clip,
                                style: AppFontStyle.styleW700(
                                  AppColor.black,
                                  18,
                                ),
                              ),
                      ),
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

class PkUserUi extends StatelessWidget {
  const PkUserUi({super.key, required this.indexData});

  final LiveUserList indexData;

  @override
  Widget build(BuildContext context) {
    final List pkImages = indexData.pkPreviewImages ?? [];

    return GestureDetector(
      onTap: () {
        final controller = Get.find<StreamController>();

        if (indexData.isFake == true) {
          final List pkImages = indexData.pkPreviewImages ?? [];
          final List pkVideoUrl = indexData.pkMediaSources ?? [];

          Get.toNamed(AppRoutes.fakeLivePage, arguments: {
            "isHost": false,
            "isFollow": indexData.isFollow ?? false,
            "roomId": indexData.liveHistoryId ?? "",
            "userId": indexData.userId ?? "",
            "userName": indexData.userName ?? "",
            "name": indexData.name ?? "",
            "image": pkImages.isNotEmpty ? pkImages[0] : indexData.videoImage ?? "",
            "videoUrl": pkVideoUrl.isNotEmpty ? pkVideoUrl[0] : indexData.videoUrl ?? "",
            "host2Image": pkImages.length == 2 ? pkImages[1] : indexData.videoImage ?? "",
            "host2VideoUrl": pkVideoUrl.length == 2 ? pkVideoUrl[1] : indexData.videoUrl ?? "",
            "isPkMode": indexData.isPkMode ?? false,
          })?.then(
            (value) {
              controller.init();
            },
          );
        } else {
          Get.to(
            MultiLivePageView(
              userId: indexData.userId ?? "",
              liveUserObjId: indexData.liveUserObjId ?? "",
              liveHistoryId: indexData.liveHistoryId ?? "",
              isHost: false,
            ),
          )?.then((value) {
            controller.init();
          });
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColor.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColor.colorBorder),
        ),
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppColor.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              SizedBox(
                height: 180,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      height: 180,
                      width: Get.width,
                      clipBehavior: Clip.antiAlias,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15),
                        ),
                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        alignment: Alignment.center,
                        children: [
                          Container(
                            clipBehavior: Clip.antiAlias,
                            height: 180,
                            width: Get.width / 2.4,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(15),
                                topRight: Radius.circular(15),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 180,
                                    clipBehavior: Clip.antiAlias,
                                    padding: EdgeInsets.only(left: 0, top: 1, bottom: 0),
                                    decoration: BoxDecoration(
                                      color: AppColor.transparent,
                                      borderRadius: BorderRadius.only(topLeft: Radius.circular(15)),
                                    ),
                                    child: Container(
                                      clipBehavior: Clip.antiAlias,
                                      decoration: BoxDecoration(
                                        color: AppColor.transparent,
                                        borderRadius: BorderRadius.only(topLeft: Radius.circular(15)),
                                      ),
                                      child: CustomPreviewImage(
                                        image: pkImages.isNotEmpty ? pkImages[0] : indexData.image ?? " ",
                                        fit: BoxFit.cover,
                                        isProfileImage: false,
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    height: 180,
                                    clipBehavior: Clip.antiAlias,
                                    padding: EdgeInsets.only(right: 0, top: 1, bottom: 0),
                                    decoration: BoxDecoration(
                                      color: AppColor.transparent,
                                      borderRadius: BorderRadius.only(topRight: Radius.circular(15)),
                                    ),
                                    child: CustomPreviewImage(
                                      image: pkImages.length == 2 ? pkImages[1] : indexData.host2Image ?? " ",
                                      fit: BoxFit.cover,
                                      isProfileImage: false,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Image.asset(AppAsset.img_pk_vs_main, fit: BoxFit.cover),
                    Positioned(
                      top: 12,
                      left: 10,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(AppAsset.icView, width: 16),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4.0),
                            child: Text(
                              CustomFormatNumber.convert(indexData.view ?? 0),
                              style: AppFontStyle.styleW700(AppColor.white, 10.0),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 10,
                      child: Container(
                        height: 20,
                        width: 45,
                        decoration: BoxDecoration(
                          color: AppColor.black.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: AppColor.white, width: 0.3),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Positioned(
                              left: 0,
                              bottom: 2,
                              child: Lottie.asset(
                                AppAsset.lottiePulsingDot,
                                fit: BoxFit.cover,
                                height: 20,
                                width: 20,
                              ),
                            ),
                            Positioned(
                              right: 7,
                              child: Text(
                                EnumLocal.txtLive.name.tr,
                                style: AppFontStyle.styleW600(AppColor.white, 10),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        clipBehavior: Clip.antiAlias,
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(shape: BoxShape.circle),
                        child: CustomPreviewImage(
                          image: indexData.image,
                          isBanned: indexData.isProfileImageBanned,
                        ),
                      ),
                      6.width,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 90,
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    indexData.name ?? "",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppFontStyle.styleW700(AppColor.black, 12),
                                  ),
                                ),
                                Visibility(
                                  visible: indexData.isVerified ?? false,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 2),
                                    child: Image.asset(AppAsset.icBlueTick, width: 15),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 90,
                            child: Text(
                              indexData.userName ?? "",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppFontStyle.styleW400(AppColor.black, 10),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      indexData.isFake ?? false
                          ? Container(height: 20, width: 20, child: Image.network(indexData.countryFlagImage ?? ""))
                          : Text(
                              indexData.countryFlagImage ?? "",
                              style: AppFontStyle.styleW700(AppColor.black, 18),
                            ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
