class PkGiftTopUserModel {
  final UserId? userId;
  final int? totalCoins;
  final String? id;

  PkGiftTopUserModel({
    this.userId,
    this.totalCoins,
    this.id,
  });

  factory PkGiftTopUserModel.fromJson(Map<String, dynamic> json) {
    return PkGiftTopUserModel(
      userId: json['userId'] != null ? UserId.fromJson(json['userId']) : null,
      totalCoins: json['totalCoins'],
      id: json['_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId?.toJson(),
      'totalCoins': totalCoins,
      '_id': id,
    };
  }
}

class UserId {
  final String? id;
  final String? name;
  final String? image;
  final int? coin;
  final bool? isProfilePicBanned;

  UserId({
    this.id,
    this.name,
    this.image,
    this.coin,
    this.isProfilePicBanned,
  });

  factory UserId.fromJson(Map<String, dynamic> json) {
    return UserId(
      id: json['_id'],
      name: json['name'],
      image: json['image'],
      coin: json['coin'],
      isProfilePicBanned: json['isProfilePicBanned'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'image': image,
      'coin': coin,
      'isProfilePicBanned': isProfilePicBanned,
    };
  }
}
