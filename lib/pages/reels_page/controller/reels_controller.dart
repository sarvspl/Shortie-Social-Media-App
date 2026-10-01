import 'package:get/get.dart';
import 'package:preload_page_view/preload_page_view.dart';
import 'package:quick_actions/quick_actions.dart';
import 'package:shortie/deep_link/services/deep_link_services.dart';
import 'package:shortie/google_ad/google_ad_services.dart';
import 'package:shortie/pages/reels_page/api/fetch_reels_api.dart';
import 'package:shortie/pages/reels_page/model/fetch_reels_model.dart';
import 'package:shortie/routes/app_routes.dart';
import 'package:shortie/utils/database.dart';
import 'package:shortie/utils/utils.dart';

import '../../bottom_bar_page/controller/bottom_bar_controller.dart';

class ReelsController extends GetxController {
  PreloadPageController preloadPageController = PreloadPageController();

  bool isLoadingReels = false;
  FetchReelsModel? fetchReelsModel;

  bool isPaginationLoading = false;

  List mainReels = []; // *** >>> Google Ad Code <<< ***
  // List<Data> mainReels = [];

  int currentPageIndex = 0;
  final quickAction = QuickActions();
  BottomBarController controller = Get.put(BottomBarController());

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();

    quickAction.setShortcutItems([
      ShortcutItem(
        type: 'reel',
        localizedTitle: 'Reel',
        icon: "reel",
      ),
      ShortcutItem(
        type: 'chat',
        localizedTitle: 'Chat',
        icon: "message",
      ),
      ShortcutItem(
        type: 'feeds',
        localizedTitle: 'Feeds',
        icon: "feed",
      ),
      ShortcutItem(
        type: 'search',
        localizedTitle: 'Search',
        icon: "search",
      ),
    ]);

    quickAction.initialize(
      (type) {
        if (type == 'reel') {
          controller.onChangeBottomBar(0);
        } else if (type == 'chat') {
          controller.onChangeBottomBar(3);
        } else if (type == 'feeds') {
          controller.onChangeBottomBar(2);
        } else if (type == 'search') {
          // controller.onChangeBottomBar(0);
          Get.toNamed(AppRoutes.searchPage);
        }
      },
    );
  }

  Future<void> init() async {
    currentPageIndex = 0;
    mainReels.clear();
    FetchReelsApi.startPagination = 0;
    isLoadingReels = true;
    update(["onGetReels"]);
    await onGetReels();
    isLoadingReels = false;
  }

  void onPagination(int value) async {
    if ((mainReels.length - 1) == value) {
      if (isPaginationLoading == false) {
        isPaginationLoading = true;
        update(["onPagination"]);
        await onGetReels();
        isPaginationLoading = false;
        update(["onPagination"]);
      }
    }
  }

  void onChangePage(int index) async {
    Utils.isCurrentlyVideoPage.value = true;
    currentPageIndex = index;
    update(["onChangePage"]);
  }

  Future<void> onGetReels() async {
    fetchReelsModel = null;
    fetchReelsModel = await FetchReelsApi.callApi(
        loginUserId: Database.loginUserId, videoId: DeepLinkServices.eventType == DeepLinkServices.reels ? DeepLinkServices.eventId : "");

    if (fetchReelsModel?.data != null) {
      if (fetchReelsModel!.data!.isNotEmpty) {
        final paginationData = fetchReelsModel?.data ?? [];

        // <<< Code Start *** >>> Google Ad Code <<< ***
        if (GoogleAdServices.isShowFullNativeAdReels) {
          for (int i = 0; i < paginationData.length; i++) {
            if (i != 0 && i % GoogleAdServices.adShowIndex == 0) {
              mainReels.add(null);
              mainReels.add(paginationData[i]);
            } else {
              mainReels.add(paginationData[i]);
            }
          }
        } else {
          mainReels.addAll(paginationData);
        }
        // *** >>> Google Ad Code <<< *** Code End >>>

        // mainReels.addAll(paginationData);

        update(["onGetReels"]);
      } else {
        FetchReelsApi.startPagination--;
      }
    }
    if (mainReels.isEmpty) {
      update(["onGetReels"]);
    }

    if (DeepLinkServices.isNavigationComplete) {
      DeepLinkServices.eventId = ""; // Refresh Time Not Show Same Post On Top
      DeepLinkServices.eventType = ""; // Refresh Time Not Show Same Post On Top
    }
  }
}
