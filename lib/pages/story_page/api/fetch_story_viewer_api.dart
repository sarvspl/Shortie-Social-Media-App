import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shortie/pages/story_page/model/fetch_story_viewer_model.dart';
import 'package:shortie/utils/api.dart';
import 'package:shortie/utils/utils.dart';

class FetchStoryViewerApi {
  static Future<FetchStoryViewerModel?> callApi({required String storyId}) async {
    Utils.showLog("Fetch Story Viewer Api Calling...");

    final uri = Uri.parse("${Api.fetchStoryViewers}?storyId=$storyId");

    Utils.showLog("Fetch Story Viewer Api Url => $uri");

    final headers = {"key": Api.secretKey};

    try {
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        Utils.showLog("Fetch Story Viewer Api Response => ${response.body}");

        return FetchStoryViewerModel.fromJson(jsonResponse);
      } else {
        Utils.showLog("Fetch Story Viewer Api StateCode Error");
      }
    } catch (error) {
      Utils.showLog("Fetch Story Viewer Api Error => $error");
    }
    return null;
  }
}
