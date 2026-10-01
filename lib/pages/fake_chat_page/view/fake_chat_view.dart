import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:shortie/custom/custom_format_audio_time.dart';
import 'package:shortie/main.dart';
import 'package:shortie/pages/chat_page/widget/chat_widget.dart';
import 'package:shortie/pages/fake_chat_page/controller/fake_chat_controller.dart';
import 'package:shortie/pages/fake_chat_page/widget/fake_chat_widget.dart';
import 'package:shortie/utils/asset.dart';
import 'package:shortie/utils/color.dart';
import 'package:shortie/utils/database.dart';
import 'package:shortie/utils/font_style.dart';
import 'package:shortie/ui/loading_ui.dart';
import 'package:shortie/ui/no_data_found_ui.dart';
import 'package:shortie/custom/custom_format_chat_time.dart';

import '../../chat_page/model/fetch_user_chat_model.dart';

class FakeChatView extends GetView<FakeChatController> {
  const FakeChatView({super.key});

  @override
  Widget build(BuildContext context) {
        // controller.onScrollDown();
    return Scaffold(

      // floatingActionButton: FloatingActionButton(onPressed: () {
      //
      //
      //   controller.scrollToBottomFully();
      // },),

      backgroundColor: AppColor.colorScaffold,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: AppColor.white,
          surfaceTintColor: AppColor.transparent,
          shadowColor: AppColor.black.withValues(alpha: 0.4),
          flexibleSpace: const FakeChatAppBarUi(),
        ),
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            height: Get.height,
            width: Get.width,
            child: Column(
              children: [
                Expanded(
                  child: SizedBox(
                    height: Get.height,
                    width: Get.width,
                    child: Stack(
                      children: [
                        Image.asset(AppAsset.icChatBackGround, fit: BoxFit.cover, width: Get.width),
                        SizedBox(
                          height: Get.height,
                          width: Get.width,
                          child: GetBuilder<FakeChatController>(
                            id: "onGetUserChats",
                            builder: (controller) => controller.isLoading
                                ? LoadingUi()
                                : controller.userChats.isEmpty
                                ? NoDataFoundUi(iconSize: 160, fontSize: 19)
                                : _buildChatList(controller),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const FakeMessageTextFieldUi()
              ],
            ),
          ),
          Positioned(
            top: 20,
            child: GetBuilder<FakeChatController>(
              id: "onChangeAudioRecordingEvent",
              builder: (controller) => Visibility(
                visible: controller.isRecordingAudio,
                child: Container(
                  height: 40,
                  width: 110,
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: AppColor.colorBorder.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Image.asset(
                        AppAsset.icMicOn,
                        color: AppColor.primary,
                        width: 20,
                      ),
                      5.width,
                      Text(
                        CustomFormatAudioTime.convert(controller.countTime),
                        style: AppFontStyle.styleW500(AppColor.black, 13),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildChatList(FakeChatController controller) {
    Map<String, List<Chat>> groupedMessages = {};

    for (var chat in controller.userChats) {
      final key = _getDateLabel(chat.createdAt ?? DateTime.now().toString());
      groupedMessages.putIfAbsent(key, () => []);
      groupedMessages[key]!.add(chat);
    }

    final dateKeys = groupedMessages.keys.toList();

    return CustomScrollView(
      controller: controller.scrollController,
      slivers: dateKeys.map((dateKey) {
        final messages = groupedMessages[dateKey]!;

        return SliverStickyHeader(
          header: _buildStickyDateHeader(dateKey),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                return _buildChatMessage(messages[index]);
              },
              childCount: messages.length,
            ),
          ),
        );
      }).toList(),
    );
  }


  // Widget _buildStickyDateHeader(String dateLabel) {
  //   return Container(
  //     margin: EdgeInsets.symmetric(vertical: 10),
  //     alignment: Alignment.center,
  //     child: Container(
  //       padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  //       decoration: BoxDecoration(
  //         color: AppColor.colorBorder.withValues(alpha: 0.7),
  //         borderRadius: BorderRadius.circular(12),
  //       ),
  //       child: Text(
  //         dateLabel,
  //         style: AppFontStyle.styleW500(AppColor.black, 12),
  //       ),
  //     ),
  //   );
  // }


  Widget _buildStickyDateHeader(String dateLabel) {
    return GetBuilder<FakeChatController>(
      id: "stickyHeader",
      builder: (c) {
        return AnimatedOpacity(
          duration: const Duration(milliseconds: 250),
          opacity: c.showStickyHeader ? 1 : 0,
          child: IgnorePointer(
            ignoring: !c.showStickyHeader,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              alignment: Alignment.center,
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  boxShadow: [BoxShadow(color: AppColor.black.withValues(alpha: 0.1),blurRadius: 2,offset: Offset(0, 1),spreadRadius: 0)],
                  color: AppColor.colorBorder.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  dateLabel,
                  style:
                  AppFontStyle.styleW500(AppColor.black, 10),
                ),
              ),
            ),
          ),
        );
      },
    );
  }



  String _getDateLabel(String dateTimeString) {
    final messageDate = DateTime.parse(dateTimeString);
    final now = DateTime.now();

    final today = DateTime(now.year, now.month, now.day);
    final messageDay =
    DateTime(messageDate.year, messageDate.month, messageDate.day);

    // ✅ Only Today
    if (messageDay == today) {
      return "Today";
    }

    // ❌ No Yesterday — always show date
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return "${messageDate.day} "
        "${months[messageDate.month - 1]} "
        "${messageDate.year}";
  }

  Widget _buildChatMessage(dynamic chat) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
      child: chat.messageType == 1 // Text Message...
          ? chat.senderUserId == Database.loginUserId
          ? SenderMessageUi(
        message: chat.message ?? "",
        time: CustomFormatChatTime.convert(
          chat.createdAt ?? DateTime.now().toString(),
        ),
      )
          : ReceiverMessageUi(
        message: chat.message ?? "",
        time: CustomFormatChatTime.convert(
          chat.createdAt ?? DateTime.now().toString(),
        ),
      )
          : chat.messageType == 2 // Image Message...
          ? chat.senderUserId == Database.loginUserId
          ? FakeSenderImageUi(
        image: chat.image ?? "",
        time: CustomFormatChatTime.convert(
          chat.createdAt ?? DateTime.now().toString(),
        ),
      )
          : FakeReceiverImageUi(
        image: chat.image ?? "",
        time: CustomFormatChatTime.convert(
          chat.createdAt ?? DateTime.now().toString(),
        ),
      )
          : chat.messageType == 3
          ? chat.senderUserId == Database.loginUserId // Audio Message...
          ? FakeSenderAudioUi(
        id: chat.id ?? "",
        audio: (chat.audio ?? ""),
        time: CustomFormatChatTime.convert(
          chat.createdAt ?? DateTime.now().toString(),
        ),
      )
          : FakeReceiverAudioUi(
        id: chat.id ?? "",
        audio: (chat.audio ?? ""),
        time: CustomFormatChatTime.convert(
          chat.createdAt ?? DateTime.now().toString(),
        ),
      )
          : chat.messageType == 4
          ? chat.senderUserId == Database.loginUserId
          ? SenderStoryReaction(
        image: chat.storyId?.mediaImageUrl ?? "",
        time: CustomFormatChatTime.convert(chat.createdAt ?? DateTime.now().toString()),
        reaction: chat.image ?? "",
        callback: () {},
      )
          : ReceiverStoryReaction(
        image: chat.storyId?.mediaImageUrl ?? "",
        time: CustomFormatChatTime.convert(chat.createdAt ?? DateTime.now().toString()),
        reaction: chat.image ?? "",
        callback: () {},
      )
          : chat.messageType == 5
          ? chat.senderUserId == Database.loginUserId
          ? SenderStoryReply(
        image: chat.storyId?.mediaImageUrl ?? "",
        time: CustomFormatChatTime.convert(chat.createdAt ?? DateTime.now().toString()),
        message: chat.message ?? "",
        callback: () {},
      )
          : ReceiverStoryReply(
        image: chat.storyId?.mediaImageUrl ?? "",
        time: CustomFormatChatTime.convert(chat.createdAt ?? DateTime.now().toString()),
        message: chat.message ?? "",
        callback: () {},
      )
          : UploadAudioUi(),
    );
  }
}