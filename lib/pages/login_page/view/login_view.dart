import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shortie/main.dart';
import 'package:shortie/pages/login_page/controller/login_controller.dart';
import 'package:shortie/utils/asset.dart';
import 'package:shortie/utils/color.dart';
import 'package:shortie/utils/constant.dart';
import 'package:shortie/utils/enums.dart';
import 'package:shortie/utils/font_style.dart';

class LoginView extends GetView<LoginController> {
  LoginView({super.key});
  @override
  Widget build(BuildContext context) {
    Future.delayed(
      Duration(milliseconds: 300),
      () => SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarColor: AppColor.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
    );
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(AppAsset.imgLoginBg, height: Get.height, width: Get.width, fit: BoxFit.cover),
          Positioned(
            bottom: 0,
            child: Container(
              height: 600,
              width: Get.width,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColor.transparent, AppColor.black, AppColor.black, AppColor.black],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          SingleChildScrollView(
              physics: ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: Get.height),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 30),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Image.asset(
                        AppAsset.icAppIcon,
                        height: 180,
                        width: 180,
                      ),
                      25.height,
                      SizedBox(
                        width: Get.width / 1.2,
                        child: Text(
                          EnumLocal.txtLoginTitle.name.tr,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 33,
                            color: AppColor.white,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w900,
                            fontFamily: AppConstant.appFontBold,
                          ),
                        ),
                      ),
                      5.height,
                      Text(
                        EnumLocal.txtLoginSubTitle.name.tr,
                        textAlign: TextAlign.center,
                        style: AppFontStyle.styleW400(AppColor.white, 14),
                      ),
                      20.height,
                      GestureDetector(
                        onTap: controller.onQuickLogin,
                        child: Container(
                          height: 56,
                          width: Get.width,
                          padding: EdgeInsets.symmetric(horizontal: 6),
                          decoration: BoxDecoration(
                            gradient: AppColor.primaryLinearGradient,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            children: [
                              Container(
                                height: 46,
                                width: 46,
                                decoration: BoxDecoration(
                                  color: AppColor.white,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(child: Image.asset(AppAsset.icQuickLogo, width: 24)),
                              ),
                              Expanded(
                                child: Center(
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      EnumLocal.txtQuickLogIn.name.tr,
                                      style: AppFontStyle.styleW600(AppColor.white, 16),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 46),
                            ],
                          ),
                        ),
                      ),
                      15.height,
                      Row(
                        children: [
                          Expanded(child: Divider(color: AppColor.white.withValues(alpha: 0.15))),
                          15.width,
                          Text(
                            EnumLocal.txtOr.name.tr,
                            style: AppFontStyle.styleW600(AppColor.white, 12),
                          ),
                          15.width,
                          Expanded(child: Divider(color: AppColor.white.withValues(alpha: 0.15))),
                        ],
                      ),
                      15.height,
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: controller.onGoogleLogin,
                              child: Container(
                                height: 56,
                                padding: EdgeInsets.symmetric(horizontal: 6),
                                decoration: BoxDecoration(
                                  color: AppColor.colorDarkPink,
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      height: 46,
                                      width: 46,
                                      decoration: BoxDecoration(
                                        color: AppColor.white,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(child: Image.asset(AppAsset.icGoogleLogo, width: 28)),
                                    ),
                                    Expanded(
                                      child: Center(
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(
                                            EnumLocal.txtGoogle.name.tr,
                                            style: AppFontStyle.styleW600(AppColor.white, 15),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          15.width,
                          Expanded(
                            child: GestureDetector(
                              onTap: controller.onMobileNumber,
                              child: Container(
                                height: 56,
                                padding: EdgeInsets.symmetric(horizontal: 6),
                                decoration: BoxDecoration(
                                  color: AppColor.colorBlue,
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      height: 46,
                                      width: 46,
                                      decoration: BoxDecoration(
                                        color: AppColor.white,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(child: Image.asset(AppAsset.icMobile, width: 28)),
                                    ),
                                    Expanded(
                                      child: Center(
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(
                                            EnumLocal.txtMobile.name.tr,
                                            style: AppFontStyle.styleW600(AppColor.white, 15),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Platform.isIOS
                          ? GestureDetector(
                              onTap: controller.onAppleLogin,
                              child: Container(
                                height: 56,
                                width: Get.width,
                                padding: EdgeInsets.symmetric(horizontal: 6),
                                decoration: BoxDecoration(
                                  color: AppColor.black,
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(color: AppColor.white, width: 1),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      height: 46,
                                      width: 46,
                                      decoration: BoxDecoration(
                                        color: AppColor.white,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Icon(
                                          Icons.apple,
                                          size: 32,
                                          color: AppColor.black,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Center(
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(
                                            "Apple",
                                            style: AppFontStyle.styleW600(AppColor.white, 16),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 46),
                                  ],
                                ),
                              ),
                            ).paddingOnly(top: 22)
                          : SizedBox.shrink(),
                      // Terms and Conditions Checkbox Section
                      15.height,
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Obx(() => Row(
                              children: [
                                GestureDetector(
                                  onTap: () => controller.toggleTermsAcceptance(),
                                  child: Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(
                                        color: controller.isTermsAccepted.value ? AppColor.white : AppColor.white.withValues(alpha: 0.5),
                                        width: 2,
                                      ),
                                      color: controller.isTermsAccepted.value ? AppColor.white : AppColor.transparent,
                                    ),
                                    child: controller.isTermsAccepted.value
                                        ? Icon(
                                            Icons.check,
                                            size: 14,
                                            color: AppColor.black,
                                          )
                                        : null,
                                  ),
                                ),
                                10.width,
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => controller.toggleTermsAcceptance(),
                                    child: RichText(
                                      text: TextSpan(
                                        style: AppFontStyle.styleW400(AppColor.white.withValues(alpha: 0.8), 12),
                                        children: [
                                          TextSpan(text: "I agree to the "),
                                          WidgetSpan(
                                            child: GestureDetector(
                                              onTap: () => controller.onTermsAndConditionsPressed(),
                                              child: Text(
                                                "Terms & Conditions",
                                                style: AppFontStyle.styleW600(AppColor.white, 12).copyWith(
                                                  decoration: TextDecoration.underline,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )),
                      ),
                      10.height,
                      10.height,
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }
}
