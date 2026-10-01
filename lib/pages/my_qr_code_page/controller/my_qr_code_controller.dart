import 'dart:io';

import 'package:flutter/services.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:shortie/deep_link/services/deep_link_services.dart';
import 'package:shortie/deep_link/share_manager/share_manager.dart';
import 'package:shortie/ui/loading_ui.dart';
import 'package:shortie/utils/api.dart';
import 'package:shortie/utils/database.dart';
import 'package:shortie/utils/enums.dart';
import 'package:shortie/utils/utils.dart';
import 'package:url_launcher/url_launcher.dart';

class MyQrCodeController extends GetxController {
  ScreenshotController screenshotController = ScreenshotController();

  Future<String?> onCaptureImage() async {
    try {
      final directory = (await getApplicationDocumentsDirectory()).path;
      String fileName = DateTime.now().microsecondsSinceEpoch.toString();
      final String filePath = '$directory/$fileName.png';

      final image = await screenshotController.capture();
      if (image != null) {
        final file = File(filePath);
        await file.writeAsBytes(image);

        Utils.showLog("Capture Screen Shorts => $filePath");

        return filePath;
      } else {
        Utils.showLog("Capture Screen Shorts Failed => No image captured");
      }
    } catch (e) {
      Utils.showLog("Capture Screen Shorts Failed => $e");
    }

    return null;
  }

  Future<void> onClickDownload() async {
    Get.dialog(LoadingUi(), barrierDismissible: false); // Show Loading...
    try {
      final filePath = await onCaptureImage();
      if (filePath != null) {
        await GallerySaver.saveImage(filePath);
        Utils.showToast(EnumLocal.txtDownloadSuccess.name.tr);
      }
    } catch (e) {
      Utils.showLog("Download Screen Shorts Failed => $e");
    }
    Get.back(); // Stop Loading...
  }

  Future<void> onClickWhatsapp() async {
    Get.dialog(LoadingUi(), barrierDismissible: false);
    try {
      final deepLink = DeepLinkServices.onGenerateLink(
        id: Database.fetchLoginUserProfileModel?.user?.id ?? "",
        pageRoutes: DeepLinkServices.user_profile,
        liveUserId: Database.fetchLoginUserProfileModel?.user?.id ?? "",
      );

      // ✅ Encode the deep link so its `&` params don't bleed into wa.me's query
      final encodedLink = Uri.encodeComponent(deepLink);
      final Uri _url = Uri.parse('https://wa.me/?text=$encodedLink');

      Utils.showLog("WhatsApp URL => $_url");
      await launchUrl(_url, mode: LaunchMode.externalApplication);
    } catch (e) {
      Utils.showLog("Launch Url Failed => $e");
    }
    Get.back();
  }

  Future<void> onClickCopy() async {
    try {
      final deepLink = DeepLinkServices.onGenerateLink(id: Database.fetchLoginUserProfileModel?.user?.id ?? "", pageRoutes: DeepLinkServices.user_profile, liveUserId: Database.fetchLoginUserProfileModel?.user?.id ?? "");

      Clipboard.setData(ClipboardData(text: deepLink));
      Utils.showToast("Copied on clipboard");
    } catch (e) {
      Utils.showToast("Copy Text Failed => $e");
    }
  }

  Future<void> onClickShare() async {
    Get.dialog(const LoadingUi(), barrierDismissible: false); // Start Loading...

    final image = Database.fetchLoginUserProfileModel?.user?.image ?? "";

    await ShareManager.shareContent(
      id: Database.fetchLoginUserProfileModel?.user?.id ?? "",
      title: Database.fetchLoginUserProfileModel?.user?.name ?? "",
      imageUrl: (image.startsWith("https")) ? (image) : (Api.baseUrl + image),
      shareType: ShareType.withImage, // Choose your preferred type
      pageRoutes: DeepLinkServices.user_profile,
    );

    Get.back(); // Stop Loading...
  }
}
