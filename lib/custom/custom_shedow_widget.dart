import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortie/utils/color.dart';

class ShadowWidget extends StatelessWidget {
  const ShadowWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 0,
          child: Container(
            height: 200,
            width: Get.width,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColor.black.withValues(alpha: 0.7),
                  AppColor.transparent,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          child: Container(
            height: 200,
            width: Get.width,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColor.transparent, AppColor.black.withValues(alpha: 0.7)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
