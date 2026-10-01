import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shortie/pages/chat_page/model/send_file_model.dart';
import 'package:shortie/utils/api.dart';
import 'package:shortie/utils/utils.dart';

class SendFileApi {
  static Future<SendFileModel?> callApi({
    required String senderUserId,
    required String receiverUserId,
    required int messageType,
    required String filePath,
  }) async {
    Utils.showLog("Send File Api Calling...");

    try {
      final headers = {"key": Api.secretKey, "Content-Type": "application/json"};

      final uri = Uri.parse("${Api.sendFile}?senderUserId=$senderUserId&receiverUserId=$receiverUserId&messageType=$messageType");

      final body = messageType == 2 ? json.encode({'image': filePath}) : json.encode({'audio': filePath}); // Message Type Image => 2 && Message Type Audio => 3

      Utils.showLog("Send File Api Uri => ${uri}");
      Utils.showLog("Send File Api Body => ${body}");

      final response = await http.post(uri, headers: headers, body: body);

      if (response.statusCode == 200) {
        final jsonResult = jsonDecode(response.body);

        Utils.showLog("Send File Api Response => ${jsonResult}");

        return SendFileModel.fromJson(jsonResult);
      } else {
        Utils.showLog("Send File Api Response Error");
        return null;
      }
    } catch (e) {
      Utils.showLog("Send File Api Error => $e");
      return null;
    }
  }
}
