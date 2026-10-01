import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shortie/pages/bottom_bar_page/controller/bottom_bar_controller.dart';
import 'package:shortie/pages/stream_page/controller/stream_controller.dart';
import 'package:shortie/pages/stream_page/widget/stream_widget.dart';
import 'package:shortie/shimmer/stream_shimmer_ui.dart';
import 'package:shortie/ui/no_data_found_ui.dart';
import 'package:shortie/utils/color.dart';

class StreamView extends StatelessWidget {
  const StreamView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(StreamController());
    controller.init();

    Timer(
      Duration(milliseconds: 300),
      () {
        SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(statusBarColor: AppColor.transparent, statusBarIconBrightness: Brightness.dark));
      },
    );

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        Get.find<BottomBarController>().onChangeBottomBar(0);
      },
      child: Scaffold(
        appBar: Get.find<BottomBarController>().selectedTabIndex == 1
            ? AppBar(
                toolbarHeight: 60,
                automaticallyImplyLeading: false,
                backgroundColor: AppColor.white,
                elevation: 1,
                shadowColor: AppColor.colorBorder.withValues(alpha: 0.5),
                surfaceTintColor: AppColor.transparent,
                flexibleSpace: const StreamAppBarUi(),
              )
            : PreferredSize(
                preferredSize: Size.fromHeight(0),
                child: Offstage(),
              ),
        body: GetBuilder<StreamController>(
          id: "onGetLiveUser",
          builder: (controller) => controller.isLoading
              ? StreamShimmerUi()
              : RefreshIndicator(
                  color: AppColor.primary,
                  onRefresh: () async => controller.init(),
                  child: controller.liveUsers.isEmpty
                      ? Center(
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: NoDataFoundUi(iconSize: 160, fontSize: 19, text: "No live streaming found"),
                          ),
                        )
                      : SingleChildScrollView(
                          controller: controller.scrollController,
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: GridView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.only(left: 12, right: 12, bottom: 12, top: 12),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              mainAxisExtent: 230,
                            ),
                            itemCount: controller.liveUsers.length,
                            itemBuilder: (context, index) {
                              final indexData = controller.liveUsers[index];

                              return (indexData.isFake == true)
                                  ? (indexData.pkPreviewImages?.isNotEmpty ?? false)
                                      ? PkUserUi(indexData: indexData)
                                      : LiveUserUi(indexData: indexData)
                                  : (indexData.isPkMode == true)
                                      ? PkUserUi(indexData: indexData)
                                      : LiveUserUi(indexData: indexData);
                            },
                          ),
                        ),
                ),
        ),
        bottomNavigationBar: GetBuilder<StreamController>(
          id: "onPagination",
          builder: (controller) => Visibility(
            visible: controller.isPaginationLoading,
            child: LinearProgressIndicator(color: AppColor.primary),
          ),
        ),
      ),
    );
  }
}
