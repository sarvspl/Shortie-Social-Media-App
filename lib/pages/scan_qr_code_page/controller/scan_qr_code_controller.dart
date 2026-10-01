import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:shortie/utils/utils.dart';

class ScanQrCodeController extends GetxController {
  late MobileScannerController mobileScannerController;

  @override
  void onInit() {
    mobileScannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
    );
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    mobileScannerController.dispose();
    super.onClose();
  }
}
