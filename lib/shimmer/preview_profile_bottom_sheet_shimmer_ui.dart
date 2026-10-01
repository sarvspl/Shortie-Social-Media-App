import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:shortie/main.dart';
import 'package:shortie/utils/color.dart';
import 'package:flutter/widgets.dart';

class PreviewProfileBottomSheetShimmerUi extends StatelessWidget {
  const PreviewProfileBottomSheetShimmerUi({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColor.shimmer,
      highlightColor: AppColor.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row Shimmer: Avatar + Text Column + Arrow Circle
            Row(
              children: [
                // Avatar Circle Skeleton
                Container(
                  height: 80,
                  width: 80,
                  decoration: const BoxDecoration(color: AppColor.black, shape: BoxShape.circle),
                ),
                15.width,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name Bar
                      Container(
                        height: 20,
                        width: 140,
                        decoration: BoxDecoration(color: AppColor.black, borderRadius: BorderRadius.circular(10)),
                      ),
                      8.height,
                      // Username Bar
                      Container(
                        height: 14,
                        width: 100,
                        decoration: BoxDecoration(color: AppColor.black, borderRadius: BorderRadius.circular(10)),
                      ),
                      12.height,
                      // Flag + Gender Pill row
                      Row(
                        children: [
                          // Flag Circle Skeleton
                          Container(
                            height: 20,
                            width: 20,
                            decoration: const BoxDecoration(color: AppColor.black, shape: BoxShape.circle),
                          ),
                          8.width,
                          // Gender Pill Skeleton
                          Container(
                            height: 20,
                            width: 65,
                            decoration: BoxDecoration(color: AppColor.black, borderRadius: BorderRadius.circular(20)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                5.width,
                // Circular Arrow Right Button Skeleton
                Container(
                  height: 34,
                  width: 34,
                  decoration: const BoxDecoration(color: AppColor.black, shape: BoxShape.circle),
                ),
              ],
            ),
            18.height,
            // Stats Container Card Skeleton
            Container(
              height: 62,
              width: Get.width,
              decoration: BoxDecoration(
                color: AppColor.black,
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            20.height,
            // Bottom Row Buttons Skeleton
            Row(
              children: [
                // Message Button skeleton
                Expanded(
                  child: Container(
                            height: 52,
                    decoration: BoxDecoration(color: AppColor.black, borderRadius: BorderRadius.circular(100)),
                  ),
                ),
                12.width,
                // Follow Button skeleton
                Expanded(
                  child: Container(
                            height: 52,
                    decoration: BoxDecoration(color: AppColor.black, borderRadius: BorderRadius.circular(100)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
