import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortie/main.dart';
import 'package:shortie/utils/asset.dart';
import 'package:shortie/utils/color.dart';
import 'package:shortie/utils/enums.dart';
import 'package:shortie/utils/font_style.dart';

class ConfirmGuestSlotsDialogUi {
  static Future<void> onShow({
    required int newSlots,
    required int guestsToRemove,
    required VoidCallback onConfirm,
  }) async {
    Get.dialog(
      barrierColor: AppColor.black.withValues(alpha:0.9),
      Dialog(
        backgroundColor: AppColor.transparent,
        elevation: 0,
        child: Container(
          height: 400,
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
                  Image.asset(AppAsset.icAlert, color: AppColor.colorRedContainer, width: 90),
                  10.height,
                  Text(
                    "Confirm Guest Slot Change",
                    style: AppFontStyle.styleW700(AppColor.black, 22),
                    textAlign: TextAlign.center,
                  ),
                  10.height,
                  Text(
                    textAlign: TextAlign.center,
                    "Reducing to $newSlots slots will remove $guestsToRemove active guest(s). Are you sure you want to continue?",
                    style: AppFontStyle.styleW400(AppColor.colorTextGrey, 12),
                  ),
                  20.height,
                  GestureDetector(
                    onTap: onConfirm,
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
                            Text("Confirm", style: AppFontStyle.styleW700(AppColor.colorTextRed, 16)),
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
    );
  }
}
