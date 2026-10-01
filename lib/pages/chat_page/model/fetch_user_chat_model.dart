import 'package:shortie/pages/story_page/model/fetch_story_model.dart';

class FetchUserChatModel {
  FetchUserChatModel({
    bool? status,
    String? message,
    String? chatTopic,
    List<Chat>? chat,
  }) {
    _status = status;
    _message = message;
    _chatTopic = chatTopic;
    _chat = chat;
  }

  FetchUserChatModel.fromJson(dynamic json) {
    _status = json['status'];
    _message = json['message'];
    _chatTopic = json['chatTopic'];
    if (json['chat'] != null) {
      _chat = [];
      json['chat'].forEach((v) {
        _chat?.add(Chat.fromJson(v));
      });
    }
  }
  bool? _status;
  String? _message;
  String? _chatTopic;
  List<Chat>? _chat;
  FetchUserChatModel copyWith({
    bool? status,
    String? message,
    String? chatTopic,
    List<Chat>? chat,
  }) =>
      FetchUserChatModel(
        status: status ?? _status,
        message: message ?? _message,
        chatTopic: chatTopic ?? _chatTopic,
        chat: chat ?? _chat,
      );
  bool? get status => _status;
  String? get message => _message;
  String? get chatTopic => _chatTopic;
  List<Chat>? get chat => _chat;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['status'] = _status;
    map['message'] = _message;
    map['chatTopic'] = _chatTopic;
    if (_chat != null) {
      map['chat'] = _chat?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class Chat {
  Chat({
    String? id,
    String? chatTopicId,
    String? senderUserId,
    StoryOwnerId? storyOwnerId,
    StoryId? storyId,
    int? messageType,
    String? message,
    String? audio,
    String? image,
    String? reaction,
    bool? isChatMediaBanned,
    bool? isRead,
    String? date,
    String? createdAt,
    String? updatedAt,
  }) {
    _id = id;
    _chatTopicId = chatTopicId;
    _senderUserId = senderUserId;
    _storyOwnerId = storyOwnerId;
    _storyId = storyId;
    _messageType = messageType;
    _message = message;
    _audio = audio;
    _image = image;
    _reaction = reaction;
    _isChatMediaBanned = isChatMediaBanned;
    _isRead = isRead;
    _date = date;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
  }

  Chat.fromJson(dynamic json) {
    _id = json['_id'];
    _chatTopicId = json['chatTopicId'];
    _senderUserId = json['senderUserId'];
    _storyOwnerId = json['storyOwnerId'] != null ? StoryOwnerId.fromJson(json['storyOwnerId']) : null;
    _storyId = json['storyId'] != null ? StoryId.fromJson(json['storyId']) : null;
    _messageType = json['messageType'];
    _message = json['message'];
    _audio = json['audio'];
    _image = json['image'];
    _reaction = json['reaction'];
    _isChatMediaBanned = json['isChatMediaBanned'];
    _isRead = json['isRead'];
    _date = json['date'];
    _createdAt = json['createdAt'];
    _updatedAt = json['updatedAt'];
  }
  String? _id;
  String? _chatTopicId;
  String? _senderUserId;
  StoryOwnerId? _storyOwnerId;
  StoryId? _storyId;
  int? _messageType;
  String? _message;
  String? _audio;
  String? _image;
  String? _reaction;
  bool? _isChatMediaBanned;
  bool? _isRead;
  String? _date;
  String? _createdAt;
  String? _updatedAt;
  Chat copyWith({
    String? id,
    String? chatTopicId,
    String? senderUserId,
    StoryOwnerId? storyOwnerId,
    StoryId? storyId,
    int? messageType,
    String? message,
    String? audio,
    String? image,
    String? reaction,
    bool? isChatMediaBanned,
    bool? isRead,
    String? date,
    String? createdAt,
    String? updatedAt,
  }) =>
      Chat(
        id: id ?? _id,
        chatTopicId: chatTopicId ?? _chatTopicId,
        senderUserId: senderUserId ?? _senderUserId,
        storyOwnerId: storyOwnerId ?? _storyOwnerId,
        storyId: storyId ?? _storyId,
        messageType: messageType ?? _messageType,
        message: message ?? _message,
        audio: audio ?? _audio,
        image: image ?? _image,
        reaction: reaction ?? _reaction,
        isChatMediaBanned: isChatMediaBanned ?? _isChatMediaBanned,
        isRead: isRead ?? _isRead,
        date: date ?? _date,
        createdAt: createdAt ?? _createdAt,
        updatedAt: updatedAt ?? _updatedAt,
      );
  String? get id => _id;
  String? get chatTopicId => _chatTopicId;
  String? get senderUserId => _senderUserId;
  StoryOwnerId? get storyOwnerId => _storyOwnerId;
  StoryId? get storyId => _storyId;
  int? get messageType => _messageType;
  String? get message => _message;
  String? get audio => _audio;
  String? get image => _image;
  String? get reaction => _reaction;
  bool? get isChatMediaBanned => _isChatMediaBanned;
  bool? get isRead => _isRead;
  String? get date => _date;
  String? get createdAt => _createdAt;
  String? get updatedAt => _updatedAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['_id'] = _id;
    map['chatTopicId'] = _chatTopicId;
    map['senderUserId'] = _senderUserId;
    if (_storyOwnerId != null) {
      map['storyOwnerId'] = _storyOwnerId?.toJson();
    }
    if (_storyId != null) {
      map['storyId'] = _storyId?.toJson();
    }
    map['messageType'] = _messageType;
    map['message'] = _message;
    map['audio'] = _audio;
    map['image'] = _image;
    map['reaction'] = _reaction;
    map['isChatMediaBanned'] = _isChatMediaBanned;
    map['isRead'] = _isRead;
    map['date'] = _date;
    map['createdAt'] = _createdAt;
    map['updatedAt'] = _updatedAt;
    return map;
  }
}

class StoryId {
  StoryId({
    String? id,
    BackgroundSong? backgroundSong,
    int? storyType,
    String? mediaImageUrl,
    String? mediaVideoUrl,
    int? duration,
    int? viewsCount,
    int? reactionsCount,
    String? createdAt,
  }) {
    _id = id;
    _backgroundSong = backgroundSong;
    _storyType = storyType;
    _mediaImageUrl = mediaImageUrl;
    _mediaVideoUrl = mediaVideoUrl;
    _duration = duration;
    _viewsCount = viewsCount;
    _reactionsCount = reactionsCount;
    _createdAt = createdAt;
  }

  StoryId.fromJson(dynamic json) {
    _id = json['_id'];
    _backgroundSong = json['backgroundSong'] != null ? BackgroundSong.fromJson(json['backgroundSong']) : null;
    _storyType = json['storyType'];
    _mediaImageUrl = json['mediaImageUrl'];
    _mediaVideoUrl = json['mediaVideoUrl'];
    _duration = json['duration'];
    _viewsCount = json['viewsCount'];
    _reactionsCount = json['reactionsCount'];
    _createdAt = json['createdAt'];
  }
  String? _id;
  BackgroundSong? _backgroundSong;
  int? _storyType;
  String? _mediaImageUrl;
  String? _mediaVideoUrl;
  int? _duration;
  int? _viewsCount;
  int? _reactionsCount;
  String? _createdAt;
  StoryId copyWith({
    String? id,
    BackgroundSong? backgroundSong,
    int? storyType,
    String? mediaImageUrl,
    String? mediaVideoUrl,
    int? duration,
    int? viewsCount,
    int? reactionsCount,
    String? createdAt,
  }) =>
      StoryId(
        id: id ?? _id,
        backgroundSong: backgroundSong ?? _backgroundSong,
        storyType: storyType ?? _storyType,
        mediaImageUrl: mediaImageUrl ?? _mediaImageUrl,
        mediaVideoUrl: mediaVideoUrl ?? _mediaVideoUrl,
        duration: duration ?? _duration,
        viewsCount: viewsCount ?? _viewsCount,
        reactionsCount: reactionsCount ?? _reactionsCount,
        createdAt: createdAt ?? _createdAt,
      );
  String? get id => _id;
  BackgroundSong? get backgroundSong => _backgroundSong;
  int? get storyType => _storyType;
  String? get mediaImageUrl => _mediaImageUrl;
  String? get mediaVideoUrl => _mediaVideoUrl;
  int? get duration => _duration;
  int? get viewsCount => _viewsCount;
  int? get reactionsCount => _reactionsCount;
  String? get createdAt => _createdAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['_id'] = _id;
    if (_backgroundSong != null) {
      map['backgroundSong'] = _backgroundSong?.toJson();
    }
    map['storyType'] = _storyType;
    map['mediaImageUrl'] = _mediaImageUrl;
    map['mediaVideoUrl'] = _mediaVideoUrl;
    map['duration'] = _duration;
    map['viewsCount'] = _viewsCount;
    map['reactionsCount'] = _reactionsCount;
    map['createdAt'] = _createdAt;
    return map;
  }
}

// class BackgroundSong {
//   BackgroundSong({
//     String? id,
//     String? songTitle,
//     String? songImage,
//     String? singerName,
//     String? songLink,
//     double? songTime,
//   }) {
//     _id = id;
//     _songTitle = songTitle;
//     _songImage = songImage;
//     _singerName = singerName;
//     _songLink = songLink;
//     _songTime = songTime;
//   }
//
//   BackgroundSong.fromJson(dynamic json) {
//     _id = json['_id'];
//     _songTitle = json['songTitle'];
//     _songImage = json['songImage'];
//     _singerName = json['singerName'];
//     _songLink = json['songLink'];
//     _songTime = json['songTime'];
//   }
//   String? _id;
//   String? _songTitle;
//   String? _songImage;
//   String? _singerName;
//   String? _songLink;
//   double? _songTime;
//   BackgroundSong copyWith({
//     String? id,
//     String? songTitle,
//     String? songImage,
//     String? singerName,
//     String? songLink,
//     double? songTime,
//   }) =>
//       BackgroundSong(
//         id: id ?? _id,
//         songTitle: songTitle ?? _songTitle,
//         songImage: songImage ?? _songImage,
//         singerName: singerName ?? _singerName,
//         songLink: songLink ?? _songLink,
//         songTime: songTime ?? _songTime,
//       );
//   String? get id => _id;
//   String? get songTitle => _songTitle;
//   String? get songImage => _songImage;
//   String? get singerName => _singerName;
//   String? get songLink => _songLink;
//   double? get songTime => _songTime;
//
//   Map<String, dynamic> toJson() {
//     final map = <String, dynamic>{};
//     map['_id'] = _id;
//     map['songTitle'] = _songTitle;
//     map['songImage'] = _songImage;
//     map['singerName'] = _singerName;
//     map['songLink'] = _songLink;
//     map['songTime'] = _songTime;
//     return map;
//   }
// }

class StoryOwnerId {
  StoryOwnerId({
    String? id,
    String? name,
    String? userName,
    String? image,
    bool? isProfileImageBanned,
  }) {
    _id = id;
    _name = name;
    _userName = userName;
    _image = image;
    _isProfileImageBanned = isProfileImageBanned;
  }

  StoryOwnerId.fromJson(dynamic json) {
    _id = json['_id'];
    _name = json['name'];
    _userName = json['userName'];
    _image = json['image'];
    _isProfileImageBanned = json['isProfileImageBanned'];
  }
  String? _id;
  String? _name;
  String? _userName;
  String? _image;
  bool? _isProfileImageBanned;
  StoryOwnerId copyWith({
    String? id,
    String? name,
    String? userName,
    String? image,
    bool? isProfileImageBanned,
  }) =>
      StoryOwnerId(
        id: id ?? _id,
        name: name ?? _name,
        userName: userName ?? _userName,
        image: image ?? _image,
        isProfileImageBanned: isProfileImageBanned ?? _isProfileImageBanned,
      );
  String? get id => _id;
  String? get name => _name;
  String? get userName => _userName;
  String? get image => _image;
  bool? get isProfileImageBanned => _isProfileImageBanned;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['_id'] = _id;
    map['name'] = _name;
    map['userName'] = _userName;
    map['image'] = _image;
    map['isProfileImageBanned'] = _isProfileImageBanned;
    return map;
  }
}
