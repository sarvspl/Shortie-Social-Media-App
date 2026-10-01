import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shortie/pages/search_page/model/search_hash_tag_model.dart';
import 'package:shortie/utils/api.dart';
import 'package:shortie/utils/utils.dart';

class SearchHashTagApi {
  static Future<SearchHashTagModel?> callApi({required String loginUserId, required String searchText}) async {
    Utils.showLog("Search Hash Tag Api Calling...");

    final uri = Uri.parse("${Api.searchHashTag}?userId=$loginUserId&hashTagSearchString=$searchText");

    final headers = {"key": Api.secretKey};

    try {
      final response = await http.post(uri, headers: headers);

      if (response.statusCode == 200) {
        Utils.showLog("Search Hash Tag Api Response => ${response.body}");
        final responseBody = response.body.trim();

        // Check if response is valid JSON
        try {
          final jsonResponse = json.decode(responseBody);

          // Validate that the response is a Map
          if (jsonResponse is Map<String, dynamic>) {
            return SearchHashTagModel.fromJson(jsonResponse);
          } else {
            Utils.showLog("Search Hash Tag Api Error: Response is not a valid JSON object, got: ${jsonResponse.runtimeType}");
            return null;
          }
        } catch (jsonError) {
          Utils.showLog("Search Hash Tag Api JSON Decode Error: $jsonError");
          Utils.showLog("Response body that failed to parse: $responseBody");
          return null;
        }
      } else {
        Utils.showLog("Search Hash Tag Api StatusCode Error: ${response.statusCode}");
        Utils.showLog("Error Response Body: ${response.body}");
      }
    } catch (error) {
      Utils.showLog("Search Hash Tag Api Error => $error");
    }
    return null;
  }
}
