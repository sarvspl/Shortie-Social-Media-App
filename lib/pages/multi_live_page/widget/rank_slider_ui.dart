import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortie/main.dart';
import 'package:shortie/utils/asset.dart';
import 'package:shortie/utils/color.dart';
import 'package:shortie/utils/font_style.dart';

class RankSliderUi extends StatelessWidget {
  const RankSliderUi({super.key, required this.rank1, required this.rank2});

  final int rank1;
  final int rank2;

  @override
  Widget build(BuildContext context) {
    final int totalRank = rank1 + rank2;

    // Ensure totalRank is not zero to avoid division by zero
    if (totalRank == 0) {
      return Container(
        width: Get.width,
        height: 15,
        child: Row(
          children: [
            Expanded(
              child: Container(
                alignment: Alignment.centerLeft,
                width: Get.width,
                color: AppColor.primary,
                child: Padding(
                  padding: const EdgeInsets.only(left: 4.0),
                  child: Text("$rank1", style: AppFontStyle.styleW500(AppColor.white, 10)),
                ),
              ),
            ),
            Container(decoration: const BoxDecoration(gradient: AppColor.primaryLinearGradient), child: Image.asset(AppAsset.icPkSpark, height: 15, width: 15)),
            Expanded(
              child: Container(
                alignment: Alignment.centerRight,
                width: Get.width,
                color: AppColor.secondary,
                child: Padding(
                  padding: const EdgeInsets.only(right: 4.0),
                  child: Text("${rank2}", style: AppFontStyle.styleW500(AppColor.white, 10)),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Calculate the ratios
    final double user1WidthRatio = rank1 / totalRank;
    final double user2WidthRatio = rank2 / totalRank;

    // Minimum width for sliders
    const double minWidth = 30.0;

    // Calculate dynamic widths
    final double user1Width = (Get.width * user1WidthRatio).clamp(minWidth, Get.width - minWidth);
    final double user2Width = (Get.width * user2WidthRatio).clamp(minWidth, Get.width - minWidth);

    return Container(
      width: Get.width,
      height: 15,
      child: Row(
        children: [
          AnimatedContainer(
            alignment: Alignment.centerLeft,
            duration: const Duration(milliseconds: 1000),
            curve: Curves.linear,
            width: user1Width,
            padding: EdgeInsets.zero,
            color: AppColor.primary,
            child: Padding(
              padding: const EdgeInsets.only(
                left: 4.0,
              ),
              child: Text("$rank1", style: AppFontStyle.styleW500(AppColor.white, 10)),
            ),
          ),
          SizedBox(
            height: 15,
            width: 30,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Positioned(
                  left: -2,
                  child: Container(height: 15, width: 17, color: AppColor.primary),
                ),
                Positioned(
                  right: -2,
                  child: Container(height: 15, width: 17, color: AppColor.secondary),
                ),
                Image.asset(AppAsset.icPkSpark, width: 30),
              ],
            ),
          ),
          AnimatedContainer(
            padding: EdgeInsets.zero,
            alignment: Alignment.centerRight,
            duration: const Duration(milliseconds: 1000),
            curve: Curves.linear,
            width: user2Width,
            color: AppColor.secondary,
            child: Padding(
              padding: const EdgeInsets.only(right: 4.0),
              child: Text("${rank2}", style: AppFontStyle.styleW500(AppColor.white, 10)),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomRankSliderWidget extends StatelessWidget {
  const CustomRankSliderWidget({super.key, required this.rank1, required this.rank2, required this.width, required this.height});

  final int rank1;
  final int rank2;
  final double height;
  final double width;

  @override
  Widget build(BuildContext context) {
    final int totalRank = rank1 + rank2;

    if (totalRank == 0) {
      return SizedBox(
        height: height,
        width: width,
        child: Row(
          children: [
            Expanded(
              child: AnimatedContainer(
                height: height,
                duration: const Duration(milliseconds: 1000),
                curve: Curves.linear,
                decoration: BoxDecoration(color: AppColor.primary),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: Image.asset(AppAsset.icCircleBlurStar, width: 17),
                    ),
                    3.width,
                    Text(
                      "0",
                      style: AppFontStyle.styleW700(AppColor.white, 11),
                    ),
                    5.width,
                  ],
                ),
              ),
            ),
            SizedBox(
              height: height,
              width: 30,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Positioned(
                    left: -2,
                    child: Container(height: height, width: 17, color: AppColor.primary),
                  ),
                  Positioned(
                    right: -2,
                    child: Container(height: height, width: 17, color: AppColor.secondary),
                  ),
                  Image.asset(AppAsset.icPkSpark, width: 30),
                ],
              ),
            ),
            Expanded(
              child: AnimatedContainer(
                height: height,
                duration: const Duration(milliseconds: 1000),
                curve: Curves.linear,
                decoration: BoxDecoration(
                  color: AppColor.secondary,
                  // borderRadius: BorderRadius.horizontal(right: Radius.circular(100)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    5.width,
                    Text(
                      "0",
                      style: AppFontStyle.styleW700(AppColor.white, 11),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: Image.asset(AppAsset.icCircleBlurStar, width: 17),
                    ),
                    3.width,
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    final double user1WidthRatio = rank1 / totalRank;
    final double user2WidthRatio = rank2 / totalRank;

// Minimum width for sliders
    const double minWidth = 100.0;

    final double user1Width = (width * user1WidthRatio).clamp(minWidth, width - minWidth);
    final double user2Width = (width * user2WidthRatio).clamp(minWidth, width - minWidth);

    return SizedBox(
      height: height,
      width: width,
      child: Row(
        children: [
          AnimatedContainer(
            height: height,
            duration: const Duration(milliseconds: 1000),
            curve: Curves.linear,
            width: user1Width - 15,
            decoration: BoxDecoration(
              color: AppColor.primary,
              // borderRadius: BorderRadius.horizontal(left: Radius.circular(100)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: Image.asset(AppAsset.icCircleBlurStar, width: 17),
                ),
                3.width,
                Text(
                  rank1.toStringAsFixed(0),
                  style: AppFontStyle.styleW700(AppColor.white, 11),
                ),
                5.width,
              ],
            ),
          ),
          SizedBox(
            height: height,
            width: 30,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Positioned(
                  left: -2,
                  child: Container(height: height, width: 17, color: AppColor.primary),
                ),
                Positioned(
                  right: -2,
                  child: Container(height: height, width: 17, color: AppColor.secondary),
                ),
                Image.asset(AppAsset.icPkSpark, width: 30),
              ],
            ),
          ),
          AnimatedContainer(
            height: height,
            duration: const Duration(milliseconds: 1000),
            curve: Curves.linear,
            width: user2Width - 15,
            decoration: BoxDecoration(
              color: AppColor.secondary,
              // borderRadius: BorderRadius.horizontal(right: Radius.circular(100)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                5.width,
                Text(
                  rank2.toStringAsFixed(0),
                  style: AppFontStyle.styleW700(AppColor.white, 11),
                ),
                3.width,
                Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: Image.asset(AppAsset.icCircleBlurStar, width: 17),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
