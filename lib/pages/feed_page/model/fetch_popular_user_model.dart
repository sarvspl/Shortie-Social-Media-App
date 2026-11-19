class FetchPopularUserModel {
  bool? status;
  String? message;
  List<PopularUser>? data;

  FetchPopularUserModel({this.status, this.message, this.data});

  FetchPopularUserModel.fromJson(dynamic json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data?.add(PopularUser.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['status'] = status;
    map['message'] = message;
    if (data != null) {
      map['data'] = data?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class PopularUser {
  String? id;
  String? name;
  String? userName;
  String? image;
  bool? isVerified;
  bool? isFake;
  int? coin;
  int? receivedCoin;
  int? receivedGift;
  String? countryFlagImage;
  bool? isLive;
  String? liveUserObjId;
  String? liveHistoryId;
  bool? isPkMode;

  PopularUser({
    this.id,
    this.name,
    this.userName,
    this.image,
    this.isVerified,
    this.isFake,
    this.coin,
    this.receivedCoin,
    this.receivedGift,
    this.countryFlagImage,
    this.isLive,
    this.liveUserObjId,
    this.liveHistoryId,
    this.isPkMode,
  });

  PopularUser.fromJson(dynamic json) {
    id = json['_id']?.toString() ?? json['userId']?.toString();
    name = json['name'];
    userName = json['userName'];
    image = json['image'];
    isVerified = json['isVerified'];
    isFake = json['isFake'];
    coin = json['coin'] is int ? json['coin'] : int.tryParse(json['coin']?.toString() ?? '0');
    receivedCoin = json['receivedCoin'] is int ? json['receivedCoin'] : int.tryParse(json['receivedCoin']?.toString() ?? '0');
    receivedGift = json['receivedGift'] is int ? json['receivedGift'] : int.tryParse(json['receivedGift']?.toString() ?? '0');
    countryFlagImage = json['countryFlagImage'];
    isLive = json['isLive'];
    liveUserObjId = json['liveUserObjId']?.toString();
    liveHistoryId = json['liveHistoryId']?.toString();
    isPkMode = json['isPkMode'];
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['_id'] = id;
    map['name'] = name;
    map['userName'] = userName;
    map['image'] = image;
    map['isVerified'] = isVerified;
    map['isFake'] = isFake;
    map['coin'] = coin;
    map['receivedCoin'] = receivedCoin;
    map['receivedGift'] = receivedGift;
    map['countryFlagImage'] = countryFlagImage;
    map['isLive'] = isLive;
    map['liveUserObjId'] = liveUserObjId;
    map['liveHistoryId'] = liveHistoryId;
    map['isPkMode'] = isPkMode;
    return map;
  }
}
