import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shortie/pages/multi_live_page/model/fetch_live_users_model.dart';
import 'package:shortie/utils/api.dart';
import 'package:shortie/utils/utils.dart';

class FetchLiveUsersApi {
  static Future<FetchLiveUsersModel?> callApi({required String loginUserId}) async {
    Utils.showLog("Fetch Live Users Api Calling...");

    final uri = Uri.parse("${Api.fetchLiveUserListForPk}?userId=$loginUserId");

    Utils.showLog("Fetch Live Users Api Url => $uri");

    final headers = {"key": Api.secretKey};

    try {
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        Utils.showLog("Fetch Live Users Api Response => ${response.body}");

        return FetchLiveUsersModel.fromJson(jsonResponse);
      } else {
        Utils.showLog("Fetch Live Users Api StateCode Error");
      }
    } catch (error) {
      Utils.showLog("Fetch Live Users Api Error => $error");
    }
    return null;
  }
}
