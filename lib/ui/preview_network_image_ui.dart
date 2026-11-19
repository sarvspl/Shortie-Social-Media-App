import 'dart:io';

import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_typedefs/rx_typedefs.dart';
import 'package:shortie/custom/custom_svga_player.dart';
import 'package:shortie/utils/asset.dart';
import 'package:shortie/utils/color.dart';
import 'package:shortie/utils/utils.dart';

class PreviewNetworkImageUi extends StatelessWidget {
  const PreviewNetworkImageUi({super.key, this.image, this.boxFit});

  final String? image;
  final BoxFit? boxFit;

  @override
  Widget build(BuildContext context) {
    final cleanImage = Utils.resolveUrl(image);
    if (cleanImage.isEmpty) return const Offstage();

    if (cleanImage.startsWith("http://") || cleanImage.startsWith("https://")) {
      return CachedNetworkImage(
        imageUrl: cleanImage,
        fit: boxFit ?? BoxFit.cover,
        memCacheWidth: 720,
        memCacheHeight: 720,
        placeholder: (context, url) => Image.asset(AppAsset.icProfilePlaceHolder, fit: boxFit ?? BoxFit.cover),
        errorWidget: (context, url, error) {
          Utils.showLog("❌ PreviewNetworkImageUi error on $url => $error. Falling back to Image.network.");
          return Image.network(
            cleanImage,
            fit: boxFit ?? BoxFit.cover,
            errorBuilder: (context, error2, stack) {
              return Image.asset(AppAsset.icProfilePlaceHolder, fit: boxFit ?? BoxFit.cover);
            },
          );
        },
      );
    } else {
      return Image.file(
        File(cleanImage),
        fit: boxFit ?? BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const Offstage(),
      );
    }
  }
}

class PreviewBannedNetworkImageUi extends StatelessWidget {
  const PreviewBannedNetworkImageUi({super.key, this.image});

  final String? image;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      width: 50,
      color: AppColor.black,
      alignment: Alignment.center,
      child: Image.asset(AppAsset.icNone, color: AppColor.colorRedContainer, width: 20),
    );
  }
}

class PreviewProfileImageWidget extends StatelessWidget {
  const PreviewProfileImageWidget({super.key, this.image, this.fit, this.isBanned, this.isShowPlaceHolder});

  final String? image;
  final BoxFit? fit;
  final bool? isBanned;
  final bool? isShowPlaceHolder;

  @override
  Widget build(BuildContext context) {
    final cleanImage = Utils.resolveUrl(image);
    if (cleanImage.isEmpty) {
      return isShowPlaceHolder == false ? const Offstage() : const ProfileImagePlaceHolder();
    }

    return LayoutBuilder(builder: (context, box) {
      Widget imageWidget = (cleanImage.startsWith("http://") || cleanImage.startsWith("https://"))
          ? CachedNetworkImage(
              imageUrl: cleanImage,
              fit: fit ?? BoxFit.cover,
              memCacheWidth: 300,
              memCacheHeight: 300,
              placeholder: (context, url) => isShowPlaceHolder == false ? const Offstage() : const ProfileImagePlaceHolder(),
              errorWidget: (context, url, error) {
                Utils.showLog("❌ PreviewProfileImageWidget error on $url => $error. Falling back to Image.network.");
                return Image.network(
                  cleanImage,
                  fit: fit ?? BoxFit.cover,
                  errorBuilder: (context, error2, stack) => isShowPlaceHolder == false ? const Offstage() : const ProfileImagePlaceHolder(),
                );
              },
            )
          : Image.file(
              File(cleanImage),
              fit: fit ?? BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => isShowPlaceHolder == false ? const Offstage() : const ProfileImagePlaceHolder(),
            );

      if (isBanned == true) {
        return Stack(
          fit: StackFit.expand,
          children: [
            imageWidget,
            BlurryContainer(
              blur: 3,
              color: AppColor.black.withValues(alpha: 0.2),
              child: const Offstage(),
            ),
          ],
        );
      }
      return imageWidget;
    });
  }
}

class PreviewPostImageWidget extends StatelessWidget {
  const PreviewPostImageWidget({
    super.key,
    this.image,
    this.fit,
    this.isBanned,
    this.size,
    this.isShowPlaceHolder,
  });

  final String? image;
  final BoxFit? fit;
  final bool? isBanned;
  final double? size;
  final bool? isShowPlaceHolder;

  @override
  Widget build(BuildContext context) {
    final cleanImage = Utils.resolveUrl(image);
    if (cleanImage.isEmpty) {
      return PostImagePlaceHolder(size: size, isShowPlaceHolder: isShowPlaceHolder);
    }

    Widget imageWidget = (cleanImage.startsWith("http://") || cleanImage.startsWith("https://"))
        ? CachedNetworkImage(
            imageUrl: cleanImage,
            fit: fit ?? BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            placeholder: (context, url) => PostImagePlaceHolder(size: size, isShowPlaceHolder: isShowPlaceHolder),
            errorWidget: (context, url, error) {
              Utils.showLog("❌ PreviewPostImageWidget error on $url => $error. Falling back to Image.network.");
              return Image.network(
                cleanImage,
                fit: fit ?? BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (context, error2, stack) => PostImagePlaceHolder(size: size, isShowPlaceHolder: isShowPlaceHolder),
              );
            },
          )
        : Image.file(
            File(cleanImage),
            fit: fit ?? BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (context, error, stackTrace) => PostImagePlaceHolder(size: size, isShowPlaceHolder: isShowPlaceHolder),
          );

    if (isBanned == true) {
      return Stack(
        fit: StackFit.expand,
        children: [
          imageWidget,
          BlurryContainer(
            blur: 10,
            color: AppColor.black.withValues(alpha: 0.3),
            child: const Offstage(),
          ),
        ],
      );
    }
    return imageWidget;
  }
}

class CustomPreviewImage extends StatelessWidget {
  const CustomPreviewImage({
    super.key,
    this.image,
    this.fit,
    this.isBanned,
    this.isProfileImage,
    this.placeHolderSize,
    this.imageQuality,
    this.isShowPlaceHolder,
    this.placeHolderPadding,
  });

  final String? image;
  final BoxFit? fit; // DEFAULT VALUE => BoxFit.cover
  final bool? isBanned;
  final bool? isProfileImage; // DEFAULT VALUE => TRUE
  final double? placeHolderSize;
  final int? imageQuality;
  final bool? isShowPlaceHolder; // DEFAULT VALUE => TRUE
  final EdgeInsetsGeometry? placeHolderPadding;

  @override
  Widget build(BuildContext context) {
    final cleanImage = Utils.resolveUrl(image);
    final fallbackPlaceholder = isProfileImage == false
        ? PostImagePlaceHolder(isShowPlaceHolder: isShowPlaceHolder, padding: placeHolderPadding)
        : ProfileImagePlaceHolder(isShowPlaceHolder: isShowPlaceHolder, padding: placeHolderPadding);

    if (cleanImage.isEmpty) {
      return fallbackPlaceholder;
    }

    Widget imageWidget = (cleanImage.startsWith("http://") || cleanImage.startsWith("https://"))
        ? CachedNetworkImage(
            imageUrl: cleanImage,
            fit: fit ?? BoxFit.cover,
            placeholder: (context, url) => fallbackPlaceholder,
            errorWidget: (context, url, error) {
              Utils.showLog("❌ CustomPreviewImage error on $url => $error. Falling back to Image.network.");
              return Image.network(
                cleanImage,
                fit: fit ?? BoxFit.cover,
                errorBuilder: (context, error2, stack) => fallbackPlaceholder,
              );
            },
          )
        : Image.file(
            File(cleanImage),
            fit: fit ?? BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => fallbackPlaceholder,
          );

    if (isBanned == true) {
      return Stack(
        fit: StackFit.expand,
        children: [
          imageWidget,
          BlurryContainer(
            blur: 10,
            borderRadius: BorderRadius.zero,
            color: AppColor.black.withValues(alpha: 0.3),
            child: const Offstage(),
          ),
        ],
      );
    }
    return imageWidget;
  }
}

class PostImagePlaceHolder extends StatelessWidget {
  const PostImagePlaceHolder({super.key, this.size, this.isShowPlaceHolder, this.padding});

  final double? size;
  final bool? isShowPlaceHolder;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return isShowPlaceHolder == false
        ? const Offstage()
        : Center(
            child: Padding(
              padding: padding ?? const EdgeInsets.all(0),
              child: Image.asset(
                AppAsset.icImagePlaceHolder,
                color: AppColor.colorTextGrey,
                width: size ?? 45,
              ),
            ),
          );
  }
}

class ProfileImagePlaceHolder extends StatelessWidget {
  const ProfileImagePlaceHolder({super.key, this.isShowPlaceHolder, this.padding});

  final bool? isShowPlaceHolder;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return isShowPlaceHolder == false
        ? const Offstage()
        : Center(
            child: Padding(
              padding: padding ?? const EdgeInsets.all(0),
              child: Image.asset(
                AppAsset.icProfilePlaceHolder,
                fit: BoxFit.cover,
              ),
            ),
          );
  }
}

class PreviewGiftWidget extends StatelessWidget {
  const PreviewGiftWidget({super.key, this.url, this.type, this.isShowThumbnail, this.thumbnailUrl, this.fit, this.whenCompleteSVGA});

  final String? url;
  final int? type;
  final String? thumbnailUrl;
  final bool? isShowThumbnail;
  final BoxFit? fit;
  final Callback? whenCompleteSVGA;

  @override
  Widget build(BuildContext context) {
    final cleanUrl = Utils.resolveUrl(url);
    final cleanThumb = Utils.resolveUrl(thumbnailUrl);

    if (cleanUrl.isEmpty || type == null) return const Offstage();

    if (type == 3 && isShowThumbnail == true) {
      return CachedNetworkImage(
        imageUrl: cleanThumb,
        fit: fit,
        errorWidget: (context, url, error) => Image.network(
          cleanThumb,
          fit: fit,
          errorBuilder: (context, error2, stack) => const Offstage(),
        ),
      );
    } else if (type == 3) {
      return SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: CustomSVGAPlayer(
          giftUrl: cleanUrl,
          callBack: whenCompleteSVGA,
        ),
      );
    } else {
      return CachedNetworkImage(
        imageUrl: cleanUrl,
        fit: fit,
        errorWidget: (context, url, error) => Image.network(
          cleanUrl,
          fit: fit,
          errorBuilder: (context, error2, stack) => const Offstage(),
        ),
      );
    }
  }
}
