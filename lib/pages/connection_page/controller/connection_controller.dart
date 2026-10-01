// import 'package:get/get.dart';
// import 'package:shortie/pages/connection_page/api/fetch_followers_api.dart';
// import 'package:shortie/pages/connection_page/api/fetch_following_api.dart';
// import 'package:shortie/pages/connection_page/model/fetch_followers_model.dart';
// import 'package:shortie/pages/connection_page/model/fetch_following_model.dart';
// import 'package:shortie/pages/connection_page/widget/connection_widget.dart';
//
// class ConnectionController extends GetxController {
//   @override
//   void onInit() {
//     if (Get.arguments != null) {
//       onChangeTabBar(Get.arguments["type"]);
//     }
//     super.onInit();
//   }
//
//   void init() async {
//     onGetFollowing();
//     onGetFollowers();
//   }
//
//   int selectedTabIndex = 0;
//   final List connectionTabPages = [const FollowingTabUi(), const FollowersTabUi()];
//
//   bool isLoadingFollowing = false;
//   bool isLoadingFollowers = false;
//
//   FetchFollowingModel? fetchFollowingModel;
//   FetchFollowersModel? fetchFollowersModel;
//
//   List<FollowingData> following = [];
//   List<FollowersData> followers = [];
//
//   Future<void> onGetFollowing() async {
//     isLoadingFollowing = true;
//
//     following.clear();
//
//     fetchFollowingModel = await FetchFollowingApi.callApi(userId: Get.arguments["userId"]);
//
//     if (fetchFollowingModel?.followerFollowing != null) {
//       following.addAll(fetchFollowingModel?.followerFollowing ?? []);
//
//       isLoadingFollowing = false;
//
//       update(["onGetFollowing"]);
//     }
//   }
//
//   Future<void> onGetFollowers() async {
//     isLoadingFollowers = true;
//
//     followers.clear();
//
//     fetchFollowersModel = null;
//
//     fetchFollowersModel = await FetchFollowersApi.callApi(userId: Get.arguments["userId"]);
//
//     if (fetchFollowersModel?.followerFollowing != null) {
//       followers.addAll(fetchFollowersModel?.followerFollowing ?? []);
//
//       isLoadingFollowers = false;
//
//       update(["onGetFollowers"]);
//     }
//   }
//
//   void onChangeTabBar(int index) {
//     selectedTabIndex = index;
//
//     if (index == 0 && following.isEmpty) {
//       onGetFollowing();
//     }
//     if (index == 1 && followers.isEmpty) {
//       onGetFollowers();
//     }
//
//     update(["onChangeTabBar"]);
//   }
// }
import 'package:get/get.dart';
import 'package:shortie/pages/connection_page/api/fetch_followers_api.dart';
import 'package:shortie/pages/connection_page/api/fetch_following_api.dart';
import 'package:shortie/pages/connection_page/model/fetch_followers_model.dart';
import 'package:shortie/pages/connection_page/model/fetch_following_model.dart';
import 'package:shortie/pages/connection_page/widget/connection_widget.dart';

class ConnectionController extends GetxController {
  // ── Pagination constants ──────────────────────────────────────────────────
  static const int _pageLimit = 20;

  // ── Tab state ─────────────────────────────────────────────────────────────
  int selectedTabIndex = 0;
  final List connectionTabPages = [
    const FollowingTabUi(),
    const FollowersTabUi(),
  ];

  // ── Following state ───────────────────────────────────────────────────────
  bool isLoadingFollowing = false;
  bool isLoadingMoreFollowing = false;
  bool hasMoreFollowing = true;
  int _followingPage = 1;
  FetchFollowingModel? fetchFollowingModel;
  List<FollowingData> following = [];

  // ── Followers state ───────────────────────────────────────────────────────
  bool isLoadingFollowers = false;
  bool isLoadingMoreFollowers = false;
  bool hasMoreFollowers = true;
  int _followersPage = 1;
  FetchFollowersModel? fetchFollowersModel;
  List<FollowersData> followers = [];

  // ── Lifecycle ─────────────────────────────────────────────────────────────
  @override
  void onInit() {
    if (Get.arguments != null) {
      onChangeTabBar(Get.arguments["type"] ?? 0);
    }
    super.onInit();
  }

  // ── Following ─────────────────────────────────────────────────────────────

  Future<void> onGetFollowing() async {
    if (isLoadingFollowing) return;

    isLoadingFollowing = true;
    _followingPage = 1;
    hasMoreFollowing = true;
    following.clear();
    update(["onGetFollowing"]);

    await _fetchFollowingPage();

    isLoadingFollowing = false;
    update(["onGetFollowing"]);
  }

  Future<void> onLoadMoreFollowing() async {
    if (isLoadingMoreFollowing || !hasMoreFollowing) return;

    isLoadingMoreFollowing = true;
    update(["onLoadMoreFollowing"]);

    await _fetchFollowingPage();

    isLoadingMoreFollowing = false;
    update(["onLoadMoreFollowing", "onGetFollowing"]);
  }

  Future<void> _fetchFollowingPage() async {
    final model = await FetchFollowingApi.callApi(
      userId: Get.arguments["userId"],
      page: _followingPage,
      limit: _pageLimit,
    );

    if (model?.followerFollowing != null) {
      final newItems = model!.followerFollowing!;
      following.addAll(newItems);
      fetchFollowingModel = model;

      if (newItems.length < _pageLimit) {
        hasMoreFollowing = false;
      } else {
        _followingPage++;
      }
    } else {
      hasMoreFollowing = false;
    }
  }

  // ── Followers ─────────────────────────────────────────────────────────────

  Future<void> onGetFollowers() async {
    if (isLoadingFollowers) return;

    isLoadingFollowers = true;
    _followersPage = 1;
    hasMoreFollowers = true;
    followers.clear();
    update(["onGetFollowers"]);

    await _fetchFollowersPage();

    isLoadingFollowers = false;
    update(["onGetFollowers"]);
  }

  Future<void> onLoadMoreFollowers() async {
    if (isLoadingMoreFollowers || !hasMoreFollowers) return;

    isLoadingMoreFollowers = true;
    update(["onLoadMoreFollowers"]);

    await _fetchFollowersPage();

    isLoadingMoreFollowers = false;
    update(["onLoadMoreFollowers", "onGetFollowers"]);
  }

  Future<void> _fetchFollowersPage() async {
    final model = await FetchFollowersApi.callApi(
      userId: Get.arguments["userId"],
      page: _followersPage,
      limit: _pageLimit,
    );

    if (model?.followerFollowing != null) {
      final newItems = model!.followerFollowing!;
      followers.addAll(newItems);
      fetchFollowersModel = model;

      if (newItems.length < _pageLimit) {
        hasMoreFollowers = false;
      } else {
        _followersPage++;
      }
    } else {
      hasMoreFollowers = false;
    }
  }

  // ── Tab switching ─────────────────────────────────────────────────────────
  void onChangeTabBar(int index) {
    selectedTabIndex = index;

    if (index == 0 && following.isEmpty) onGetFollowing();
    if (index == 1 && followers.isEmpty) onGetFollowers();

    update(["onChangeTabBar"]);
  }
}
