import 'package:flutter/material.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:get/get.dart';
import 'package:shortie/pages/chat_page/widget/chat_widget.dart';
import 'package:shortie/pages/chat_page/controller/chat_controller.dart';
import 'package:shortie/ui/loading_ui.dart';
import 'package:shortie/ui/no_data_found_ui.dart';
import 'package:shortie/utils/asset.dart';
import 'package:shortie/utils/color.dart';
import 'package:shortie/utils/database.dart';
import 'package:shortie/utils/font_style.dart';
import 'package:shortie/utils/socket_services.dart';
import 'package:shortie/custom/custom_format_chat_time.dart';
import 'package:shortie/custom/custom_format_audio_time.dart';

class ChatView extends GetView<ChatController> {
  const ChatView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.colorScaffold,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: AppColor.white,
          surfaceTintColor: AppColor.transparent,
          shadowColor: AppColor.black.withValues(alpha: 0.4),
          flexibleSpace: const ChatAppBarUi(),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              /// pagination loader
              GetBuilder<ChatController>(
                id: "onPagination",
                builder: (c) => Visibility(
                  visible: c.isPaginationLoading,
                  child: LinearProgressIndicator(color: AppColor.primary),
                ),
              ),

              /// chat list
              Expanded(
                child: Stack(
                  children: [
                    Image.asset(
                      AppAsset.icChatBackGround,
                      fit: BoxFit.cover,
                      width: Get.width,
                      height: Get.height,
                    ),
                    GetBuilder<ChatController>(
                      id: "onGetUserChats",
                      builder: (controller) {
                        if (controller.isLoading) {
                          return LoadingUi();
                        }

                        return Obx(() {
                          SocketServices.onChangeChats.value;

                          /// auto scroll after build
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            _scrollToBottom();
                          });

                          return SocketServices.userChats.isEmpty ? NoDataFoundUi(iconSize: 160, fontSize: 19) : _buildChatList();
                        });
                      },
                    ),
                  ],
                ),
              ),

              /// message input
              const MessageTextFieldUi(),
            ],
          ),

          /// audio recording ui
          Positioned(
            top: 20,
            child: GetBuilder<ChatController>(
              id: "onChangeAudioRecordingEvent",
              builder: (controller) => Visibility(
                visible: controller.isRecordingAudio,
                child: Container(
                  height: 40,
                  width: 110,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
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
                      const SizedBox(width: 5),
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

  /// ===============================
  /// CHAT LIST (REVERSE + STICKY)
  /// ===============================
  Widget _buildChatList() {
    Map<String, List<dynamic>> groupedMessages = {};

    for (var chat in SocketServices.userChats) {
      final key = _getDateLabel(chat.createdAt ?? DateTime.now().toString());
      groupedMessages.putIfAbsent(key, () => []);
      groupedMessages[key]!.add(chat);
    }

    final dateKeys = groupedMessages.keys.toList().reversed.toList();

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        controller.onUserScroll();
        return false;
      },
      child: CustomScrollView(
        controller: SocketServices.scrollController,
        // reverse: true,
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
      ),
    );
  }

  /// ===============================
  /// STICKY DATE HEADER (SHOW / HIDE)
  /// ===============================
  Widget _buildStickyDateHeader(String dateLabel) {
    return GetBuilder<ChatController>(
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
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  boxShadow: [BoxShadow(color: AppColor.black.withValues(alpha: 0.1), blurRadius: 2, offset: Offset(0, 1), spreadRadius: 0)],
                  color: AppColor.colorBorder.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  dateLabel,
                  style: AppFontStyle.styleW500(AppColor.black, 10),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// ===============================
  /// MESSAGE ITEM
  /// ===============================
  // Widget _buildChatMessage(dynamic chat) {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
  //     child: chat.messageType == 1
  //         ? chat.senderUserId == Database.loginUserId
  //         ? SenderMessageUi(
  //       message: chat.message ?? "",
  //       time: CustomFormatChatTime.convert(chat.createdAt ?? ""),
  //     )
  //         : ReceiverMessageUi(
  //       message: chat.message ?? "",
  //       time: CustomFormatChatTime.convert(chat.createdAt ?? ""),
  //     )
  //         : chat.messageType == 2
  //         ? chat.senderUserId == Database.loginUserId
  //         ? SenderImageUi(
  //       image: chat.image ?? "",
  //       time: CustomFormatChatTime.convert(chat.createdAt ?? ""),
  //       isBanned: chat.isChatMediaBanned ?? false,
  //     )
  //         : ReceiverImageUi(
  //       image: chat.image ?? "",
  //       time: CustomFormatChatTime.convert(chat.createdAt ?? ""),
  //       isBanned: chat.isChatMediaBanned ?? false,
  //     )
  //         : chat.messageType == 3
  //         ? chat.senderUserId == Database.loginUserId
  //         ? SenderAudioUi(
  //       id: chat.id ?? "",
  //       audio: chat.audio ?? "",
  //       time:
  //       CustomFormatChatTime.convert(chat.createdAt ?? ""),
  //     )
  //         : ReceiverAudioUi(
  //       id: chat.id ?? "",
  //       audio: chat.audio ?? "",
  //       time:
  //       CustomFormatChatTime.convert(chat.createdAt ?? ""),
  //     )
  //         : UploadAudioUi(),
  //   );
  // }
  Widget _buildChatMessage(dynamic chat) {
    final bool isSender = chat.senderUserId == Database.loginUserId;
    final String time = CustomFormatChatTime.convert(chat.createdAt ?? "");

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
      child: switch (chat.messageType) {
        1 => isSender ? SenderMessageUi(message: chat.message ?? "", time: time) : ReceiverMessageUi(message: chat.message ?? "", time: time),
        2 => isSender ? SenderImageUi(image: chat.image ?? "", time: time, isBanned: chat.isChatMediaBanned ?? false) : ReceiverImageUi(image: chat.image ?? "", time: time, isBanned: chat.isChatMediaBanned ?? false),
        3 => isSender ? SenderAudioUi(id: chat.id ?? "", audio: chat.audio ?? "", time: time) : ReceiverAudioUi(id: chat.id ?? "", audio: chat.audio ?? "", time: time),
        4 => StoryReactionUi(chat: chat, isSender: isSender, time: time), // ✅ Story Reaction
        5 => StoryReplyUi(chat: chat, isSender: isSender, time: time), // ✅ Story Reply
        _ => UploadAudioUi(),
      },
    );
  }

  /// ===============================
  /// DATE LABEL
  /// ===============================
  String _getDateLabel(String dateTimeString) {
    final messageDate = DateTime.parse(dateTimeString);
    final now = DateTime.now();

    final today = DateTime(now.year, now.month, now.day);
    final messageDay = DateTime(messageDate.year, messageDate.month, messageDate.day);

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

  /// ===============================
  /// AUTO SCROLL (REVERSE)
  /// ===============================
  void _scrollToBottom() {
    if (SocketServices.scrollController.hasClients) {
      SocketServices.scrollController.jumpTo(
        SocketServices.scrollController.position.maxScrollExtent,
      );
    }
  }
}
