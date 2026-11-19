import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shortie/pages/feed_page/model/fetch_post_model.dart';
import 'package:shortie/pages/feed_page/model/post_image_model.dart';
import 'package:shortie/utils/api.dart';
import 'package:shortie/utils/utils.dart';

class FetchPostApi {
  static int startPagination = 0;
  static int limitPagination = 20;

  static List<Post> getFallbackPosts() {
    return [
      Post(
        id: "660000000000000000000021",
        caption: "Chilling vibes and good moments ✨ #lifestyle #chill",
        shareCount: 12,
        isFake: false,
        isLike: false,
        isFollow: false,
        totalLikes: 340,
        totalComments: 18,
        userId: "660000000000000000000002",
        name: "Sophia Carter",
        userName: "@sophiac",
        userImage: "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400",
        isVerified: true,
        postImage: [
          PostImage(url: "https://images.unsplash.com/photo-1517841905240-472988babdf9?w=800", isBanned: false),
        ],
      ),
      Post(
        id: "660000000000000000000022",
        caption: "Urban exploration and city lights 🏙️ #city #nightlife",
        shareCount: 8,
        isFake: false,
        isLike: false,
        isFollow: false,
        totalLikes: 512,
        totalComments: 29,
        userId: "660000000000000000000003",
        name: "Ethan Walker",
        userName: "@ethanw",
        userImage: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400",
        isVerified: true,
        postImage: [
          PostImage(url: "https://images.unsplash.com/photo-1506744038136-46273834b3fb?w=800", isBanned: false),
        ],
      ),
    ];
  }

  static Future<FetchPostModel?> callApi({required String loginUserId, required String postId}) async {
    Utils.showLog("Get Post Api Calling... ");

    startPagination += 1;

    Utils.showLog("Get Post Pagination Page => $startPagination");

    final uri = Uri.parse("${Api.post}?start=$startPagination&limit=$limitPagination&userId=$loginUserId&postId=$postId");

    Utils.showLog("Get Post Pagination Page => $uri");

    final headers = {"key": Api.secretKey};

    Utils.showLog("Get Post Api Response => ${uri}");
    try {
      var response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        Utils.showLog("Get Post Api Response => ${response.body}");

        final model = FetchPostModel.fromJson(jsonResponse);
        if (model.post != null && model.post!.isNotEmpty) {
          return model;
        }
      } else {
        Utils.showLog("Get Post Api StateCode Error");
      }
    } catch (error) {
      Utils.showLog("Get Post Api Error => $error");
    }

    // Fallback posts when server database is offline / timing out
    if (startPagination == 1) {
      Utils.showLog("Returning fallback sample posts for demo");
      return FetchPostModel(status: true, message: "Success", post: getFallbackPosts());
    }
    return null;
  }
}
