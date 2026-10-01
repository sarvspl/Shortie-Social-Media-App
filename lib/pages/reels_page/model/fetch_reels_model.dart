// To parse this JSON data, do
//
//     final fetchReelsModel = fetchReelsModelFromJson(jsonString);

import 'dart:convert';

FetchReelsModel fetchReelsModelFromJson(String str) => FetchReelsModel.fromJson(json.decode(str));

String fetchReelsModelToJson(FetchReelsModel data) => json.encode(data.toJson());

class FetchReelsModel {
  bool? status;
  String? message;
  List<Datum>? data;

  FetchReelsModel({
    this.status,
    this.message,
    this.data,
  });

  factory FetchReelsModel.fromJson(Map<String, dynamic> json) => FetchReelsModel(
    status: json["status"],
    message: json["message"],
    data: json["data"] == null ? [] : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class Datum {
  String? id;
  String? caption;
  String? videoUrl;
  String? videoImage;
  dynamic songId;
  int? shareCount;
  bool? isFake;
  DateTime? createdAt;
  List<Story>? stories;
  List<String>? hashTag;
  String? userId;
  String? name;
  String? userName;
  String? userImage;
  bool? isVerified;
  bool? userIsFake;
  bool? isProfileImageBanned;
  bool? isLike;
  bool? isFollow;
  int? totalLikes;
  int? totalComments;
  Time? time;

  Datum({
    this.id,
    this.caption,
    this.videoUrl,
    this.videoImage,
    this.songId,
    this.shareCount,
    this.isFake,
    this.createdAt,
    this.stories,
    this.hashTag,
    this.userId,
    this.name,
    this.userName,
    this.userImage,
    this.isVerified,
    this.userIsFake,
    this.isProfileImageBanned,
    this.isLike,
    this.isFollow,
    this.totalLikes,
    this.totalComments,
    this.time,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["_id"],
    caption: json["caption"],
    videoUrl: json["videoUrl"],
    videoImage: json["videoImage"],
    songId: json["songId"],
    shareCount: json["shareCount"],
    isFake: json["isFake"],
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    stories: json["stories"] == null ? [] : List<Story>.from(json["stories"]!.map((x) => Story.fromJson(x))),
    hashTag: json["hashTag"] == null ? [] : List<String>.from(json["hashTag"]!.map((x) => x)),
    userId: json["userId"],
    name: json["name"],
    userName: json["userName"],
    userImage: json["userImage"],
    isVerified: json["isVerified"],
    userIsFake: json["userIsFake"],
    isProfileImageBanned: json["isProfileImageBanned"],
    isLike: json["isLike"],
    isFollow: json["isFollow"],
    totalLikes: json["totalLikes"],
    totalComments: json["totalComments"],
    time: json["time"] != null ? timeValues.map[json["time"]] : null,
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "caption": caption,
    "videoUrl": videoUrl,
    "videoImage": videoImage,
    "songId": songId,
    "shareCount": shareCount,
    "isFake": isFake,
    "createdAt": createdAt?.toIso8601String(),
    "stories": stories == null ? [] : List<dynamic>.from(stories!.map((x) => x.toJson())),
    "hashTag": hashTag == null ? [] : List<dynamic>.from(hashTag!.map((x) => x)),
    "userId": userId,
    "name": name,
    "userName": userName,
    "userImage": userImage,
    "isVerified": isVerified,
    "userIsFake": userIsFake,
    "isProfileImageBanned": isProfileImageBanned,
    "isLike": isLike,
    "isFollow": isFollow,
    "totalLikes": totalLikes,
    "totalComments": totalComments,
    "time": timeValues.reverse[time],
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

enum Time {
  THE_1_MONTHS_AGO,
  THE_2_MONTHS_AGO,
  THE_2_WEEKS_AGO,
  THE_8_MONTHS_AGO
}

final timeValues = EnumValues({
  "1 months ago": Time.THE_1_MONTHS_AGO,
  "2 months ago": Time.THE_2_MONTHS_AGO,
  "2 weeks ago": Time.THE_2_WEEKS_AGO,
  "8 months ago": Time.THE_8_MONTHS_AGO
});

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
