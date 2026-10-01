import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:shortie/pages/multi_live_page/view/multi_live_page_view.dart';
import 'package:shortie/ui/loading_ui.dart';
import 'package:shortie/pages/go_live_page/api/create_live_user_api.dart';
import 'package:shortie/pages/go_live_page/model/create_live_user_model.dart';
import 'package:shortie/utils/database.dart';
import 'package:shortie/utils/enums.dart';
import 'package:shortie/utils/utils.dart';

class GoLiveController extends GetxController {
  CameraController? cameraController;
  CameraLensDirection cameraLensDirection = CameraLensDirection.front;

  bool isFlashOn = false;

  @override
  void onInit() {
    WakelockPlus.enable();
    onRequestPermissions();
    super.onInit();
  }

  @override
  void onClose() {
    WakelockPlus.disable();
    onDisposeCamera();
    super.onClose();
  }

  Future<void> onRequestPermissions() async {
    final camera = await Permission.camera.request();
    final microphone = await Permission.microphone.request();
    if (camera.isGranted && microphone.isGranted) {
      onInitializeCamera();
    } else {
      Utils.showToast(EnumLocal.txtPleaseAllowPermission.name.tr);
    }
  }

  Future<void> onInitializeCamera() async {
    try {
      final cameras = await availableCameras();
      final camera = cameras.last; // Use the first available camera
      cameraController = CameraController(camera, ResolutionPreset.medium);
      await cameraController!.initialize();
      update(["onInitializeCamera"]);
    } catch (e) {
      Utils.showLog("Error initializing camera: $e");
    }
  }

  Future<void> onDisposeCamera() async {
    cameraController?.dispose();
    cameraController = null;

    Utils.showLog("Camera Controller Dispose Success");
  }

  Future<void> onSwitchFlash() async {
    if (cameraLensDirection == CameraLensDirection.back) {
      if (isFlashOn) {
        isFlashOn = false;
        await cameraController?.setFlashMode(FlashMode.off);
      } else {
        isFlashOn = true;
        await cameraController?.setFlashMode(FlashMode.torch);
      }
      update(["onSwitchFlash"]);
    }
  }

  Future<void> onSwitchCamera() async {
    Utils.showLog("Switch Normal Camera Method Calling....");

    Get.dialog(barrierDismissible: false, PopScope(canPop: false, child: const LoadingUi())); // Start Loading...
    if (isFlashOn) {
      onSwitchFlash();
    }

    cameraLensDirection = cameraLensDirection == CameraLensDirection.back ? CameraLensDirection.front : CameraLensDirection.back;
    final cameras = await availableCameras();
    final camera = cameras.firstWhere((camera) => camera.lensDirection == cameraLensDirection);
    cameraController = CameraController(camera, ResolutionPreset.high);
    await cameraController!.initialize();
    update(["onInitializeCamera"]);
    Get.back(); // Stop Loading...
  }

  Future<void> onClickGoLive() async {
    CreateLiveUserModel? createLiveUserModel;

    Get.dialog(barrierDismissible: false, PopScope(canPop: false, child: const LoadingUi())); // Start Loading...
    createLiveUserModel = await CreateLiveUserApi.callApi(loginUserId: Database.loginUserId);

    Get.back(); // Stop Loading...

    if (createLiveUserModel?.data?.liveHistoryId != null) {
      Utils.showLog("Live User Room Id => ${createLiveUserModel?.data?.liveHistoryId}");

      Get.off(
        MultiLivePageView(
          isHost: true,
          userId: createLiveUserModel?.data?.userId ?? "",
          liveUserObjId: createLiveUserModel?.data?.id ?? "",
          liveHistoryId: createLiveUserModel?.data?.liveHistoryId ?? "",
        ),
      );
    }
  }
}
