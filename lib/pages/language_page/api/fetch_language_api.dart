import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shortie/pages/language_page/model/fetch_language_model.dart';
import 'package:shortie/utils/api.dart';
import 'package:shortie/utils/utils.dart';

class FetchLanguageApi {
  static Future<FetchLanguageModel?> callApi({required int start, required int limit}) async {
    Utils.showLog("Get Language Api Calling... ");

    Utils.showLog("Get Language Pagination Page => $start");

    final uri = Uri.parse("${Api.fetchLanguages}?start=$start&limit=$limit");

    Utils.showLog("Get Language Api Url => $uri");

    final headers = {"key": Api.secretKey};

    try {
      var response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        Utils.showLog("Get Language Api Response => ${response.body}");

        return FetchLanguageModel.fromJson(jsonResponse);
      } else {
        Utils.showLog("Get Language Api StateCode Error");
      }
    } catch (error) {
      Utils.showLog("Get Language Api Error => $error");
    }
    return null;
  }
}
