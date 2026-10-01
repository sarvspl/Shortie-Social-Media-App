import 'dart:developer';

import 'package:share_plus/share_plus.dart';
import 'package:shortie/deep_link/services/deep_link_services.dart';
import 'package:shortie/utils/color.dart';

import 'pure_flutter_share_service.dart';
import 'share_card_generator.dart';

class ShareManager {
  static Future<void> shareContent(
      {required String id,
      required String title,
      String? imageUrl,
      String? thumbnailUrl,
      ShareType shareType = ShareType.richText,
      String? pageRoutes,
      String? referralCode,
      Function()? onComplete}) async {
    final deepLink = DeepLinkServices.onGenerateLink(id: id, pageRoutes: pageRoutes, referralCode: referralCode, liveUserId: id);
    // final safeTitle = title.trim().isEmpty ? 'Check this out!' : title.trim();
    log("✅ DEEP LINK GENERATE SUCCESS => $deepLink");

    switch (shareType) {
      case ShareType.richText:
        await _shareRichText(title: title, deepLink: deepLink, onComplete: onComplete);
        break;

      case ShareType.withImage:
        await PureFlutterShareService.shareRichContent(title: title, imageUrl: imageUrl, deepLink: deepLink, onComplete: onComplete);
        break;

      case ShareType.asPreviewCard:
        await ShareCardGenerator.shareAsPreviewCard(title: title, websiteName: "YourApp", imageUrl: thumbnailUrl ?? imageUrl, deepLink: deepLink, brandColor: AppColor.primary, onComplete: onComplete);
        break;
    }
  }

  static Future<void> _shareRichText({required String title, String? deepLink, Function()? onComplete}) async {
    final shareText = '''
📱 $title


${deepLink != null ? '👉 $deepLink' : ''}
    '''
        .trim();

    await Share.share(shareText, subject: title).whenComplete(() => onComplete?.call());
  }
}

enum ShareType { richText, withImage, asPreviewCard }
