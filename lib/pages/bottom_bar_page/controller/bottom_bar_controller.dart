import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortie/deep_link/services/deep_link_services.dart';
import 'package:shortie/google_ad/google_ad_interstitial.dart';
import 'package:shortie/pages/fake_live_page/widget/fake_send_gift_bottom_sheet_widget.dart';
import 'package:shortie/pages/feed_page/view/feed_view.dart';
import 'package:shortie/pages/message_page/view/message_view.dart';
import 'package:shortie/pages/profile_page/view/profile_view.dart';
import 'package:shortie/pages/reels_page/view/reels_view.dart';
import 'package:shortie/pages/stream_page/view/stream_view.dart';
import 'package:shortie/utils/socket_services.dart';

class BottomBarController extends GetxController {
  int selectedTabIndex = 0;
  PageController pageController = PageController();

  @override
  void onInit() {
    init();
    super.onInit();
  }

  void init() async {
    selectedTabIndex = 0;

    await SocketServices.socketConnect();

    GoogleAdInterstitial.loadAd(); // *** >>> Google Ad Code <<< ***

    FakeSendGiftBottomSheetWidget.onGetGift();

    DeepLinkServices.onChangeRoutes(isBottomBarRoutes: true);
  }

  List bottomBarPages = [
    const ReelsView(),
    const StreamView(),
    const FeedView(),
    const MessageView(),
    const ProfileView(),
  ];

  void onChangeBottomBar(int index) {
    if (index != selectedTabIndex) {
      selectedTabIndex = index;
      update(["onChangeBottomBar"]);
    }
  }
}
