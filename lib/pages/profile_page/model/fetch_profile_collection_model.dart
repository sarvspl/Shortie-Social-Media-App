class FetchProfileCollectionModel {
  FetchProfileCollectionModel({
    bool? status,
    String? message,
    List<ProfileCollectionData>? data,
  }) {
    _status = status;
    _message = message;
    _data = data;
  }

  FetchProfileCollectionModel.fromJson(dynamic json) {
    _status = json['status'];
    _message = json['message'];
    if (json['data'] != null) {
      _data = [];
      json['data'].forEach((v) {
        _data?.add(ProfileCollectionData.fromJson(v));
      });
    }
  }
  bool? _status;
  String? _message;
  List<ProfileCollectionData>? _data;
  FetchProfileCollectionModel copyWith({
    bool? status,
    String? message,
    List<ProfileCollectionData>? data,
  }) =>
      FetchProfileCollectionModel(
        status: status ?? _status,
        message: message ?? _message,
        data: data ?? _data,
      );
  bool? get status => _status;
  String? get message => _message;
  List<ProfileCollectionData>? get data => _data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['status'] = _status;
    map['message'] = _message;
    if (_data != null) {
      map['data'] = _data?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class ProfileCollectionData {
  ProfileCollectionData({
    int? total,
    int? giftCoin,
    String? giftImage,
    String? giftSvgaImage,
    int? giftType,
  }) {
    _total = total;
    _giftCoin = giftCoin;
    _giftImage = giftImage;
    _giftSvgaImage = giftSvgaImage;
    _giftType = giftType;
  }

  ProfileCollectionData.fromJson(dynamic json) {
    _total = json['total'];
    _giftCoin = json['giftCoin'];
    _giftImage = json['giftImage'];
    _giftSvgaImage = json['giftSvgaImage'];
    _giftType = json['giftType'];
  }
  int? _total;
  int? _giftCoin;
  String? _giftImage;
  String? _giftSvgaImage;
  int? _giftType;
  ProfileCollectionData copyWith({
    int? total,
    int? giftCoin,
    String? giftImage,
    String? giftSvgaImage,
    int? giftType,
  }) =>
      ProfileCollectionData(
        total: total ?? _total,
        giftCoin: giftCoin ?? _giftCoin,
        giftImage: giftImage ?? _giftImage,
        giftSvgaImage: giftSvgaImage ?? _giftSvgaImage,
        giftType: giftType ?? _giftType,
      );
  int? get total => _total;
  int? get giftCoin => _giftCoin;
  String? get giftImage => _giftImage;
  String? get giftSvgaImage => _giftSvgaImage;
  int? get giftType => _giftType;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['total'] = _total;
    map['giftCoin'] = _giftCoin;
    map['giftImage'] = _giftImage;
    map['giftSvgaImage'] = _giftSvgaImage;
    map['giftType'] = _giftType;
    return map;
  }
}
