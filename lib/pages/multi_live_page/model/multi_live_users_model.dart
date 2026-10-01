import 'package:shortie/utils/utils.dart';

class MultiLiveUsersModel {
  String? userId;
  String? name;
  String? userName;
  String? image;
  String? country;
  bool? isVerified;
  String? agoraUid;
  bool? isMute;
  bool? isRequested;
  bool? isAccepted;
  bool? isInvited;
  bool? isCameraEnabled;
  bool? isSendRequestByHost;
  int? position;
  int? coin;

  MultiLiveUsersModel({
    this.userId,
    this.name,
    this.userName,
    this.image,
    this.country,
    this.isVerified,
    this.agoraUid,
    this.isMute,
    this.isRequested,
    this.isAccepted,
    this.isInvited,
    this.isCameraEnabled,
    this.isSendRequestByHost,
    this.position,
    this.coin,
  });

  MultiLiveUsersModel.fromJson(Map<String, dynamic> json) {
    Utils.showLog("MultiLiveUsersModel.fromJson json ==> $json");
    userId = json['userId'];
    name = json['name'];
    userName = json['userName'];
    image = json['image'];
    country = json['country'];
    isVerified = json['isVerified'];
    agoraUid = json['agoraUid'];
    isMute = json['isMute'];
    isRequested = json['isRequested'];
    isAccepted = json['isAccepted'];
    isInvited = json['isInvited'];
    isCameraEnabled = json['isCameraEnabled'];
    isSendRequestByHost = json['isSendrequestByHost'];
    position = json['position'];
    coin = json['coin'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userId'] = this.userId;
    data['name'] = this.name;
    data['userName'] = this.userName;
    data['image'] = this.image;
    data['country'] = this.country;
    data['isVerified'] = this.isVerified;
    data['agoraUid'] = this.agoraUid;
    data['isMute'] = this.isMute;
    data['isRequested'] = this.isRequested;
    data['isAccepted'] = this.isAccepted;
    data['isInvited'] = this.isInvited;
    data['isCameraEnabled'] = this.isCameraEnabled;
    data['isSendrequestByHost'] = this.isSendRequestByHost;
    data['position'] = this.position;
    data['coin'] = this.coin;
    return data;
  }
}
