import 'package:get/get.dart';
import 'package:shortie/pages/multi_live_page/controller/multi_live_controller.dart';

class MultiLivePageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => MultiLiveController());
  }
}



