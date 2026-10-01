import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shortie/pages/upload_post_page/model/upload_post_model.dart';
import 'package:shortie/utils/api.dart';
import 'package:shortie/utils/utils.dart';

class UploadPostApi {
  static Future<UploadPostModel?> callApi({
    required String loginUserId,
    required String hashTag,
    required String caption,
    required List postImages,
  }) async {
    Utils.showLog("Upload Post Api Calling...");

    try {
      final headers = {"key": Api.secretKey, "Content-Type": "application/json"};

      final uri = Uri.parse("${Api.uploadPost}?userId=$loginUserId");

      final body = json.encode({
        'caption': caption,
        'hashTagId': hashTag,
        'postImage': postImages,
      });

      // List<Future> images = [];
      //
      // for (int i = 0; i < postImages.length; i++) {
      //   images.add(
      //     http.MultipartFile.fromPath('postImage', postImages[i]).then(
      //       (value) => request.files.add(value),
      //     ),
      //   );
      // }

      // request.headers.addAll(headers);
      //
      // final response = await request.send();

      Utils.showLog("Upload Post Api Uri => ${uri}");
      Utils.showLog("Upload Post Api Body => ${body}");

      final response = await http.post(uri, headers: headers, body: body);

      Utils.showLog("Upload Post Api Response => ${response.body}");
      if (response.statusCode == 200) {
        final jsonResult = jsonDecode(response.body);
        return UploadPostModel.fromJson(jsonResult);
      } else {
        Utils.showLog("Upload Post Api Response Error ");
        return null;
      }
    } catch (e) {
      Utils.showLog("Upload Post Api Error => $e");
      return null;
    }
  }
}

//
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:shortie/pages/upload_post_page/model/upload_post_model.dart';
// import 'package:shortie/utils/api.dart';
// import 'package:shortie/utils/utils.dart';
//
// class UploadPostApi {
//   static Future<UploadPostModel?> callApi({
//     required String loginUserId,
//     required String hashTag,
//     required String caption,
//     required List postImages,
//   }) async {
//     Utils.showLog("Upload Post Api Calling...");
//
//     try {
//       var headers = {'key': Api.secretKey};
//
//       var request = http.MultipartRequest('POST', Uri.parse("${Api.uploadPost}?userId=$loginUserId"));
//
//       request.fields.addAll({'caption': caption, 'hashTagId': hashTag});
//
//       List<Future> images = [];
//
//       for (int i = 0; i < postImages.length; i++) {
//         images.add(
//           http.MultipartFile.fromPath('postImage', postImages[i]).then(
//             (value) => request.files.add(value),
//           ),
//         );
//       }
//
//       request.headers.addAll(headers);
//
//       final response = await request.send();
//
//       if (response.statusCode == 200) {
//         final responseBody = await response.stream.bytesToString();
//         final jsonResult = jsonDecode(responseBody);
//         Utils.showLog("Upload Post Api Response => ${jsonResult}");
//         return UploadPostModel.fromJson(jsonResult);
//       } else {
//         Utils.showLog("Upload Post Api Response Error");
//         return null;
//       }
//     } catch (e) {
//       Utils.showLog("Upload Post Api Error => $e");
//       return null;
//     }
//   }
// }
