import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortie/main.dart';
import 'package:shortie/pages/fake_live_page/controller/fake_live_controller.dart';
import 'package:shortie/utils/asset.dart';
import 'package:shortie/utils/color.dart';
import 'package:shortie/utils/font_style.dart';

class FakeCoinWidget extends StatelessWidget {
  const FakeCoinWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 35,
      padding: EdgeInsets.only(bottom: 10),
      width: Get.width,
      child: Row(
        children: [
          15.width,
          Container(
            height: 25,
            padding: EdgeInsets.only(left: 5, right: 8),
            decoration: BoxDecoration(
              color: AppColor.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Row(
              children: [
                Image.asset(AppAsset.icCoin, width: 18),
                5.width,
                GetBuilder<FakeLiveController>(
                  id: "",
                  builder: (controller) => Text(
                    Random().nextInt(1000).toString(),
                    style: AppFontStyle.styleW700(Colors.orange, 12),
                  ),
                ),
                5.width,
              ],
            ),
          ),
          Spacer(),
          10.width,
          Text(
            "ID 986532147",
            style: AppFontStyle.styleW500(AppColor.white.withValues(alpha: 0.8), 10),
          ),
          15.width,
        ],
      ),
    );
  }
}
