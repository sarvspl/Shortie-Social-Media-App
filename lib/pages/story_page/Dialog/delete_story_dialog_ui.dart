import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_typedefs/rx_typedefs.dart';
import 'package:shortie/main.dart';
import 'package:shortie/utils/asset.dart';
import 'package:shortie/utils/color.dart';
import 'package:shortie/utils/enums.dart';
import 'package:shortie/utils/font_style.dart';

class DeleteStoryDialogUi {
  static Callback? function;
  static Future<void> onShow({
    required Callback callback,
    required Callback onDelete,
  }) async {
    function = callback;

    Get.dialog(
      barrierColor: AppColor.black.withValues(alpha: 0.9),
      Dialog(
        backgroundColor: AppColor.transparent,
        elevation: 0,
        child: Container(
          height: 380,
          width: 310,
          decoration: BoxDecoration(
            color: AppColor.white,
            borderRadius: BorderRadius.circular(45),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  10.height,
                  Image.asset(AppAsset.icDelete, width: 90),
                  10.height,
                  Text(
                    "Delete Story",
                    style: AppFontStyle.styleW700(AppColor.black, 24),
                  ),
                  10.height,
                  Text(
                    textAlign: TextAlign.center,
                    "This will remove the story from your status updates. Your contacts won't be able to see it anymore",
                    style: AppFontStyle.styleW400(AppColor.colorTextGrey, 11.5),
                  ),
                  20.height,
                  GestureDetector(
                    onTap: onDelete,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: AppColor.colorLightRedBg,
                      ),
                      height: 52,
                      width: Get.width,
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(EnumLocal.txtDelete.name.tr, style: AppFontStyle.styleW700(AppColor.colorTextRed, 16)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  10.height,
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: AppColor.colorGreyBg,
                      ),
                      height: 52,
                      width: Get.width,
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(EnumLocal.txtCancel.name.tr, style: AppFontStyle.styleW700(AppColor.coloGreyText, 16)),
                          ],
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
    ).whenComplete(
      () {
        function?.call();
      },
    );
  }
}
