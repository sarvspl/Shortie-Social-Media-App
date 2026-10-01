import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shortie/pages/verification_request_page/model/create_verification_request_model.dart';
import 'package:shortie/utils/api.dart';
import 'package:shortie/utils/utils.dart';

class CreateVerificationRequestApi {
  static Future<CreateVerificationRequestModel?> callApi({
    required String loginUserId,
    required String documentId,
    required String nameOnDocument,
    required String address,
    required String profileSelfie,
    required String document,
  }) async {
    Utils.showLog("Create Verification Request Api Calling...");

    try {
      final headers = {"key": Api.secretKey, "Content-Type": "application/json"};

      final uri = Uri.parse("${Api.createVerificationRequest}");

      Utils.showLog("Create Verification Request Api Url => $uri");

      final body = json.encode({
        'userId': loginUserId,
        'documentId': documentId,
        'nameOnDocument': nameOnDocument,
        'address': address,
        'profileSelfie': profileSelfie,
        'document': document,
      });

      Utils.showLog("Create Verification Request Api Body => $body");

      final response = await http.post(uri, headers: headers, body: body);
      if (response.statusCode == 200) {
        final jsonResult = jsonDecode(response.body);

        Utils.showLog("Create Verification Request Api Response => ${jsonResult}");

        return CreateVerificationRequestModel.fromJson(jsonResult);
      } else {
        Utils.showLog("Create Verification Request Api Response Error");
        return null;
      }
    } catch (e) {
      Utils.showLog("Create Verification Request Api Error => $e");
      return null;
    }
  }
}
