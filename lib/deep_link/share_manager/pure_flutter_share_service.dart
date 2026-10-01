import 'dart:developer';
import 'dart:io';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shortie/ui/loading_ui.dart';

import '../../utils/color.dart';

class PureFlutterShareService {
  /// Share with image + formatted text (appears as image + caption)
  static Future<void> shareRichContent({
    required String title,
    String? imageUrl,
    String? deepLink,
    Function()? onComplete,
  }) async {
    // Download first, THEN show loading, share after
    XFile? imageFile;

    try {
      if (imageUrl != null) {
        // Show loading only during download
        Get.dialog(
          const LoadingUi(color: AppColor.primary),
          barrierDismissible: false,
        );

        imageFile = await _downloadImage(imageUrl);
        Get.back(); // Dismiss BEFORE share sheet opens
        await Future.delayed(const Duration(milliseconds: 300)); // iOS needs this gap
      }

      final shareText = deepLink != null ? '🔗 $deepLink' : '';

      if (imageFile != null) {
        final result = await Share.shareXFiles(
          [imageFile],
          text: shareText,
          subject: title.isEmpty ? null : title,
        );
        if (result.status == ShareResultStatus.success || result.status == ShareResultStatus.dismissed) {
          onComplete?.call();
        }
      } else {
        await Share.share(shareText, subject: title);
        onComplete?.call();
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      log("Share failed: $e", name: "ShareService");
    }
  }

  static Future<XFile?> _downloadImage(String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl)).timeout(const Duration(seconds: 10)); // timeout add કરો

      if (response.statusCode == 200) {
        final tempDir = await getTemporaryDirectory();
        final fileName = 'share_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final file = File('${tempDir.path}/$fileName');
        await file.writeAsBytes(response.bodyBytes);

        // Verify file actually written
        if (await file.exists() && await file.length() > 0) {
          return XFile(file.path, mimeType: 'image/jpeg'); // explicit mimeType
        }
      }
      return null;
    } catch (e) {
      log("Image download failed: $e", name: "ShareService");
      return null;
    }
  }
}
