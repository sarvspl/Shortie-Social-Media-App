// class LiveUserObject {
//   String? id;
//   String? userId;
//   String? liveHistoryId;
//   String? name;
//   String? userName;
//   String? image;
//   bool? isProfileImageBanned;
//   String? countryFlagImage;
//   String? country; // Added - was missing
//   bool? isVerified;
//   int? view;
//   List<Requested>? requested;
//   int? liveType;
//   int? shareCount;
//   String? videoUrl;
//   String? host1Channel;
//   String? host2Channel;
//   String? host2Image;
//   int? host1WinnerPoint;
//   int? host2WinnerPoint;
//   int? localRank;
//   int? remoteRank;
//   bool? isLive;
//   bool? isHostCameraEnabled;
//   bool? isFake;
//   bool? isFollow;
//
//   // Missing fields from socket response
//   bool? isPkMode;
//   bool? isPkRound;
//   String? pkEndTime;
//   String? pkId;
//   int? totalPkRounds;
//   PkConfig? pkConfig; // New nested object
//   DateTime? createdAt;
//   DateTime? updatedAt;
//
//   LiveUserObject({
//     this.id,
//     this.userId,
//     this.liveHistoryId,
//     this.name,
//     this.userName,
//     this.image,
//     this.isProfileImageBanned,
//     this.countryFlagImage,
//     this.country,
//     this.isVerified,
//     this.view,
//     this.requested,
//     this.liveType,
//     this.shareCount,
//     this.videoUrl,
//     this.host1Channel,
//     this.host2Channel,
//     this.host2Image,
//     this.host1WinnerPoint,
//     this.host2WinnerPoint,
//     this.localRank,
//     this.remoteRank,
//     this.isLive,
//     this.isHostCameraEnabled,
//     this.isFake,
//     this.isFollow,
//     this.isPkMode,
//     this.isPkRound,
//     this.pkEndTime,
//     this.pkId,
//     this.totalPkRounds,
//     this.pkConfig,
//     this.createdAt,
//     this.updatedAt,
//   });
//
//   factory LiveUserObject.fromJson(Map<String, dynamic> json) => LiveUserObject(
//         id: json["_id"],
//         userId: json["userId"],
//         liveHistoryId: json["liveHistoryId"],
//         name: json["name"],
//         userName: json["userName"],
//         image: json["image"],
//         isProfileImageBanned: json["isProfileImageBanned"],
//         countryFlagImage: json["countryFlagImage"],
//         country: json["country"],
//         isVerified: json["isVerified"],
//         view: json["view"],
//         requested: json["requested"] == null ? [] : List<Requested>.from(json["requested"]!.map((x) => Requested.fromJson(x))),
//         liveType: json["liveType"],
//         shareCount: json["shareCount"],
//         videoUrl: json["videoUrl"],
//         host1Channel: json["host1Channel"],
//         host2Channel: json["host2Channel"],
//         host2Image: json["host2Image"],
//         host1WinnerPoint: json["host1WinnerPoint"] ?? 0,
//         host2WinnerPoint: json["host2WinnerPoint"] ?? 0,
//         localRank: json["localRank"] ?? 0,
//         remoteRank: json["remoteRank"] ?? 0,
//         isLive: json["isLive"],
//         isHostCameraEnabled: json["isHostCameraEnabled"],
//         isFake: json["isFake"],
//         isFollow: json["isFollow"],
//         isPkMode: json["isPkMode"],
//         isPkRound: json["isPkRound"],
//         pkEndTime: json["pkEndTime"],
//         pkId: json["pkId"],
//         totalPkRounds: json["totalPkRounds"] ?? 0,
//         pkConfig: json["pkConfig"] != null ? PkConfig.fromJson(json["pkConfig"]) : null,
//         createdAt: json["createdAt"] != null ? DateTime.parse(json["createdAt"]) : null,
//         updatedAt: json["updatedAt"] != null ? DateTime.parse(json["updatedAt"]) : null,
//       );
//
//   Map<String, dynamic> toJson() => {
//         "_id": id,
//         "userId": userId,
//         "liveHistoryId": liveHistoryId,
//         "name": name,
//         "userName": userName,
//         "image": image,
//         "isProfileImageBanned": isProfileImageBanned,
//         "countryFlagImage": countryFlagImage,
//         "country": country,
//         "isVerified": isVerified,
//         "view": view,
//         "requested": requested?.map((x) => x.toJson()).toList(),
//         "liveType": liveType,
//         "shareCount": shareCount,
//         "videoUrl": videoUrl,
//         "host1Channel": host1Channel,
//         "host2Channel": host2Channel,
//         "host2Image": host2Image,
//         "host1WinnerPoint": host1WinnerPoint,
//         "host2WinnerPoint": host2WinnerPoint,
//         "localRank": localRank,
//         "remoteRank": remoteRank,
//         "isLive": isLive,
//         "isHostCameraEnabled": isHostCameraEnabled,
//         "isFake": isFake,
//         "isFollow": isFollow,
//         "isPkMode": isPkMode,
//         "isPkRound": isPkRound,
//         "pkEndTime": pkEndTime,
//         "pkId": pkId,
//         "totalPkRounds": totalPkRounds,
//         "pkConfig": pkConfig?.toJson(),
//         "createdAt": createdAt?.toIso8601String(),
//         "updatedAt": updatedAt?.toIso8601String(),
//       };
// }

// New PkConfig class for the nested pkConfig object
class PkConfig {
  HostDetails? host1Details;
  HostDetails? host2Details;
  String? host1Id;
  String? host2Id;
  String? host1UniqueId;
  String? host2UniqueId;
  String? host1Name;
  String? host2Name;
  String? host2userName;
  String? host1Image;
  String? host2Image;
  String? host1LiveId;
  String? host2LiveId;
  String? host1Channel;
  String? host2Channel;
  int? host1WinnerPoint;
  int? host2WinnerPoint;
  int? localRank;
  int? remoteRank;
  int? isWinner;
  int? localRankTotal;
  int? remoteRankTotal;

  PkConfig({
    this.host1Details,
    this.host2Details,
    this.host1Id,
    this.host2Id,
    this.host1UniqueId,
    this.host2UniqueId,
    this.host1Name,
    this.host2Name,
    this.host2userName,
    this.host1Image,
    this.host2Image,
    this.host1LiveId,
    this.host2LiveId,
    this.host1Channel,
    this.host2Channel,
    this.host1WinnerPoint,
    this.host2WinnerPoint,
    this.localRank,
    this.remoteRank,
    this.isWinner,
    this.localRankTotal,
    this.remoteRankTotal,
  });

  factory PkConfig.fromJson(Map<String, dynamic> json) => PkConfig(
        host1Details: json["host1Details"] != null ? HostDetails.fromJson(json["host1Details"]) : null,
        host2Details: json["host2Details"] != null ? HostDetails.fromJson(json["host2Details"]) : null,
        host1Id: json["host1Id"],
        host2Id: json["host2Id"],
        host1UniqueId: json["host1UniqueId"],
        host2UniqueId: json["host2UniqueId"],
        host1Name: json["host1Name"],
        host2Name: json["host2Name"],
        host2userName: json["host2userName"],
        host1Image: json["host1Image"],
        host2Image: json["host2Image"],
        host1LiveId: json["host1LiveId"],
        host2LiveId: json["host2LiveId"],
        host1Channel: json["host1Channel"],
        host2Channel: json["host2Channel"],
        host1WinnerPoint: json["host1WinnerPoint"] ?? 0,
        host2WinnerPoint: json["host2WinnerPoint"] ?? 0,
        localRank: json["localRank"] ?? 0,
        remoteRank: json["remoteRank"] ?? 0,
        isWinner: json["isWinner"] ?? 0,
        localRankTotal: json["localRankTotal"] ?? 0,
        remoteRankTotal: json["remoteRankTotal"] ?? 0,
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
        "host2userName": host2userName,
        "host1Image": host1Image,
        "host2Image": host2Image,
        "host1LiveId": host1LiveId,
        "host2LiveId": host2LiveId,
        "host1Channel": host1Channel,
        "host2Channel": host2Channel,
        "host1WinnerPoint": host1WinnerPoint,
        "host2WinnerPoint": host2WinnerPoint,
        "localRank": localRank,
        "remoteRank": remoteRank,
        "isWinner": isWinner,
        "localRankTotal": localRankTotal,
        "remoteRankTotal": remoteRankTotal,
      };
}

// Host details for PK configuration
class HostDetails {
  String? userId;
  String? name;
  int? coin;
  String? image;
  String? countryFlagImage;
  String? country;
  String? uniqueId;

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
        coin: json["coin"] ?? 0,
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

class Requested {
  String? id;
  dynamic userId;
  String? name;
  String? userName;
  String? image;
  String? countryFlagImage;
  String? country;
  bool? isVerified;
  String? agoraUid;
  bool? isMute;
  bool? isRequested;
  bool? isAccepted;
  bool? isInvited;
  bool? isCameraEnabled;
  int? position;
  int? coin;

  Requested({
    this.id,
    this.userId,
    this.name,
    this.userName,
    this.image,
    this.countryFlagImage,
    this.country,
    this.isVerified,
    this.agoraUid,
    this.isMute,
    this.isRequested,
    this.isAccepted,
    this.isInvited,
    this.isCameraEnabled,
    this.position,
    this.coin,
  });

  factory Requested.fromJson(Map<String, dynamic> json) => Requested(
        id: json["_id"],
        userId: json["userId"],
        name: json["name"],
        userName: json["userName"],
        image: json["image"],
        countryFlagImage: json["countryFlagImage"],
        country: json["country"],
        isVerified: json["isVerified"],
        agoraUid: json["agoraUid"],
        isMute: json["isMute"],
        isRequested: json["isRequested"],
        isAccepted: json["isAccepted"],
        isInvited: json["isInvited"],
        isCameraEnabled: json["isCameraEnabled"],
        position: json["position"],
        coin: json["coin"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "userId": userId,
        "name": name,
        "userName": userName,
        "image": image,
        "countryFlagImage": countryFlagImage,
        "country": country,
        "isVerified": isVerified,
        "agoraUid": agoraUid,
        "isMute": isMute,
        "isRequested": isRequested,
        "isAccepted": isAccepted,
        "isInvited": isInvited,
        "isCameraEnabled": isCameraEnabled,
        "position": position,
        "coin": coin,
      };
}

class LiveUserObject {
  String? id;
  String? name;
  String? userName;
  String? image;
  bool? isProfileImageBanned;
  bool? isFake;
  String? countryFlagImage;
  bool? isVerified;
  int? view;
  bool? isPkMode;
  String? liveHistoryId;
  String? userId;
  String? host1Channel;
  int? host1Coin;
  String? host2Id;
  String? host2UniqueId;
  String? host2Name;
  String? host2userName;
  String? host2Image;
  bool? host2isProfileImageBanned;
  int? host2Coin;
  String? host2Channel;
  String? host2LiveId;
  String? host2ObjId;
  int? localRank;
  int? remoteRank;
  bool? host2IsFollow;
  bool? isFollow;
  String? videoImage;
  String? videoUrl;
  List<String>? pkPreviewImages;
  List<String>? pkMediaSources;

  LiveUserObject({
    this.id,
    this.name,
    this.userName,
    this.image,
    this.isProfileImageBanned,
    this.isFake,
    this.countryFlagImage,
    this.isVerified,
    this.view,
    this.isPkMode,
    this.liveHistoryId,
    this.userId,
    this.host1Channel,
    this.host1Coin,
    this.host2Id,
    this.host2UniqueId,
    this.host2Name,
    this.host2userName,
    this.host2Image,
    this.host2isProfileImageBanned,
    this.host2Coin,
    this.host2Channel,
    this.host2LiveId,
    this.host2ObjId,
    this.localRank,
    this.remoteRank,
    this.host2IsFollow,
    this.isFollow,
    this.videoImage,
    this.videoUrl,
    this.pkPreviewImages,
    this.pkMediaSources,
  });

  factory LiveUserObject.fromJson(Map<String, dynamic> json) => LiveUserObject(
        id: json["_id"],
        name: json["name"],
        userName: json["userName"],
        image: json["image"],
        isProfileImageBanned: json["isProfileImageBanned"],
        isFake: json["isFake"],
        countryFlagImage: json["countryFlagImage"],
        isVerified: json["isVerified"],
        view: json["view"] ?? 0,
        isPkMode: json["isPkMode"],
        liveHistoryId: json["liveHistoryId"],
        userId: json["userId"],
        host1Channel: json["host1Channel"],
        host1Coin: json["host1Coin"] ?? 0,
        host2Id: json["host2Id"],
        host2UniqueId: json["host2UniqueId"],
        host2Name: json["host2Name"],
        host2userName: json["host2userName"],
        host2Image: json["host2Image"],
        host2isProfileImageBanned: json["host2isProfileImageBanned"],
        host2Coin: json["host2Coin"] ?? 0,
        host2Channel: json["host2Channel"],
        host2LiveId: json["host2LiveId"],
        host2ObjId: json["host2ObjId"],
        localRank: json["localRank"] ?? 0,
        remoteRank: json["remoteRank"] ?? 0,
        host2IsFollow: json["host2IsFollow"],
        isFollow: json["isFollow"],
        videoImage: json["videoImage"],
        videoUrl: json["videoUrl"],
        pkPreviewImages: json["pkPreviewImages"] != null ? List<String>.from(json["pkPreviewImages"]) : [],
        pkMediaSources: json["pkMediaSources"] != null ? List<String>.from(json["pkMediaSources"]) : [],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
        "userName": userName,
        "image": image,
        "isProfileImageBanned": isProfileImageBanned,
        "isFake": isFake,
        "countryFlagImage": countryFlagImage,
        "isVerified": isVerified,
        "view": view,
        "isPkMode": isPkMode,
        "liveHistoryId": liveHistoryId,
        "userId": userId,
        "host1Channel": host1Channel,
        "host1Coin": host1Coin,
        "host2Id": host2Id,
        "host2UniqueId": host2UniqueId,
        "host2Name": host2Name,
        "host2userName": host2userName,
        "host2Image": host2Image,
        "host2isProfileImageBanned": host2isProfileImageBanned,
        "host2Coin": host2Coin,
        "host2Channel": host2Channel,
        "host2LiveId": host2LiveId,
        "host2ObjId": host2ObjId,
        "localRank": localRank,
        "remoteRank": remoteRank,
        "host2IsFollow": host2IsFollow,
        "isFollow": isFollow,
        "videoImage": videoImage,
        "videoUrl": videoUrl,
        "pkPreviewImages": pkPreviewImages,
        "pkMediaSources": pkMediaSources,
      };
}
