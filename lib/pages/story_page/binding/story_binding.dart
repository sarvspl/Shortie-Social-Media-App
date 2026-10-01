import 'package:get/get.dart';
import 'package:shortie/pages/story_page/controller/story_controller.dart';

class StoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StoryController>(() => StoryController());
  }
}
