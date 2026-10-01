import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shortie/pages/story_page/model/upload_story_model.dart';
import 'package:shortie/utils/api.dart';
import 'package:shortie/utils/utils.dart';

class UploadStoryApi {
  static Future<UploadStoryModel?> callApi({
    required String userId,
    required String backgroundSong,
    required String mediaImageUrl,
    required String mediaVideoUrl,
    required bool isVideo,
    required int duration,
  }) async {
    Utils.showLog("Upload Story Api Calling...");

    try {
      final headers = {"key": Api.secretKey, "Content-Type": "application/json"};

      final uri = Uri.parse("${Api.uploadStory}");

      Map<String, dynamic> bodyData = {
        'userId': userId,
        'duration': duration,
        'mediaImageUrl': mediaImageUrl,
      };

      if (backgroundSong.trim().isNotEmpty) bodyData.addAll({'backgroundSong': backgroundSong});

      isVideo ? bodyData.addAll({'storyType': 2}) : bodyData.addAll({'storyType': 1});

      if (isVideo) bodyData.addAll({'mediaVideoUrl': mediaVideoUrl});

      final body = json.encode(bodyData);

      Utils.showLog("Upload Story Api Uri => ${uri}");

      Utils.showLog("Upload Story Api Body => ${body}");

      final response = await http.post(uri, headers: headers, body: body);

      if (response.statusCode == 200) {
        Utils.showLog("Upload Story Api Response => ${response.body}");

        final jsonResult = jsonDecode(response.body);
        return UploadStoryModel.fromJson(jsonResult);
      } else {
        Utils.showLog("Upload Story Api Response Error");
        return null;
      }
    } catch (e) {
      Utils.showLog("Upload Story Api Error => $e");
      return null;
    }
  }
}

// key : storyType
// exports.STORY_TYPE = {
//   IMAGE: 1,
//   VIDEO: 2,
// };
