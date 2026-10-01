import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortie/pages/bottom_bar_page/controller/bottom_bar_controller.dart';
import 'package:shortie/pages/bottom_bar_page/widget/bottom_bar_widget.dart';
import 'package:shortie/utils/color.dart';

class BottomBarView extends StatelessWidget {
  const BottomBarView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<BottomBarController>(
        id: "onChangeBottomBar",
        builder: (logic) {
          return PageView.builder(
            physics: const NeverScrollableScrollPhysics(),
            itemCount: logic.bottomBarPages.length,
            controller: logic.pageController,
            onPageChanged: (int index) => logic.onChangeBottomBar(index),
            itemBuilder: (context, index) => logic.bottomBarPages[logic.selectedTabIndex],
          );
        },
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColor.black,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6.0,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: const BottomBarUi(),
      ),
    );
  }
}
