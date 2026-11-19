import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortie/main.dart';
import 'package:shortie/pages/multi_live_page/controller/multi_live_controller.dart';
import 'package:shortie/ui/preview_network_image_ui.dart';
import 'package:shortie/utils/asset.dart';
import 'package:shortie/utils/color.dart';
import 'package:shortie/utils/database.dart';
import 'package:shortie/utils/font_style.dart';
import 'package:shortie/utils/socket_services.dart';
import 'package:shortie/utils/utils.dart';

class InviteUserForMultiLiveBottomSheet {
  static bool isOpenBottomSheet = false;
  static Future<void> show({required BuildContext context, required int postion}) async {
    // final controller = Get.find<MultiLiveController>();
    // controller.onGetLiveUserList();
    SocketServices.liveViewers;
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
                        "Invite For Multi Live",
                        style: AppFontStyle.styleW700(AppColor.black, 17),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            10.height,
            Expanded(
              child: Obx(
                () => SocketServices.liveViewers.isEmpty
                    ? Center(
                        child: Text(
                          "Live User Not Available",
                          style: AppFontStyle.styleW700(AppColor.black, 17),
                        ),
                      )
                    : ListView.builder(
                        itemCount: SocketServices.liveViewers.length,
                        itemBuilder: (context, index) {
                          final indexData = SocketServices.liveViewers[index];
                          final targetId = indexData['userId']?.toString() ?? "";
                          final targetName = indexData['name'] ?? indexData['userName'] ?? "User";
                          final targetImage = indexData['image'] ?? "";
                          final controller = Get.find<MultiLiveController>();

                          return GestureDetector(
                            onTap: () async {
                              if (targetId == Database.loginUserId) {
                                Utils.showToast("You can't invite yourself");
                                Get.back();
                                return;
                              } else if (controller.requestedList?.any((element) => element.userId == targetId && element.isAccepted == true && element.agoraUid != "") == true) {
                                Utils.showToast("This user is already in the live");
                                Get.back();
                                return;
                              } else if (controller.requestedList?.any((element) => element.userId == targetId && element.isRequested == true) == true) {
                                Utils.showToast("You have already sent a request to this user");
                                Get.back();
                                return;
                              } else {
                                Utils.showLog("Join request ==> $targetId ${Database.loginUserId}");
                                await controller
                                    .onSendMultiLiveRequestOnSocketForUser(
                                  name: targetName,
                                  image: targetImage,
                                  userName: indexData['userName'] ?? "",
                                  userId: targetId,
                                  coHost: targetId,
                                  country: indexData['country'] ?? "",
                                  countryFlagImage: indexData['countryFlagImage'] ?? "",
                                  isVerified: indexData['isVerified'] ?? false,
                                  position: postion,
                                  liveUserObjId: (indexData['liveUserId'] != null && indexData['liveUserId'].toString().isNotEmpty) ? indexData['liveUserId'].toString() : controller.liveUserObjId,
                                  liveHistoryId: (indexData['liveHistoryId'] != null && indexData['liveHistoryId'].toString().isNotEmpty) ? indexData['liveHistoryId'].toString() : controller.roomID,
                                )
                                    .then(
                                  (value) {
                                    Get.back();
                                    Utils.showToast("Join request sent successfully");
                                  },
                                );
                                Utils.showLog("Join request ==> ${indexData}");
                              }
                            },
                            child: Container(
                              height: 60,
                              width: Get.width,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              margin: const EdgeInsets.only(bottom: 10, left: 15, right: 15),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    height: 55,
                                    width: 55,
                                    clipBehavior: Clip.antiAlias,
                                    alignment: Alignment.center,
                                    decoration: const BoxDecoration(shape: BoxShape.circle),
                                    child: Stack(
                                      children: [
                                        AspectRatio(
                                          aspectRatio: 1,
                                          child: Image.asset(AppAsset.icProfilePlaceHolder, fit: BoxFit.cover),
                                        ),
                                        AspectRatio(
                                          aspectRatio: 1,
                                          child: PreviewNetworkImageUi(
                                            image: targetImage,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  10.width,
                                  Expanded(
                                    child: Text(
                                      targetName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppFontStyle.styleW700(AppColor.black, 17),
                                    ),
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
