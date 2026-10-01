import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:shortie/pages/search_page/api/search_hash_tag_api.dart';
import 'package:shortie/pages/search_page/api/search_user_api.dart';
import 'package:shortie/pages/search_page/model/search_hash_tag_model.dart';
import 'package:shortie/pages/search_page/model/search_user_model.dart';
import 'package:shortie/pages/search_page/widget/search_widget.dart';
import 'package:shortie/pages/story_page/model/fetch_story_model.dart';
import 'package:shortie/pages/story_page/widget/simple_story_viewer.dart';
import 'package:shortie/utils/database.dart';

class SearchController extends GetxController {
  TextEditingController searchFieldController = TextEditingController();

  int selectedTabIndex = 0;
  final List searchTabPages = [const SearchUserTabUi(), const HashTagTabUi()];

  bool isSearching = false;

  // >>>> >>>> >>>> Search User <<<< <<<< <<<<

  SearchUserModel? searchUserModel;

  bool isLoadingUser = false;
  List<SearchUserData> userCollection = [];

  bool isSearchingUser = false;
  List<SearchUserData> searchUsers = [];

  // >>>> >>>> >>>> Search HashTag <<<< <<<< <<<<

  SearchHashTagModel? searchHashTagModel;

  bool isLoadingHashTag = false;
  List<SearchHashTagData> hashTagCollection = [];

  bool isSearchingHashTag = false;
  List<SearchHashTagData> searchHashTags = [];

  @override
  void onInit() async {
    init();
    super.onInit();
  }

  Future<void> init() async {
    isSearching = false;
    userCollection.clear();
    hashTagCollection.clear();
    await onChangeTabBar(0);
  }

  Future<void> onChangeTabBar(int index) async {
    selectedTabIndex = index;
    update(["onChangeTabBar"]);

    if (index == 0 && userCollection.isEmpty) {
      await onGetUser();
    } else if (index == 1 && hashTagCollection.isEmpty) {
      await onGetHashTag();
    }
  }

  Future<void> onGetUser() async {
    isLoadingUser = true;
    searchUserModel = null;
    searchUserModel = await SearchUserApi.callApi(loginUserId: Database.loginUserId, searchText: "");
    if (searchUserModel?.searchData != null) {
      userCollection.addAll(searchUserModel?.searchData ?? []);
      isLoadingUser = false;
      update(["onGetUser"]);
    }
    log('userCollection --> ${userCollection.length}');
  }

  Future<void> onGetHashTag() async {
    isLoadingHashTag = true;
    searchHashTagModel = null;
    searchHashTagModel = await SearchHashTagApi.callApi(loginUserId: Database.loginUserId, searchText: "");
    if (searchHashTagModel?.searchData != null) {
      hashTagCollection.addAll(searchHashTagModel?.searchData ?? []);
      isLoadingHashTag = false;
      update(["onGetHashTag"]);
    }
  }

  Future<void> onSearching() async {
    if (searchFieldController.text.trim().isNotEmpty) {
      isSearching = true; // Show Search Data...
      update(["onSearching"]);

      if (selectedTabIndex == 0) {
        await onSearchUser(searchFieldController.text);
      } else {
        await onSearchHashTag(searchFieldController.text);
      }
    } else if (searchFieldController.text.isEmpty) {
      isSearching = false; // Show All Data...
      update(["onSearching"]);
    }
  }

  Future<void> onSearchUser(String searchText) async {
    searchUserModel = null;
    searchUsers.clear();
    log("Search User Method Calling... --> ${searchUsers.length}");
    isSearchingUser = true;
    update(["onSearchUser"]);

    searchUserModel = await SearchUserApi.callApi(loginUserId: Database.loginUserId, searchText: searchText);
    if (searchUserModel?.searchData != null) {
      searchUsers.clear();
      searchUsers.addAll(searchUserModel?.searchData ?? []);
      isSearchingUser = false;
      update(["onSearchUser"]);
    }
  }

  Future<void> onSearchHashTag(String searchText) async {
    searchHashTagModel = null;
    searchHashTags.clear();
    isSearchingHashTag = true;
    update(["onSearchHashTag"]);
    searchHashTagModel = await SearchHashTagApi.callApi(loginUserId: Database.loginUserId, searchText: searchText);
    if (searchHashTagModel?.searchData != null) {
      searchHashTags.clear();
      searchHashTags.addAll(searchHashTagModel?.searchData ?? []);
      isSearchingHashTag = false;
      update(["onSearchHashTag"]);
    }
  }

  Future<void> onGetStory({List<Stories>? userStory, String? userId, String? title, String? subTitle, String? leading, bool? isProfileImageBanned}) async {
    if ((userStory?.isNotEmpty ?? true)) {
      final stories = (userStory ?? [])
          .map<Stories>((s) => Stories.fromJson({
                "_id": s.id,
                "storyType": s.storyType,
                "mediaImageUrl": s.mediaImageUrl,
                "mediaVideoUrl": s.mediaVideoUrl,
                "duration": s.duration,
                "viewsCount": s.viewsCount,
                "reactionsCount": s.reactionsCount,
                "createdAt": s.createdAt,
                "backgroundSong": s.backgroundSong == null
                    ? null
                    : {
                        "_id": s.backgroundSong?.id,
                        "songTitle": s.backgroundSong?.songTitle,
                        "songImage": s.backgroundSong?.songImage,
                        "singerName": s.backgroundSong?.singerName,
                        "songTime": s.backgroundSong?.songTime,
                        "songLink": s.backgroundSong?.songLink,
                      },
              }))
          .toList();

      if (userId == Database.loginUserId) {
        await StoryViewer.openOwn(stories: stories, initialIndex: 0);
      } else {
        final group = StoryGroup(
          user: User(
            id: userId,
            name: title,
            userName: subTitle,
            image: leading,
            isProfileImageBanned: isProfileImageBanned,
          ),
          stories: stories,
        );
        await StoryViewer.openOthers(groups: [group], initialGroupIndex: 0);
      }
    }
  }
}
