import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_typedefs/rx_typedefs.dart';
import 'package:http/http.dart' as http;
import 'package:shortie/main.dart';
import 'package:shortie/pages/message_page/controller/message_controller.dart';
import 'package:shortie/pages/story_page/model/fetch_story_model.dart' as Viewer;
import 'package:shortie/pages/story_page/widget/simple_story_viewer.dart';
import 'package:shortie/ui/preview_network_image_ui.dart';
import 'package:shortie/utils/asset.dart';
import 'package:shortie/utils/color.dart';
import 'package:shortie/utils/enums.dart';
import 'package:shortie/utils/font_style.dart';

import '../model/fetch_message_user_model.dart';

class MessageUserUi extends StatelessWidget {
  const MessageUserUi({
    super.key,
    required this.title,
    required this.subTitle,
    required this.leading,
    this.messageCount,
    this.dateTime,
    required this.callback,
    required this.isVerified,
    required this.isProfileImageBanned,
    required this.userId, // other user id
    required this.userUserName, // other user username
    this.stories,
  });

  final String title;
  final String subTitle;
  final String leading;
  final int? messageCount;
  final String? dateTime;
  final Callback callback;
  final bool isVerified;
  final bool isProfileImageBanned;
  final String userId;
  final String userUserName;
  final List<Story>? stories;

  @override
  Widget build(BuildContext context) {
    log(Get.statusBarHeight.toString());
    final bool hasStories = (stories?.isNotEmpty ?? false);

    return GestureDetector(
      onTap: callback,
      child: Container(
        height: 70,
        width: Get.width,
        padding: EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(
          color: AppColor.transparent,
          border: Border(
            bottom: BorderSide(color: AppColor.colorBorder.withValues(alpha: 0.5)),
          ),
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: () async {
                // Story open
                if (!hasStories) return;

                // Map your API Story (this file) -> Viewer.Stories (story viewer models)
                final viewerStories = stories!.map((s) {
                  return Viewer.Stories(
                    id: s.id,
                    mediaImageUrl: s.mediaImageUrl,
                    mediaVideoUrl: s.mediaVideoUrl,
                    viewsCount: s.viewsCount,
                    reactionsCount: s.reactionsCount,
                    storyType: s.storyType,
                    duration: s.duration,
                    createdAt: s.createdAt?.toIso8601String(),
                    backgroundSong: s.backgroundSong == null
                        ? null
                        : Viewer.BackgroundSong(
                            id: s.backgroundSong!.id,
                            songTitle: s.backgroundSong!.songTitle,
                            songImage: s.backgroundSong!.songImage,
                            singerName: s.backgroundSong!.singerName,
                            songTime: s.backgroundSong!.songTime, // double? ok
                            songLink: s.backgroundSong!.songLink,
                          ),
                  );
                }).toList();

                final group = Viewer.StoryGroup(
                  user: Viewer.User(
                    id: userId,
                    name: title,
                    userName: userUserName,
                    image: leading,
                    isProfileImageBanned: isProfileImageBanned,
                  ),
                  stories: viewerStories,
                );

                await StoryViewer.openOthers(groups: [group], initialGroupIndex: 0);
              },
              child: Container(
                // OUTER RING
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: hasStories ? AppColor.primaryLinearGradient : null,
                  color: AppColor.white,
                ),
                child: Container(
                  // inner white gap ring
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColor.white,
                  ),
                  child: Container(
                    height: 46,
                    width: 46,
                    clipBehavior: Clip.antiAlias,
                    decoration: const BoxDecoration(shape: BoxShape.circle),
                    child: CustomPreviewImage(image: leading, isBanned: isProfileImageBanned),
                  ),
                ),
              ),
            ),
            12.width,
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Flexible(
                              fit: FlexFit.loose,
                              child: Text(
                                title,
                                maxLines: 1,
                                style: AppFontStyle.styleW700(AppColor.black, 15.5),
                              ),
                            ),
                            Visibility(
                              visible: isVerified,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 3),
                                child: Image.asset(AppAsset.icBlueTick, width: 20),
                              ),
                            ),
                          ],
                        ),
                      ),
                      messageCount == null || messageCount == 0
                          ? const Offstage()
                          : Container(
                              padding: EdgeInsets.symmetric(horizontal: messageCount! < 10 ? 9 : 6.5, vertical: 4),
                              decoration: BoxDecoration(
                                gradient: AppColor.primaryLinearGradient,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Center(
                                child: Text(
                                  messageCount.toString(),
                                  maxLines: 1,
                                  style: AppFontStyle.styleW600(AppColor.white, 12),
                                ),
                              ),
                            ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: FutureBuilder(
                          future: onCheckUrlAndBuildWidget(subTitle),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.done) {
                              return snapshot.data ?? const Offstage();
                            }
                            return Offstage();
                          },
                        ),
                        // Text(
                        //   subTitle,
                        //   maxLines: 1,
                        //   style: AppFontStyle.styleW400(AppColor.coloGreyText, 14),
                        // ),
                      ),
                      dateTime == null
                          ? const Offstage()
                          : Text(
                              dateTime!,
                              style: AppFontStyle.styleW400(AppColor.coloGreyText, 10),
                            ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SearchMessageUserUi extends StatelessWidget {
  const SearchMessageUserUi({
    super.key,
    required this.callback,
    required this.onClickClear,
    required this.controller,
    required this.onChanged,
    required this.onCompleteSearch,
    required this.isShowClearIcon,
  });

  final Callback callback;
  final Callback onClickClear;
  final TextEditingController controller;
  final Function(String value) onChanged;
  final Function(String value) onCompleteSearch;
  final bool isShowClearIcon;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.only(left: 15, right: 12),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColor.colorUnselectedIcon.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColor.colorBorder.withValues(alpha: 0.8)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            height: 20,
            width: 20,
            AppAsset.icSearch,
            color: AppColor.black,
          ),
          5.width,
          VerticalDivider(
            indent: 12,
            endIndent: 12,
            color: AppColor.coloGreyText.withValues(alpha: 0.3),
          ),
          5.width,
          Expanded(
            child: TextFormField(
              controller: controller,
              cursorColor: AppColor.colorTextGrey,
              maxLines: 1,
              onChanged: onChanged,
              onTap: callback,
              onFieldSubmitted: onCompleteSearch,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.only(top: 0),
                border: InputBorder.none,
                hintText: EnumLocal.txtSearchHintText.name.tr,
                hintStyle: AppFontStyle.styleW400(AppColor.coloGreyText, 17),
              ),
            ),
          ),
          Visibility(
            visible: isShowClearIcon,
            child: GestureDetector(
              onTap: onClickClear,
              child: Container(
                height: 30,
                width: 30,
                color: AppColor.transparent,
                child: Center(
                  child: Image.asset(
                    height: 20,
                    width: 20,
                    AppAsset.icClose,
                    color: AppColor.coloGreyText,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SearchHistoryUi extends StatelessWidget {
  const SearchHistoryUi({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10, top: 8),
      child: GetBuilder<MessageController>(
        id: "onChangeSearchHistory",
        builder: (controller) => SingleChildScrollView(
          child: Wrap(
            spacing: 5,
            alignment: WrapAlignment.start,
            children: [
              for (int index = 0; index < controller.searchMessageUserHistory.length; index++)
                SearchHistoryItem(
                  title: controller.searchMessageUserHistory[index],
                  onTap: () {
                    controller.searchController.text = controller.searchMessageUserHistory[index];
                    controller.onChangeSearchHistory(false);
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
                  onDelete: () {
                    controller.onDeleteSearchHistory(index);
                    if (controller.searchMessageUserHistory.isEmpty) {
                      controller.onChangeSearchHistory(false);
                      FocusManager.instance.primaryFocus?.unfocus();
                    }
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class SearchHistoryItem extends StatelessWidget {
  const SearchHistoryItem({
    super.key,
    required this.title,
    required this.onTap,
    required this.onDelete,
  });
  final String title;
  final Callback onTap;
  final Callback onDelete;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Chip(
        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
          side: BorderSide(color: AppColor.colorTextGrey.withValues(alpha: 0.1), width: 1.0),
        ),
        deleteIconColor: AppColor.black,
        onDeleted: onDelete,
        deleteIcon: const Padding(
          padding: EdgeInsets.only(right: 8.0),
          child: Icon(Icons.close, color: AppColor.colorTextGrey, size: 16),
        ),
        backgroundColor: AppColor.white,
        label: Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 4, left: 2),
          child: Text(
            title,
            style: AppFontStyle.styleW400(AppColor.colorTextGrey, 14),
          ),
        ),
      ),
    );
  }
}

Future<Widget> onCheckUrlAndBuildWidget(String inputText) async {
  debugPrint("Original text: $inputText");

  // Improved URL regex pattern
  final urlRegExp = RegExp(
    r'https?:\/\/(?:www\.)?[-\w@:%.+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b(?:[-\w()@:%+.~#?&/=]*)',
    caseSensitive: false,
  );

  final urlMatch = urlRegExp.firstMatch(inputText);

  if (urlMatch != null) {
    final url = urlMatch.group(0)!;
    debugPrint("Found URL: $url");

    try {
      // Add timeout and follow redirects
      final response = await http.head(Uri.parse(url)).timeout(const Duration(seconds: 5));

      debugPrint("HTTP Status: ${response.statusCode}");

      if (response.statusCode == 200) {
        // More comprehensive image check
        final isImage = url.toLowerCase().contains('.png') ||
            url.toLowerCase().contains('.jpg') ||
            url.toLowerCase().contains('.jpeg') ||
            url.toLowerCase().contains('.gif') ||
            response.headers['content-type']?.contains('image') == true;

        if (isImage) {
          final textBeforeUrl = inputText.substring(0, urlMatch.start).trim();

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (textBeforeUrl.isNotEmpty)
                Text(
                  textBeforeUrl,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFontStyle.styleW400(AppColor.coloGreyText, 14),
                ),
              const SizedBox(width: 3),
              SizedBox(height: 15, width: 15, child: PreviewProfileImageWidget(image: url, fit: BoxFit.contain)),
              // Image.network(
              //   url,
              //   errorBuilder: (context, error, stackTrace) {
              //     debugPrint("Image load error: $error");
              //     return Text(
              //       inputText,
              //       style: AppFontStyle.styleW400(AppColor.coloGreyText, 14),
              //     ); // Fallback to text if image fails
              //   },
              //   height: 15,
              //   width: 15,
              // ),
            ],
          );
        }
      }
    } catch (e) {
      debugPrint("URL check failed: $e");
      // Continue to return text only
    }
  }

  // Fallback to just text
  return Text(
    inputText,
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
    style: AppFontStyle.styleW400(AppColor.coloGreyText, 14),
  );
}
