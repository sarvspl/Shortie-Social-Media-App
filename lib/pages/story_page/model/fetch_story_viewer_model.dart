class FetchStoryViewerModel {
  FetchStoryViewerModel({
    bool? status,
    String? message,
    List<Viewers>? viewers,
  }) {
    _status = status;
    _message = message;
    _viewers = viewers;
  }

  FetchStoryViewerModel.fromJson(dynamic json) {
    _status = json['status'];
    _message = json['message'];
    if (json['viewers'] != null) {
      _viewers = [];
      json['viewers'].forEach((v) {
        _viewers?.add(Viewers.fromJson(v));
      });
    }
  }
  bool? _status;
  String? _message;
  List<Viewers>? _viewers;
  FetchStoryViewerModel copyWith({
    bool? status,
    String? message,
    List<Viewers>? viewers,
  }) =>
      FetchStoryViewerModel(
        status: status ?? _status,
        message: message ?? _message,
        viewers: viewers ?? _viewers,
      );
  bool? get status => _status;
  String? get message => _message;
  List<Viewers>? get viewers => _viewers;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['status'] = _status;
    map['message'] = _message;
    if (_viewers != null) {
      map['viewers'] = _viewers?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class Viewers {
  Viewers({
    dynamic reaction,
    String? viewerId,
    String? name,
    String? userName,
    String? image,
    bool? isProfileImageBanned,
    String? viewedAt,
  }) {
    _reaction = reaction;
    _viewerId = viewerId;
    _name = name;
    _userName = userName;
    _image = image;
    _isProfileImageBanned = isProfileImageBanned;
    _viewedAt = viewedAt;
  }

  Viewers.fromJson(dynamic json) {
    _reaction = json['reaction'];
    _viewerId = json['viewerId'];
    _name = json['name'];
    _userName = json['userName'];
    _image = json['image'];
    _isProfileImageBanned = json['isProfileImageBanned'];
    _viewedAt = json['viewedAt'];
  }
  dynamic _reaction;
  String? _viewerId;
  String? _name;
  String? _userName;
  String? _image;
  bool? _isProfileImageBanned;
  String? _viewedAt;
  Viewers copyWith({
    dynamic reaction,
    String? viewerId,
    String? name,
    String? userName,
    String? image,
    bool? isProfileImageBanned,
    String? viewedAt,
  }) =>
      Viewers(
        reaction: reaction ?? _reaction,
        viewerId: viewerId ?? _viewerId,
        name: name ?? _name,
        userName: userName ?? _userName,
        image: image ?? _image,
        isProfileImageBanned: isProfileImageBanned ?? _isProfileImageBanned,
        viewedAt: viewedAt ?? _viewedAt,
      );
  dynamic get reaction => _reaction;
  String? get viewerId => _viewerId;
  String? get name => _name;
  String? get userName => _userName;
  String? get image => _image;
  bool? get isProfileImageBanned => _isProfileImageBanned;
  String? get viewedAt => _viewedAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['reaction'] = _reaction;
    map['viewerId'] = _viewerId;
    map['name'] = _name;
    map['userName'] = _userName;
    map['image'] = _image;
    map['isProfileImageBanned'] = _isProfileImageBanned;
    map['viewedAt'] = _viewedAt;
    return map;
  }
}
