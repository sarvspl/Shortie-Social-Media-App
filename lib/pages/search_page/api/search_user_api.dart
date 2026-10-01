import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shortie/pages/search_page/model/search_user_model.dart';
import 'package:shortie/utils/api.dart';
import 'package:shortie/utils/utils.dart';

class SearchUserApi {
  static Future<SearchUserModel?> callApi({required String loginUserId, required String searchText}) async {
    Utils.showLog("Search User Api Calling...");

    final uri = Uri.parse("${Api.searchUser}?userId=$loginUserId&userSearchString=$searchText");

    final headers = {"key": Api.secretKey};
    Utils.showLog("Search User Api Uri => $uri");
    // try {
      final response = await http.post(uri, headers: headers);

      if (response.statusCode == 200) {
        Utils.showLog("Search User Api Response => ${response.body}");
        final responseBody = response.body.trim();

        // Check if response is valid JSON
        // try {
          final jsonResponse = json.decode(responseBody);

          // Ensure the response is actually a Map
          if (jsonResponse is Map<String, dynamic>) {
            return SearchUserModel.fromJson(jsonResponse);
          } else {
            Utils.showLog("Search User Api Error: Response is not a JSON object, got: ${jsonResponse.runtimeType}");
            return null;
          }
        // } catch (jsonError) {
        //   Utils.showLog("Search User Api JSON Decode Error: $jsonError");
        //   Utils.showLog("Response body that failed to parse: $responseBody");
        //   return null;
        // }
      } else {
        Utils.showLog("Search User Api StatusCode Error: ${response.statusCode}");
        Utils.showLog("Error Response Body: ${response.body}");
      }
    // } catch (error) {
    //   Utils.showLog("Search User Api Error => $error");
    // }
    // return null;
  }
}
