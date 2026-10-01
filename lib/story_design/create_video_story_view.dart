import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:chewie/chewie.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shortie/custom/custom_icon_button.dart';
import 'package:shortie/main.dart';
import 'package:shortie/story_design/add_story_controller.dart';
import 'package:shortie/story_design/add_story_select_music_bottomsheet.dart';
import 'package:shortie/ui/app_button_ui.dart';
import 'package:shortie/ui/loading_ui.dart';
import 'package:shortie/utils/asset.dart';
import 'package:shortie/utils/color.dart';
import 'package:shortie/utils/enums.dart';
import 'package:shortie/utils/font_style.dart';
import 'package:shortie/utils/utils.dart';
import 'package:video_player/video_player.dart';

import '../pages/story_page/widget/upload_story_process.dart';

class CreateVideoStoryView extends StatefulWidget {
  String videoUrl = "";
  String videoImage = "";
  int videoTime = 0;
  CreateVideoStoryView({
    super.key,
    required this.videoUrl,
    required this.videoImage,
    required this.videoTime,
  });

  @override
  State<CreateVideoStoryView> createState() => _CreateVideoStoryViewState();
}

class _CreateVideoStoryViewState extends State<CreateVideoStoryView> {
  ChewieController? chewieController;
  VideoPlayerController? videoPlayerController;

  bool isPlaying = true;
  bool isVideoLoading = true;
  bool isShowPlayPauseIcon = false;
  bool isMusicSelected = false;
  bool _isProcessing = false;

  int videoTime = 0;

  String videoThumbnail = "";
  String songId = "";

  // Add story controller reference
  final AddStoryController addStoryController = Get.put(AddStoryController());

  @override
  void initState() {
    initializeVideoPlayer(widget.videoUrl);
    super.initState();
  }

  Future<void> initializeVideoPlayer(String videoPath) async {
    try {
      videoPlayerController?.dispose();
      videoPlayerController = null;

      videoPlayerController = VideoPlayerController.file(File(videoPath));

      await videoPlayerController?.initialize();

      if (videoPlayerController != null && (videoPlayerController?.value.isInitialized ?? false)) {
        chewieController = ChewieController(
          videoPlayerController: videoPlayerController!,
          looping: true,
          allowedScreenSleep: false,
          allowMuting: false,
          showControlsOnInitialize: false,
          showControls: false,
          autoPlay: true,
        );

        if (chewieController != null) {
          onChangeLoading(false);
          _setupMusicListener();
        } else {
          onChangeLoading(true);
        }
      }
    } catch (e) {
      onDisposeVideoPlayer();
      Utils.showLog("Reels Video Initialization Failed !!! => $e");
    }
  }

  void _setupMusicListener() {
    addStoryController.addListener(() {
      Utils.showLog("MAKE CHECK MY MUSICC");
      if (addStoryController.selectedSound != null && !isMusicSelected) {
        Utils.showLog("MAKE CHECK MY MUSICC");
        _onMusicSelected();
      } else if (addStoryController.selectedSound == null && isMusicSelected) {
        _onMusicDeselected();
      }
    });
  }

  void _onMusicSelected() {
    if (addStoryController.selectedSound != null) {
      setState(() {
        isMusicSelected = true;
        Utils.showLog("MAKE CHECK MY MUSICC 011 ");
      });
      videoPlayerController?.setVolume(0.0);

      String musicUrl = addStoryController.selectedSound!["url"] ?? "";
      if (musicUrl.isNotEmpty) {
        addStoryController.onPlayAudio(musicUrl);
      }
    }

    Utils.showLog("Music selected - Video muted, Music playing");
  }

  void _onMusicDeselected() {
    setState(() {
      isMusicSelected = false;
    });
    videoPlayerController?.setVolume(1.0);
    addStoryController.onPauseAudio();
  }

  void onStopVideo() {
    onChangePlayPauseIcon(false);
    videoPlayerController?.pause();

    if (isMusicSelected) {
      addStoryController.onPauseAudio();
    }
  }

  void onPlayVideo() {
    onChangePlayPauseIcon(true);
    videoPlayerController?.play();

    if (isMusicSelected) {
      addStoryController.onResumeAudio();
    }
  }

  void onClickVideo() async {
    if (isVideoLoading == false) {
      videoPlayerController!.value.isPlaying ? onStopVideo() : onPlayVideo();
      onShowPlayPauseIcon(true);
      await 2.seconds.delay();
      onShowPlayPauseIcon(false);
    }
  }

  void onClickPlayPause() async {
    videoPlayerController!.value.isPlaying ? onStopVideo() : onPlayVideo();
  }

  void onChangeLoading(bool value) {
    isVideoLoading = value;
    setState(() {});
  }

  void onChangePlayPauseIcon(bool value) {
    isPlaying = value;
    setState(() {});
  }

  void onShowPlayPauseIcon(bool value) {
    isShowPlayPauseIcon = value;
    setState(() {});
  }

  void onDisposeVideoPlayer() {
    try {
      Utils.showLog("Video Dispose Success");
      videoPlayerController?.dispose();
      chewieController?.dispose();
      chewieController = null;
      videoPlayerController = null;
      onChangeLoading(true);
      addStoryController.onPauseAudio();
      Utils.showLog("Video Dispose Success");
    } catch (e) {
      Utils.showLog(">>>> On Dispose VideoPlayer Error => $e");
    }
  }

  // Enhanced method to create final video with music and upload
  Future<void> _createFinalVideoWithMusic() async {
    try {
      setState(() {
        _isProcessing = true;
      });

      debugPrint('Creating final video - isMusicSelected: $isMusicSelected');
      debugPrint('Selected sound: ${addStoryController.selectedSound}');
      debugPrint('Selected sound link: ${addStoryController.selectedSound?["link"]}');
      debugPrint('Selected sound link: ${widget.videoUrl}');

      // Get the selected duration from controller
      int selectedDuration = addStoryController.getCurrentDuration();

      String audioUrl = addStoryController.selectedSound?["link"] ?? '';
      String audioId = addStoryController.selectedSound?["id"] ?? "";

      debugPrint('Selected duration: ${selectedDuration} seconds');

      double? startTime = addStoryController.selectedSound?["startTime"]?.toDouble();
      double? endTime = addStoryController.selectedSound?["endTime"]?.toDouble();
      // Check if music is selected
      UploadStoryServices.onStoryUploadProcess(
        isVideo: true,
        localPath: widget.videoUrl,
        audioUrl: audioUrl,
        songId: audioId,
        duration: selectedDuration,
        startTime: startTime,
        endTime: endTime,
      );
      Get.back();
      // if (audioUrl != null && audioUrl.isNotEmpty) {
      //   debugPrint("Creating final video with merged music...");
      //
      //   // Get timing information if available
      //   double? startTime = addStoryController.selectedSound?["startTime"]?.toDouble();
      //   double? endTime = addStoryController.selectedSound?["endTime"]?.toDouble();
      //  //   double? startTime = addStoryController.selectedSound?["startTime"]?.toDouble();
      //   double? endTime = addStoryController.selectedSound?["endTime"]?.toDouble();
      //
      //   finalVideoPath = await VideoCompositionService.createVideoWithMusicFromUrl(
      //     videoPath: widget.videoUrl,
      //     audioUrl: audioUrl,
      //     fileName: "story_${DateTime.now().millisecondsSinceEpoch}",
      //     duration: selectedDuration,
      //     startTime: startTime,
      //     endTime: endTime,
      //   );
      //
      //   backgroundSong = audioId ?? "";
      // } else {
      //   // No music selected, use original video but trim to selected duration
      //   debugPrint("No music selected, trimming video to selected duration");
      //
      //   finalVideoPath = await _trimVideoToSelectedDuration(
      //     widget.videoUrl,
      //     selectedDuration,
      //   );
      // }
      //
      // if (finalVideoPath != null) {
      //   debugPrint("Final video created: $finalVideoPath");
      //
      //   // Stop any playing audio
      //   addStoryController.onPauseAudio();
      //
      //   // Upload story to server
      //   await _uploadStoryToServer(
      //     outputPath: finalVideoPath,
      //     isVideo: true,
      //     backgroundSong: backgroundSong,
      //     duration: selectedDuration,
      //   );
      // } else {
      //   debugPrint("Failed to create final video");
      //   _showErrorDialog("Failed to create video. Please try again.");
      // }
    } catch (e) {
      debugPrint("Error creating final video: $e");
      _showErrorDialog("Error creating video: ${e.toString()}");
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  /*// Method to trim video to selected duration when no music is selected
  Future<String?> _trimVideoToSelectedDuration(String videoPath, int duration) async {
    try {
      final Directory appDir = await getTemporaryDirectory();
      final String outputPath = '${appDir.path}/trimmed_video_${DateTime.now().millisecondsSinceEpoch}.mp4';

      final String command = '-i "$videoPath" -t $duration -c copy "$outputPath"';

      final session = await FFmpegKit.executeAsync(command);
      final returnCode = await session.getReturnCode();

      debugPrint("Trim video command: $command");
      debugPrint("Trim video return code: $returnCode");

      // Wait a bit for file system
      await Future.delayed(const Duration(seconds: 2));

      if (await File(outputPath).exists()) {
        return outputPath;
      } else {
        return null;
      }
    } catch (e) {
      debugPrint("Error trimming video: $e");
      return null;
    }
  }

  // Method to upload story to server
  Future<void> _uploadStoryToServer({
    required String outputPath,
    required bool isVideo,
    required String backgroundSong,
    required int duration,
  })
  async {
    try {
      debugPrint('Starting upload to server...');

      String userId = Database.loginUserId;

      // Generate thumbnail for the video
      String? thumbnail = await CustomThumbnail.onGet(outputPath);
      String? thumbnailUrl = "";

      if (thumbnail != null && thumbnail.isNotEmpty) {
        thumbnailUrl = await _uploadFileToStorage(thumbnail, false) ?? "";
      }

      // Upload the main video file
      String? uploadedUrl = await _uploadFileToStorage(outputPath, isVideo);

      if (uploadedUrl != null) {
        debugPrint('File uploaded to storage: $uploadedUrl');

        // Call the API to save story details
        final result = await UploadStoryApi.callApi(
          userId: userId,
          backgroundSong: backgroundSong,
          mediaImageUrl: thumbnailUrl,
          mediaVideoUrl: uploadedUrl,
          isVideo: isVideo,
          duration: duration,
        );

        if (result != null) {
          debugPrint('Story uploaded successfully');
          Utils.showToast("Story uploaded successfully");
          Get.close(1);
        } else {
          _showErrorDialog('Failed to upload story. Please try again.');
        }
      } else {
        _showErrorDialog('Failed to upload file. Please check your internet connection.');
      }
    } catch (e) {
      debugPrint('Error uploading story: $e');
      _showErrorDialog('Upload failed: ${e.toString()}');
    }
  }

  Upload file using existing UploadFileApi
  Future<String?> _uploadFileToStorage(String filePath, bool isVideo) async {
    try {
      debugPrint('Uploading file to storage: $filePath');

      String keyName = 'story_${DateTime.now().millisecondsSinceEpoch}_${isVideo ? 'video' : 'image'}';
      int fileType = 8; // Story content type

      String? uploadedUrl = await UploadFileApi.callApi(
        filePath: filePath,
        fileType: fileType,
        keyName: keyName,
      );

      if (uploadedUrl != null && uploadedUrl.isNotEmpty) {
        debugPrint('File uploaded successfully: $uploadedUrl');
        return uploadedUrl;
      } else {
        debugPrint('Upload failed: No URL returned');
        return null;
      }
    } catch (e) {
      debugPrint('Error uploading file: $e');
      return null;
    }
  }*/

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  /*// Helper method to format time
  String _formatTime(double seconds) {
    int minutes = (seconds / 60).floor();
    int remainingSeconds = (seconds % 60).floor();
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  // Helper method to build duration selection buttons
  Widget _buildDurationButton(String duration, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          duration,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w900,
            fontFamily: AppConstant.appFontMedium,
          ),
        ),
      ),
    );
  }*/

  @override
  void dispose() {
    log("Dispose Called");
    onDisposeVideoPlayer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        height: Get.height,
        width: Get.width,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Video Player
            GestureDetector(
              onTap: onClickVideo,
              child: Container(
                color: AppColor.black,
                height: Get.height,
                width: Get.width,
                child: isVideoLoading
                    ? LoadingUi()
                    : SizedBox.expand(
                        child: FittedBox(
                          fit: BoxFit.cover,
                          child: SizedBox(
                            width: videoPlayerController?.value.size.width ?? 0,
                            height: videoPlayerController?.value.size.height ?? 0,
                            child: Chewie(controller: chewieController!),
                          ),
                        ),
                      ),
              ),
            ),

            // Play/Pause Icon
            isShowPlayPauseIcon
                ? Align(
                    alignment: Alignment.center,
                    child: GestureDetector(
                      onTap: onClickPlayPause,
                      child: Container(
                        height: 70,
                        width: 70,
                        padding: EdgeInsets.only(left: isPlaying ? 0 : 2),
                        decoration: BoxDecoration(color: AppColor.black.withValues(alpha:0.2), shape: BoxShape.circle),
                        child: Center(
                          child: Image.asset(
                            isPlaying ? AppAsset.icPause : AppAsset.icPlay,
                            width: 30,
                            height: 30,
                            color: AppColor.white,
                          ),
                        ),
                      ),
                    ),
                  )
                : const Offstage(),

            // Top Gradient
            Positioned(
              top: 0,
              child: Container(
                height: 150,
                width: Get.width,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColor.black.withValues(alpha:0.7), AppColor.transparent],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),

            // Bottom Gradient
            Positioned(
              bottom: 0,
              child: Container(
                height: 150,
                width: Get.width,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColor.transparent, AppColor.black.withValues(alpha:0.7)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),

            // Back Button and Preview Text
            Positioned(
              top: 30,
              left: 15,
              child: Row(
                children: [
                  CustomIconButton(
                    icon: AppAsset.icBack,
                    iconColor: AppColor.white,
                    callback: () {
                      Get.close(1);
                    },
                  ),
                  15.width,
                  Text(
                    EnumLocal.txtPreview.name.tr,
                    style: AppFontStyle.styleW700(AppColor.white, 20),
                  ),
                ],
              ),
            ),

            // Music Button
            Positioned(
              top: 35,
              right: 15,
              child: GetBuilder<AddStoryController>(
                init: AddStoryController(),
                builder: (controller) => GestureDetector(
                  onTap: () {
                    onStopVideo();
                    AddStorySelectMusicBottomSheet.show(
                      context: context,
                    ).then((value) {
                      Utils.showLog("MAKE ISS WORKINGGG ");
                      if (addStoryController.selectedSound != null && !isMusicSelected) {
                        Utils.showLog("MAKE CHECK MY MUSICC");
                        _onMusicSelected();
                      } else if (addStoryController.selectedSound == null && isMusicSelected) {
                        _onMusicDeselected();
                      }
                    });
                  },
                  child: Container(
                    height: 45,
                    width: 45,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppColor.primaryLinearGradient,
                    ),
                    child: Image.asset(
                      AppAsset.icMusic,
                      height: 15,
                      width: 15,
                      color: AppColor.white,
                    ),
                  ),
                ),
              ),
            ),

            /// Duration Selection Buttons
            // Positioned(
            //   bottom: 120,
            //   child: Center(
            //     child: GetBuilder<AddStoryController>(
            //       init: AddStoryController(),
            //       id: "onChangeDuration",
            //       builder: (storyController) {
            //         return Container(
            //           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            //           decoration: BoxDecoration(
            //             color: Colors.white.withValues(alpha:0.1),
            //             borderRadius: BorderRadius.circular(20),
            //             border: Border.all(color: Colors.white, width: 0.5),
            //           ),
            //           child: Row(
            //             mainAxisSize: MainAxisSize.min,
            //             children: storyController.availableDurations.map((duration) {
            //               return _buildDurationButton(
            //                 '${duration}s',
            //                 storyController.isDurationSelected(duration),
            //                 () {
            //                   storyController.updateSelectedDuration(duration);
            //                 },
            //               );
            //             }).toList(),
            //           ),
            //         );
            //       },
            //     ),
            //   ),
            // ),

            // Next Button
            Positioned(
              bottom: 40,
              child: SizedBox(
                width: Get.width,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: Get.width / 5),
                  child: AppButtonUi(
                    fontSize: 18,
                    gradient: _isProcessing ? null : AppColor.primaryLinearGradient,
                    color: _isProcessing ? Colors.grey : null,
                    title: _isProcessing ? "Processing..." : EnumLocal.txtNext.name.tr,
                    callback: _isProcessing ? () {} : _createFinalVideoWithMusic,
                  ),
                ),
              ),
            ),

            // Selected Music Display
            Positioned(
              top: 80,
              child: GetBuilder<AddStoryController>(
                init: AddStoryController(),
                id: "onChangeSound",
                builder: (controller) {
                  return Visibility(
                    visible: controller.selectedSound != null,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha:0.6),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Music icon/image
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                controller.selectedSound?["image"] ?? "",
                                width: 16,
                                height: 16,
                                errorBuilder: (context, error, stackTrace) => const Icon(
                                  Icons.music_note,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),

                            // Song name
                            Flexible(
                              child: Text(
                                controller.selectedSound?["name"] ?? "",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),

                            // Play/Pause button
                            GestureDetector(
                              onTap: () {
                                if (controller.audioPlayer.state == PlayerState.playing) {
                                  controller.onPauseAudio();
                                  videoPlayerController?.pause();
                                } else {
                                  controller.onResumeAudio();
                                  videoPlayerController?.play();
                                }
                                controller.update(["onChangeSound"]);
                              },
                              child: StreamBuilder<PlayerState>(
                                stream: controller.audioPlayer.onPlayerStateChanged,
                                builder: (context, snapshot) {
                                  final isPlaying = snapshot.data == PlayerState.playing;
                                  return Icon(
                                    isPlaying ? Icons.pause : Icons.play_arrow,
                                    color: Colors.white,
                                    size: 16,
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 6),

                            // Close button
                            GestureDetector(
                              onTap: () {
                                controller.onPauseAudio();
                                controller.selectedSound = null;
                                videoPlayerController?.setVolume(1.0);
                                setState(() {
                                  isMusicSelected = false;
                                });
                                controller.update(["onChangeSound"]);
                              },
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Video Muted Indicator
            if (isMusicSelected)
              Positioned(
                bottom: 160,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha:0.6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.volume_off,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "Video Muted",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Processing Indicator
            if (_isProcessing)
              Container(
                color: Colors.black.withValues(alpha:0.5),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Creating your story...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// // Keep your existing UploadStory class for any additional utilities
// class UploadStory {
//   static Future<String?> onMergeAudioWithVideo(String videoPath, String audioPath, int duration) async {
//     final String path = '${(await getTemporaryDirectory()).path}/STORY_${DateTime.now().millisecondsSinceEpoch}.mp4';
//
//     final command = '-i $videoPath -i $audioPath -t $duration -c:v copy -c:a aac -strict experimental -map 0:v:0 -map 1:a:0 $path';
//     final sessionRemoveAudio = await FFmpegKit.executeAsync(command);
//     final returnCodeRemoveAudio = await sessionRemoveAudio.getReturnCode();
//
//     Utils.showLog("Merge Video Path => $path");
//     Utils.showLog("Return Code => $returnCodeRemoveAudio");
//
//     await 5.seconds.delay(); // Path Error Handling...
//     return path;
//   }
//
//   Future<void> onUploadStory() async {
//     await UploadStoryApi.callApi(
//       userId: Database.loginUserId,
//       backgroundSong: "",
//       isVideo: true,
//       mediaImageUrl: "",
//       mediaVideoUrl: "",
//       duration: 10,
//     );
//   }
// }

// Video Composition Service Class
class VideoCompositionService {
  static Future<String?> createVideoWithMusicFromUrl({
    required String videoPath,
    required String audioUrl,
    required String fileName,
    int? duration,
    double? startTime,
    double? endTime,
  }) async {
    try {
      final Directory appDir = await getTemporaryDirectory();
      final String outputPath = '${appDir.path}/${fileName}.mp4';

      // Build FFmpeg command
      String command;

      if (startTime != null && endTime != null) {
        // Trim audio and merge
        double audioDuration = endTime - startTime;
        command = '-i "$videoPath" -i "$audioUrl" -ss $startTime -t $audioDuration -t ${duration ?? 15} -c:v copy -c:a aac -strict experimental -map 0:v:0 -map 1:a:0 "$outputPath"';
      } else if (duration != null) {
        // Just limit duration
        command = '-i "$videoPath" -i "$audioUrl" -t $duration -c:v copy -c:a aac -strict experimental -map 0:v:0 -map 1:a:0 "$outputPath"';
      } else {
        // Basic merge
        command = '-i "$videoPath" -i "$audioUrl" -c:v copy -c:a aac -strict experimental -map 0:v:0 -map 1:a:0 "$outputPath"';
      }

      debugPrint("FFmpeg command: $command");

      final session = await FFmpegKit.executeAsync(command);
      final returnCode = await session.getReturnCode();

      debugPrint("FFmpeg return code: $returnCode");

      // Wait for file system
      await Future.delayed(const Duration(seconds: 3));

      if (await File(outputPath).exists()) {
        debugPrint("Output file created successfully: $outputPath");
        return outputPath;
      } else {
        debugPrint("Output file was not created");
        return null;
      }
    } catch (e) {
      debugPrint("Error in createVideoWithMusicFromUrl: $e");
      return null;
    }
  }
}
