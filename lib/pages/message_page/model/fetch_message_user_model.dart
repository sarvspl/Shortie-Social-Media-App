// To parse this JSON data, do
//
//     final fetchMessageUserModel = fetchMessageUserModelFromJson(jsonString);

import 'dart:convert';

import '../../story_page/model/fetch_story_model.dart';

FetchMessageUserModel fetchMessageUserModelFromJson(String str) => FetchMessageUserModel.fromJson(json.decode(str));

String fetchMessageUserModelToJson(FetchMessageUserModel data) => json.encode(data.toJson());

class FetchMessageUserModel {
  bool? status;
  String? message;
  int? pendingCount;
  List<Datum>? data;

  FetchMessageUserModel({
    this.status,
    this.message,
    this.pendingCount,
    this.data,
  });

  factory FetchMessageUserModel.fromJson(Map<String, dynamic> json) => FetchMessageUserModel(
        status: json["status"],
        message: json["message"],
        pendingCount: json["pendingCount"],
        data: json["data"] == null ? [] : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "pendingCount": pendingCount,
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class Datum {
  String? id;
  String? name;
  String? userName;
  String? image;
  bool? isOnline;
  bool? isFake;
  bool? isVerified;
  bool? isProfileImageBanned;
  List<Story>? stories;
  String? chatTopicId;
  String? time;
  String? userId;
  String? senderUserId;
  bool? isAccepted;
  String? message;
  int? unreadCount;

  Datum({
    this.id,
    this.name,
    this.userName,
    this.image,
    this.isOnline,
    this.isFake,
    this.isVerified,
    this.isProfileImageBanned,
    this.stories,
    this.chatTopicId,
    this.time,
    this.userId,
    this.senderUserId,
    this.isAccepted,
    this.message,
    this.unreadCount,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["_id"],
        name: json["name"],
        userName: json["userName"],
        image: json["image"],
        isOnline: json["isOnline"],
        isFake: json["isFake"],
        isVerified: json["isVerified"],
        isProfileImageBanned: json["isProfileImageBanned"],
        stories: json["stories"] == null ? [] : List<Story>.from(json["stories"]!.map((x) => Story.fromJson(x))),
        chatTopicId: json["chatTopicId"],
        time: json["time"],
        userId: json["userId"],
        senderUserId: json["senderUserId"],
        isAccepted: json["isAccepted"],
        message: json["message"],
        unreadCount: json["unreadCount"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
        "userName": userName,
        "image": image,
        "isOnline": isOnline,
        "isFake": isFake,
        "isVerified": isVerified,
        "isProfileImageBanned": isProfileImageBanned,
        "stories": stories == null ? [] : List<dynamic>.from(stories!.map((x) => x.toJson())),
        "chatTopicId": chatTopicId,
        "time": time,
        "userId": userId,
        "senderUserId": senderUserId,
        "isAccepted": isAccepted,
        "message": message,
        "unreadCount": unreadCount,
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
