import 'package:shortie/pages/story_page/model/fetch_story_model.dart';

class FetchOwnStoryModel {
  FetchOwnStoryModel({
    bool? status,
    String? message,
    OwnStoryGroup? storyGroup,
  }) {
    _status = status;
    _message = message;
    _storyGroup = storyGroup;
  }

  FetchOwnStoryModel.fromJson(dynamic json) {
    _status = json['status'];
    _message = json['message'];
    _storyGroup = json['storyGroup'] != null ? OwnStoryGroup.fromJson(json['storyGroup']) : null;
  }
  bool? _status;
  String? _message;
  OwnStoryGroup? _storyGroup;
  FetchOwnStoryModel copyWith({
    bool? status,
    String? message,
    OwnStoryGroup? storyGroup,
  }) =>
      FetchOwnStoryModel(
        status: status ?? _status,
        message: message ?? _message,
        storyGroup: storyGroup ?? _storyGroup,
      );
  bool? get status => _status;
  String? get message => _message;
  OwnStoryGroup? get storyGroup => _storyGroup;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['status'] = _status;
    map['message'] = _message;
    if (_storyGroup != null) {
      map['storyGroup'] = _storyGroup?.toJson();
    }
    return map;
  }
}

class OwnStoryGroup {
  OwnStoryGroup({
    User? user,
    List<Stories>? stories,
  }) {
    _user = user;
    _stories = stories;
  }

  OwnStoryGroup.fromJson(dynamic json) {
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
  OwnStoryGroup copyWith({
    User? user,
    List<Stories>? stories,
  }) =>
      OwnStoryGroup(
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

// class Stories {
//   Stories({
//     String? id,
//     BackgroundSong? backgroundSong,
//     int? storyType,
//     String? mediaImageUrl,
//     String? mediaVideoUrl,
//     int? duration,
//     int? viewsCount,
//     int? reactionsCount,
//   }) {
//     _id = id;
//     _backgroundSong = backgroundSong;
//     _storyType = storyType;
//     _mediaImageUrl = mediaImageUrl;
//     _mediaVideoUrl = mediaVideoUrl;
//     _duration = duration;
//     _viewsCount = viewsCount;
//     _reactionsCount = reactionsCount;
//   }
//
//   Stories.fromJson(dynamic json) {
//     _id = json['_id'];
//     _backgroundSong = json['backgroundSong'] != null ? BackgroundSong.fromJson(json['backgroundSong']) : null;
//     _storyType = json['storyType'];
//     _mediaImageUrl = json['mediaImageUrl'];
//     _mediaVideoUrl = json['mediaVideoUrl'];
//     _duration = json['duration'];
//     _viewsCount = json['viewsCount'];
//     _reactionsCount = json['reactionsCount'];
//   }
//   String? _id;
//   BackgroundSong? _backgroundSong;
//   int? _storyType;
//   String? _mediaImageUrl;
//   String? _mediaVideoUrl;
//   int? _duration;
//   int? _viewsCount;
//   int? _reactionsCount;
//   Stories copyWith({
//     String? id,
//     BackgroundSong? backgroundSong,
//     int? storyType,
//     String? mediaImageUrl,
//     String? mediaVideoUrl,
//     int? duration,
//     int? viewsCount,
//     int? reactionsCount,
//   }) =>
//       Stories(
//         id: id ?? _id,
//         backgroundSong: backgroundSong ?? _backgroundSong,
//         storyType: storyType ?? _storyType,
//         mediaImageUrl: mediaImageUrl ?? _mediaImageUrl,
//         mediaVideoUrl: mediaVideoUrl ?? _mediaVideoUrl,
//         duration: duration ?? _duration,
//         viewsCount: viewsCount ?? _viewsCount,
//         reactionsCount: reactionsCount ?? _reactionsCount,
//       );
//   String? get id => _id;
//   BackgroundSong? get backgroundSong => _backgroundSong;
//   int? get storyType => _storyType;
//   String? get mediaImageUrl => _mediaImageUrl;
//   String? get mediaVideoUrl => _mediaVideoUrl;
//   int? get duration => _duration;
//   int? get viewsCount => _viewsCount;
//   int? get reactionsCount => _reactionsCount;
//
//   Map<String, dynamic> toJson() {
//     final map = <String, dynamic>{};
//     map['_id'] = _id;
//     if (_backgroundSong != null) {
//       map['backgroundSong'] = _backgroundSong?.toJson();
//     }
//     map['storyType'] = _storyType;
//     map['mediaImageUrl'] = _mediaImageUrl;
//     map['mediaVideoUrl'] = _mediaVideoUrl;
//     map['duration'] = _duration;
//     map['viewsCount'] = _viewsCount;
//     map['reactionsCount'] = _reactionsCount;
//     return map;
//   }
// }
//
// class BackgroundSong {
//   BackgroundSong({
//     String? id,
//     String? songTitle,
//     String? songImage,
//     String? singerName,
//     double? songTime,
//     String? songLink,
//   }) {
//     _id = id;
//     _songTitle = songTitle;
//     _songImage = songImage;
//     _singerName = singerName;
//     _songTime = songTime;
//     _songLink = songLink;
//   }
//
//   BackgroundSong.fromJson(dynamic json) {
//     _id = json['_id'];
//     _songTitle = json['songTitle'];
//     _songImage = json['songImage'];
//     _singerName = json['singerName'];
//     _songTime = json['songTime'];
//     _songLink = json['songLink'];
//   }
//   String? _id;
//   String? _songTitle;
//   String? _songImage;
//   String? _singerName;
//   double? _songTime;
//   String? _songLink;
//   BackgroundSong copyWith({
//     String? id,
//     String? songTitle,
//     String? songImage,
//     String? singerName,
//     double? songTime,
//     String? songLink,
//   }) =>
//       BackgroundSong(
//         id: id ?? _id,
//         songTitle: songTitle ?? _songTitle,
//         songImage: songImage ?? _songImage,
//         singerName: singerName ?? _singerName,
//         songTime: songTime ?? _songTime,
//         songLink: songLink ?? _songLink,
//       );
//   String? get id => _id;
//   String? get songTitle => _songTitle;
//   String? get songImage => _songImage;
//   String? get singerName => _singerName;
//   double? get songTime => _songTime;
//   String? get songLink => _songLink;
//
//   Map<String, dynamic> toJson() {
//     final map = <String, dynamic>{};
//     map['_id'] = _id;
//     map['songTitle'] = _songTitle;
//     map['songImage'] = _songImage;
//     map['singerName'] = _singerName;
//     map['songTime'] = _songTime;
//     map['songLink'] = _songLink;
//     return map;
//   }
// }
//
// class User {
//   User({
//     String? id,
//     String? name,
//     String? userName,
//     String? image,
//     bool? isProfileImageBanned,
//   }) {
//     _id = id;
//     _name = name;
//     _userName = userName;
//     _image = image;
//     _isProfileImageBanned = isProfileImageBanned;
//   }
//
//   User.fromJson(dynamic json) {
//     _id = json['_id'];
//     _name = json['name'];
//     _userName = json['userName'];
//     _image = json['image'];
//     _isProfileImageBanned = json['isProfileImageBanned'];
//   }
//   String? _id;
//   String? _name;
//   String? _userName;
//   String? _image;
//   bool? _isProfileImageBanned;
//   User copyWith({
//     String? id,
//     String? name,
//     String? userName,
//     String? image,
//     bool? isProfileImageBanned,
//   }) =>
//       User(
//         id: id ?? _id,
//         name: name ?? _name,
//         userName: userName ?? _userName,
//         image: image ?? _image,
//         isProfileImageBanned: isProfileImageBanned ?? _isProfileImageBanned,
//       );
//   String? get id => _id;
//   String? get name => _name;
//   String? get userName => _userName;
//   String? get image => _image;
//   bool? get isProfileImageBanned => _isProfileImageBanned;
//
//   Map<String, dynamic> toJson() {
//     final map = <String, dynamic>{};
//     map['_id'] = _id;
//     map['name'] = _name;
//     map['userName'] = _userName;
//     map['image'] = _image;
//     map['isProfileImageBanned'] = _isProfileImageBanned;
//     return map;
//   }
// }
