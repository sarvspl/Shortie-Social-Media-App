import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shortie/pages/story_page/model/send_reaction_to_story_model.dart';
import 'package:shortie/utils/api.dart';
import 'package:shortie/utils/utils.dart';

class SendReactionToStoryApi {
  static SendReactionToStoryModel? sendReactionToStoryModel;
  static Future<void> callApi({required String loginUserId, required String storyId, required String reaction}) async {
    sendReactionToStoryModel = null;

    Utils.showLog("Send Reaction To Story Api Calling...");

    try {
      final headers = {"key": Api.secretKey, "Content-Type": "application/json"};

      final uri = Uri.parse("${Api.reactionToStory}");

      Utils.showLog("Send Reaction To Story Api Url => $uri");

      final body = json.encode({
        'userId': loginUserId,
        'storyId': storyId,
        'reaction': reaction,
      });

      Utils.showLog("Send Reaction To Story Api Body => $body");

      final response = await http.post(uri, headers: headers, body: body);
      if (response.statusCode == 200) {
        final jsonResult = jsonDecode(response.body);

        Utils.showLog("Send Reaction To Story Api Response => ${jsonResult}");

        sendReactionToStoryModel = SendReactionToStoryModel.fromJson(jsonResult);
      } else {
        Utils.showLog("Send Reaction To Story Api Response Error");
      }
    } catch (e) {
      Utils.showLog("Send Reaction To Story Api Error => $e");
    }
  }
}
