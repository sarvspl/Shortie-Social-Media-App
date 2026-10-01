import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortie/utils/color.dart';
import 'package:shortie/utils/font_style.dart';

class ExtendedLicenseDialog extends StatelessWidget {
  const ExtendedLicenseDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(30),
        ),
      ),
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        height: 320,
        child: Material(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(30),
            ),
          ),
          color: AppColor.white,
          child: Column(
            children: [
              const SizedBox(height: 20),
              Icon(Icons.lock, size: 70, color: AppColor.primary),
              Padding(
                padding: const EdgeInsets.only(top: 15),
                child: Text(
                  "Extended License Required",
                  style: AppFontStyle.styleW700(
                    AppColor.primary,
                    20,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 13, left: 10, right: 10),
                child: Text(
                  "Please purchase or enter an extended license to enable payment methods.",
                  textAlign: TextAlign.center,
                  style: AppFontStyle.styleW500(
                    AppColor.black.withValues(alpha: 0.7),
                    14,
                  ),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  Get.back();
                },
                child: Container(
                  height: 47,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    gradient: AppColor.primaryLinearGradient,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    "Close",
                    style: AppFontStyle.styleW700(
                      AppColor.white,
                      17,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ).paddingAll(15),
        ),
      ),
    );
  }
}
