import 'dart:developer';

import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_typedefs/rx_typedefs.dart';
import 'package:lottie/lottie.dart';
import 'package:shortie/custom/custom_format_audio_time.dart';
import 'package:shortie/custom/custom_format_chat_time.dart';
import 'package:shortie/google_ad/google_ad_interstitial.dart';
import 'package:shortie/google_ad/google_ad_services.dart';
import 'package:shortie/ui/loading_ui.dart';
import 'package:shortie/ui/preview_network_image_ui.dart';
import 'package:shortie/main.dart';
import 'package:shortie/pages/chat_page/controller/chat_controller.dart';
import 'package:shortie/ui/preview_profile_bottom_sheet_ui.dart';
import 'package:shortie/ui/report_bottom_sheet_ui.dart';
import 'package:shortie/utils/asset.dart';
import 'package:shortie/utils/color.dart';
import 'package:shortie/utils/enums.dart';
import 'package:shortie/utils/font_style.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shortie/utils/utils.dart';
import 'package:vibration/vibration.dart';

class ChatAppBarUi extends GetView<ChatController> {
  const ChatAppBarUi({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        color: AppColor.transparent,
        padding: EdgeInsets.symmetric(horizontal: 5),
        child: Center(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              GestureDetector(
                // <<< Code Start *** >>> Google Ad Code <<< ***
                onTap: () {
                  if (GoogleAdServices.isShowInterstitialAdChat) {
                    GoogleAdInterstitial.showAd(navigation: () => Get.back());
                  } else {
                    Get.back();
                  }
                },
                // *** >>> Google Ad Code <<< *** Code End >>>

                // onTap: () {
                //   Get.back();
                // },

                child: Container(
                  height: 50,
                  width: 50,
                  decoration: const BoxDecoration(
                    color: AppColor.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Center(child: Image.asset(AppAsset.icBack, width: 25)),
                ),
              ),
              2.width,
              GestureDetector(
                onTap: () {
                  if (controller.receiverUserId != "") {
                    PreviewProfileBottomSheetUi.show(
                      context: context,
                      userId: controller.receiverUserId,
                    );
                  }
                },
                child: Row(
                  children: [
                    Container(
                      height: 46,
                      width: 46,
                      clipBehavior: Clip.antiAlias,
                      decoration: const BoxDecoration(
                        color: AppColor.colorBorder,
                        shape: BoxShape.circle,
                      ),
                      child: Stack(
                        children: [
                          AspectRatio(
                            aspectRatio: 1,
                            child: Image.asset(AppAsset.icProfilePlaceHolder),
                          ),
                          AspectRatio(
                            aspectRatio: 1,
                            child: PreviewNetworkImageUi(image: controller.receiverImage),
                          ),
                          Visibility(
                            visible: controller.isProfileImageBanned,
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: Container(
                                clipBehavior: Clip.antiAlias,
                                decoration: BoxDecoration(shape: BoxShape.circle),
                                child: BlurryContainer(
                                  blur: 3,
                                  borderRadius: BorderRadius.circular(50),
                                  color: AppColor.black.withValues(alpha: 0.3),
                                  child: Offstage(),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    10.width,
                    Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        SizedBox(
                          width: Get.width / 2,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Flexible(
                                fit: FlexFit.loose,
                                child: Text(
                                  controller.receiverName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppFontStyle.styleW700(AppColor.black, 16.5),
                                ).paddingOnly(bottom: 16),
                              ),
                              Visibility(
                                visible: controller.receiverIsBlueTik,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 2, bottom: 12),
                                  child: Image.asset(AppAsset.icBlueTick, width: 20),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: Get.width / 2,
                          child: Text(
                            controller.receiverUserName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppFontStyle.styleW500(AppColor.coloGreyText, 12),
                          ).paddingOnly(top: 22),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Spacer(),
              GestureDetector(
                onTap: () => ReportBottomSheetUi.show(context: context, eventId: '', eventType: 2),
                child: Container(
                  width: 35,
                  height: 35,
                  margin: const EdgeInsets.only(right: 5),
                  child: Icon(
                    Icons.more_vert_rounded,
                    color: AppColor.black.withValues(alpha: 0.7),
                    size: 26,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MessageTextFieldUi extends GetView<ChatController> {
  const MessageTextFieldUi({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              height: 50,
              padding: const EdgeInsets.only(left: 20),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColor.colorTextGrey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: AppColor.colorTextGrey.withValues(alpha: 0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: GetBuilder<ChatController>(
                      id: "onChangeAudioRecordingEvent",
                      builder: (controller) => TextFormField(
                        controller: controller.messageController,
                        cursorColor: AppColor.colorTextGrey,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.only(bottom: 2),
                          hintText:
                              controller.isRecordingAudio ? CustomFormatAudioTime.convert(controller.countTime) : EnumLocal.txtTypeSomething.name.tr,
                          // hintText: controller.isRecordingAudio ? EnumLocal.txtAudioRecording.name.tr : EnumLocal.txtTypeSomething.name.tr,
                          hintStyle: AppFontStyle.styleW400(controller.isRecordingAudio ? AppColor.primary : AppColor.coloGreyText, 16),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      15.width,
                      GestureDetector(
                        onTap: () {
                          Vibration.vibrate(duration: 50, amplitude: 128);
                          Utils.showToast(EnumLocal.txtLongPressToEnableAudioRecording.name.tr);
                        },
                        onLongPressStart: (details) {
                          if (controller.isSendingAudioFile.value == false) {
                            Vibration.vibrate(duration: 50, amplitude: 128);
                            controller.onLongPressStartMic();
                          }
                        },
                        onLongPressEnd: (details) {
                          if (controller.isSendingAudioFile.value == false) {
                            Vibration.vibrate(duration: 50, amplitude: 128);
                            controller.onLongPressEndMic();
                          }
                        },
                        child: Container(
                          height: 45,
                          width: 45,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColor.transparent,
                          ),
                          child: Image.asset(
                            AppAsset.icMicOn,
                            color: AppColor.coloGreyText.withValues(alpha: 0.6),
                            width: 25,
                            height: 25,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => controller.onClickImage(context),
                        child: Container(
                          height: 45,
                          width: 45,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColor.transparent,
                          ),
                          child: Image.asset(
                            height: 23,
                            width: 23,
                            AppAsset.icGallery,
                            color: AppColor.coloGreyText.withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                      10.width,
                    ],
                  )
                ],
              ),
            ),
          ),
          15.width,
          GestureDetector(
            onTap: controller.onClickSend,
            child: Container(
              height: 50,
              width: 50,
              decoration: const BoxDecoration(
                gradient: AppColor.primaryLinearGradient,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Image.asset(
                  height: 28,
                  width: 28,
                  AppAsset.icSendMessage,
                  color: AppColor.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SenderMessageUi extends StatelessWidget {
  const SenderMessageUi({super.key, required this.message, required this.time});

  final String message;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        SizedBox(
          width: Get.width / 1.6,
          child: Stack(
            alignment: Alignment.centerRight,
            children: [
              Container(
                padding: const EdgeInsets.only(left: 12, right: 38, top: 6, bottom: 18),
                decoration: const BoxDecoration(
                  gradient: AppColor.primaryLinearGradient,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                  ),
                ),
                child: Text(
                  message,
                  style: AppFontStyle.styleW400(AppColor.white, 16),
                ),
              ),
              Positioned(
                bottom: 3,
                right: 6,
                child: Text(
                  time,
                  style: AppFontStyle.styleW500(AppColor.white, 8),
                ),
              ),
            ],
          ),
        ).paddingOnly(bottom: 15),
      ],
    );
  }
}

class ReceiverMessageUi extends StatelessWidget {
  const ReceiverMessageUi({super.key, required this.message, required this.time});

  final String message;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: Get.width / 1.6,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: AppColor.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.only(left: 12, right: 38, top: 6, bottom: 18),
                    decoration: BoxDecoration(
                      color: Color(0xFFEAECF8),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                        bottomRight: Radius.circular(10),
                      ),
                    ),
                    child: Text(
                      message,
                      style: AppFontStyle.styleW400(AppColor.black, 16),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 3,
                  right: 10,
                  child: Text(
                    time,
                    style: AppFontStyle.styleW500(AppColor.black, 8),
                  ),
                ),
              ],
            ),
          ),
        ).paddingOnly(bottom: 15),
      ],
    );
  }
}

class SenderImageUi extends StatelessWidget {
  const SenderImageUi({super.key, required this.image, required this.time, required this.isBanned});

  final String image;
  final String time;
  final bool isBanned;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        GestureDetector(
          onTap: () {
            log("onTap");
            Get.to(PreviewChatImageUi(
              image: image,
              time: time,
              isBanned: isBanned,
            ));
          },
          child: Container(
            height: 250,
            width: Get.width / 2,
            margin: EdgeInsets.only(bottom: 15),
            decoration: BoxDecoration(
              gradient: AppColor.primaryLinearGradient,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
                bottomLeft: Radius.circular(10),
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: 230,
                  width: Get.width / 2,
                  margin: EdgeInsets.only(left: 5, right: 5, top: 5, bottom: 15),
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: AppColor.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    alignment: Alignment.center,
                    children: [
                      Center(child: Image.asset(AppAsset.icImagePlaceHolder, width: 100)),
                      Container(
                        clipBehavior: Clip.antiAlias,
                        height: 230,
                        width: Get.width / 2,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: PreviewNetworkImageUi(image: image),
                      ),
                      Visibility(
                        visible: isBanned,
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: Container(
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(),
                            child: BlurryContainer(
                              blur: 8,
                              borderRadius: BorderRadius.zero,
                              color: AppColor.black.withValues(alpha: 0.3),
                              child: Offstage(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 3,
                  right: 6,
                  child: Text(
                    time,
                    style: AppFontStyle.styleW500(AppColor.white, 8),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class ReceiverImageUi extends StatelessWidget {
  const ReceiverImageUi({super.key, required this.image, required this.time, required this.isBanned});

  final String image;
  final String time;
  final bool isBanned;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            log("message>>>>>>$image");
            Get.to(PreviewChatImageUi(image: image, time: time, isBanned: isBanned));
          },
          child: Container(
            margin: EdgeInsets.only(bottom: 15),
            decoration: BoxDecoration(
              color: AppColor.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
            ),
            child: Container(
              height: 250,
              width: Get.width / 2,
              decoration: BoxDecoration(
                color: Color(0xFFEAECF8),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    height: 230,
                    width: Get.width / 2,
                    margin: EdgeInsets.only(left: 5, right: 5, top: 5, bottom: 15),
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: AppColor.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      alignment: Alignment.center,
                      children: [
                        Center(child: Image.asset(AppAsset.icImagePlaceHolder, width: 100)),
                        Container(
                          clipBehavior: Clip.antiAlias,
                          height: 230,
                          width: Get.width / 2,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: PreviewNetworkImageUi(image: image),
                        ),
                        Visibility(
                          visible: isBanned,
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: Container(
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(),
                              child: BlurryContainer(
                                blur: 8,
                                borderRadius: BorderRadius.zero,
                                color: AppColor.black.withValues(alpha: 0.3),
                                child: Offstage(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 3,
                    right: 8,
                    child: Text(
                      time,
                      style: AppFontStyle.styleW500(AppColor.black, 8),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ReceiverAudioUi extends StatefulWidget {
  const ReceiverAudioUi({super.key, required this.id, required this.audio, required this.time});

  final String id;
  final String audio;
  final String time;

  @override
  State<ReceiverAudioUi> createState() => _ReceiverAudioUiState();
}

class _ReceiverAudioUiState extends State<ReceiverAudioUi> {
  AudioPlayer audioPlayer = AudioPlayer();

  RxBool isPlaying = false.obs;
  RxBool isLoading = false.obs;

  RxInt audioDuration = 0.obs;
  RxInt audioCurrentDuration = 0.obs;

  final controller = Get.find<ChatController>();

  @override
  void initState() {
    onInit();
    super.initState();
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  void onInit() async {
    try {
      isLoading.value = true;
      await audioPlayer.play(UrlSource(widget.audio));
      onPauseAudio();

      final Duration? duration = await audioPlayer.getDuration();

      if (duration != null) {
        audioDuration.value = duration.inSeconds;
        Utils.showLog("Audio Duration => ${audioDuration.value}");
        isLoading.value = false;
      }

      audioPlayer.onPositionChanged.listen((event) {
        audioCurrentDuration.value = event.inSeconds;
        if (controller.currentPlayAudioId != widget.id && isPlaying.value) {
          onPauseAudio();
        }
      });
      audioPlayer.onPlayerComplete.listen(
        (event) async {
          audioCurrentDuration.value = 0;
          onPauseAudio();
          await audioPlayer.play(UrlSource(widget.audio));
          onPauseAudio();
        },
      );
    } catch (e) {
      Utils.showLog("Audio Play Failed !! => $e");
    }
  }

  void onPlayAudio() async {
    isPlaying.value = true;

    audioPlayer.resume();
    controller.currentPlayAudioId = widget.id;
  }

  void onPauseAudio() {
    isPlaying.value = false;
    audioPlayer.pause();

    // audioPlayer.source
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(bottom: 15),
          decoration: BoxDecoration(
            color: AppColor.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(5),
              topRight: Radius.circular(5),
              bottomRight: Radius.circular(5),
            ),
          ),
          child: Container(
            height: 75,
            width: Get.width / 1.6,
            decoration: BoxDecoration(
              color: AppColor.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(5),
                topRight: Radius.circular(5),
                bottomRight: Radius.circular(5),
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: 75,
                  width: Get.width / 1.6,
                  margin: EdgeInsets.only(left: 5, right: 5, top: 5, bottom: 15),
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: AppColor.colorBorder.withValues(alpha: 0.6),
                  ),
                  child: Row(
                    children: [
                      Obx(
                        () => isLoading.value
                            ? Padding(
                                padding: EdgeInsets.only(right: 2.5, top: 5, bottom: 5),
                                child: LoadingUi(size: 30),
                              )
                            : GestureDetector(
                                onTap: () => isPlaying.value ? onPauseAudio() : onPlayAudio(),
                                child: Image.asset(isPlaying.value ? AppAsset.icPause : AppAsset.icPlay, width: 30),
                              ),
                      ),
                      5.width,
                      Expanded(
                        child: Obx(
                          () => SliderTheme(
                            data: SliderThemeData(
                              overlayShape: SliderComponentShape.noOverlay,
                              activeTrackColor: AppColor.colorTabBar,
                              thumbColor: AppColor.colorTabBar,
                              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 10),
                              trackHeight: 5,
                            ),
                            child: Slider(
                              min: 0,
                              max: audioDuration.value.toDouble(),
                              value: audioCurrentDuration.value.toDouble(),
                              onChanged: (value) {
                                audioPlayer.seek(Duration(seconds: value.toInt()));
                              },
                            ),
                          ),
                        ),
                      ),
                      3.width,
                      Container(
                        height: 40,
                        width: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColor.primary,
                        ),
                        child: Image.asset(
                          AppAsset.icMicOn,
                          width: 20,
                          color: AppColor.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 20,
                  right: 70,
                  child: Obx(
                    () => Text(
                      CustomFormatAudioTime.convert(audioCurrentDuration.value),
                      style: AppFontStyle.styleW500(AppColor.primary, 9),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 3,
                  right: 8,
                  child: Text(
                    widget.time,
                    style: AppFontStyle.styleW500(AppColor.black, 8),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class SenderAudioUi extends StatefulWidget {
  const SenderAudioUi({super.key, required this.id, required this.audio, required this.time});

  final String id;
  final String audio;
  final String time;

  @override
  State<SenderAudioUi> createState() => _SenderAudioUiState();
}

class _SenderAudioUiState extends State<SenderAudioUi> {
  AudioPlayer audioPlayer = AudioPlayer();

  RxBool isPlaying = false.obs;
  RxBool isLoading = false.obs;

  RxInt audioDuration = 0.obs;
  RxInt audioCurrentDuration = 0.obs;

  final controller = Get.find<ChatController>();

  @override
  void initState() {
    onInit();
    super.initState();
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  void onInit() async {
    Utils.showLog("Audio Initializing...  ${widget.audio}");

    isLoading.value = true;
    audioPlayer.audioCache.clearAll();
    await audioPlayer.play(UrlSource(widget.audio));

    onPauseAudio();

    final Duration? duration = await audioPlayer.getDuration();

    if (duration != null) {
      audioDuration.value = duration.inSeconds;
      Utils.showLog("Audio Duration => ${audioDuration.value}");
      isLoading.value = false;
    }

    audioPlayer.onPositionChanged.listen((event) {
      audioCurrentDuration.value = event.inSeconds;

      if (controller.currentPlayAudioId != widget.id && isPlaying.value) {
        onPauseAudio();
      }
    });

    audioPlayer.onPlayerComplete.listen(
      (event) async {
        audioCurrentDuration.value = 0;
        onPauseAudio();
        await audioPlayer.play(UrlSource(widget.audio));
        onPauseAudio();
      },
    );
  }

  void onPlayAudio() async {
    isPlaying.value = true;
    audioPlayer.resume();
    controller.currentPlayAudioId = widget.id;
  }

  void onPauseAudio() {
    isPlaying.value = false;
    audioPlayer.pause();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          height: 75,
          width: Get.width / 1.6,
          margin: EdgeInsets.only(bottom: 15),
          decoration: BoxDecoration(
            gradient: AppColor.primaryLinearGradient,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(5),
              topRight: Radius.circular(5),
              bottomLeft: Radius.circular(5),
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                height: 75,
                width: Get.width / 1.6,
                margin: EdgeInsets.only(left: 6, right: 6, top: 6, bottom: 15),
                padding: EdgeInsets.symmetric(horizontal: 10),
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: AppColor.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(0),
                ),
                child: Row(
                  children: [
                    Obx(
                      () => isLoading.value
                          ? Padding(
                              padding: EdgeInsets.only(right: 2.5, top: 5, bottom: 5),
                              child: LoadingUi(size: 30),
                            )
                          : GestureDetector(
                              onTap: () => isPlaying.value ? onPauseAudio() : onPlayAudio(),
                              child: Image.asset(isPlaying.value ? AppAsset.icPause : AppAsset.icPlay, width: 30),
                            ),
                    ),
                    5.width,
                    Expanded(
                      child: Obx(
                        () => SliderTheme(
                          data: SliderThemeData(
                            overlayShape: SliderComponentShape.noOverlay,
                            activeTrackColor: AppColor.colorTabBar,
                            thumbColor: AppColor.colorTabBar,
                            thumbShape: RoundSliderThumbShape(enabledThumbRadius: 10),
                            trackHeight: 5,
                          ),
                          child: Slider(
                            min: 0,
                            max: audioDuration.value.toDouble(),
                            value: audioCurrentDuration.value.toDouble(),
                            onChanged: (value) {
                              audioPlayer.seek(Duration(seconds: value.toInt()));
                            },
                          ),
                        ),
                      ),
                    ),
                    3.width,
                    Container(
                      height: 40,
                      width: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColor.primary,
                      ),
                      child: Image.asset(
                        AppAsset.icMicOn,
                        width: 20,
                        color: AppColor.white,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 20,
                right: 70,
                child: Obx(
                  () => Text(
                    CustomFormatAudioTime.convert(audioCurrentDuration.value),
                    style: AppFontStyle.styleW500(AppColor.primary, 9),
                  ),
                ),
              ),
              Positioned(
                bottom: 3,
                right: 8,
                child: Text(
                  widget.time,
                  style: AppFontStyle.styleW500(AppColor.white, 8),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class PreviewChatImageUi extends GetView<ChatController> {
  PreviewChatImageUi({super.key, required this.image, required this.isBanned, required this.time});

  final String image;
  final String time;
  final bool isBanned;
  double dragStartPosition = 0;
  void onHandleDragStart({required DragStartDetails details}) {
    try {
      dragStartPosition = details.globalPosition.dy;
    } catch (e) {
      Utils.showLog("onHandleDragStart Error => $e");
    }
  }

  void onHandleDragUpdate({required DragUpdateDetails details, required BuildContext context}) {
    try {
      final currentPosition = details.globalPosition.dy;
      final delta = currentPosition - dragStartPosition;

      if (delta > 20) {
        Get.back();
      } else if (delta < -20) {
        Get.back();
      }
    } catch (e) {
      Utils.showLog("onHandleDragUpdate Error => $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    Future.delayed(
      Duration(milliseconds: 200),
      () {
        SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle(
            systemNavigationBarColor: AppColor.black,
            statusBarColor: AppColor.black,
            statusBarBrightness: Brightness.light,
          ),
        );
      },
    );
    return Scaffold(
      backgroundColor: AppColor.black,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: AppColor.black,
          surfaceTintColor: AppColor.transparent,
          shadowColor: AppColor.black.withValues(alpha: 0.4),
          flexibleSpace: SafeArea(
            bottom: false,
            child: Container(
              color: AppColor.transparent,
              padding: EdgeInsets.symmetric(horizontal: 5),
              child: Center(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        height: 50,
                        width: 50,
                        decoration: const BoxDecoration(
                          color: AppColor.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: Center(child: Image.asset(AppAsset.icBack, color: AppColor.white, width: 25)),
                      ),
                    ),
                    2.width,
                    Container(
                      height: 46,
                      width: 46,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        color: AppColor.colorBorder,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColor.white,
                            spreadRadius: 0.5,
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          AspectRatio(
                            aspectRatio: 1,
                            child: Image.asset(AppAsset.icProfilePlaceHolder),
                          ),
                          AspectRatio(
                            aspectRatio: 1,
                            child: PreviewNetworkImageUi(image: controller.receiverImage),
                          ),
                          Visibility(
                            visible: isBanned,
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: Container(
                                clipBehavior: Clip.antiAlias,
                                decoration: BoxDecoration(),
                                child: BlurryContainer(
                                  blur: 3,
                                  borderRadius: BorderRadius.zero,
                                  color: AppColor.black.withValues(alpha: 0.3),
                                  child: Offstage(),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    10.width,
                    Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        Text(
                          controller.receiverName,
                          style: AppFontStyle.styleW700(AppColor.white, 16.5),
                        ).paddingOnly(bottom: 16),
                        Text(
                          controller.receiverUserName,
                          style: AppFontStyle.styleW500(AppColor.white.withValues(alpha: 0.8), 12),
                        ).paddingOnly(top: 22),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () {
          log("onTap");
        },
        onVerticalDragStart: (details) => onHandleDragStart(details: details),
        onVerticalDragUpdate: (details) => onHandleDragUpdate(details: details, context: context),
        child: Container(
          height: Get.height,
          width: Get.width,
          child: Stack(
            fit: StackFit.expand,
            alignment: Alignment.center,
            children: [
              // Image.asset(AppAsset.icImagePlaceHolder, height: Get.width / 2),
              Center(child: PreviewNetworkImageUi(image: image)),
              Visibility(
                visible: isBanned,
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    height: Get.height,
                    width: Get.width,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(),
                    child: BlurryContainer(
                      blur: 12,
                      borderRadius: BorderRadius.zero,
                      color: AppColor.black.withValues(alpha: 0.3),
                      child: Offstage(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class UploadAudioUi extends StatelessWidget {
  const UploadAudioUi({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          height: 75,
          width: Get.width / 1.6,
          margin: EdgeInsets.only(bottom: 15),
          decoration: BoxDecoration(
            gradient: AppColor.primaryLinearGradient,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(5),
              topRight: Radius.circular(5),
              bottomLeft: Radius.circular(5),
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                height: 75,
                width: Get.width / 1.6,
                margin: EdgeInsets.only(left: 6, right: 6, top: 6, bottom: 15),
                padding: EdgeInsets.symmetric(horizontal: 10),
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: AppColor.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(0),
                ),
                child: Row(
                  children: [
                    Lottie.asset(AppAsset.lottieUpload, width: 35),
                    5.width,
                    Expanded(
                      child: SliderTheme(
                        data: SliderThemeData(
                          overlayShape: SliderComponentShape.noOverlay,
                          activeTrackColor: AppColor.colorTabBar,
                          thumbColor: AppColor.colorTabBar,
                          thumbShape: RoundSliderThumbShape(enabledThumbRadius: 10),
                          trackHeight: 5,
                        ),
                        child: Slider(
                          min: 0,
                          max: 10,
                          value: 0,
                          onChanged: (value) {},
                        ),
                      ),
                    ),
                    3.width,
                    Container(
                      height: 40,
                      width: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColor.primary,
                      ),
                      child: Image.asset(
                        AppAsset.icMicOn,
                        width: 20,
                        color: AppColor.white,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 20,
                right: 70,
                child: Text(
                  CustomFormatAudioTime.convert(0),
                  style: AppFontStyle.styleW500(AppColor.primary, 9),
                ),
              ),
              Positioned(
                bottom: 3,
                right: 8,
                child: Text(
                  CustomFormatChatTime.convert(DateTime.now().toString()),
                  style: AppFontStyle.styleW500(AppColor.white, 8),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class SenderStoryReaction extends StatelessWidget {
  const SenderStoryReaction({super.key, required this.image, required this.time, required this.reaction, required this.callback});

  final String image;
  final String reaction;
  final String time;
  final Callback callback;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        GestureDetector(
          onTap: callback,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "Reacted to your story",
                style: AppFontStyle.styleW500(AppColor.primary, 12),
              ),
              5.height,
              image.trim().isEmpty
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Story unavailable",
                          style: AppFontStyle.styleW500(AppColor.coloGreyText, 12),
                        ),
                        5.width,
                        Container(
                          height: 20,
                          width: 3,
                          decoration: BoxDecoration(
                            color: AppColor.coloGreyText.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                      ],
                    )
                  : Container(
                      height: 210,
                      width: Get.width / 3,
                      margin: EdgeInsets.only(bottom: 15),
                      decoration: BoxDecoration(
                        gradient: AppColor.primaryLinearGradient,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10),
                          bottomLeft: Radius.circular(10),
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            height: 180,
                            width: Get.width / 3,
                            margin: EdgeInsets.only(left: 5, right: 5, top: 5, bottom: 15),
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(
                              color: AppColor.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Stack(
                              fit: StackFit.expand,
                              alignment: Alignment.center,
                              children: [
                                Center(child: Image.asset(AppAsset.icImagePlaceHolder, width: 100)),
                                Container(
                                  clipBehavior: Clip.antiAlias,
                                  height: 180,
                                  width: Get.width / 3,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: PreviewNetworkImageUi(image: image),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            bottom: 3,
                            right: 6,
                            child: Text(
                              time,
                              style: AppFontStyle.styleW500(AppColor.white, 8),
                            ),
                          ),
                          Positioned(
                            left: -25,
                            bottom: 0,
                            child: SizedBox(
                              height: 80,
                              width: 80,
                              child: PreviewPostImageWidget(image: reaction),
                            ),
                          ),
                        ],
                      ),
                    ),
              Visibility(
                visible: image.trim().isEmpty,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: SizedBox(
                    height: 80,
                    width: 80,
                    child: PreviewPostImageWidget(image: reaction),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ReceiverStoryReaction extends StatelessWidget {
  const ReceiverStoryReaction({super.key, required this.image, required this.time, required this.reaction, required this.callback});

  final String image;
  final String reaction;
  final String time;
  final Callback callback;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: callback,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Reacted to your story",
                style: AppFontStyle.styleW500(AppColor.black, 12),
              ),
              5.height,
              image.trim().isEmpty
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          height: 20,
                          width: 3,
                          decoration: BoxDecoration(
                            color: AppColor.coloGreyText.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                        5.width,
                        Text(
                          "Story unavailable",
                          style: AppFontStyle.styleW500(AppColor.coloGreyText, 12),
                        ),
                      ],
                    )
                  : Container(
                      margin: EdgeInsets.only(bottom: 15),
                      decoration: BoxDecoration(
                        color: AppColor.white,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10),
                          bottomRight: Radius.circular(10),
                        ),
                      ),
                      child: Container(
                        height: 210,
                        width: Get.width / 3,
                        decoration: BoxDecoration(
                          color: Color(0xFFEAECF8),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                            bottomRight: Radius.circular(10),
                          ),
                        ),
                        child: Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.center,
                          children: [
                            Container(
                              height: 180,
                              width: Get.width / 3,
                              margin: EdgeInsets.only(left: 5, right: 5, top: 5, bottom: 15),
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(
                                color: AppColor.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Stack(
                                fit: StackFit.expand,
                                alignment: Alignment.center,
                                children: [
                                  Center(child: Image.asset(AppAsset.icImagePlaceHolder, width: 100)),
                                  Container(
                                    clipBehavior: Clip.antiAlias,
                                    height: 180,
                                    width: Get.width / 3,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: PreviewNetworkImageUi(image: image),
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              bottom: 3,
                              right: 8,
                              child: Text(
                                time,
                                style: AppFontStyle.styleW500(AppColor.black, 8),
                              ),
                            ),
                            Positioned(
                              right: -25,
                              bottom: 20,
                              child: SizedBox(
                                height: 80,
                                width: 80,
                                child: PreviewPostImageWidget(image: reaction),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
              Visibility(
                visible: image.trim().isEmpty,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: SizedBox(
                    height: 80,
                    width: 80,
                    child: PreviewPostImageWidget(image: reaction),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class SenderStoryReply extends StatelessWidget {
  const SenderStoryReply({super.key, required this.image, required this.time, required this.message, required this.callback});

  final String image;
  final String message;
  final String time;
  final Callback callback;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        SizedBox(
          width: Get.width / 1.6,
          child: Align(
            alignment: Alignment.centerRight,
            child: IntrinsicHeight(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: callback,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "Replied to your story",
                            style: AppFontStyle.styleW500(AppColor.primary, 12),
                          ),
                          5.height,
                          image.trim().isEmpty
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Story unavailable",
                                      style: AppFontStyle.styleW500(AppColor.coloGreyText, 12),
                                    ),
                                    5.width,
                                    Container(
                                      height: 20,
                                      width: 3,
                                      decoration: BoxDecoration(
                                        color: AppColor.coloGreyText.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(100),
                                      ),
                                    ),
                                  ],
                                )
                              : Container(
                                  height: 210,
                                  width: Get.width / 3,
                                  decoration: BoxDecoration(
                                    gradient: AppColor.primaryLinearGradient,
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      topRight: Radius.circular(10),
                                      bottomLeft: Radius.circular(10),
                                    ),
                                  ),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    clipBehavior: Clip.none,
                                    children: [
                                      Container(
                                        height: 180,
                                        width: Get.width / 3,
                                        margin: EdgeInsets.only(left: 5, right: 5, top: 5, bottom: 15),
                                        clipBehavior: Clip.antiAlias,
                                        decoration: BoxDecoration(
                                          color: AppColor.white,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Stack(
                                          fit: StackFit.expand,
                                          alignment: Alignment.center,
                                          children: [
                                            Center(child: Image.asset(AppAsset.icImagePlaceHolder, width: 100)),
                                            Container(
                                              clipBehavior: Clip.antiAlias,
                                              height: 180,
                                              width: Get.width / 3,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: PreviewNetworkImageUi(image: image),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 3,
                                        right: 6,
                                        child: Text(
                                          time,
                                          style: AppFontStyle.styleW500(AppColor.white, 8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                          5.height,
                          Container(
                            padding: const EdgeInsets.only(left: 12, right: 12, top: 6, bottom: 5),
                            decoration: BoxDecoration(
                              color: AppColor.coloGreyText.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10),
                                bottomLeft: Radius.circular(10),
                              ),
                            ),
                            child: Text(
                              message,
                              style: AppFontStyle.styleW400(AppColor.black, 16),
                            ),
                          ),
                          15.height,
                        ],
                      ),
                    ),
                  ),
                  Visibility(
                    visible: image.trim().isNotEmpty,
                    child: Container(
                      width: 5,
                      margin: EdgeInsets.only(bottom: 15, top: 20, left: 8),
                      decoration: BoxDecoration(
                        color: AppColor.coloGreyText.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ReceiverStoryReply extends StatelessWidget {
  const ReceiverStoryReply({super.key, required this.image, required this.time, required this.message, required this.callback});

  final String image;
  final String message;
  final String time;
  final Callback callback;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: Get.width / 1.6,
          child: Align(
            alignment: Alignment.centerRight,
            child: IntrinsicHeight(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Visibility(
                    visible: image.trim().isNotEmpty,
                    child: Container(
                      width: 5,
                      margin: EdgeInsets.only(bottom: 15, top: 20, right: 8),
                      decoration: BoxDecoration(
                        color: Color(0xFFEAECF8),
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: callback,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Replied to your story",
                            style: AppFontStyle.styleW500(AppColor.black, 12),
                          ),
                          5.height,
                          image.trim().isEmpty
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      height: 20,
                                      width: 3,
                                      decoration: BoxDecoration(
                                        color: AppColor.coloGreyText.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(100),
                                      ),
                                    ),
                                    5.width,
                                    Text(
                                      "Story unavailable",
                                      style: AppFontStyle.styleW500(AppColor.coloGreyText, 12),
                                    ),
                                  ],
                                )
                              : Container(
                                  decoration: BoxDecoration(
                                    color: AppColor.white,
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      topRight: Radius.circular(10),
                                      bottomRight: Radius.circular(10),
                                    ),
                                  ),
                                  child: Container(
                                    height: 210,
                                    width: Get.width / 3,
                                    decoration: BoxDecoration(
                                      color: AppColor.white,
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(10),
                                        topRight: Radius.circular(10),
                                        bottomRight: Radius.circular(10),
                                      ),
                                    ),
                                    child: Stack(
                                      clipBehavior: Clip.none,
                                      alignment: Alignment.center,
                                      children: [
                                        Container(
                                          height: 180,
                                          width: Get.width / 3,
                                          margin: EdgeInsets.only(left: 5, right: 5, top: 5, bottom: 15),
                                          clipBehavior: Clip.antiAlias,
                                          decoration: BoxDecoration(
                                            color: AppColor.white,
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Stack(
                                            fit: StackFit.expand,
                                            alignment: Alignment.center,
                                            children: [
                                              Center(child: Image.asset(AppAsset.icImagePlaceHolder, width: 100)),
                                              Container(
                                                clipBehavior: Clip.antiAlias,
                                                height: 180,
                                                width: Get.width / 3,
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                                child: PreviewNetworkImageUi(image: image),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Positioned(
                                          bottom: 3,
                                          right: 8,
                                          child: Text(
                                            time,
                                            style: AppFontStyle.styleW500(AppColor.black, 8),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                          5.height,
                          Container(
                            decoration: BoxDecoration(
                              color: AppColor.white,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10),
                                bottomRight: Radius.circular(10),
                              ),
                            ),
                            child: Container(
                              padding: const EdgeInsets.only(left: 12, right: 12, top: 6, bottom: 6),
                              decoration: BoxDecoration(
                                color: Color(0xFFEAECF8),
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  topRight: Radius.circular(10),
                                  bottomRight: Radius.circular(10),
                                ),
                              ),
                              child: Text(
                                message,
                                style: AppFontStyle.styleW400(AppColor.black, 16),
                              ),
                            ),
                          ),
                          15.height,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
// story_reaction_ui.dart

class StoryReactionUi extends StatelessWidget {
  final dynamic chat;
  final bool isSender;
  final String time;

  const StoryReactionUi({
    super.key,
    required this.chat,
    required this.isSender,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    final storyImage = chat.storyId?.mediaImageUrl ?? "";
    final storyOwnerName = chat.storyOwnerId?.name ?? "";
    final reactionGif = chat.reaction ?? "";

    return Align(
      alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          /// 🔹 Context label
          Padding(
            padding: const EdgeInsets.only(bottom: 4, left: 4, right: 4),
            child: Text(
              isSender ? "You reacted to ${storyOwnerName}'s story" : "$storyOwnerName reacted to your story",
              style: AppFontStyle.styleW400(AppColor.colorGreyDarkText, 11),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          /// 🔹 Main container
          Container(
            constraints: BoxConstraints(maxWidth: Get.width * 0.65),
            decoration: BoxDecoration(
              color: isSender ? AppColor.primary.withValues(alpha: 0.1) : AppColor.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isSender ? 16 : 4),
                bottomRight: Radius.circular(isSender ? 4 : 16),
              ),
              border: Border.all(
                color: AppColor.colorBorderGrey.withValues(alpha: 0.5),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// 🔹 Story preview
                if (storyImage.isNotEmpty)
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CachedNetworkImage(
                          imageUrl: storyImage,
                          height: 160,
                          width: Get.width * 0.65,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                            height: 160,
                            color: AppColor.colorTextGrey.withValues(alpha: 0.1),
                          ),
                          errorWidget: (_, __, ___) => Container(
                            height: 160,
                            color: AppColor.colorTextGrey.withValues(alpha: 0.1),
                            child: const Icon(Icons.image_not_supported_outlined),
                          ),
                        ),

                        /// Blur overlay
                        Container(
                          height: 160,
                          width: Get.width * 0.65,
                          color: AppColor.black.withValues(alpha: 0.25),
                        ),

                        /// Reaction GIF
                        if (reactionGif.isNotEmpty)
                          CachedNetworkImage(
                            imageUrl: reactionGif,
                            height: 60,
                            width: 60,
                          ),
                      ],
                    ),
                  ),

                /// 🔹 Time
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Spacer(),
                      Text(
                        time,
                        style: AppFontStyle.styleW400(
                          AppColor.colorGreyDarkText.withValues(alpha: 0.7),
                          10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class StoryReplyUi extends StatelessWidget {
  final dynamic chat;
  final bool isSender;
  final String time;

  const StoryReplyUi({
    super.key,
    required this.chat,
    required this.isSender,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    final storyImage = chat.storyId?.mediaImageUrl ?? "";
    final storyOwnerName = chat.storyOwnerId?.name ?? "";
    final replyMessage = chat.message ?? "";

    return Align(
      alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          /// 🔹 Context label
          Padding(
            padding: const EdgeInsets.only(bottom: 4, left: 4, right: 4),
            child: Text(
              isSender ? "You replied to ${storyOwnerName}'s story" : "$storyOwnerName replied to your story",
              style: AppFontStyle.styleW400(AppColor.colorGreyDarkText, 11),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          /// 🔹 Main container
          Container(
            constraints: BoxConstraints(maxWidth: Get.width * 0.65),
            decoration: BoxDecoration(
              color: isSender ? AppColor.primary.withValues(alpha: 0.1) : AppColor.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isSender ? 16 : 4),
                bottomRight: Radius.circular(isSender ? 4 : 16),
              ),
              border: Border.all(
                color: AppColor.colorBorderGrey.withValues(alpha: 0.5),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// 🔹 Story preview (small)
                if (storyImage.isNotEmpty)
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: storyImage,
                      height: 120,
                      width: Get.width * 0.65,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        height: 120,
                        color: AppColor.colorTextGrey.withValues(alpha: 0.1),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        height: 120,
                        color: AppColor.colorTextGrey.withValues(alpha: 0.1),
                      ),
                    ),
                  ),

                /// 🔹 Reply message
                if (replyMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                    child: Text(
                      replyMessage,
                      style: AppFontStyle.styleW500(AppColor.black, 14),
                    ),
                  ),

                /// 🔹 Time
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 10, 8),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      time,
                      style: AppFontStyle.styleW400(
                        AppColor.colorGreyDarkText.withValues(alpha: 0.7),
                        10,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
