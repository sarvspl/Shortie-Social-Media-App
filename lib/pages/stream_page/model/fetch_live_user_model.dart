class FetchLiveUserModel {
  FetchLiveUserModel({
    bool? status,
    String? message,
    List<LiveUserList>? liveUserList,
  }) {
    _status = status;
    _message = message;
    _liveUserList = liveUserList;
  }

  FetchLiveUserModel.fromJson(dynamic json) {
    _status = json['status'];
    _message = json['message'];
    if (json['liveUserList'] != null) {
      _liveUserList = [];
      json['liveUserList'].forEach((v) {
        _liveUserList?.add(LiveUserList.fromJson(v));
      });
    }
  }
  bool? _status;
  String? _message;
  List<LiveUserList>? _liveUserList;
  FetchLiveUserModel copyWith({
    bool? status,
    String? message,
    List<LiveUserList>? liveUserList,
  }) =>
      FetchLiveUserModel(
        status: status ?? _status,
        message: message ?? _message,
        liveUserList: liveUserList ?? _liveUserList,
      );
  bool? get status => _status;
  String? get message => _message;
  List<LiveUserList>? get liveUserList => _liveUserList;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['status'] = _status;
    map['message'] = _message;
    if (_liveUserList != null) {
      map['liveUserList'] = _liveUserList?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class LiveUserList {
  LiveUserList({
    String? name,
    String? userName,
    String? image,
    bool? isProfileImageBanned,
    String? countryFlagImage,
    bool? isFake,
    bool? isVerified,
    String? videoImage,
    String? videoUrl,
    List<String>? pkPreviewImages,
    List<String>? pkMediaSources,
    String? userId,
    String? liveUserObjId,
    String? liveHistoryId,
    int? view,
    bool? isPkMode,
    bool? isFollow,
    String? host2Name,
    String? host2Image,
    bool? host2isProfileImageBanned,
  }) {
    _name = name;
    _userName = userName;
    _image = image;
    _isProfileImageBanned = isProfileImageBanned;
    _countryFlagImage = countryFlagImage;
    _isFake = isFake;
    _isVerified = isVerified;
    _videoImage = videoImage;
    _videoUrl = videoUrl;
    _pkPreviewImages = pkPreviewImages;
    _pkMediaSources = pkMediaSources;
    _userId = userId;
    _liveUserObjId = liveUserObjId;
    _liveHistoryId = liveHistoryId;
    _view = view;
    _isPkMode = isPkMode;
    _isFollow = isFollow;
    _host2Name = host2Name;
    _host2Image = host2Image;
    _host2isProfileImageBanned = host2isProfileImageBanned;
  }

  LiveUserList.fromJson(dynamic json) {
    _name = json['name'];
    _userName = json['userName'];
    _image = json['image'];
    _isProfileImageBanned = json['isProfileImageBanned'];
    _countryFlagImage = json['countryFlagImage'];
    _isFake = json['isFake'];
    _isVerified = json['isVerified'];
    _videoImage = json['videoImage'];
    _videoUrl = json['videoUrl'];
    _pkPreviewImages = json['pkPreviewImages'] != null ? json['pkPreviewImages'].cast<String>() : [];
    _pkMediaSources = json['pkMediaSources'] != null ? json['pkMediaSources'].cast<String>() : [];
    _userId = json['userId'];
    _liveUserObjId = json['liveUserObjId'];
    _liveHistoryId = json['liveHistoryId'];
    _view = json['view'];
    _isPkMode = json['isPkMode'];
    _isFollow = json['isFollow'];
    _host2Name = json['host2Name'];
    _host2Image = json['host2Image'];
    _host2isProfileImageBanned = json['host2isProfileImageBanned'];
  }
  String? _name;
  String? _userName;
  String? _image;
  bool? _isProfileImageBanned;
  String? _countryFlagImage;
  bool? _isFake;
  bool? _isVerified;
  String? _videoImage;
  String? _videoUrl;
  List<String>? _pkPreviewImages;
  List<String>? _pkMediaSources;
  String? _userId;
  String? _liveUserObjId;
  String? _liveHistoryId;
  int? _view;
  bool? _isPkMode;
  bool? _isFollow;
  String? _host2Name;
  String? _host2Image;
  bool? _host2isProfileImageBanned;
  LiveUserList copyWith({
    String? name,
    String? userName,
    String? image,
    bool? isProfileImageBanned,
    String? countryFlagImage,
    bool? isFake,
    bool? isVerified,
    String? videoImage,
    String? videoUrl,
    List<String>? pkPreviewImages,
    List<String>? pkMediaSources,
    String? userId,
    String? liveUserObjId,
    String? liveHistoryId,
    int? view,
    bool? isPkMode,
    bool? isFollow,
    String? host2Name,
    String? host2Image,
    bool? host2isProfileImageBanned,
  }) =>
      LiveUserList(
        name: name ?? _name,
        userName: userName ?? _userName,
        image: image ?? _image,
        isProfileImageBanned: isProfileImageBanned ?? _isProfileImageBanned,
        countryFlagImage: countryFlagImage ?? _countryFlagImage,
        isFake: isFake ?? _isFake,
        isVerified: isVerified ?? _isVerified,
        videoImage: videoImage ?? _videoImage,
        videoUrl: videoUrl ?? _videoUrl,
        pkPreviewImages: pkPreviewImages ?? _pkPreviewImages,
        pkMediaSources: pkMediaSources ?? _pkMediaSources,
        userId: userId ?? _userId,
        liveUserObjId: liveUserObjId ?? _liveUserObjId,
        liveHistoryId: liveHistoryId ?? _liveHistoryId,
        view: view ?? _view,
        isPkMode: isPkMode ?? _isPkMode,
        isFollow: isFollow ?? _isFollow,
        host2Name: host2Name ?? _host2Name,
        host2Image: host2Image ?? _host2Image,
        host2isProfileImageBanned: host2isProfileImageBanned ?? _host2isProfileImageBanned,
      );
  String? get name => _name;
  String? get userName => _userName;
  String? get image => _image;
  bool? get isProfileImageBanned => _isProfileImageBanned;
  String? get countryFlagImage => _countryFlagImage;
  bool? get isFake => _isFake;
  bool? get isVerified => _isVerified;
  String? get videoImage => _videoImage;
  String? get videoUrl => _videoUrl;
  List<String>? get pkPreviewImages => _pkPreviewImages;
  List<String>? get pkMediaSources => _pkMediaSources;
  String? get userId => _userId;
  String? get liveUserObjId => _liveUserObjId;
  String? get liveHistoryId => _liveHistoryId;
  int? get view => _view;
  bool? get isPkMode => _isPkMode;
  bool? get isFollow => _isFollow;
  String? get host2Name => _host2Name;
  String? get host2Image => _host2Image;
  bool? get host2isProfileImageBanned => _host2isProfileImageBanned;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['name'] = _name;
    map['userName'] = _userName;
    map['image'] = _image;
    map['isProfileImageBanned'] = _isProfileImageBanned;
    map['countryFlagImage'] = _countryFlagImage;
    map['isFake'] = _isFake;
    map['isVerified'] = _isVerified;
    map['videoImage'] = _videoImage;
    map['videoUrl'] = _videoUrl;
    map['pkPreviewImages'] = _pkPreviewImages;
    map['pkMediaSources'] = _pkMediaSources;
    map['userId'] = _userId;
    map['liveUserObjId'] = _liveUserObjId;
    map['liveHistoryId'] = _liveHistoryId;
    map['view'] = _view;
    map['isPkMode'] = _isPkMode;
    map['isFollow'] = _isFollow;
    map['host2Name'] = _host2Name;
    map['host2Image'] = _host2Image;
    map['host2isProfileImageBanned'] = _host2isProfileImageBanned;
    return map;
  }
}
