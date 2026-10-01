// To parse this JSON data, do
//
//     final fetchProfilePostModel = fetchProfilePostModelFromJson(jsonString);

import 'dart:convert';

import 'package:shortie/pages/feed_page/model/post_image_model.dart';

FetchProfilePostModel fetchProfilePostModelFromJson(String str) => FetchProfilePostModel.fromJson(json.decode(str));

String fetchProfilePostModelToJson(FetchProfilePostModel data) => json.encode(data.toJson());

class FetchProfilePostModel {
  bool? status;
  String? message;
  List<ProfilePostData>? data;

  FetchProfilePostModel({
    this.status,
    this.message,
    this.data,
  });

  FetchProfilePostModel copyWith({
    bool? status,
    String? message,
    List<ProfilePostData>? data,
  }) =>
      FetchProfilePostModel(
        status: status ?? this.status,
        message: message ?? this.message,
        data: data ?? this.data,
      );

  factory FetchProfilePostModel.fromJson(Map<String, dynamic> json) => FetchProfilePostModel(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null ? [] : List<ProfilePostData>.from(json["data"]!.map((x) => ProfilePostData.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class ProfilePostData {
  String? id;
  String? caption;
  String? mainPostImage;
  String? userId;
  List<PostImage>? postImage;
  DateTime? createdAt;
  String? name;
  String? userName;
  String? userImage;
  bool? isProfileImageBanned;
  bool? isVerified;
  List<dynamic>? hashTag;
  int? totalLikes;
  int? totalComments;
  bool? isLike;

  ProfilePostData({
    this.id,
    this.caption,
    this.mainPostImage,
    this.userId,
    this.postImage,
    this.createdAt,
    this.name,
    this.userName,
    this.userImage,
    this.isProfileImageBanned,
    this.isVerified,
    this.hashTag,
    this.totalLikes,
    this.totalComments,
    this.isLike,
  });

  ProfilePostData copyWith({
    String? id,
    String? caption,
    String? mainPostImage,
    String? userId,
    List<PostImage>? postImage,
    DateTime? createdAt,
    String? name,
    String? userName,
    String? userImage,
    bool? isProfileImageBanned,
    bool? isVerified,
    List<dynamic>? hashTag,
    int? totalLikes,
    int? totalComments,
    bool? isLike,
  }) =>
      ProfilePostData(
        id: id ?? this.id,
        caption: caption ?? this.caption,
        mainPostImage: mainPostImage ?? this.mainPostImage,
        userId: userId ?? this.userId,
        postImage: postImage ?? this.postImage,
        createdAt: createdAt ?? this.createdAt,
        name: name ?? this.name,
        userName: userName ?? this.userName,
        userImage: userImage ?? this.userImage,
        isProfileImageBanned: isProfileImageBanned ?? this.isProfileImageBanned,
        isVerified: isVerified ?? this.isVerified,
        hashTag: hashTag ?? this.hashTag,
        totalLikes: totalLikes ?? this.totalLikes,
        totalComments: totalComments ?? this.totalComments,
        isLike: isLike ?? this.isLike,
      );

  factory ProfilePostData.fromJson(Map<String, dynamic> json) => ProfilePostData(
        id: json["_id"],
        caption: json["caption"],
        mainPostImage: json["mainPostImage"],
        userId: json["userId"],
        postImage: json["postImage"] == null ? [] : List<PostImage>.from(json["postImage"]!.map((x) => PostImage.fromJson(x))),
        createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
        name: json["name"],
        userName: json["userName"],
        userImage: json["userImage"],
        isProfileImageBanned: json["isProfileImageBanned"],
        isVerified: json["isVerified"],
        hashTag: json["hashTag"] == null ? [] : List<dynamic>.from(json["hashTag"]!.map((x) => x)),
        totalLikes: json["totalLikes"],
        totalComments: json["totalComments"],
        isLike: json["isLike"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "caption": caption,
        "mainPostImage": mainPostImage,
        "userId": userId,
        "postImage": postImage == null ? [] : List<dynamic>.from(postImage!.map((x) => x.toJson())),
        "createdAt": createdAt?.toIso8601String(),
        "name": name,
        "userName": userName,
        "userImage": userImage,
        "isProfileImageBanned": isProfileImageBanned,
        "isVerified": isVerified,
        "hashTag": hashTag == null ? [] : List<dynamic>.from(hashTag!.map((x) => x)),
        "totalLikes": totalLikes,
        "totalComments": totalComments,
        "isLike": isLike,
      };
}
//
// class PostImage {
//   String? url;
//   bool? isBanned;
//   String? id;
//
//   PostImage({
//     this.url,
//     this.isBanned,
//     this.id,
//   });
//
//   PostImage copyWith({
//     String? url,
//     bool? isBanned,
//     String? id,
//   }) =>
//       PostImage(
//         url: url ?? this.url,
//         isBanned: isBanned ?? this.isBanned,
//         id: id ?? this.id,
//       );
//
//   factory PostImage.fromJson(Map<String, dynamic> json) => PostImage(
//     url: json["url"],
//     isBanned: json["isBanned"],
//     id: json["_id"],
//   );
//
//   Map<String, dynamic> toJson() => {
//     "url": url,
//     "isBanned": isBanned,
//     "_id": id,
//   };
// }
