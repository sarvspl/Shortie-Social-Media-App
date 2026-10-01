import 'dart:io';

import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_typedefs/rx_typedefs.dart';
import 'package:http/http.dart' as http;
import 'package:shortie/custom/custom_svga_player.dart';
import 'package:shortie/utils/api.dart';
import 'package:shortie/utils/asset.dart';
import 'package:shortie/utils/color.dart';
import 'package:shortie/utils/database.dart';
import 'package:shortie/utils/utils.dart';

class PreviewNetworkImageUi extends StatelessWidget {
  const PreviewNetworkImageUi({super.key, this.image, this.boxFit});

  final String? image;
  final BoxFit? boxFit;

  @override
  Widget build(BuildContext context) {
    return (image != null && image != "")
        ? (image!.startsWith("http") || image!.startsWith("https"))
            ? CachedNetworkImage(
                imageUrl: image ?? "",
                fit: boxFit ?? BoxFit.cover,
                errorWidget: (context, url, error) => Offstage(),
                placeholder: (context, url) => Offstage(),
              )
            : Image.file(
                File(image ?? ""),
                fit: boxFit ?? BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return CachedNetworkImage(
                    imageUrl: image ?? "",
                    fit: boxFit ?? BoxFit.cover,
                    errorWidget: (context, url, error) => Offstage(),
                    placeholder: (context, url) => Offstage(),
                  );
                },
              )
        : Offstage();

    // Database.networkImage(Api.baseUrl + image!) != null
    //             ? CachedNetworkImage(
    //                 imageUrl: Database.networkImage(Api.baseUrl + image!)!,
    //                 fit: BoxFit.cover,
    //                 errorWidget: (context, url, error) => Offstage(),
    //                 placeholder: (context, url) {
    //                   return AspectRatio(
    //                     aspectRatio: 1,
    //                     child: Image.asset(
    //                       AppAsset.icProfilePlaceHolder,
    //                       fit: boxFit ?? BoxFit.cover,
    //                     ),
    //                   );
    //                 },
    //               )
    //             : FutureBuilder(
    //                 future: _onCheckImage(Api.baseUrl + image!),
    //                 builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
    //                   if (snapshot.connectionState == ConnectionState.waiting) {
    //                     return Offstage();
    //                   } else if (snapshot.hasError) {
    //                     return Offstage();
    //                   } else {
    //                     if (snapshot.data == true) {
    //                       Database.onSetNetworkImage(Api.baseUrl + image!);
    //                       return CachedNetworkImage(
    //                         imageUrl: Api.baseUrl + image!,
    //                         fit: BoxFit.cover,
    //                         errorWidget: (context, url, error) => Offstage(),
    //                       );
    //                     } else {
    //                       return Offstage();
    //                     }
    //                   }
    //                 },
    //               )
    //     : Offstage();
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

Future<bool> _onCheckImage(String image) async {
  try {
    final response = await http.head(Uri.parse(image));

    return response.statusCode == 200;
  } catch (e) {
    Utils.showLog('Check Profile Image Filed !! => $e');
    return false;
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
    return LayoutBuilder(builder: (context, box) {
      final cacheHeight = (box.maxHeight * 2).toInt();
      final cacheWidth = (box.maxWidth * 2).toInt();

      return (image != null && image != "")
          ? image!.startsWith("https") || image!.startsWith("http")
              ? CachedNetworkImage(
                  imageUrl: image ?? "",
                  fit: fit ?? BoxFit.cover,
                  errorWidget: (context, url, error) => isShowPlaceHolder == false ? Offstage() : ProfileImagePlaceHolder(),
                  placeholder: (context, url) => isShowPlaceHolder == false ? Offstage() : ProfileImagePlaceHolder(),
                  memCacheHeight: cacheHeight,
                  maxHeightDiskCache: cacheHeight,
                  memCacheWidth: cacheWidth,
                  maxWidthDiskCache: cacheWidth,
                )
              : Database.networkImage(Api.baseUrl + image!) != null
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        CachedNetworkImage(
                          imageUrl: (Api.baseUrl + (image ?? "")),
                          fit: fit ?? BoxFit.cover,
                          errorWidget: (context, url, error) => isShowPlaceHolder == false ? Offstage() : ProfileImagePlaceHolder(),
                          placeholder: (context, url) => isShowPlaceHolder == false ? Offstage() : ProfileImagePlaceHolder(),
                          memCacheHeight: cacheHeight,
                          maxHeightDiskCache: cacheHeight,
                          memCacheWidth: cacheWidth,
                          maxWidthDiskCache: cacheWidth,
                        ),
                        Visibility(
                          visible: isBanned ?? false,
                          child: BlurryContainer(
                            blur: 3,
                            color: AppColor.black.withValues(alpha: 0.2),
                            child: Offstage(),
                          ),
                        )
                      ],
                    )
                  : FutureBuilder(
                      future: _onCheckImage(Api.baseUrl + image!),
                      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return isShowPlaceHolder == false ? Offstage() : ProfileImagePlaceHolder();
                        } else if (snapshot.hasError) {
                          return isShowPlaceHolder == false ? Offstage() : ProfileImagePlaceHolder();
                        } else {
                          if (snapshot.data == true) {
                            Database.onSetNetworkImage(Api.baseUrl + image!);
                            return CachedNetworkImage(
                              imageUrl: Api.baseUrl + image!,
                              fit: fit ?? BoxFit.cover,
                              placeholder: (context, url) => isShowPlaceHolder == false ? Offstage() : ProfileImagePlaceHolder(),
                              errorWidget: (context, url, error) => isShowPlaceHolder == false ? Offstage() : ProfileImagePlaceHolder(),
                              memCacheHeight: cacheHeight,
                              maxHeightDiskCache: cacheHeight,
                              memCacheWidth: cacheWidth,
                              maxWidthDiskCache: cacheWidth,
                            );
                          } else {
                            return isShowPlaceHolder == false ? Offstage() : ProfileImagePlaceHolder();
                          }
                        }
                      },
                    )
          : ProfileImagePlaceHolder();
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
    return LayoutBuilder(builder: (context, box) {
      return (image != null && image != "")
          ? image!.startsWith("https") || image!.startsWith("http")
              ? Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: image != null ? ((image ?? "")) : "",
                      fit: fit,
                      errorWidget: (context, url, error) => PostImagePlaceHolder(size: size, isShowPlaceHolder: isShowPlaceHolder),
                      placeholder: (context, url) => PostImagePlaceHolder(size: size, isShowPlaceHolder: isShowPlaceHolder),
                      width: double.infinity,
                      height: double.infinity,
                    ),
                    Visibility(
                      visible: isBanned ?? false,
                      child: BlurryContainer(
                        blur: 10,
                        color: AppColor.black.withValues(alpha: 0.3),
                        child: Offstage(),
                      ),
                    )
                  ],
                )
              : Database.networkImage(Api.baseUrl + image!) != null
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        CachedNetworkImage(
                          imageUrl: image != null ? (Api.baseUrl + (image ?? "")) : "",
                          fit: fit,
                          errorWidget: (context, url, error) => PostImagePlaceHolder(size: size, isShowPlaceHolder: isShowPlaceHolder),
                          placeholder: (context, url) => PostImagePlaceHolder(size: size, isShowPlaceHolder: isShowPlaceHolder),
                          width: double.infinity,
                          height: double.infinity,
                        ),
                        Visibility(
                          visible: isBanned ?? false,
                          child: BlurryContainer(
                            blur: 10,
                            color: AppColor.black.withValues(alpha: 0.3),
                            child: Offstage(),
                          ),
                        )
                      ],
                    )
                  : FutureBuilder(
                      future: _onCheckImage(Api.baseUrl + image!),
                      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return PostImagePlaceHolder(size: size, isShowPlaceHolder: isShowPlaceHolder);
                        } else if (snapshot.hasError) {
                          return PostImagePlaceHolder(size: size, isShowPlaceHolder: isShowPlaceHolder);
                        } else {
                          if (snapshot.data == true) {
                            Database.onSetNetworkImage(Api.baseUrl + image!);
                            return CachedNetworkImage(
                              imageUrl: Api.baseUrl + image!,
                              fit: fit,
                              placeholder: (context, url) => PostImagePlaceHolder(size: size, isShowPlaceHolder: isShowPlaceHolder),
                              errorWidget: (context, url, error) => PostImagePlaceHolder(size: size, isShowPlaceHolder: isShowPlaceHolder),
                              width: double.infinity,
                              height: double.infinity,
                            );
                          } else {
                            return PostImagePlaceHolder(size: size, isShowPlaceHolder: isShowPlaceHolder);
                          }
                        }
                      },
                    )
          : PostImagePlaceHolder(size: size, isShowPlaceHolder: isShowPlaceHolder);
    });
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
    final int? previewImageQuality = imageQuality ?? ((isProfileImage == false) ? null : null);

    return (image?.trim().isNotEmpty ?? false)
        ? Stack(
            fit: StackFit.expand,
            children: [
              (image!.startsWith("http") || image!.startsWith("https"))
                  ? CachedNetworkImage(
                      imageUrl: image ?? "",
                      fit: fit ?? BoxFit.cover,
                      placeholder: (context, url) => isProfileImage == false
                          ? PostImagePlaceHolder(isShowPlaceHolder: isShowPlaceHolder)
                          : ProfileImagePlaceHolder(isShowPlaceHolder: isShowPlaceHolder),
                      maxHeightDiskCache: previewImageQuality,
                      maxWidthDiskCache: previewImageQuality,
                      memCacheHeight: previewImageQuality,
                      memCacheWidth: previewImageQuality,
                      errorWidget: (context, url, error) => Image.file(
                        File(image ?? ""),
                        fit: fit ?? BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => isProfileImage == false
                            ? PostImagePlaceHolder(isShowPlaceHolder: isShowPlaceHolder)
                            : ProfileImagePlaceHolder(isShowPlaceHolder: isShowPlaceHolder),
                      ),
                    )
                  : Image.file(
                      File(image ?? ""),
                      fit: fit ?? BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => isProfileImage == false
                          ? PostImagePlaceHolder(
                              isShowPlaceHolder: isShowPlaceHolder,
                              padding: placeHolderPadding,
                            )
                          : ProfileImagePlaceHolder(
                              isShowPlaceHolder: isShowPlaceHolder,
                              padding: placeHolderPadding,
                            ),
                    ),
              Visibility(
                visible: isBanned ?? false,
                child: BlurryContainer(
                  blur: 10,
                  borderRadius: BorderRadius.zero,
                  color: AppColor.black.withValues(alpha: 0.3),
                  child: Offstage(),
                ),
              )
            ],
          )
        : isProfileImage == false
            ? PostImagePlaceHolder(
                isShowPlaceHolder: isShowPlaceHolder,
                padding: placeHolderPadding,
              )
            : ProfileImagePlaceHolder(
                isShowPlaceHolder: isShowPlaceHolder,
                padding: placeHolderPadding,
              );
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
        ? Offstage()
        : Center(
            child: Container(
              padding: padding,
              child: Image.asset(
                AppAsset.icImagePlaceHolder,
                height: size ?? 100,
                width: size ?? 100,
              ),
            ),
          );
  }
}

class ProfileImagePlaceHolder extends StatelessWidget {
  const ProfileImagePlaceHolder({super.key, this.size, this.isShowPlaceHolder, this.padding});

  final double? size;
  final bool? isShowPlaceHolder;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return isShowPlaceHolder == false
        ? Offstage()
        : Container(
            padding: padding,
            child: Image.asset(
              AppAsset.icProfilePlaceHolder,
              fit: BoxFit.cover,
              height: size,
              width: size,
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
    Utils.showLog("Gift Type => $type **** Gift Url => $url");

    return (url?.trim().isNotEmpty ?? false) && type != null
        ? type == 3 && isShowThumbnail == true
            ? CachedNetworkImage(
                imageUrl: ((thumbnailUrl ?? "")),
                fit: fit,
                errorWidget: (context, url, error) => Offstage(),
              )
            : type == 3
                ? SizedBox(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    child: CustomSVGAPlayer(
                      giftUrl: (url ?? ""),
                      callBack: whenCompleteSVGA,
                    ),
                  )
                : CachedNetworkImage(
                    imageUrl: (url ?? ""),
                    fit: fit,
                    errorWidget: (context, url, error) => Offstage(),
                  )
        : Offstage();
  }
}
