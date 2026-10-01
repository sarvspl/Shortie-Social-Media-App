import 'dart:io';
import 'dart:math';

import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shortie/custom/custom_thumbnail.dart';
import 'package:shortie/pages/splash_screen_page/api/upload_file_api.dart';
import 'package:shortie/pages/story_page/api/upload_story_api.dart';
import 'package:shortie/pages/story_page/controller/story_controller.dart';
import 'package:shortie/pages/story_page/model/upload_story_model.dart';
import 'package:shortie/utils/database.dart';
import 'package:shortie/utils/notification_services.dart';
import 'package:shortie/utils/utils.dart';

class UploadStoryServices {
  static int _uploadNotificationId = 0;

  static int processCount = 0;

  static UploadStoryModel? uploadStoryModel;

  static Future<void> onStoryUploadProcess({
    required bool isVideo,
    required String localPath,
    required String audioUrl,
    required String songId,
    required int duration,
    double? startTime,
    double? endTime,
  }) async {
    try {
      final isSongAvailable = (songId.trim().isNotEmpty && audioUrl.trim().isNotEmpty); // CHECK SONG ADDED

      uploadStoryModel = null;

      Utils.showLog("STORY PROCESS RUNNING....");

      _uploadNotificationId = Random().nextInt(10000);

      Utils.showLog("STORY NOTIFICATION ID => $_uploadNotificationId");

      _showProgressNotification(0, "");

      if (isSongAvailable && isVideo == false) {
        final trimmedAudio = (startTime != null && endTime != null) ? await onTrimAudio(audioUrl, startTime, endTime) : audioUrl;
        Utils.showLog("STORY PROCESS TRIM AUDIO => $trimmedAudio");
        _showProgressNotification(10, "");

        final _finalVideoPath = (await createVideoFromImageAndAudio(localPath, trimmedAudio, duration) ?? ""); // MERGE IMAGE/SONG
        Utils.showLog("STORY PROCESS IMAGE TO VIDEO URL => $_finalVideoPath");
        _showProgressNotification(30, "");

        final thumbnailPath = await CustomThumbnail.onGet(_finalVideoPath) ?? "";
        _showProgressNotification(50, "");

        final imageUrl = await onFileUpload(filePath: thumbnailPath, isVideo: false); // THUMBNAIL CONVERT
        Utils.showLog("STORY PROCESS THUMBNAIL URL => $imageUrl");
        _showProgressNotification(70, "");

        final videoUrl = await onFileUpload(filePath: _finalVideoPath, isVideo: true); // VIDEO CONVERT
        Utils.showLog("STORY PROCESS VIDEO URL => $videoUrl");
        _showProgressNotification(90, "");

        uploadStoryModel = await onUploadStory(songId: songId, image: imageUrl ?? "", video: videoUrl ?? "", isVideo: true, duration: duration); // CALL MAIN API
        _showProgressNotification(100, "");
      } else if (isVideo) {
        final trimmedAudio = (startTime != null && endTime != null) ? await onTrimAudio(audioUrl, startTime, endTime) : audioUrl;
        Utils.showLog("STORY PROCESS TRIM AUDIO => $trimmedAudio");
        _showProgressNotification(10, "");

        final _finalVideoPath = isSongAvailable ? (await onMergeAudioWithVideo(localPath, trimmedAudio, duration) ?? "") : localPath; // MERGE VIDEO/SONG
        _showProgressNotification(30, "");

        final thumbnailPath = await CustomThumbnail.onGet(_finalVideoPath) ?? "";
        _showProgressNotification(50, "");

        final imageUrl = await onFileUpload(filePath: thumbnailPath, isVideo: false); // THUMBNAIL CONVERT
        Utils.showLog("STORY PROCESS THUMBNAIL URL => $imageUrl");
        _showProgressNotification(70, "");

        final videoUrl = await onFileUpload(filePath: _finalVideoPath, isVideo: true); // VIDEO CONVERT
        Utils.showLog("STORY PROCESS VIDEO URL => $videoUrl");
        _showProgressNotification(90, "");

        uploadStoryModel = await onUploadStory(songId: songId, image: imageUrl ?? "", video: videoUrl ?? "", isVideo: isVideo, duration: duration); // CALL MAIN API
        _showProgressNotification(100, "");
      } else {
        final imageUrl = await onFileUpload(filePath: localPath, isVideo: false); // IMAGE CONVERT
        _showProgressNotification(50, "");

        Utils.showLog("STORY PROCESS IMAGE URL => $imageUrl");

        uploadStoryModel = await onUploadStory(songId: songId, image: imageUrl ?? "", video: "", isVideo: isVideo, duration: duration); // CALL MAIN API
        _showProgressNotification(100, "");
      }

      Utils.showLog("STORY PROCESS STATUS => ${uploadStoryModel?.status}");

      uploadStoryModel?.status == true ? _showCompletionNotification() : _showErrorNotification(uploadStoryModel?.message ?? "");

      if (uploadStoryModel?.status == true) {
        final controller = Get.find<StoryController>();
        controller.init();
      }
      Utils.showLog("STORY PROCESS COMPLETE");
    } catch (e) {
      await _showErrorNotification('Error: ${e.toString()}');
      Utils.showLog("STORY PROCESS FAILED => $e");
    }
  }

  static Future<String> onTrimAudio(String audioPath, double startTime, double endTime) async {
    try {
      Directory appDir = await getApplicationDocumentsDirectory();
      String trimmedPath = '${appDir.path}/trimmed_audio_${DateTime.now().millisecondsSinceEpoch}.mp3';

      await FFmpegKit.execute('-i "$audioPath" -ss $startTime -t ${endTime - startTime} -c copy "$trimmedPath"');

      return trimmedPath;
    } catch (e) {
      print('Error trimming audio: $e');
      return audioPath;
    }
  }

  static Future<String?> onMergeAudioWithVideo(String videoPath, String audioPath, int duration) async {
    final String path = '${(await getTemporaryDirectory()).path}/ST_${DateTime.now().millisecondsSinceEpoch}.mp4';

    final command = '-i $videoPath -i $audioPath -t $duration -c:v copy -c:a aac -strict experimental -map 0:v:0 -map 1:a:0 $path';
    final sessionRemoveAudio = await FFmpegKit.executeAsync(command);
    final returnCodeRemoveAudio = await sessionRemoveAudio.getReturnCode();

    Utils.showLog("Merge Video Path => $path");
    Utils.showLog("Return Code => $returnCodeRemoveAudio");

    await 5.seconds.delay(); // Path Error Handling...
    return path;
  }

  static Future<String?> createVideoFromImageAndAudio(String imagePath, String audioPath, int duration) async {
    final String path = '${(await getTemporaryDirectory()).path}/st_${DateTime.now().millisecondsSinceEpoch}.mp4';

    List<String> ffmpegArgs = [];

    if (audioPath.trim().isNotEmpty) {
      ffmpegArgs = [
        '-y',
        '-loop',
        '1',
        '-i',
        imagePath,
        '-i',
        audioPath,
        '-c:v',
        'libx264',
        '-tune',
        'stillimage',
        '-pix_fmt',
        'yuv420p',
        '-r',
        '30',
        '-vf',
        'scale=1080:1920:force_original_aspect_ratio=decrease,pad=1080:1920:(ow-iw)/2:(oh-ih)/2:black',
        '-c:a',
        'aac',
        '-b:a',
        '192k',
        '-ar',
        '44100',
        '-t',
        duration.toString(),
        '-map',
        '0:v',
        '-map',
        '1:a',
        path
      ];
    } else {
      ffmpegArgs = ['-y', '-loop', '1', '-i', imagePath, '-c:v', 'libx264', '-tune', 'stillimage', '-pix_fmt', 'yuv420p', '-vf', 'scale=1080:1920:force_original_aspect_ratio=decrease,pad=1080:1920:(ow-iw)/2:(oh-ih)/2:black', '-r', '30', '-t', duration.toString(), path];
    }

    var session = await FFmpegKit.executeWithArguments(ffmpegArgs);
    final returnCode = await session.getReturnCode();

    Utils.showLog("Created Video Path => $path");
    Utils.showLog("Return Code => $returnCode");

    await 5.seconds.delay(); // Path Error Handling...
    return path;
  }

  static Future<String?> onFileUpload({required String filePath, required bool isVideo}) async {
    ///data/user/0/com.incodes.shortie/cache/1f91fa45-a99f-4559-a1da-25fbeb97d390/Inhaled Antibiotics for VAP #intubation.mp4

    String keyName = 'story_${DateTime.now().millisecondsSinceEpoch}_${isVideo ? 'video' : 'image'}';

    final fileUrl = await UploadFileApi.callApi(
      filePath: filePath,
      fileType: 8, // Story Content
      keyName: keyName,
    );

    return fileUrl;
  }

  static Future<UploadStoryModel?> onUploadStory({
    required String songId,
    required String image,
    required String video,
    required bool isVideo,
    required int duration,
  }) async {
    // backgroundSong: "687e0f7622db584c8ad62286",
    return await UploadStoryApi.callApi(
      userId: Database.loginUserId,
      backgroundSong: songId,
      isVideo: isVideo,
      mediaImageUrl: image,
      mediaVideoUrl: video,
      duration: duration,
    );
  }

  static Future<void> _showProgressNotification(int progress, String message) async {
    try {
      await NotificationServices.showUploadProgressNotification(
        notificationId: _uploadNotificationId,
        title: 'Uploading File',
        body: message,
        progress: progress,
        isCompleted: false,
      );
    } catch (e) {
      Utils.showLog("Error showing progress notification: $e");
    }
  }

  static Future<void> _showCompletionNotification() async {
    try {
      // Update the existing notification instead of creating a new one
      await NotificationServices.showUploadProgressNotification(
        notificationId: _uploadNotificationId,
        title: 'Upload Complete',
        body: 'File uploaded successfully!',
        progress: 100,
        isCompleted: true,
      );
    } catch (e) {
      Utils.showLog("Error showing completion notification: $e");
    }
  }

  static Future<void> _showErrorNotification(String error) async {
    try {
      await NotificationServices.showUploadProgressNotification(
        notificationId: _uploadNotificationId,
        title: 'Upload Failed',
        body: error,
        progress: 0,
        isCompleted: true,
      );
    } catch (e) {
      Utils.showLog("Error showing error notification: $e");
    }
  }
}
