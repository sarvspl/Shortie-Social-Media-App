import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shortie/pages/story_page/model/fetch_story_model.dart';
import 'package:shortie/utils/api.dart';
import 'package:shortie/utils/utils.dart';

class FetchStoryApi {
  static Future<FetchStoryModel?> callApi({required String loginUserId}) async {
    Utils.showLog("Fetch Story Api Calling...");

    final uri = Uri.parse("${Api.fetchStories}?userId=$loginUserId");

    Utils.showLog("Fetch Story Api Url => $uri");

    final headers = {"key": Api.secretKey};

    try {
      final response = await http.get(uri, headers: headers);

      Utils.showLog("Fetch Story Api Response => ${response.body}");

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        return FetchStoryModel.fromJson(jsonResponse);
      } else {
        Utils.showLog("Fetch Story Api StateCode Error");
      }
    } catch (error) {
      Utils.showLog("Fetch Story Api Error => $error");
    }
    return null;
  }
}
