import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shortie/pages/feed_page/model/fetch_popular_user_model.dart';
import 'package:shortie/utils/api.dart';
import 'package:shortie/utils/utils.dart';

class FetchPopularUserApi {
  static int startPagination = 0;
  static int limitPagination = 20;

  static Future<FetchPopularUserModel?> callApi() async {
    Utils.showLog("Get Popular Users Api Calling...");

    startPagination++;

    final uri = Uri.parse("${Api.fetchPopularUsers}?start=$startPagination&limit=$limitPagination");
    Utils.showLog("Get Popular Users Api Url => $uri");

    final headers = {"key": Api.secretKey};

    try {
      final response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        Utils.showLog("Get Popular Users Api Response => ${response.body}");
        return FetchPopularUserModel.fromJson(jsonResponse);
      } else {
        Utils.showLog("Get Popular Users Api StatusCode Error: ${response.statusCode}");
      }
    } catch (error) {
      Utils.showLog("Get Popular Users Api Error => $error");
    }
    return null;
  }
}
