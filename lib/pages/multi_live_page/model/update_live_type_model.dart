// To parse this JSON data, do
//
//     final updateLiveTypeModel = updateLiveTypeModelFromJson(jsonString);

import 'dart:convert';

import 'package:shortie/pages/stream_page/model/live_user_object_model.dart';

UpdateLiveTypeModel updateLiveTypeModelFromJson(String str) => UpdateLiveTypeModel.fromJson(json.decode(str));

String updateLiveTypeModelToJson(UpdateLiveTypeModel data) => json.encode(data.toJson());

class UpdateLiveTypeModel {
  String? id;
  PkConfig? pkConfig;
  String? userId;
  String? liveHistoryId;
  String? name;
  String? userName;
  String? image;
  bool? isProfileImageBanned;
  String? countryFlagImage;
  String? country;
  bool? isVerified;
  int? view;
  bool? isPkMode;
  dynamic pkEndTime;
  dynamic pkId;
  bool? isHostCameraEnabled;
  List<Requested>? requested;
  int? liveType;
  DateTime? createdAt;
  DateTime? updatedAt;

  UpdateLiveTypeModel({
    this.id,
    this.pkConfig,
    this.userId,
    this.liveHistoryId,
    this.name,
    this.userName,
    this.image,
    this.isProfileImageBanned,
    this.countryFlagImage,
    this.country,
    this.isVerified,
    this.view,
    this.isPkMode,
    this.pkEndTime,
    this.pkId,
    this.isHostCameraEnabled,
    this.requested,
    this.liveType,
    this.createdAt,
    this.updatedAt,
  });

  factory UpdateLiveTypeModel.fromJson(Map<String, dynamic> json) => UpdateLiveTypeModel(
        id: json["_id"],
        pkConfig: json["pkConfig"] == null ? null : PkConfig.fromJson(json["pkConfig"]),
        userId: json["userId"],
        liveHistoryId: json["liveHistoryId"],
        name: json["name"],
        userName: json["userName"],
        image: json["image"],
        isProfileImageBanned: json["isProfileImageBanned"],
        countryFlagImage: json["countryFlagImage"],
        country: json["country"],
        isVerified: json["isVerified"],
        view: json["view"],
        isPkMode: json["isPkMode"],
        pkEndTime: json["pkEndTime"],
        pkId: json["pkId"],
        isHostCameraEnabled: json["isHostCameraEnabled"],
        requested: json["requested"] == null ? [] : List<Requested>.from(json["requested"]!.map((x) => Requested.fromJson(x))),
        liveType: json["liveType"],
        createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "pkConfig": pkConfig?.toJson(),
        "userId": userId,
        "liveHistoryId": liveHistoryId,
        "name": name,
        "userName": userName,
        "image": image,
        "isProfileImageBanned": isProfileImageBanned,
        "countryFlagImage": countryFlagImage,
        "country": country,
        "isVerified": isVerified,
        "view": view,
        "isPkMode": isPkMode,
        "pkEndTime": pkEndTime,
        "pkId": pkId,
        "isHostCameraEnabled": isHostCameraEnabled,
        "requested": requested == null ? [] : List<dynamic>.from(requested!.map((x) => x.toJson())),
        "liveType": liveType,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
      };
}

class PkConfig {
  HostDetails? host1Details;
  HostDetails? host2Details;
  dynamic host1Id;
  dynamic host2Id;
  dynamic host1UniqueId;
  dynamic host2UniqueId;
  dynamic host1Name;
  dynamic host2Name;
  dynamic host2UserName;
  dynamic host1Image;
  dynamic host2Image;
  dynamic host1LiveId;
  dynamic host2LiveId;
  int? localRank;
  int? remoteRank;
  int? isWinner;

  PkConfig({
    this.host1Details,
    this.host2Details,
    this.host1Id,
    this.host2Id,
    this.host1UniqueId,
    this.host2UniqueId,
    this.host1Name,
    this.host2Name,
    this.host2UserName,
    this.host1Image,
    this.host2Image,
    this.host1LiveId,
    this.host2LiveId,
    this.localRank,
    this.remoteRank,
    this.isWinner,
  });

  factory PkConfig.fromJson(Map<String, dynamic> json) => PkConfig(
        host1Details: json["host1Details"] == null ? null : HostDetails.fromJson(json["host1Details"]),
        host2Details: json["host2Details"] == null ? null : HostDetails.fromJson(json["host2Details"]),
        host1Id: json["host1Id"],
        host2Id: json["host2Id"],
        host1UniqueId: json["host1UniqueId"],
        host2UniqueId: json["host2UniqueId"],
        host1Name: json["host1Name"],
        host2Name: json["host2Name"],
        host2UserName: json["host2userName"],
        host1Image: json["host1Image"],
        host2Image: json["host2Image"],
        host1LiveId: json["host1LiveId"],
        host2LiveId: json["host2LiveId"],
        localRank: json["localRank"],
        remoteRank: json["remoteRank"],
        isWinner: json["isWinner"],
      );

  Map<String, dynamic> toJson() => {
        "host1Details": host1Details?.toJson(),
        "host2Details": host2Details?.toJson(),
        "host1Id": host1Id,
        "host2Id": host2Id,
        "host1UniqueId": host1UniqueId,
        "host2UniqueId": host2UniqueId,
        "host1Name": host1Name,
        "host2Name": host2Name,
        "host2userName": host2UserName,
        "host1Image": host1Image,
        "host2Image": host2Image,
        "host1LiveId": host1LiveId,
        "host2LiveId": host2LiveId,
        "localRank": localRank,
        "remoteRank": remoteRank,
        "isWinner": isWinner,
      };
}

class HostDetails {
  dynamic userId;
  dynamic name;
  int? coin;
  dynamic image;
  dynamic countryFlagImage;
  dynamic country;
  dynamic uniqueId;

  HostDetails({
    this.userId,
    this.name,
    this.coin,
    this.image,
    this.countryFlagImage,
    this.country,
    this.uniqueId,
  });

  factory HostDetails.fromJson(Map<String, dynamic> json) => HostDetails(
        userId: json["userId"],
        name: json["name"],
        coin: json["coin"],
        image: json["image"],
        countryFlagImage: json["countryFlagImage"],
        country: json["country"],
        uniqueId: json["uniqueId"],
      );

  Map<String, dynamic> toJson() => {
        "userId": userId,
        "name": name,
        "coin": coin,
        "image": image,
        "countryFlagImage": countryFlagImage,
        "country": country,
        "uniqueId": uniqueId,
      };
}
