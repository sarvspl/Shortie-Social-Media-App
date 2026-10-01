import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shortie/pages/edit_profile_page/model/edit_profile_model.dart';
import 'package:shortie/utils/api.dart';
import 'package:shortie/utils/enums.dart';
import 'package:shortie/utils/internet_connection.dart';
import 'package:shortie/utils/utils.dart';

class EditProfileApi {
  static Future<EditProfileModel?> callApi({
    required String loginUserId,
    String? image,
    required String name,
    required String userName,
    required String country,
    required String bio,
    required String gender,
    required String countryFlagImage,
  }) async {
    Utils.showLog("Edit Profile Api Calling...");

    final uri = Uri.parse("${Api.editProfile}?userId=$loginUserId");

    Utils.showLog("Edit Profile Api Uri => $uri");

    final headers = {"key": Api.secretKey, "Content-Type": "application/json"};

    final body = image != null
        ? json.encode({
            'name': name,
            'userName': userName,
            'image': image,
            'gender': gender,
            'bio': bio,
            'country': country,
            'countryFlagImage': countryFlagImage,
          })
        : json.encode({
            'name': name,
            'userName': userName,
            'gender': gender,
            'bio': bio,
            'country': country,
            'countryFlagImage': countryFlagImage,
          });

    try {
      if (InternetConnection.isConnect.value) {
        Utils.showLog("Edit Profile Api Body => ${body}");

        final response = await http.patch(uri, headers: headers, body: body);

        if (response.statusCode == 200) {
          Utils.showLog("Edit Profile Api Response => ${response.body}");
          final jsonResponse = json.decode(response.body);
          return EditProfileModel.fromJson(jsonResponse);
        } else {
          Utils.showLog(">>>>> Edit Profile Api StateCode Error <<<<<");
        }
      } else {
        Utils.showToast(EnumLocal.txtConnectionLost.name.tr);
      }
    } catch (error) {
      Utils.showLog("Edit Profile Api Error => $error");
    }
    return null;
  }
}
