import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_typedefs/rx_typedefs.dart';
import 'package:shortie/main.dart';
import 'package:shortie/ui/preview_network_image_ui.dart';
import 'package:shortie/utils/asset.dart';
import 'package:shortie/utils/color.dart';
import 'package:shortie/utils/font_style.dart';
import 'package:shortie/utils/utils.dart';

class SendingPkRequestBottomSheet {
  static bool isOpenBottomSheet = false;
  static Future<void> onShow({
    required String h1Name,
    required String h1Image,
    required String h2Name,
    required String h2Image,
    required BuildContext context,
    required Callback callback,
  }) async {
    Utils.showLog("Pk Event => Host1 Open Sending Pk Request BS => $h1Image => $h2Image");
    isOpenBottomSheet = true;
    await showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      enableDrag: false,
      isDismissible: false,
      backgroundColor: AppColor.transparent,
      builder: (context) => PopScope(
        canPop: false,
        child: Container(
          height: 250,
          width: Get.width,
          clipBehavior: Clip.antiAlias,
          decoration: const BoxDecoration(
            color: AppColor.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(40),
              topRight: Radius.circular(40),
            ),
          ),
          child: Column(
            children: [
              Container(
                height: 65,
                color: AppColor.grey_100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Spacer(),
                    // 50.width,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 4,
                          width: 35,
                          decoration: BoxDecoration(
                            color: AppColor.colorTextDarkGrey,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        10.height,
                        Text(
                          "Waiting for response...",
                          style: AppFontStyle.styleW700(AppColor.black, 17),
                        ),
                      ],
                    ),
                    const Spacer(),
                    // GestureDetector(
                    //   onTap: () {
                    //     callback();
                    //     Get.back();
                    //   },
                    //   child: Container(
                    //     height: 30,
                    //     width: 30,
                    //     margin: const EdgeInsets.only(right: 20),
                    //     decoration: BoxDecoration(
                    //       shape: BoxShape.circle,
                    //       color: AppColor.transparent,
                    //       border: Border.all(color: AppColor.black),
                    //     ),
                    //     child: Center(
                    //       child: Image.asset(
                    //         width: 18,
                    //         AppAsset.icClose,
                    //         color: AppColor.black,
                    //       ),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),
              20.height,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Container(
                          height: 70,
                          width: 70,
                          clipBehavior: Clip.antiAlias,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(shape: BoxShape.circle),
                          child: Stack(
                            children: [
                              AspectRatio(
                                aspectRatio: 1,
                                child: Image.asset(
                                  AppAsset.icProfilePlaceHolder,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              AspectRatio(
                                aspectRatio: 1,
                                child: PreviewNetworkImageUi(image: h1Image),
                              ),
                            ],
                          ),
                        ),
                        5.height,
                        Text(
                          h1Name,
                          style: AppFontStyle.styleW700(AppColor.black, 15),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: callback,
                    child: Container(
                      height: 40,
                      width: 70,
                      clipBehavior: Clip.antiAlias,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: AppColor.colorRedContainer,
                      ),
                      child: Icon(Icons.call_end_rounded, size: 28, color: AppColor.white),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Container(
                          height: 70,
                          width: 70,
                          clipBehavior: Clip.antiAlias,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(shape: BoxShape.circle),
                          child: Stack(
                            children: [
                              AspectRatio(
                                aspectRatio: 1,
                                child: Image.asset(
                                  AppAsset.icProfilePlaceHolder,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              AspectRatio(
                                aspectRatio: 1,
                                child: PreviewNetworkImageUi(image: h2Image),
                              ),
                            ],
                          ),
                        ),
                        5.height,
                        Text(
                          h2Name,
                          style: AppFontStyle.styleW700(AppColor.black, 15),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              20.height,
              Text(
                "Once matched, the battle will start!",
                style: AppFontStyle.styleW600(AppColor.black, 16),
              ),
              25.height,
            ],
          ),
        ),
      ),
    ).whenComplete(() => isOpenBottomSheet = false);
  }
}
