import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortie/pages/multi_live_page/controller/multi_live_controller.dart';
import 'package:shortie/pages/multi_live_page/model/multi_live_users_model.dart';
import 'package:shortie/utils/api.dart';
import 'package:shortie/utils/color.dart';
import 'package:shortie/utils/enums.dart';
import 'package:shortie/utils/font_style.dart';
import 'package:shortie/utils/socket_services.dart';

class AcceptDeclineBottomSheet {
  static Future<void> show({
    required String userImage,
    required String userName,
    required MultiLiveUsersModel userModel,
  }) async {
    final controller = Get.find<MultiLiveController>();
    await showModalBottomSheet(
      isScrollControlled: true,
      context: Get.context!,
      isDismissible: true,
      enableDrag: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        // height: 250,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 5,
              margin: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            Text(EnumLocal.txtIncomingRequest.name.tr, style: AppFontStyle.styleW700(AppColor.black, 18)),
            const SizedBox(height: 10),
            CircleAvatar(
              radius: 35,
              backgroundImage: NetworkImage(Api.baseUrl + userImage),
              backgroundColor: Colors.grey[200],
            ),
            const SizedBox(height: 8),
            Text(
              userName,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            Text(
              EnumLocal.txtDoYouWantToJoinMultiLive.name.tr,
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            // const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      icon: const Icon(
                        Icons.call_end_rounded,
                        color: AppColor.white,
                      ),
                      label: Text(EnumLocal.txtDecline.name.tr, style: AppFontStyle.styleW700(AppColor.white, 14)),
                      onPressed: () {
                        SocketServices().onEmitRemoveCallJoinRequest(
                          userId: userModel.userId ?? "",
                          liveHistoryId: controller.roomID,
                          liveUserObjId: controller.liveUserObjId,
                          isMute: userModel.isMute ?? false,
                          isCameraEnabled: userModel.isCameraEnabled ?? false,
                          coHostRequestPosition: userModel.position ?? 0,
                        );

                        // Add your decline logic here
                        Get.back(result: false);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        icon: const Icon(
                          Icons.phone_rounded,
                          color: AppColor.white,
                        ),
                        label: Text(EnumLocal.txtAccept.name.tr, style: AppFontStyle.styleW700(AppColor.white, 14)),
                        onPressed: () async {
                          Get.back();

                          await 500.milliseconds.delay();

                          log("message>>>>>>>>>>>>>>>> controller.joinMultiLiveUsers.length>> ${controller.multiLiveRequestedList.length} ${controller.requestedList?.length}");
                          log("message>>>>>>>>>>>>>>>> controllerNEW .length>> ${controller.multiLiveRequestedList.length} ${controller.maxGuestSlots}");

                          if (userModel.isAccepted == true) {
                            SocketServices().onEmitLeftParticipantOfCallJoin(
                              userId: userModel.userId ?? "",
                              liveHistoryId: controller.roomID,
                              liveUserObjId: controller.liveUserObjId,
                              isCameraEnabled: userModel.isCameraEnabled ?? false,
                              position: userModel.position ?? 0,
                              isMute: userModel.isMute ?? false,
                            );
                          } else {
                            // if (controller.multiLiveRequestedList.length == (controller.maxGuestSlots)) {
                            SocketServices().onEmitAddParticipantToCallJoin(
                              userId: userModel.userId ?? "",
                              liveHistoryId: controller.roomID,
                              liveUserObjId: controller.liveUserObjId,
                              agoraUid: userModel.agoraUid ?? "",
                              position: userModel.position ?? 0,
                              isCameraEnabled: userModel.isCameraEnabled ?? false,
                              isMute: userModel.isMute ?? false,
                            );
                            // } else {
                            //   Utils.showToast("Maximum 4 user join multi live");
                            // }
                          }
                        }

                        // Add your accept logic here
                        // Get.back(result: true);

                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
