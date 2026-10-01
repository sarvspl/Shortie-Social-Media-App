class FetchStoryModel {
  FetchStoryModel({
    bool? status,
    String? message,
    List<StoryGroup>? storyGroup,
  }) {
    _status = status;
    _message = message;
    _storyGroup = storyGroup;
  }

  FetchStoryModel.fromJson(dynamic json) {
    _status = json['status'];
    _message = json['message'];
    if (json['storyGroup'] != null) {
      _storyGroup = [];
      json['storyGroup'].forEach((v) {
        _storyGroup?.add(StoryGroup.fromJson(v));
      });
    }
  }
  bool? _status;
  String? _message;
  List<StoryGroup>? _storyGroup;
  FetchStoryModel copyWith({
    bool? status,
    String? message,
    List<StoryGroup>? storyGroup,
  }) =>
      FetchStoryModel(
        status: status ?? _status,
        message: message ?? _message,
        storyGroup: storyGroup ?? _storyGroup,
      );
  bool? get status => _status;
  String? get message => _message;
  List<StoryGroup>? get storyGroup => _storyGroup;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['status'] = _status;
    map['message'] = _message;
    if (_storyGroup != null) {
      map['storyGroup'] = _storyGroup?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class StoryGroup {
  StoryGroup({
    User? user,
    List<Stories>? stories,
  }) {
    _user = user;
    _stories = stories;
  }

  StoryGroup.fromJson(dynamic json) {
    _user = json['user'] != null ? User.fromJson(json['user']) : null;
    if (json['stories'] != null) {
      _stories = [];
      json['stories'].forEach((v) {
        _stories?.add(Stories.fromJson(v));
      });
    }
  }
  User? _user;
  List<Stories>? _stories;
  StoryGroup copyWith({
    User? user,
    List<Stories>? stories,
  }) =>
      StoryGroup(
        user: user ?? _user,
        stories: stories ?? _stories,
      );
  User? get user => _user;
  List<Stories>? get stories => _stories;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (_user != null) {
      map['user'] = _user?.toJson();
    }
    if (_stories != null) {
      map['stories'] = _stories?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class Stories {
  Stories({
    String? id,
    String? mediaImageUrl,
    String? mediaVideoUrl,
    int? viewsCount,
    int? reactionsCount,
    bool? isView,
    BackgroundSong? backgroundSong,
    int? storyType,
    int? duration,
    bool? isFake,
    String? createdAt,
  }) {
    _id = id;
    _mediaImageUrl = mediaImageUrl;
    _mediaVideoUrl = mediaVideoUrl;
    _viewsCount = viewsCount;
    _reactionsCount = reactionsCount;
    _isView = isView;
    _backgroundSong = backgroundSong;
    _storyType = storyType;
    _duration = duration;
    _isFake = isFake;
    _createdAt = createdAt;
  }

  Stories.fromJson(dynamic json) {
    _id = json['_id'];
    _mediaImageUrl = json['mediaImageUrl'];
    _mediaVideoUrl = json['mediaVideoUrl'];
    _viewsCount = json['viewsCount'];
    _reactionsCount = json['reactionsCount'];
    _isView = json['isView'];
    // _backgroundSong = json['backgroundSong'] != null ? BackgroundSong.fromJson(json['backgroundSong']) : null;
    _backgroundSong = (json['backgroundSong'] is Map<String, dynamic>)
        ? BackgroundSong.fromJson(json['backgroundSong'])
        : null;
    _storyType = json['storyType'];
    _duration = json['duration'];
    _isFake = json['isFake'];
    _createdAt = json['createdAt'];
  }
  String? _id;
  String? _mediaImageUrl;
  String? _mediaVideoUrl;
  int? _viewsCount;
  int? _reactionsCount;
  bool? _isView;
  BackgroundSong? _backgroundSong;
  int? _storyType;
  int? _duration;
  bool? _isFake;
  String? _createdAt;
  Stories copyWith({
    String? id,
    String? mediaImageUrl,
    String? mediaVideoUrl,
    int? viewsCount,
    int? reactionsCount,
    bool? isView,
    BackgroundSong? backgroundSong,
    int? storyType,
    int? duration,
    bool? isFake,
    String? createdAt,
  }) =>
      Stories(
        id: id ?? _id,
        mediaImageUrl: mediaImageUrl ?? _mediaImageUrl,
        mediaVideoUrl: mediaVideoUrl ?? _mediaVideoUrl,
        viewsCount: viewsCount ?? _viewsCount,
        reactionsCount: reactionsCount ?? _reactionsCount,
        isView: isView ?? _isView,
        backgroundSong: backgroundSong ?? _backgroundSong,
        storyType: storyType ?? _storyType,
        duration: duration ?? _duration,
        isFake: isFake ?? _isFake,
        createdAt: createdAt ?? _createdAt,
      );
  String? get id => _id;
  String? get mediaImageUrl => _mediaImageUrl;
  String? get mediaVideoUrl => _mediaVideoUrl;
  int? get viewsCount => _viewsCount;
  int? get reactionsCount => _reactionsCount;
  bool? get isView => _isView;
  BackgroundSong? get backgroundSong => _backgroundSong;
  int? get storyType => _storyType;
  int? get duration => _duration;
  bool? get isFake => _isFake;
  String? get createdAt => _createdAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['_id'] = _id;
    map['mediaImageUrl'] = _mediaImageUrl;
    map['mediaVideoUrl'] = _mediaVideoUrl;
    map['viewsCount'] = _viewsCount;
    map['reactionsCount'] = _reactionsCount;
    map['isView'] = _isView;
    if (_backgroundSong != null) {
      map['backgroundSong'] = _backgroundSong?.toJson();
    }
    map['storyType'] = _storyType;
    map['duration'] = _duration;
    map['isFake'] = _isFake;
    map['createdAt'] = _createdAt;
    return map;
  }
}

class BackgroundSong {
  BackgroundSong({
    String? id,
    String? songTitle,
    String? songImage,
    String? singerName,
    double? songTime,
    String? songLink,
  }) {
    _id = id;
    _songTitle = songTitle;
    _songImage = songImage;
    _singerName = singerName;
    _songTime = songTime;
    _songLink = songLink;
  }

  BackgroundSong.fromJson(dynamic json) {
    _id = json['_id'];
    _songTitle = json['songTitle'];
    _songImage = json['songImage'];
    _singerName = json['singerName'];
    _songTime = json['songTime'];
    _songLink = json['songLink'];
  }
  String? _id;
  String? _songTitle;
  String? _songImage;
  String? _singerName;
  double? _songTime;
  String? _songLink;
  BackgroundSong copyWith({
    String? id,
    String? songTitle,
    String? songImage,
    String? singerName,
    double? songTime,
    String? songLink,
  }) =>
      BackgroundSong(
        id: id ?? _id,
        songTitle: songTitle ?? _songTitle,
        songImage: songImage ?? _songImage,
        singerName: singerName ?? _singerName,
        songTime: songTime ?? _songTime,
        songLink: songLink ?? _songLink,
      );
  String? get id => _id;
  String? get songTitle => _songTitle;
  String? get songImage => _songImage;
  String? get singerName => _singerName;
  double? get songTime => _songTime;
  String? get songLink => _songLink;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['_id'] = _id;
    map['songTitle'] = _songTitle;
    map['songImage'] = _songImage;
    map['singerName'] = _singerName;
    map['songTime'] = _songTime;
    map['songLink'] = _songLink;
    return map;
  }
}

class User {
  User({
    String? id,
    String? name,
    String? userName,
    String? image,
    bool? isFake,
    bool? isProfileImageBanned,
  }) {
    _id = id;
    _name = name;
    _userName = userName;
    _image = image;
    _isFake = isFake;
    _isProfileImageBanned = isProfileImageBanned;
  }

  User.fromJson(dynamic json) {
    _id = json['_id'];
    _name = json['name'];
    _userName = json['userName'];
    _image = json['image'];
    _isFake = json['isFake'];
    _isProfileImageBanned = json['isProfileImageBanned'];
  }
  String? _id;
  String? _name;
  String? _userName;
  String? _image;
  bool? _isFake;
  bool? _isProfileImageBanned;
  User copyWith({
    String? id,
    String? name,
    String? userName,
    String? image,
    bool? isFake,
    bool? isProfileImageBanned,
  }) =>
      User(
        id: id ?? _id,
        name: name ?? _name,
        userName: userName ?? _userName,
        image: image ?? _image,
        isFake: isFake ?? _isFake,
        isProfileImageBanned: isProfileImageBanned ?? _isProfileImageBanned,
      );
  String? get id => _id;
  String? get name => _name;
  String? get userName => _userName;
  String? get image => _image;
  bool? get isFake => _isFake;
  bool? get isProfileImageBanned => _isProfileImageBanned;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['_id'] = _id;
    map['name'] = _name;
    map['userName'] = _userName;
    map['image'] = _image;
    map['isFake'] = _isFake;
    map['isProfileImageBanned'] = _isProfileImageBanned;
    return map;
  }
}
