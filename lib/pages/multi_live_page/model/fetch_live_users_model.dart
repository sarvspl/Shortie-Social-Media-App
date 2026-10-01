class FetchLiveUsersModel {
  bool? status;
  String? message;
  List<UserLiveList>? liveUserList;

  FetchLiveUsersModel({this.status, this.message, this.liveUserList});

  FetchLiveUsersModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['liveUserList'] != null) {
      liveUserList = <UserLiveList>[];
      json['liveUserList'].forEach((v) {
        liveUserList!.add(new UserLiveList.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.liveUserList != null) {
      data['liveUserList'] = this.liveUserList!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class UserLiveList {
  String? sId;
  String? name;
  String? userName;
  String? image;
  String? channel;
  String? token;
  String? liveHistoryId;
  String? userId;

  UserLiveList({this.sId, this.name, this.userName, this.image, this.channel, this.token, this.liveHistoryId, this.userId});

  UserLiveList.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    userName = json['userName'];
    image = json['image'];
    channel = json['channel'];
    token = json['token'];
    liveHistoryId = json['liveHistoryId'];
    userId = json['userId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['name'] = this.name;
    data['userName'] = this.userName;
    data['image'] = this.image;
    data['channel'] = this.channel;
    data['token'] = this.token;
    data['liveHistoryId'] = this.liveHistoryId;
    data['userId'] = this.userId;
    return data;
  }
}
