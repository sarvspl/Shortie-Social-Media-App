import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shortie/pages/verification_request_page/model/create_verification_request_model.dart';
import 'package:shortie/utils/api.dart';
import 'package:shortie/utils/utils.dart';

class CreateViewStoryHistoryApi {
  static Future<CreateVerificationRequestModel?> callApi(
      {required String loginUserId, required String storyId}) async {
    Utils.showLog("Create View Story History Api Calling...");

    try {
      final headers = {
        "key": Api.secretKey,
        "Content-Type": "application/json"
      };

      final uri = Uri.parse(Api.viewStory);

      Utils.showLog("Create View Story History Api Url => $uri");

      final body = jsonEncode({
        "userId": loginUserId,
        "storyId": storyId,
      });

      final response = await http.post(uri, headers: headers, body: body);

      if (response.statusCode == 200) {
        final jsonResult = jsonDecode(response.body);

        Utils.showLog(
            "Create View Story History Api Response => ${jsonResult}");

        return CreateVerificationRequestModel.fromJson(jsonResult);
      } else {
        Utils.showLog("Create View Story History Api Response Error");
        return null;
      }
    } catch (e) {
      Utils.showLog("Create View Story History Api Error => $e");
      return null;
    }
  }
}
