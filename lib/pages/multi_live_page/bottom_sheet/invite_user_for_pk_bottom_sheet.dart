import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_typedefs/rx_typedefs.dart';
import 'package:shortie/main.dart';
import 'package:shortie/pages/multi_live_page/controller/multi_live_controller.dart';
import 'package:shortie/ui/preview_network_image_ui.dart';
import 'package:shortie/utils/asset.dart';
import 'package:shortie/utils/color.dart';
import 'package:shortie/utils/font_style.dart';

class InviteUserForPkBottomSheet {
  static bool isOpenBottomSheet = false;
  static Future<void> show({required BuildContext context, required Callback callback}) async {
    final controller = Get.find<MultiLiveController>();
    controller.onGetLiveUserList();
    isOpenBottomSheet = true;
    await showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      backgroundColor: AppColor.transparent,
      builder: (context) => Container(
        height: 315,
        width: Get.width,
        clipBehavior: Clip.antiAlias,
        decoration: const BoxDecoration(
          color: AppColor.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(40),
            topRight: Radius.circular(40),
          ),
        ),
        child: Column(
          children: [
            Container(
              height: 65,
              width: Get.width,
              color: AppColor.grey_100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 4,
                        width: 35,
                        decoration: BoxDecoration(
                          color: AppColor.colorTextDarkGrey.withValues(alpha:0.3),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      10.height,
                      Text(
                        "Invite For Pk Battle",
                        style: AppFontStyle.styleW700(AppColor.black, 17),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            10.height,
            Expanded(
              child: GetBuilder<MultiLiveController>(
                id: "onGetLiveUserList",
                builder: (controller) => controller.isLoadingLiveUserList
                    ? Center(child: CircularProgressIndicator())
                    : controller.liveUserList.isEmpty
                        ? Center(
                            child: Text(
                              "Live User Not Available",
                              style: AppFontStyle.styleW700(AppColor.black, 17),
                            ),
                          )
                        : ListView.builder(
                            itemCount: controller.liveUserList.length,
                            itemBuilder: (context, index) {
                              final indexData = controller.liveUserList[index];
                              return GestureDetector(
                                onTap: () async {
                                  String streamID = '${indexData.userId}_call';
                                  controller.host2Id = indexData.userId ?? "";
                                  controller.host2Name = indexData.name ?? "";
                                  controller.host2UserName = indexData.userName ?? "";
                                  controller.host2Image = indexData.image ?? "";

                                  controller.host2Token = indexData.token ?? "";
                                  controller.host2ChannelId = streamID;
                                  controller.host2RoomId = indexData.liveHistoryId ?? "";

                                  await 100.milliseconds.delay();
                                  callback();
                                },
                                child: Container(
                                  height: 60,
                                  width: Get.width,
                                  color: Colors.transparent,
                                  margin: EdgeInsets.only(bottom: 10, left: 15, right: 15),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Container(
                                        height: 55,
                                        width: 55,
                                        clipBehavior: Clip.antiAlias,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(shape: BoxShape.circle),
                                        child: Stack(
                                          children: [
                                            AspectRatio(
                                              aspectRatio: 1,
                                              child: Image.asset(AppAsset.icProfilePlaceHolder, fit: BoxFit.cover),
                                            ),
                                            AspectRatio(
                                              aspectRatio: 1,
                                              child: PreviewNetworkImageUi(
                                                image: indexData.image,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      10.width,
                                      Text(
                                        indexData.name ?? "",
                                        style: AppFontStyle.styleW700(AppColor.black, 17),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ),
          ],
        ),
      ),
    ).then((value) => isOpenBottomSheet = false);
  }
}
