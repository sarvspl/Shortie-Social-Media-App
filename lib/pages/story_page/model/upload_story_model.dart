class UploadStoryModel {
  UploadStoryModel({
    bool? status,
    String? message,
  }) {
    _status = status;
    _message = message;
  }

  UploadStoryModel.fromJson(dynamic json) {
    _status = json['status'];
    _message = json['message'];
  }
  bool? _status;
  String? _message;
  UploadStoryModel copyWith({
    bool? status,
    String? message,
  }) =>
      UploadStoryModel(
        status: status ?? _status,
        message: message ?? _message,
      );
  bool? get status => _status;
  String? get message => _message;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['status'] = _status;
    map['message'] = _message;
    return map;
  }
}
