import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shortie/pages/help_page/model/help_model.dart';
import 'package:shortie/utils/api.dart';
import 'package:shortie/utils/utils.dart';

class HelpApi {
  static Future<HelpModel?> callApi({
    required String loginUserId,
    required String complaint,
    required String contact,
    String? image,
  }) async {
    Utils.showLog("Help Api Calling...");

    try {
      final headers = {"key": Api.secretKey, "Content-Type": "application/json"};

      final uri = Uri.parse("${Api.help}");

      final body = image != null
          ? json.encode({
              'userId': loginUserId,
              'complaint': complaint,
              'contact': contact,
              'image': image,
            })
          : json.encode({
              'userId': loginUserId,
              'complaint': complaint,
              'contact': contact,
            });

      final response = await http.post(uri, headers: headers, body: body);

      if (response.statusCode == 200) {
        final jsonResult = jsonDecode(response.body);
        Utils.showLog("Help Api Response => ${jsonResult}");
        return HelpModel.fromJson(jsonResult);
      } else {
        Utils.showLog("Help Api Response Error");
        return null;
      }
    } catch (e) {
      Utils.showLog("Help Api Error => $e");
      return null;
    }
  }
}
