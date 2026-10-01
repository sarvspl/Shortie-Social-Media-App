import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shortie/pages/splash_screen_page/model/upload_multiple_file_model.dart';
import 'package:shortie/utils/api.dart';
import 'package:shortie/utils/utils.dart';

class UploadMultipleFileApi {
  static UploadMultipleFileModel? uploadMultipleFileModel;
  static Future<List?> callApi({required List images}) async {
    Utils.showLog("Upload Multiple File Api Calling...");

    try {
      var headers = {'key': Api.secretKey};

      var request = http.MultipartRequest('PUT', Uri.parse(Api.uploadMultipleFile));

      request.fields.addAll({'folderStructure': Api.postContent});

      for (int i = 0; i < images.length; i++) {
        request.files.add(await http.MultipartFile.fromPath('content', images[i]));
      }

      Utils.showLog("Upload Multiple File Api Uri => ${request}");

      request.headers.addAll(headers);

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final jsonResult = jsonDecode(responseBody);
        Utils.showLog("Upload Multiple File Api Response => ${jsonResult}");
        uploadMultipleFileModel = UploadMultipleFileModel.fromJson(jsonResult);
        return uploadMultipleFileModel?.urls;
      } else {
        Utils.showLog("Upload Multiple File Api Status Code Error");
      }
    } catch (e) {
      Utils.showLog("Upload Multiple File Api Error");
    }

    return null;
  }
}
