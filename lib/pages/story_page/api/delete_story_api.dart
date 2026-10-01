import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shortie/pages/story_page/model/delete_story_model.dart';
import 'package:shortie/utils/api.dart';
import 'package:shortie/utils/utils.dart';

class DeleteStoryApi {
  static DeleteStoryModel? deleteStoryModel;
  static Future<void> callApi({
    required String loginUserId,
    required String storyId,
  }) async {
    Utils.showLog("Delete Story Api Calling... ");

    final uri = Uri.parse("${Api.deleteStory}?userId=$loginUserId&storyId=$storyId");

    final headers = {"key": Api.secretKey};

    try {
      var response = await http.delete(uri, headers: headers);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        Utils.showLog("Delete Story Api Response => ${response.body}");

        deleteStoryModel = DeleteStoryModel.fromJson(jsonResponse);
      } else {
        Utils.showLog("Delete Story Api StateCode Error");
      }
    } catch (error) {
      Utils.showLog("Delete Story Api Error => $error");
    }
    return null;
  }
}
