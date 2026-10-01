import 'package:shortie/pages/story_page/model/fetch_story_model.dart';

class SearchUserModel {
  bool? status;
  String? message;
  List<SearchUserData>? searchData;

  SearchUserModel({this.status, this.message, this.searchData});

  SearchUserModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['searchData'] != null) {
      searchData = <SearchUserData>[];
      json['searchData'].forEach((v) {
        searchData!.add(new SearchUserData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.searchData != null) {
      data['searchData'] = this.searchData!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class SearchUserData {
  String? id;
  String? name;
  String? userName;
  String? image;
  bool? isProfileImageBanned;
  bool? isFake;
  bool? isVerified;
  List<Stories>? stories;

  SearchUserData({
    this.id,
    this.name,
    this.userName,
    this.image,
    this.isProfileImageBanned,
    this.isFake,
    this.isVerified,
    this.stories,
  });

  factory SearchUserData.fromJson(Map<String, dynamic> json) => SearchUserData(
        id: json["_id"],
        name: json["name"],
        userName: json["userName"],
        image: json["image"],
        isProfileImageBanned: json["isProfileImageBanned"],
        isFake: json["isFake"],
        isVerified: json["isVerified"],
        stories: (json["stories"] as List<dynamic>? ?? []).map((x) => Stories.fromJson(x)).toList(),
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
        "userName": userName,
        "image": image,
        "isProfileImageBanned": isProfileImageBanned,
        "isFake": isFake,
        "isVerified": isVerified,
        "stories": stories?.map((x) => x.toJson()).toList() ?? [],
      };
}

/*// To parse this JSON data, do

// final searchUserModel = searchUserModelFromJson(jsonString);

import 'dart:convert';

import '../../message_page/model/fetch_message_user_model.dart';

SearchUserModel searchUserModelFromJson(String str) => SearchUserModel.fromJson(json.decode(str));

String searchUserModelToJson(SearchUserModel data) => json.encode(data.toJson());

class SearchUserModel {
  bool? status;
  String? message;
  List<SearchUserData>? searchData;

  SearchUserModel({
    this.status,
    this.message,
    this.searchData,
  });

  factory SearchUserModel.fromJson(Map<String, dynamic> json) => SearchUserModel(
        status: json["status"],
        message: json["message"],
        searchData: json["searchData"] == null ? [] : List<SearchUserData>.from(json["searchData"]!.map((x) => SearchUserData.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "searchData": searchData == null ? [] : List<dynamic>.from(searchData!.map((x) => x.toJson())),
      };
}

class SearchUserData {
  String? id;
  String? name;
  String? userName;
  String? image;
  bool? isProfileImageBanned;
  bool? isFake;
  bool? isVerified;
  List<Story>? stories;

  SearchUserData({
    this.id,
    this.name,
    this.userName,
    this.image,
    this.isProfileImageBanned,
    this.isFake,
    this.isVerified,
    this.stories,
  });

  factory SearchUserData.fromJson(Map<String, dynamic> json) => SearchUserData(
        id: json["_id"],
        name: json["name"],
        userName: json["userName"],
        image: json["image"],
        isProfileImageBanned: json["isProfileImageBanned"],
        isFake: json["isFake"],
        isVerified: json["isVerified"],
        stories: json["stories"] == null ? [] : List<Story>.from(json["stories"]!.map((x) => Story.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
        "userName": userName,
        "image": image,
        "isProfileImageBanned": isProfileImageBanned,
        "isFake": isFake,
        "isVerified": isVerified,
        "stories": stories == null ? [] : List<dynamic>.from(stories!.map((x) => x.toJson())),
      };
}*/
