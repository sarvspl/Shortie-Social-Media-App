import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shortie/pages/story_page/model/fetch_own_story_model.dart';

import 'package:shortie/utils/api.dart';
import 'package:shortie/utils/utils.dart';

class FetchOwnStoryApi {
  static Future<FetchOwnStoryModel?> callApi({required String loginUserId}) async {
    Utils.showLog("Fetch Own Story Api Calling...");

    final uri = Uri.parse("${Api.fetchOwnStory}?userId=$loginUserId");

    Utils.showLog("Fetch Own Story Api Url => $uri");

    final headers = {"key": Api.secretKey};

    try {
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        Utils.showLog("Fetch Own Story Api Response => ${response.body}");

        return FetchOwnStoryModel.fromJson(jsonResponse);
      } else {
        Utils.showLog("Fetch Own Story Api StateCode Error");
      }
    } catch (error) {
      Utils.showLog("Fetch Own Story Api Error => $error");
    }
    return null;
  }
}
