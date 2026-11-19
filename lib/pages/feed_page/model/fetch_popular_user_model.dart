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
  });

  PopularUser.fromJson(dynamic json) {
    id = json['_id']?.toString();
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
    return map;
  }
}
