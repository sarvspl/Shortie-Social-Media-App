// To parse this JSON data, do
//
//     final fetchProfileModel = fetchProfileModelFromJson(jsonString);

import 'dart:convert';

FetchProfileModel fetchProfileModelFromJson(String str) => FetchProfileModel.fromJson(json.decode(str));

String fetchProfileModelToJson(FetchProfileModel data) => json.encode(data.toJson());

class FetchProfileModel {
  bool? status;
  String? message;
  UserProfileData? userProfileData;
  List<Story>? stories;

  FetchProfileModel({
    this.status,
    this.message,
    this.userProfileData,
    this.stories,
  });

  factory FetchProfileModel.fromJson(Map<String, dynamic> json) => FetchProfileModel(
    status: json["status"],
    message: json["message"],
    userProfileData: json["userProfileData"] == null ? null : UserProfileData.fromJson(json["userProfileData"]),
    stories: json["stories"] == null ? [] : List<Story>.from(json["stories"]!.map((x) => Story.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "userProfileData": userProfileData?.toJson(),
    "stories": stories == null ? [] : List<dynamic>.from(stories!.map((x) => x.toJson())),
  };
}

class Story {
  String? id;
  BackgroundSong? backgroundSong;
  int? storyType;
  String? mediaImageUrl;
  String? mediaVideoUrl;
  int? duration;
  int? viewsCount;
  int? reactionsCount;
  DateTime? createdAt;

  Story({
    this.id,
    this.backgroundSong,
    this.storyType,
    this.mediaImageUrl,
    this.mediaVideoUrl,
    this.duration,
    this.viewsCount,
    this.reactionsCount,
    this.createdAt,
  });

  factory Story.fromJson(Map<String, dynamic> json) => Story(
    id: json["_id"],
    backgroundSong: json["backgroundSong"] == null ? null : BackgroundSong.fromJson(json["backgroundSong"]),
    storyType: json["storyType"],
    mediaImageUrl: json["mediaImageUrl"],
    mediaVideoUrl: json["mediaVideoUrl"],
    duration: json["duration"],
    viewsCount: json["viewsCount"],
    reactionsCount: json["reactionsCount"],
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "backgroundSong": backgroundSong?.toJson(),
    "storyType": storyType,
    "mediaImageUrl": mediaImageUrl,
    "mediaVideoUrl": mediaVideoUrl,
    "duration": duration,
    "viewsCount": viewsCount,
    "reactionsCount": reactionsCount,
    "createdAt": createdAt?.toIso8601String(),
  };
}

class BackgroundSong {
  String? id;
  String? songTitle;
  String? songImage;
  String? singerName;
  double? songTime;
  String? songLink;

  BackgroundSong({
    this.id,
    this.songTitle,
    this.songImage,
    this.singerName,
    this.songTime,
    this.songLink,
  });

  factory BackgroundSong.fromJson(Map<String, dynamic> json) => BackgroundSong(
    id: json["_id"],
    songTitle: json["songTitle"],
    songImage: json["songImage"],
    singerName: json["singerName"],
    songTime: json["songTime"]?.toDouble(),
    songLink: json["songLink"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "songTitle": songTitle,
    "songImage": songImage,
    "singerName": singerName,
    "songTime": songTime,
    "songLink": songLink,
  };
}

class UserProfileData {
  User? user;
  int? totalFollowers;
  int? totalFollowing;
  int? totalLikesOfVideoPost;

  UserProfileData({
    this.user,
    this.totalFollowers,
    this.totalFollowing,
    this.totalLikesOfVideoPost,
  });

  factory UserProfileData.fromJson(Map<String, dynamic> json) => UserProfileData(
    user: json["user"] == null ? null : User.fromJson(json["user"]),
    totalFollowers: json["totalFollowers"],
    totalFollowing: json["totalFollowing"],
    totalLikesOfVideoPost: json["totalLikesOfVideoPost"],
  );

  Map<String, dynamic> toJson() => {
    "user": user?.toJson(),
    "totalFollowers": totalFollowers,
    "totalFollowing": totalFollowing,
    "totalLikesOfVideoPost": totalLikesOfVideoPost,
  };
}

class User {
  String? name;
  String? userName;
  String? bio;
  String? gender;
  String? image;
  String? countryFlagImage;
  String? country;
  bool? isVerified;
  bool? isFollow;
  bool? isFake;
  bool? isProfileImageBanned;

  User({
    this.name,
    this.userName,
    this.bio,
    this.gender,
    this.image,
    this.countryFlagImage,
    this.country,
    this.isVerified,
    this.isFollow,
    this.isFake,
    this.isProfileImageBanned,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    name: json["name"],
    userName: json["userName"],
    bio: json["bio"],
    gender: json["gender"],
    image: json["image"],
    countryFlagImage: json["countryFlagImage"],
    country: json["country"],
    isVerified: json["isVerified"],
    isFollow: json["isFollow"],
    isFake: json["isFake"],
    isProfileImageBanned: json["isProfileImageBanned"],
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "userName": userName,
    "bio": bio,
    "gender": gender,
    "image": image,
    "countryFlagImage": countryFlagImage,
    "country": country,
    "isVerified": isVerified,
    "isFollow": isFollow,
    "isFake": isFake,
    "isProfileImageBanned": isProfileImageBanned,
  };
}
