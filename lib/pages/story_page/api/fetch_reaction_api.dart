import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shortie/pages/story_page/model/fetch_reaction_model.dart';
import 'package:shortie/utils/api.dart';
import 'package:shortie/utils/utils.dart';

class FetchReactionApi {
  static Future<FetchReactionModel?> callApi() async {
    Utils.showLog("Fetch Reaction Api Calling...");

    final uri = Uri.parse("${Api.fetchReaction}");

    Utils.showLog("Fetch Reaction Api Url => $uri");

    final headers = {"key": Api.secretKey};

    try {
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        Utils.showLog("Fetch Reaction Api Response => ${response.body}");

        return FetchReactionModel.fromJson(jsonResponse);
      } else {
        Utils.showLog("Fetch Reaction Api StateCode Error");
      }
    } catch (error) {
      Utils.showLog("Fetch Reaction Api Error => $error");
    }
    return null;
  }
}
