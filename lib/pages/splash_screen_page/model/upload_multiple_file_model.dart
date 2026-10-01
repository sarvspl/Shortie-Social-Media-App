import 'dart:convert';

UploadMultipleFileModel multipleUploadFileModelFromJson(String str) => UploadMultipleFileModel.fromJson(json.decode(str));
String multipleUploadFileModelToJson(UploadMultipleFileModel data) => json.encode(data.toJson());

class UploadMultipleFileModel {
  UploadMultipleFileModel({
    bool? status,
    String? message,
    List<String>? urls,
  }) {
    _status = status;
    _message = message;
    _postImage = urls;
  }

  UploadMultipleFileModel.fromJson(dynamic json) {
    _status = json['status'];
    _message = json['message'];
    _postImage = json['urls'] != null ? json['urls'].cast<String>() : [];
  }
  bool? _status;
  String? _message;
  List<String>? _postImage;
  UploadMultipleFileModel copyWith({
    bool? status,
    String? message,
    List<String>? urls,
  }) =>
      UploadMultipleFileModel(
        status: status ?? _status,
        message: message ?? _message,
        urls: urls ?? _postImage,
      );
  bool? get status => _status;
  String? get message => _message;
  List<String>? get urls => _postImage;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['status'] = _status;
    map['message'] = _message;
    map['urls'] = _postImage;
    return map;
  }
}
