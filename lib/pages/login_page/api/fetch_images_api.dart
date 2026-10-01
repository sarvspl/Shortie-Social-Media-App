import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shortie/pages/login_page/model/fetch_images_model.dart';
import 'package:shortie/utils/api.dart';
import 'package:shortie/utils/utils.dart';

class FetchImagesApi {
  static FetchImagesModel? fetchImagesModel;
  static List<String> images = [];

  static Future<void> callApi() async {
    images.clear();
    Utils.showLog("Fetch Images Api Calling...");

    final uri = Uri.parse(Api.fetchImages);

    final headers = {"key": Api.secretKey};

    try {
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        Utils.showLog("Fetch Images Api Response => ${response.body}");

        fetchImagesModel = FetchImagesModel.fromJson(jsonResponse);

        images = fetchImagesModel?.data ?? [];

        Utils.showLog("Profile Images Length => ${images.length}");
      } else {
        Utils.showLog("Fetch Images Api StateCode Error");
      }
    } catch (error) {
      Utils.showLog("Fetch Images Api Error => $error");
    }
    return null;
  }
}
