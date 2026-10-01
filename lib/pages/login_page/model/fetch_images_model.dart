class FetchImagesModel {
  FetchImagesModel({
    bool? status,
    String? message,
    List<String>? data,
  }) {
    _status = status;
    _message = message;
    _data = data;
  }

  FetchImagesModel.fromJson(dynamic json) {
    _status = json['status'];
    _message = json['message'];
    _data = json['data'] != null ? json['data'].cast<String>() : [];
  }
  bool? _status;
  String? _message;
  List<String>? _data;
  FetchImagesModel copyWith({
    bool? status,
    String? message,
    List<String>? data,
  }) =>
      FetchImagesModel(
        status: status ?? _status,
        message: message ?? _message,
        data: data ?? _data,
      );
  bool? get status => _status;
  String? get message => _message;
  List<String>? get data => _data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['status'] = _status;
    map['message'] = _message;
    map['data'] = _data;
    return map;
  }
}
