// To parse this JSON data, do
//
//     final fetchPostModel = fetchPostModelFromJson(jsonString);

import 'dart:convert';

import 'package:shortie/pages/feed_page/model/post_image_model.dart';

FetchPostModel fetchPostModelFromJson(String str) => FetchPostModel.fromJson(json.decode(str));

String fetchPostModelToJson(FetchPostModel data) => json.encode(data.toJson());

class FetchPostModel {
  bool? status;
  String? message;
  List<Post>? post;

  FetchPostModel({
    this.status,
    this.message,
    this.post,
  });

  FetchPostModel copyWith({
    bool? status,
    String? message,
    List<Post>? post,
  }) =>
      FetchPostModel(
        status: status ?? this.status,
        message: message ?? this.message,
        post: post ?? this.post,
      );

  factory FetchPostModel.fromJson(Map<String, dynamic> json) => FetchPostModel(
        status: json["status"],
        message: json["message"],
        post: json["post"] == null ? [] : List<Post>.from(json["post"]!.map((x) => Post.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "post": post == null ? [] : List<dynamic>.from(post!.map((x) => x.toJson())),
      };
}

class Post {
  String? id;
  String? caption;
  int? shareCount;
  bool? isFake;
  List<PostImage>? postImage;
  DateTime? createdAt;
  List<Story>? stories;
  String? userId;
  String? name;
  String? userName;
  String? userImage;
  bool? isProfileImageBanned;
  bool? isVerified;
  List<String>? hashTag;
  bool? isLike;
  bool? isFollow;
  int? totalLikes;
  int? totalComments;
  String? time;

  Post({
    this.id,
    this.caption,
    this.shareCount,
    this.isFake,
    this.postImage,
    this.createdAt,
    this.stories,
    this.userId,
    this.name,
    this.userName,
    this.userImage,
    this.isProfileImageBanned,
    this.isVerified,
    this.hashTag,
    this.isLike,
    this.isFollow,
    this.totalLikes,
    this.totalComments,
    this.time,
  });

  Post copyWith({
    String? id,
    String? caption,
    int? shareCount,
    bool? isFake,
    List<PostImage>? postImage,
    DateTime? createdAt,
    List<Story>? stories,
    String? userId,
    String? name,
    String? userName,
    String? userImage,
    bool? isProfileImageBanned,
    bool? isVerified,
    List<String>? hashTag,
    bool? isLike,
    bool? isFollow,
    int? totalLikes,
    int? totalComments,
    String? time,
  }) =>
      Post(
        id: id ?? this.id,
        caption: caption ?? this.caption,
        shareCount: shareCount ?? this.shareCount,
        isFake: isFake ?? this.isFake,
        postImage: postImage ?? this.postImage,
        createdAt: createdAt ?? this.createdAt,
        stories: stories ?? this.stories,
        userId: userId ?? this.userId,
        name: name ?? this.name,
        userName: userName ?? this.userName,
        userImage: userImage ?? this.userImage,
        isProfileImageBanned: isProfileImageBanned ?? this.isProfileImageBanned,
        isVerified: isVerified ?? this.isVerified,
        hashTag: hashTag ?? this.hashTag,
        isLike: isLike ?? this.isLike,
        isFollow: isFollow ?? this.isFollow,
        totalLikes: totalLikes ?? this.totalLikes,
        totalComments: totalComments ?? this.totalComments,
        time: time ?? this.time,
      );

  factory Post.fromJson(Map<String, dynamic> json) => Post(
        id: json["_id"],
        caption: json["caption"],
        shareCount: json["shareCount"],
        isFake: json["isFake"],
        postImage: json["postImage"] == null ? [] : List<PostImage>.from(json["postImage"]!.map((x) => PostImage.fromJson(x))),
        createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
        stories: json["stories"] == null ? [] : List<Story>.from(json["stories"]!.map((x) => Story.fromJson(x))),
        userId: json["userId"],
        name: json["name"],
        userName: json["userName"],
        userImage: json["userImage"],
        isProfileImageBanned: json["isProfileImageBanned"],
        isVerified: json["isVerified"],
        hashTag: json["hashTag"] == null ? [] : List<String>.from(json["hashTag"]!.map((x) => x)),
        isLike: json["isLike"],
        isFollow: json["isFollow"],
        totalLikes: json["totalLikes"],
        totalComments: json["totalComments"],
        time: json["time"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "caption": caption,
        "shareCount": shareCount,
        "isFake": isFake,
        "postImage": postImage == null ? [] : List<dynamic>.from(postImage!.map((x) => x.toJson())),
        "createdAt": createdAt?.toIso8601String(),
        "stories": stories == null ? [] : List<dynamic>.from(stories!.map((x) => x.toJson())),
        "userId": userId,
        "name": name,
        "userName": userName,
        "userImage": userImage,
        "isProfileImageBanned": isProfileImageBanned,
        "isVerified": isVerified,
        "hashTag": hashTag == null ? [] : List<dynamic>.from(hashTag!.map((x) => x)),
        "isLike": isLike,
        "isFollow": isFollow,
        "totalLikes": totalLikes,
        "totalComments": totalComments,
        "time": time,
      };
}

class Story {
  String? id;
  String? user;
  BackgroundSong? backgroundSong;
  int? storyType;
  String? mediaImageUrl;
  String? mediaVideoUrl;
  int? duration;
  int? viewsCount;
  int? reactionsCount;
  bool? isFake;
  DateTime? expiresAt;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? storyMediaType;

  Story({
    this.id,
    this.user,
    this.backgroundSong,
    this.storyType,
    this.mediaImageUrl,
    this.mediaVideoUrl,
    this.duration,
    this.viewsCount,
    this.reactionsCount,
    this.isFake,
    this.expiresAt,
    this.createdAt,
    this.updatedAt,
    this.storyMediaType,
  });

  Story copyWith({
    String? id,
    String? user,
    BackgroundSong? backgroundSong,
    int? storyType,
    String? mediaImageUrl,
    String? mediaVideoUrl,
    int? duration,
    int? viewsCount,
    int? reactionsCount,
    bool? isFake,
    DateTime? expiresAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? storyMediaType,
  }) =>
      Story(
        id: id ?? this.id,
        user: user ?? this.user,
        backgroundSong: backgroundSong ?? this.backgroundSong,
        storyType: storyType ?? this.storyType,
        mediaImageUrl: mediaImageUrl ?? this.mediaImageUrl,
        mediaVideoUrl: mediaVideoUrl ?? this.mediaVideoUrl,
        duration: duration ?? this.duration,
        viewsCount: viewsCount ?? this.viewsCount,
        reactionsCount: reactionsCount ?? this.reactionsCount,
        isFake: isFake ?? this.isFake,
        expiresAt: expiresAt ?? this.expiresAt,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        storyMediaType: storyMediaType ?? this.storyMediaType,
      );

  factory Story.fromJson(Map<String, dynamic> json) => Story(
    id: json["_id"],
    user: json["user"],
    backgroundSong: json["backgroundSong"] == null
        ? null
        : BackgroundSong.fromJson(json["backgroundSong"]),
    storyType: json["storyType"],
    mediaImageUrl: json["mediaImageUrl"],
    mediaVideoUrl: json["mediaVideoUrl"],
    duration: json["duration"],
    viewsCount: json["viewsCount"],
    reactionsCount: json["reactionsCount"],
    isFake: json["isFake"],
    expiresAt:
    json["expiresAt"] == null ? null : DateTime.parse(json["expiresAt"]),
    createdAt:
    json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt:
    json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
    storyMediaType: json["storyMediaType"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "user": user,
    "backgroundSong": backgroundSong?.toJson(),
    "storyType": storyType,
    "mediaImageUrl": mediaImageUrl,
    "mediaVideoUrl": mediaVideoUrl,
    "duration": duration,
    "viewsCount": viewsCount,
    "reactionsCount": reactionsCount,
    "isFake": isFake,
    "expiresAt": expiresAt?.toIso8601String(),
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "storyMediaType": storyMediaType,
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

  BackgroundSong copyWith({
    String? id,
    String? songTitle,
    String? songImage,
    String? singerName,
    double? songTime,
    String? songLink,
  }) =>
      BackgroundSong(
        id: id ?? this.id,
        songTitle: songTitle ?? this.songTitle,
        songImage: songImage ?? this.songImage,
        singerName: singerName ?? this.singerName,
        songTime: songTime ?? this.songTime,
        songLink: songLink ?? this.songLink,
      );

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
