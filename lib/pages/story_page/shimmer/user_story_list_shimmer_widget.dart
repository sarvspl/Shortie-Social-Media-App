import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:shortie/main.dart';
import 'package:shortie/utils/color.dart';

class UserStoryListShimmerWidget extends StatelessWidget {
  const UserStoryListShimmerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110,
      child: Shimmer.fromColors(
        baseColor: AppColor.shimmer,
        highlightColor: AppColor.white,
        child: ListView.builder(
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(vertical: 10),
          itemCount: 10,
          itemBuilder: (context, index) {
            return ItemWidget();
          },
        ),
      ),
    );
  }
}

class ItemWidget extends StatelessWidget {
  const ItemWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      height: 90,
      width: 85,
      alignment: Alignment.center,
      margin: EdgeInsets.only(left: 10),
      child: Column(
        children: [
          Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColor.white,
              border: Border.all(color: AppColor.transparent),
            ),
            padding: EdgeInsets.all(2),
          ),
          5.height,
          Container(
            height: 15,
            width: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: AppColor.black,
            ),
          ),
        ],
      ),
    );
  }
}
