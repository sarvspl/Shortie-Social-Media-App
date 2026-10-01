import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortie/main.dart';
import 'package:shortie/pages/fake_live_page/controller/fake_live_controller.dart';
import 'package:shortie/pages/fake_live_page/widget/fake_bottom_widget.dart';
import 'package:shortie/pages/fake_live_page/widget/fake_coin_widget.dart';
import 'package:shortie/pages/fake_live_page/widget/fake_comments_widget.dart';
import 'package:shortie/pages/fake_live_page/widget/fake_live_camera_widget.dart';
import 'package:shortie/pages/fake_live_page/widget/fake_pk_animation_widget.dart';
import 'package:shortie/pages/fake_live_page/widget/fake_pk_camera_widget.dart';
import 'package:shortie/pages/fake_live_page/widget/fake_shadow_widget.dart';
import 'package:shortie/pages/fake_live_page/widget/fake_top_widget.dart';
import 'package:shortie/pages/multi_live_page/widget/show_received_gift.dart';
import 'package:shortie/ui/stop_live_streaming_dialog_ui.dart';
import 'package:shortie/utils/color.dart';
import 'package:shortie/utils/database.dart';
import 'package:shortie/utils/socket_services.dart';
import 'package:shortie/utils/utils.dart';

class FakeLiveView extends StatefulWidget {
  const FakeLiveView({super.key});

  @override
  State<FakeLiveView> createState() => _FakeLiveViewState();
}

class _FakeLiveViewState extends State<FakeLiveView> {
  final controller = Get.put(FakeLiveController());

  bool isHost = false;
  String localUserID = Database.loginUserId;
  String localUserName = "Hello Developer";
  String roomID = "1234";

  Widget? localView;
  int? localViewID;
  Widget? remoteView;
  int? remoteViewID;

  @override
  void initState() {
    SocketServices.mainLiveComments.clear();

    isHost = Get.arguments["isHost"] ?? "";
    roomID = Get.arguments["roomId"] ?? "";
    controller.userId = Get.arguments["userId"] ?? "";
    controller.image = Get.arguments["image"] ?? "";
    controller.name = Get.arguments["name"] ?? "";
    controller.userName = Get.arguments["userName"] ?? "";
    controller.isFollow = Get.arguments["isFollow"] ?? false;
    controller.videoUrl = Get.arguments["videoUrl"] ?? "";

    controller.host2Image = Get.arguments["host2Image"] ?? "";
    controller.host2VideoUrl = Get.arguments["host2VideoUrl"] ?? "";
    controller.isPkMode = Get.arguments["isPkMode"] ?? "";

    Future.delayed(
      Duration(milliseconds: 20),
      () {
        controller.update(["initializeVideoPlayer"]);
      },
    );

    controller.initializeVideoPlayer();
    controller.initializeVideoHost2();

    Utils.showLog("Is Live User Following => ${controller.isFollow}");
    Utils.showLog("Is Live User Following => ${controller.videoUrl}");

    controller.onChangeTime();

    if (controller.isPkMode == true) controller.onShowPkAnimation();

    controller.initFollowState();

    super.initState();
  }

  @override
  void dispose() {
    controller.onDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Utils.onChangeStatusBar(brightness: Brightness.light, delay: 300);
    return WillPopScope(
      onWillPop: () async {
        ExitLiveStreamingDialogUi.onShow(
          onClickStop: () {
            Get.close(2);
          },
        );
        return false;
      },
      child: Scaffold(
        body: GetBuilder<FakeLiveController>(
          id: "initializeVideoPlayer",
          builder: (controller) => Container(
            height: Get.height,
            width: Get.width,
            decoration: BoxDecoration(
              color: AppColor.black,
              gradient: controller.isPkMode == true ? AppColor.audioRoomGradient : null,
            ),
            child: Stack(
              fit: StackFit.expand,
              alignment: Alignment.center,
              children: [
                FakeLiveCameraWidget(),
                FakeShadowWidget(),
                SizedBox(
                  height: Get.height,
                  width: Get.width,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MediaQuery.of(context).padding.top.height,
                      FakeTopWidget(),
                      FakeCoinWidget(),
                      Expanded(
                        child: Builder(
                          builder: (context) {
                            final useSpace = (MediaQuery.of(context).padding.top + 105 + 75 + MediaQuery.of(context).padding.bottom);
                            final unUseSpace = (Get.height - useSpace);

                            final double pkHeight = (((unUseSpace / 1.65) > 350) ? (unUseSpace / 1.65) : 350);

                            final commentHeight = controller.isPkMode == true ? (unUseSpace - pkHeight) : unUseSpace / 2.5;

                            return Container(
                              height: unUseSpace,
                              child: Align(
                                alignment: Alignment.bottomLeft,
                                child: SingleChildScrollView(
                                  physics: NeverScrollableScrollPhysics(),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      FakePkCameraWidget(height: pkHeight),
                                      FakeCommentsWidget(height: commentHeight),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      FakeBottomWidget(),
                      MediaQuery.of(context).padding.bottom.height,
                    ],
                  ),
                ),
                FakePkAnimationWidget(),
                ShowReceivedGift.onShowGift(),
                ShowReceivedGift.onShowSenderDetails(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
