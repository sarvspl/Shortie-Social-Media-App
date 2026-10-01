// import 'dart:async';
// import 'dart:developer';
// import 'dart:io';
// import 'dart:typed_data';
// import 'dart:ui' as ui;
//
// import 'package:audioplayers/audioplayers.dart';
// import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
// import 'package:ffmpeg_kit_flutter_new/ffprobe_kit.dart';
// import 'package:ffmpeg_kit_flutter_new/log.dart';
// import 'package:ffmpeg_kit_flutter_new/return_code.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;
// import 'package:path/path.dart' as p;
// import 'package:path_provider/path_provider.dart';
// import 'package:shortie/pages/create_reels_page/api/fetch_all_sound_api.dart';
// import 'package:shortie/pages/create_reels_page/api/fetch_favorite_sound_api.dart';
// import 'package:shortie/pages/create_reels_page/api/search_sound_api.dart';
// import 'package:shortie/pages/create_reels_page/model/fetch_all_sound_model.dart';
// import 'package:shortie/pages/create_reels_page/model/fetch_favorite_sound_model.dart';
// import 'package:shortie/pages/create_reels_page/model/search_sound_model.dart';
// import 'package:shortie/pages/splash_screen_page/api/upload_file_api.dart';
// import 'package:shortie/pages/story_page/api/upload_story_api.dart';
// import 'package:shortie/story_design/selected_bottom_sheet.dart';
// import 'package:shortie/utils/database.dart';
// import 'package:shortie/utils/utils.dart';
// import 'package:video_player/video_player.dart';
//
// import 'add_story_select_music_bottomsheet.dart';
//
// class AddStoryController extends GetxController {
// //  >>>>> >>>>> >>>>>  Duration Management <<<<< <<<<< <<<<<
//
//   int selectedDuration = 10; // Default duration in seconds
//   final List<int> availableDurations = [5, 10, 15, 20]; // Available duration options
//   double? selectedStartTime;
//   double? selectedEndTime;
//   Timer? playbackTimer;
//
//   void updateSelectedDuration(int duration) {
//     selectedDuration = duration;
//     update(["onChangeDuration"]);
//     Utils.showLog("Duration updated to: ${duration}s");
//   }
//
//   void resetDuration() {
//     selectedDuration = 10; // Reset to default
//     update(["onChangeDuration"]);
//   }
//
//   // Get current duration
//   int getCurrentDuration() {
//     return selectedDuration;
//   }
//
//   // Check if duration is selected
//   bool isDurationSelected(int duration) {
//     return selectedDuration == duration;
//   }
//
//   Future<void> playMusicFromTime({required String musicUrl, double startTime = 0.0, int? durationSeconds, required bool isAutoPlay}) async {
//     try {
//       print('Playing music from: $startTime seconds');
//
//       // Stop any currently playing audio
//       await onPauseAudio();
//
//       // Set audio source
//       await audioPlayer.setSourceUrl(musicUrl);
//
//       // Seek to start time
//       if (startTime > 0) {
//         await audioPlayer.seek(Duration(milliseconds: (startTime * 1000).toInt()));
//       }
//
//       // Start playing
//       if (isAutoPlay) await audioPlayer.resume();
//
//       // If duration is specified, stop after that time
//       if (durationSeconds != null) {
//         playbackTimer?.cancel();
//         playbackTimer = Timer(Duration(seconds: durationSeconds), () {
//           onPauseAudio();
//         });
//       }
//     } catch (e) {
//       print('Error playing music from time: $e');
//     }
//   }
//
//   void updateSelectedMusicWithTiming(Map<String, dynamic> musicData) {
//     selectedSound = {
//       'id': musicData['musicId'],
//       'name': musicData['musicName'],
//       'image': musicData['musicImage'],
//       'link': musicData['musicUrl'],
//       'singer': selectedSound?['singer'] ?? 'Unknown Artist',
//       'duration': selectedSound?['duration'] ?? '',
//       'startTime': musicData['startTime'],
//       'endTime': musicData['endTime'],
//     };
//
//     selectedStartTime = musicData['startTime']?.toDouble();
//     selectedEndTime = musicData['endTime']?.toDouble();
//     selectedDuration = musicData['duration'];
//
//     // Play music from selected time
//
//     playMusicFromTime(
//       musicUrl: musicData['musicUrl'],
//       startTime: selectedStartTime ?? 0.0,
//       durationSeconds: selectedDuration,
//       isAutoPlay: false,
//     );
//
//     update(["onChangeSound"]);
//   }
//
//   Map<String, dynamic> getCurrentMusicTiming() {
//     return {
//       'audioUrl': selectedSound?['link'],
//       'audioId': selectedSound?['id'],
//       'startTime': selectedStartTime,
//       'endTime': selectedEndTime,
//       'duration': selectedDuration,
//     };
//   }
//
//   Future<void> handleMusicSelection({required bool isAutoPlay}) async {
//     if (selectedSound == null) return;
//
//     Utils.showLog("555555555 => ${selectedSound}");
//
//     final result = await SelectedMusicBottomSheet.show(
//       context: Get.context!,
//       selectedMusic: {
//         'id': selectedSound?['id'],
//         'name': selectedSound?['name'],
//         'image': selectedSound?['image'],
//         'link': selectedSound?['link'],
//         'singer': selectedSound?['singer'] ?? 'Unknown Artist',
//         'duration': selectedSound?['duration'] ?? '',
//       },
//       preSelectedDuration: selectedDuration,
//       isAutoPlay: isAutoPlay,
//     );
//
//     print("//////////////// => ${result}");
//
//     if (result != null) {
//       updateSelectedMusicWithTiming(result);
//     }
//   }
//
//   //  >>>>> >>>>> >>>>>  Music Bottom Sheet <<<<< <<<<< <<<<<
//
//   Map? selectedSound;
//
//   int selectedTabIndex = 0;
//   TextEditingController searchController = TextEditingController();
//   final List soundTabPages = [const DiscoverTabUi(), const FavouriteTabUi()];
//
//   bool isLoadingSound = true;
//   List<AllSongs> mainSoundCollection = [];
//   FetchAllSoundModel? fetchAllSoundModel;
//
//   bool isLoadingFavoriteSound = true;
//   List<FavoriteSongs> favoriteSoundCollection = [];
//   FetchFavoriteSoundModel? fetchFavoriteSoundModel;
//   ScrollController favoriteSoundController = ScrollController();
//
//   bool isSearching = false;
//   SearchSoundModel? searchSoundModel;
//   List<SearchData> searchSounds = [];
//   bool isSearchLoading = false;
//   num videoduration = 0;
//   @override
//   void onInit() {
//     log("onInit add story ");
//     super.onInit();
//     setupAudioListeners();
//   }
//
//   @override
//   void onClose() {
//     log("add story  onClose ");
//     selectedSound = null;
//
//     stopAllAudio();
//     audioPlayer.dispose();
//     searchController.dispose();
//     favoriteSoundController.dispose();
//     super.onClose();
//   }
//
//   Future<void> onChangeTabBar(int index) async {
//     selectedTabIndex = index;
//     if (index == 0) {
//       initAllSound();
//     } else if (index == 1) {
//       initFavoriteSound();
//     }
//     update(["onChangeTabBar"]);
//   }
//
//   void onChangeSearchEvent() {
//     if (searchController.text.trim().isEmpty) {
//       isSearching = false;
//       update(["onChangeSearchEvent"]);
//     } else if (searchController.text.trim().length == 1) {
//       isSearching = true;
//       update(["onChangeSearchEvent"]);
//     }
//   }
//
//   Future<void> onSearchSound() async {
//     onChangeSearchEvent();
//     if (searchController.text.trim().isNotEmpty) {
//       Utils.showLog("Search Sound Method Calling...");
//
//       isSearchLoading = true;
//       update(["onSearchSound"]);
//
//       searchSoundModel = await SearchSoundApi.callApi(loginUserId: Database.loginUserId, searchText: searchController.text);
//
//       if (searchSoundModel?.searchData != null) {
//         searchSounds.clear();
//         searchSounds.addAll(searchSoundModel?.searchData ?? []);
//         isSearchLoading = false;
//         update(["onSearchSound"]);
//       }
//     }
//   }
//
//   Future<void> initAllSound() async {
//     mainSoundCollection.clear();
//
//     onGetAllSound();
//   }
//
//   Future<void> onGetAllSound() async {
//     if (mainSoundCollection.isEmpty) {
//       isLoadingSound = true;
//       update(["onGetAllSound"]);
//     }
//
//     fetchAllSoundModel = null;
//     fetchAllSoundModel = await FetchAllSoundApi.callApi(loginUserId: Database.loginUserId);
//
//     if (fetchAllSoundModel?.songs != null) {
//       isLoadingSound = false;
//       mainSoundCollection.addAll(fetchAllSoundModel?.songs ?? []);
//
//       Utils.showLog("All Sound Length => ${mainSoundCollection.length}");
//     }
//     update(["onGetAllSound"]);
//   }
//
//   Future<void> initFavoriteSound() async {
//     favoriteSoundCollection.clear();
//     FetchFavoriteSoundApi.startPagination = 0;
//     onGetFavoriteSound();
//   }
//
//   Future<void> onGetFavoriteSound() async {
//     if (favoriteSoundCollection.isEmpty) {
//       isLoadingFavoriteSound = true;
//       update(["onGetFavoriteSound"]);
//     }
//
//     fetchFavoriteSoundModel = null;
//     fetchFavoriteSoundModel = await FetchFavoriteSoundApi.callApi(loginUserId: Database.loginUserId);
//
//     if (fetchFavoriteSoundModel?.songs != null) {
//       isLoadingFavoriteSound = false;
//
//       favoriteSoundCollection.addAll(fetchFavoriteSoundModel?.songs ?? []);
//
//       Utils.showLog("Favorite Sound Length => ${favoriteSoundCollection.length}");
//     }
//     update(["onGetFavoriteSound"]);
//   }
//
//   AudioPlayer audioPlayer = AudioPlayer();
//
//   // // Audio handling improvements
//   // Future<void> onChangeSound(Map sound) async {
//   //   if (selectedSound?["id"] == sound["id"]) {
//   //     await onPauseAudio();
//   //     selectedSound = null;
//   //     update(["onChangeSound"]);
//   //   } else {
//   //     await onPauseAudio();
//   //     selectedSound = {
//   //       "id": sound["id"],
//   //       "name": sound["name"],
//   //       "image": sound["image"],
//   //       "link": sound["link"],
//   //     };
//   //     update(["onChangeSound"]);
//   //     await initAudio(sound["link"]);
//   //     await onResumeAudio();
//   //   }
//   // }
//
//   Future<void> onChangeSound(Map<String, dynamic> soundData) async {
//     log("Selected Sound Data: $soundData");
//
//     log("Selected Sound Data: ${soundData["link"]}");
//
//     selectedSound = soundData;
//
//     initAudio(soundData["link"]);
//
//     // Play the new audio
//     onResumeAudio();
//     update(["onChangeSound"]);
//
//     // Close the current bottom sheet first
//     Get.back();
//
//     // Show the selected music sheet with pre-selected duration
//     handleMusicSelection(isAutoPlay: true);
//   }
//
//   Future<void> initAudio(String audio) async {
//     try {
//       await audioPlayer.stop();
//
//       await audioPlayer.setSource(UrlSource(audio));
//       Utils.showLog("Audio initialized successfully =>  $audio");
//     } catch (e) {
//       Utils.showLog("Audio initialization failed: $e");
//       // Handle initialization failure gracefully
//       selectedSound = null;
//       update(["onChangeSound"]);
//     }
//   }
//
//   // Enhanced pause method
//   Future<void> onPauseAudio() async {
//     try {
//       if (audioPlayer.state == PlayerState.playing) {
//         await audioPlayer.pause();
//         Utils.showLog("Audio paused successfully");
//       }
//     } catch (e) {
//       Utils.showLog("Audio Pause Error => $e");
//     }
//   }
//
//   // Enhanced resume method
//   Future<void> onResumeAudio() async {
//     try {
//       if (selectedSound != null && audioPlayer.state == PlayerState.paused) {
//         await audioPlayer.resume();
//         Utils.showLog("Audio resumed successfully");
//       }
//     } catch (e) {
//       Utils.showLog("Audio Resume Error => $e");
//     }
//   }
//
//   // Enhanced restart method
//   Future<void> onRestartAudio() async {
//     try {
//       if (selectedSound != null) {
//         await audioPlayer.seek(const Duration(milliseconds: 0));
//         await audioPlayer.resume();
//         Utils.showLog("Audio restarted successfully");
//       }
//     } catch (e) {
//       Utils.showLog("Audio Restart Error => $e");
//     }
//   }
//
//   // Method to get audio file path for video composition
//   String? getSelectedAudioPath() {
//     return selectedSound?["link"];
//   }
//
//   // Method to stop all audio (useful when creating video)
//   Future<void> stopAllAudio() async {
//     try {
//       await audioPlayer.stop();
//       Utils.showLog("All audio stopped");
//     } catch (e) {
//       Utils.showLog("Error stopping audio: $e");
//     }
//   }
//
//   Future<void> onPlayAudio(String audioPath) async {
//     try {
//       update();
//
//       // Stop current audio if playing
//       await audioPlayer.stop();
//
//       // Play new audio
//       if (audioPath.startsWith('http')) {
//         await audioPlayer.play(UrlSource(audioPath));
//       } else {
//         await audioPlayer.play(DeviceFileSource(audioPath));
//       }
//
//       update();
//
//       print('Audio playing: $audioPath');
//     } catch (e) {
//       update(["onChangeSound", "audioControls"]);
//       print('Error playing audio: $e');
//     }
//   }
//
//   // Enhanced audio listener setup
//   void setupAudioListeners() {
//     // Listen for when audio completes
//     audioPlayer.onPlayerComplete.listen((event) {
//       // Restart the audio when it completes (loop)
//       onRestartAudio();
//       update(["onChangeSound"]);
//     });
//
//     // Listen for audio state changes
//     audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
//       Utils.showLog("Audio state changed: $state");
//       update(["onChangeSound"]);
//     });
//
//     // Listen for audio duration changes
//     audioPlayer.onDurationChanged.listen((Duration duration) {
//       Utils.showLog("Audio duration: ${duration.inSeconds}s");
//     });
//
//     // Listen for position changes
//     audioPlayer.onPositionChanged.listen((Duration position) {
//       // You can use this for progress indicators if needed
//     });
//   }
//
//   Future<void> uploadStoryToServer({
//     required String outputPath,
//     required bool isVideo,
//     required String backgroundSong,
//     required int duration,
//   }) async {
//     try {
//       print('Starting upload to server...');
//
//       // You'll need to get the current user ID - replace this with your actual user ID logic
//       String userId = Database.loginUserId; // You need to implement this method
//
//       // First, upload the file to your storage service
//       String? uploadedUrl = await _uploadFileToStorage(outputPath, isVideo);
//
//       if (uploadedUrl != null) {
//         print('File uploaded to storage: $uploadedUrl');
//
//         // Call the API to save story details
//         final result = await UploadStoryApi.callApi(
//           userId: userId,
//           backgroundSong: backgroundSong,
//           mediaImageUrl: uploadedUrl,
//           mediaVideoUrl: "",
//           isVideo: isVideo,
//           duration: duration,
//         );
//
//         if (result != null) {
//           print('Story uploaded successfully');
//
//           // Show success message
//
//           Utils.showToast("Story uploaded successfully");
//           Get.close(3);
//
//           // Call the original onDone callback if needed
//           // widget.onDone!(outputPath);
//
//           // Optionally navigate back or to another screen
//           // Navigator.of(context).pop();
//         } else {
//           _showErrorDialog('Failed to upload story. Please try again.');
//         }
//       } else {
//         _showErrorDialog('Failed to upload file. Please check your internet connection.');
//       }
//     } catch (e) {
//       print('Error uploading story: $e');
//       _showErrorDialog('Upload failed: ${e.toString()}');
//     }
//   }
//
//   void _showErrorDialog(String message) {
//     showDialog(
//       context: Get.context!,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('Error'),
//           content: Text(message),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: Text('OK'),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   Future<String?> _uploadFileToStorage(String filePath, bool isVideo) async {
//     try {
//       print('Uploading file to storage: $filePath');
//
//       // Create a unique key name for the file
//       String keyName = 'story_${DateTime.now().millisecondsSinceEpoch}_${isVideo ? 'video' : 'image'}';
//
//       // Use fileType 8 for story content (based on your fileUploadType method)
//       int fileType = 8; // This corresponds to Api.storyContent
//
//       // Call your existing upload API
//       String? uploadedUrl = await UploadFileApi.callApi(
//         filePath: filePath,
//         fileType: fileType,
//         keyName: keyName,
//       );
//
//       if (uploadedUrl != null && uploadedUrl.isNotEmpty) {
//         print('File uploaded successfully: $uploadedUrl');
//         return uploadedUrl;
//       } else {
//         print('Upload failed: No URL returned');
//         return null;
//       }
//     } catch (e) {
//       print('Error uploading file: $e');
//       return null;
//     }
//   }
// }
//
// class VideoCompositionService {
//   //NEW METHOD: Create video with music (replacing original audio)
//   // static Future<String?> createVideoWithMusic({
//   //   required String videoPath,
//   //   required String audioPath,
//   //   required String fileName,
//   // }) async {
//   //   try {
//   //     print('Starting video creation with music merge...');
//   //
//   //     // Get app documents directory
//   //     Directory appDir = await getApplicationDocumentsDirectory();
//   //     String tempDirPath = '${appDir.path}/temp_videos';
//   //     Directory tempDir = Directory(tempDirPath);
//   //
//   //     if (!await tempDir.exists()) {
//   //       await tempDir.create(recursive: true);
//   //     }
//   //
//   //     String outputPath = '${tempDir.path}/${fileName}_with_music.mp4';
//   //
//   //     // Remove output file if it exists
//   //     File outputFile = File(outputPath);
//   //     if (await outputFile.exists()) {
//   //       await outputFile.delete();
//   //     }
//   //
//   //     // First, get video duration
//   //     int? videoDuration = await _getVideoDuration(videoPath);
//   //     if (videoDuration == null) {
//   //       throw Exception('Could not determine video duration');
//   //     }
//   //
//   //     print('Video duration: ${videoDuration}s');
//   //
//   //     // FFmpeg command to replace video audio with selected music
//   //     List<String> ffmpegArgs = [
//   //       '-y', // Overwrite output file
//   //
//   //       // Input 1: Original video
//   //       '-i', videoPath,
//   //
//   //       // Input 2: Music audio
//   //       '-i', audioPath,
//   //
//   //       // Map video from input 0, audio from input 1
//   //       '-map', '0:v', // Video from first input
//   //       '-map', '1:a', // Audio from second input
//   //
//   //       // Video codec settings (copy to avoid re-encoding)
//   //       '-c:v', 'copy',
//   //
//   //       // Audio codec settings
//   //       '-c:a', 'aac',
//   //       '-b:a', '192k',
//   //       '-ar', '44100',
//   //
//   //       // Set video duration (trim if audio is longer)
//   //       '-t', videoDuration.toString(),
//   //
//   //       // Use shortest stream (video or audio)
//   //       '-shortest',
//   //
//   //       // Output file
//   //       outputPath
//   //     ];
//   //
//   //     print('FFmpeg command: ffmpeg ${ffmpegArgs.join(' ')}');
//   //
//   //     // Execute FFmpeg command
//   //     var session = await FFmpegKit.executeWithArguments(ffmpegArgs);
//   //     var returnCode = await session.getReturnCode();
//   //     var logs = await session.getAllLogs();
//   //
//   //     print('FFmpeg return code: ${returnCode?.getValue()}');
//   //
//   //     // Print logs for debugging
//   //     for (Log log in logs) {
//   //       String message = log.getMessage();
//   //       if (message.contains('Duration:') || message.contains('Stream #') || message.contains('time=') || message.contains('Error') || message.contains('Warning')) {
//   //         print('FFmpeg: $message');
//   //       }
//   //     }
//   //
//   //     if (ReturnCode.isSuccess(returnCode)) {
//   //       if (await File(outputPath).exists()) {
//   //         int outputSize = await File(outputPath).length();
//   //         print('Video with music created successfully: $outputPath (${outputSize} bytes)');
//   //         return outputPath;
//   //       } else {
//   //         throw Exception('Output video file was not created');
//   //       }
//   //     } else {
//   //       String errorLogs =
//   //           logs.where((log) => log.getMessage().contains('Error') || log.getMessage().contains('failed') || log.getMessage().contains('Invalid')).map((log) => log.getMessage()).join('\n');
//   //
//   //       throw Exception('FFmpeg failed with return code: ${returnCode?.getValue()}\nErrors: $errorLogs');
//   //     }
//   //   } catch (e) {
//   //     print('Error in createVideoWithMusic: $e');
//   //     return null;
//   //   }
//   // }
//
//   // static Future<String?> createVideoWithMusic({
//   //   required String videoPath,
//   //   required String audioPath,
//   //   required String fileName,
//   // }) async {
//   //   try {
//   //     final Directory appDir = await getTemporaryDirectory();
//   //     final String outputPath = "${appDir.path}/$fileName";
//   //
//   //     // Fix: -y to overwrite output, map streams properly
//   //     final String command = '''
//   //       -y -i "$videoPath" -i "$audioPath" -c:v copy -c:a aac -map 0:v:0 -map 1:a:0 -shortest "$outputPath"
//   //     ''';
//   //
//   //     final session = await FFmpegKit.execute(command);
//   //     final returnCode = await session.getReturnCode();
//   //
//   //     if (returnCode?.isValueSuccess() == true && File(outputPath).existsSync()) {
//   //       return outputPath;
//   //     } else {
//   //       final logs = await session.getAllLogsAsString();
//   //       print("FFmpeg failed: $logs");
//   //     }
//   //   } catch (e) {
//   //     print("Error merging video and audio: $e");
//   //   }
//   //   return null;
//   // }
//
//   static Future<String?> createVideoWithMusic({
//     required String videoPath,
//     required String audioPath,
//     required String fileName,
//   }) async {
//     final String path = '${(await getTemporaryDirectory()).path}/FV_${DateTime.now().millisecondsSinceEpoch}.mp4';
//
//     final double? videoTime = (await CustomVideoTime.onGet(videoPath) ?? 0).toDouble();
//     final double soundTime = await onGetSoundTime(audioPath) ?? 0.0;
//
//     if (soundTime != 0 && videoTime != null && videoTime != 0) {
//       final num minTime = (videoTime < soundTime) ? videoTime : soundTime;
//
//       final String command = '-y -i "$videoPath" -i "$audioPath" -t $minTime -c:v copy -c:a aac -map 0:v:0 -map 1:a:0 -shortest "$path"';
//
//       final session = await FFmpegKit.execute(command);
//       final returnCode = await session.getReturnCode();
//
//       if (returnCode?.isValueSuccess() == true && File(path).existsSync()) {
//         return path;
//       } else {
//         final logs = await session.getAllLogsAsString();
//         print("FFmpeg failed: $logs");
//       }
//     }
//
//     return null;
//   }
//
//   static Future<double?> onGetSoundTime(String videoPath) async {
//     try {
//       final session = await FFprobeKit.getMediaInformation(videoPath);
//       final info = session.getMediaInformation();
//       if (info != null) {
//         final durationStr = info.getDuration(); // e.g. "12.345"
//         final duration = double.tryParse(durationStr ?? "");
//         print("🎥 Video Duration: $duration seconds");
//         return duration;
//       } else {
//         print("❌ Could not get video info");
//         return null;
//       }
//     } catch (e) {
//       print("❌ Error getting video duration: $e");
//       return null;
//     }
//   }
//
//   static Future<String?> createVideoWithMusicFromUrl({
//     required String videoPath,
//     required String audioUrl,
//     required String fileName,
//   }) async {
//     try {
//       // Step 1: Get temp directory
//       final tempDir = await getTemporaryDirectory();
//
//       // Step 2: Download audio
//       final audioResponse = await http.get(Uri.parse(audioUrl));
//       if (audioResponse.statusCode != 200) {
//         throw Exception('Failed to download audio. Status: ${audioResponse.statusCode}');
//       }
//
//       final audioFilePath = p.join(tempDir.path, '${fileName}_downloaded_audio.m4a');
//       final audioFile = File(audioFilePath);
//       await audioFile.writeAsBytes(audioResponse.bodyBytes);
//
//       print(' music created successfully: $audioFilePath ,  video: $videoPath  File: $fileName');
//
//       // Step 3: Call createVideoWithMusic with the downloaded audio
//       return await createVideoWithMusic(
//             videoPath: videoPath,
//             audioPath: audioFilePath,
//             fileName: fileName,
//           ) ??
//           "";
//     } catch (e) {
//       print('❌ Error in createVideoWithMusicFromUrl: $e');
//       return null;
//     }
//   }
//
//   // METHOD: Create video with music (looped if shorter than video)
//   static Future<String?> createVideoWithLoopedMusic({
//     required String videoPath,
//     required String audioPath,
//     required String fileName,
//   }) async {
//     try {
//       print('Starting video creation with looped music...');
//
//       Directory appDir = await getApplicationDocumentsDirectory();
//       String tempDirPath = '${appDir.path}/temp_videos';
//       Directory tempDir = Directory(tempDirPath);
//
//       if (!await tempDir.exists()) {
//         await tempDir.create(recursive: true);
//       }
//
//       String outputPath = '${tempDir.path}/${fileName}_with_looped_music.mp4';
//
//       // Remove output file if it exists
//       File outputFile = File(outputPath);
//       if (await outputFile.exists()) {
//         await outputFile.delete();
//       }
//
//       // Get video duration
//       int? videoDuration = await _getVideoDuration(videoPath);
//       if (videoDuration == null) {
//         throw Exception('Could not determine video duration');
//       }
//
//       // FFmpeg command with looped audio
//       List<String> ffmpegArgs = [
//         '-y',
//
//         // Input 1: Video
//         '-i', videoPath,
//
//         // Input 2: Audio (with infinite loop)
//         '-stream_loop', '-1',
//         '-i', audioPath,
//
//         // Map streams
//         '-map', '0:v',
//         '-map', '1:a',
//
//         // Codecs
//         '-c:v', 'copy',
//         '-c:a', 'aac',
//         '-b:a', '192k',
//
//         // Duration (match video length)
//         '-t', videoDuration.toString(),
//
//         // Stop when shortest stream ends
//         '-shortest',
//
//         outputPath
//       ];
//
//       print('FFmpeg command: ffmpeg ${ffmpegArgs.join(' ')}');
//
//       var session = await FFmpegKit.executeWithArguments(ffmpegArgs);
//       var returnCode = await session.getReturnCode();
//
//       if (ReturnCode.isSuccess(returnCode)) {
//         if (await File(outputPath).exists()) {
//           print('Video with looped music created successfully: $outputPath');
//           return outputPath;
//         }
//       }
//
//       throw Exception('Failed to create video with looped music');
//     } catch (e) {
//       print('Error in createVideoWithLoopedMusic: $e');
//       return null;
//     }
//   }
//
//   // METHOD: Mix video audio with music (both audible)
//   static Future<String?> createVideoWithMixedAudio({
//     required String videoPath,
//     required String audioPath,
//     required String fileName,
//     double videoVolume = 0.3, // 30% original video audio
//     double musicVolume = 0.7, // 70% music audio
//   }) async {
//     try {
//       print('Starting video creation with mixed audio...');
//
//       Directory appDir = await getApplicationDocumentsDirectory();
//       String tempDirPath = '${appDir.path}/temp_videos';
//       Directory tempDir = Directory(tempDirPath);
//
//       if (!await tempDir.exists()) {
//         await tempDir.create(recursive: true);
//       }
//
//       String outputPath = '${tempDir.path}/${fileName}_mixed_audio.mp4';
//
//       // Remove output file if it exists
//       File outputFile = File(outputPath);
//       if (await outputFile.exists()) {
//         await outputFile.delete();
//       }
//
//       // Get video duration
//       int? videoDuration = await _getVideoDuration(videoPath);
//       if (videoDuration == null) {
//         throw Exception('Could not determine video duration');
//       }
//
//       // Complex FFmpeg command for audio mixing
//       List<String> ffmpegArgs = [
//         '-y',
//
//         // Input 1: Video with original audio
//         '-i', videoPath,
//
//         // Input 2: Music audio (looped)
//         '-stream_loop', '-1',
//         '-i', audioPath,
//
//         // Video codec
//         '-c:v', 'copy',
//
//         // Audio filter: mix both audio streams
//         '-filter_complex',
//         '[0:a]volume=${videoVolume}[a1];[1:a]volume=${musicVolume}[a2];[a1][a2]amix=inputs=2:duration=first:dropout_transition=2',
//
//         // Audio codec
//         '-c:a', 'aac',
//         '-b:a', '192k',
//
//         // Duration
//         '-t', videoDuration.toString(),
//
//         outputPath
//       ];
//
//       print('FFmpeg command: ffmpeg ${ffmpegArgs.join(' ')}');
//
//       var session = await FFmpegKit.executeWithArguments(ffmpegArgs);
//       var returnCode = await session.getReturnCode();
//
//       if (ReturnCode.isSuccess(returnCode)) {
//         if (await File(outputPath).exists()) {
//           print('Video with mixed audio created successfully: $outputPath');
//           return outputPath;
//         }
//       }
//
//       throw Exception('Failed to create video with mixed audio');
//     } catch (e) {
//       print('Error in createVideoWithMixedAudio: $e');
//       return null;
//     }
//   }
//
//   // HELPER METHOD: Get video duration in seconds
//   static Future<int?> _getVideoDuration(String videoPath) async {
//     try {
//       var session = await FFmpegKit.execute('-i "$videoPath" -f null -');
//       var logs = await session.getAllLogs();
//
//       for (Log log in logs) {
//         String message = log.getMessage();
//         if (message.contains('Duration:')) {
//           // Extract duration from format: Duration: 00:00:10.50
//           RegExp regExp = RegExp(r'Duration: (\d{2}):(\d{2}):(\d{2})\.(\d{2})');
//           Match? match = regExp.firstMatch(message);
//
//           if (match != null) {
//             int hours = int.parse(match.group(1)!);
//             int minutes = int.parse(match.group(2)!);
//             int seconds = int.parse(match.group(3)!);
//
//             int totalSeconds = (hours * 3600) + (minutes * 60) + seconds;
//             print('Video duration extracted: ${totalSeconds}s');
//             return totalSeconds;
//           }
//         }
//       }
//
//       return null;
//     } catch (e) {
//       print('Error getting video duration: $e');
//       return null;
//     }
//   }
//
//   // ORIGINAL METHOD: Create video from image and audio (for stories)
//   static Future<String?> createVideoWithImageAndAudio({
//     required GlobalKey contentKey,
//     required String? audioPath,
//     required int durationInSeconds,
//     required String fileName,
//     bool useDirectUrl = true,
//     double? startTime,
//     double? endTime,
//   }) async {
//     try {
//       print('Starting video creation process...');
//       if (startTime != null && endTime != null) {
//         audioPath = await _trimAudio(audioPath ?? "", startTime, endTime);
//       }
//       // Step 1: Capture the current design as image
//       String imagePath = await _captureDesignAsImage(contentKey, fileName);
//       print('Image captured at: $imagePath');
//
//       // Verify image file exists and has content
//       File imageFile = File(imagePath);
//       if (!await imageFile.exists()) {
//         throw Exception('Captured image file does not exist');
//       }
//
//       int imageSize = await imageFile.length();
//       print('Image file size: $imageSize bytes');
//
//       if (imageSize == 0) {
//         throw Exception('Captured image file is empty');
//       }
//
//       // Step 2: Create video from image and audio
//       String videoPath = await _createVideoFromImageAndAudio(
//         imagePath: imagePath,
//         audioPath: audioPath,
//         durationInSeconds: durationInSeconds,
//         fileName: fileName,
//         useDirectUrl: useDirectUrl,
//       );
//
//       return videoPath;
//     } catch (e) {
//       print('Error creating video: $e');
//       return null;
//     }
//   }
//
//   static Future<String> _trimAudio(String audioPath, double startTime, double endTime) async {
//     try {
//       // Use FFmpeg or similar to trim audio
//       // This is a placeholder - implement according to your audio processing library
//
//       Directory appDir = await getApplicationDocumentsDirectory();
//       String trimmedPath = '${appDir.path}/trimmed_audio_${DateTime.now().millisecondsSinceEpoch}.mp3';
//
//       // Example FFmpeg command (if you're using ffmpeg_kit_flutter):
//       await FFmpegKit.execute('-i "$audioPath" -ss $startTime -t ${endTime - startTime} -c copy "$trimmedPath"');
//
//       return trimmedPath;
//     } catch (e) {
//       print('Error trimming audio: $e');
//       return audioPath; // Return original if trimming fails
//     }
//   }
//
//   static Future<String> _captureDesignAsImage(GlobalKey contentKey, String fileName) async {
//     try {
//       print('Capturing design as image...');
//
//       // Ensure the widget is built and rendered
//       await Future.delayed(const Duration(milliseconds: 100));
//
//       if (contentKey.currentContext == null) {
//         throw Exception('Content key context is null');
//       }
//
//       // Get the render boundary
//       RenderObject? renderObject = contentKey.currentContext!.findRenderObject();
//       if (renderObject == null) {
//         throw Exception('Render object not found');
//       }
//
//       if (renderObject is! RenderRepaintBoundary) {
//         throw Exception('Render object is not a RenderRepaintBoundary');
//       }
//
//       RenderRepaintBoundary boundary = renderObject;
//
//       // Convert to image with high quality
//       ui.Image image = await boundary.toImage(pixelRatio: 2.0);
//       ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
//
//       if (byteData == null) {
//         throw Exception('Failed to convert image to byte data');
//       }
//
//       Uint8List pngBytes = byteData.buffer.asUint8List();
//       print('Image captured, size: ${pngBytes.length} bytes');
//
//       // Get app documents directory for better file management
//       Directory appDir = await getApplicationDocumentsDirectory();
//       String tempDirPath = '${appDir.path}/temp_videos';
//       Directory tempDir = Directory(tempDirPath);
//
//       // Create directory if it doesn't exist
//       if (!await tempDir.exists()) {
//         await tempDir.create(recursive: true);
//       }
//
//       String imagePath = '${tempDir.path}/${fileName}_design.png';
//       File imageFile = File(imagePath);
//       await imageFile.writeAsBytes(pngBytes);
//
//       print('Image saved to: $imagePath');
//       return imagePath;
//     } catch (e) {
//       print('Error capturing design as image: $e');
//       throw Exception('Failed to capture design as image: $e');
//     }
//   }
//
//   static Future<String> _createVideoFromImageAndAudio({
//     required String imagePath,
//     required String? audioPath,
//     required int durationInSeconds,
//     required String fileName,
//     bool useDirectUrl = true,
//   }) async {
//     try {
//       print('Creating video from image and audio...');
//       print('Image path: $imagePath');
//       print('Audio path: $audioPath');
//       print('Duration: ${durationInSeconds}s');
//
//       // Get app documents directory
//       Directory appDir = await getApplicationDocumentsDirectory();
//       String tempDirPath = '${appDir.path}/temp_videos';
//       Directory tempDir = Directory(tempDirPath);
//
//       if (!await tempDir.exists()) {
//         await tempDir.create(recursive: true);
//       }
//
//       String outputPath = '${tempDir.path}/${fileName}_final_video.mp4';
//
//       // Remove output file if it exists
//       File outputFile = File(outputPath);
//       if (await outputFile.exists()) {
//         await outputFile.delete();
//       }
//
//       List<String> ffmpegArgs = [];
//
//       if (audioPath != null && audioPath.isNotEmpty) {
//         // CORRECTED: Proper FFmpeg command for video with audio
//         ffmpegArgs = [
//           '-y', // Overwrite output file
//
//           // Input 1: Image (looped)
//           '-loop', '1',
//           '-i', imagePath,
//
//           // Input 2: Audio
//           '-i', audioPath,
//
//           // Video encoding settings
//           '-c:v', 'libx264',
//           '-tune', 'stillimage',
//           '-pix_fmt', 'yuv420p',
//           '-r', '30', // Frame rate
//
//           // Video filters (scaling and padding)
//           '-vf', 'scale=1080:1920:force_original_aspect_ratio=decrease,pad=1080:1920:(ow-iw)/2:(oh-ih)/2:black',
//
//           // Audio encoding settings
//           '-c:a', 'aac',
//           '-b:a', '192k',
//           '-ar', '44100', // Audio sample rate
//
//           // IMPORTANT: Duration control - this ensures video is exactly the specified duration
//           '-t', durationInSeconds.toString(),
//
//           // Map streams explicitly
//           '-map', '0:v', // Map video from input 0 (image)
//           '-map', '1:a', // Map audio from input 1 (audio file)
//
//           // Output file
//           outputPath
//         ];
//       } else {
//         // Create silent video
//         ffmpegArgs = [
//           '-y',
//           '-loop',
//           '1',
//           '-i',
//           imagePath,
//           '-c:v',
//           'libx264',
//           '-tune',
//           'stillimage',
//           '-pix_fmt',
//           'yuv420p',
//           '-vf',
//           'scale=1080:1920:force_original_aspect_ratio=decrease,pad=1080:1920:(ow-iw)/2:(oh-ih)/2:black',
//           '-r',
//           '30',
//           '-t',
//           durationInSeconds.toString(),
//           outputPath
//         ];
//       }
//
//       print('FFmpeg command: ffmpeg ${ffmpegArgs.join(' ')}');
//
//       // Execute FFmpeg command
//       var session = await FFmpegKit.executeWithArguments(ffmpegArgs);
//       var returnCode = await session.getReturnCode();
//       var logs = await session.getAllLogs();
//
//       print('FFmpeg return code: ${returnCode?.getValue()}');
//
//       // Print logs for debugging
//       for (Log log in logs) {
//         String message = log.getMessage();
//         if (message.contains('Duration:') || message.contains('Stream #') || message.contains('time=') || message.contains('Error') || message.contains('Warning')) {
//           print('FFmpeg: $message');
//         }
//       }
//
//       if (ReturnCode.isSuccess(returnCode)) {
//         if (await File(outputPath).exists()) {
//           int outputSize = await File(outputPath).length();
//           print('Video created successfully: $outputPath (${outputSize} bytes)');
//
//           // Verify the video duration using FFprobe (optional but helpful for debugging)
//           await _verifyVideoDuration(outputPath, durationInSeconds);
//
//           // Clean up temporary image file
//           try {
//             await File(imagePath).delete();
//             print('Temporary image file deleted');
//           } catch (e) {
//             print('Warning: Could not delete temporary image file: $e');
//           }
//
//           return outputPath;
//         } else {
//           throw Exception('Output video file was not created');
//         }
//       } else {
//         String errorLogs = logs.where((log) => log.getMessage().contains('Error') || log.getMessage().contains('failed') || log.getMessage().contains('Invalid')).map((log) => log.getMessage()).join('\n');
//
//         throw Exception('FFmpeg failed with return code: ${returnCode?.getValue()}\nErrors: $errorLogs');
//       }
//     } catch (e) {
//       print('Error in _createVideoFromImageAndAudio: $e');
//       throw Exception('Failed to create video: $e');
//     }
//   }
//
//   static Future<void> _verifyVideoDuration(String videoPath, int expectedDuration) async {
//     try {
//       var session = await FFmpegKit.execute('-i "$videoPath" -f null -');
//       var logs = await session.getAllLogs();
//
//       for (Log log in logs) {
//         String message = log.getMessage();
//         if (message.contains('Duration:')) {
//           print('Video info: $message');
//           break;
//         }
//       }
//     } catch (e) {
//       print('Could not verify video duration: $e');
//     }
//   }
//
//   // METHOD: Extract audio from video
//   static Future<String?> extractAudioFromVideo({
//     required String videoPath,
//     required String fileName,
//   }) async {
//     try {
//       print('Extracting audio from video...');
//
//       Directory appDir = await getApplicationDocumentsDirectory();
//       String tempDirPath = '${appDir.path}/temp_videos';
//       Directory tempDir = Directory(tempDirPath);
//
//       if (!await tempDir.exists()) {
//         await tempDir.create(recursive: true);
//       }
//
//       String outputPath = '${tempDir.path}/${fileName}_extracted_audio.aac';
//
//       // Remove output file if it exists
//       File outputFile = File(outputPath);
//       if (await outputFile.exists()) {
//         await outputFile.delete();
//       }
//
//       List<String> ffmpegArgs = [
//         '-y',
//         '-i', videoPath,
//         '-vn', // No video
//         '-acodec', 'aac',
//         '-b:a', '192k',
//         outputPath
//       ];
//
//       var session = await FFmpegKit.executeWithArguments(ffmpegArgs);
//       var returnCode = await session.getReturnCode();
//
//       if (ReturnCode.isSuccess(returnCode)) {
//         if (await File(outputPath).exists()) {
//           print('Audio extracted successfully: $outputPath');
//           return outputPath;
//         }
//       }
//
//       throw Exception('Failed to extract audio from video');
//     } catch (e) {
//       print('Error extracting audio: $e');
//       return null;
//     }
//   }
//
//   // METHOD: Get audio duration
//   static Future<int?> getAudioDuration(String audioPath) async {
//     try {
//       var session = await FFmpegKit.execute('-i "$audioPath" -f null -');
//       var logs = await session.getAllLogs();
//
//       for (Log log in logs) {
//         String message = log.getMessage();
//         if (message.contains('Duration:')) {
//           // Extract duration from format: Duration: 00:00:10.50
//           RegExp regExp = RegExp(r'Duration: (\d{2}):(\d{2}):(\d{2})\.(\d{2})');
//           Match? match = regExp.firstMatch(message);
//
//           if (match != null) {
//             int hours = int.parse(match.group(1)!);
//             int minutes = int.parse(match.group(2)!);
//             int seconds = int.parse(match.group(3)!);
//
//             int totalSeconds = (hours * 3600) + (minutes * 60) + seconds;
//             print('Audio duration extracted: ${totalSeconds}s');
//             return totalSeconds;
//           }
//         }
//       }
//
//       return null;
//     } catch (e) {
//       print('Error getting audio duration: $e');
//       return null;
//     }
//   }
//
//   // METHOD: Trim audio to specific duration
//   static Future<String?> trimAudio({
//     required String audioPath,
//     required int startSeconds,
//     required int durationSeconds,
//     required String fileName,
//   }) async {
//     try {
//       print('Trimming audio: start=${startSeconds}s, duration=${durationSeconds}s');
//
//       Directory appDir = await getApplicationDocumentsDirectory();
//       String tempDirPath = '${appDir.path}/temp_videos';
//       Directory tempDir = Directory(tempDirPath);
//
//       if (!await tempDir.exists()) {
//         await tempDir.create(recursive: true);
//       }
//
//       String outputPath = '${tempDir.path}/${fileName}_trimmed.aac';
//
//       // Remove output file if it exists
//       File outputFile = File(outputPath);
//       if (await outputFile.exists()) {
//         await outputFile.delete();
//       }
//
//       List<String> ffmpegArgs = [
//         '-y',
//         '-ss', startSeconds.toString(), // Start time
//         '-i', audioPath,
//         '-t', durationSeconds.toString(), // Duration
//         '-c:a', 'aac',
//         '-b:a', '192k',
//         outputPath
//       ];
//
//       var session = await FFmpegKit.executeWithArguments(ffmpegArgs);
//       var returnCode = await session.getReturnCode();
//
//       if (ReturnCode.isSuccess(returnCode)) {
//         if (await File(outputPath).exists()) {
//           print('Audio trimmed successfully: $outputPath');
//           return outputPath;
//         }
//       }
//
//       throw Exception('Failed to trim audio');
//     } catch (e) {
//       print('Error trimming audio: $e');
//       return null;
//     }
//   }
//
//   // METHOD: Clean up temporary files
//   static Future<void> cleanupTempFiles() async {
//     try {
//       Directory appDir = await getApplicationDocumentsDirectory();
//       String tempDirPath = '${appDir.path}/temp_videos';
//       Directory tempDir = Directory(tempDirPath);
//
//       if (await tempDir.exists()) {
//         await tempDir.delete(recursive: true);
//         print('Temporary files cleaned up');
//       }
//     } catch (e) {
//       print('Error cleaning up temporary files: $e');
//     }
//   }
// }
//
// // UTILITY CLASS: Audio Management
// class AudioManagementService {
//   // Download audio from URL if needed
//   static Future<String?> prepareAudioFile(String audioUrl) async {
//     try {
//       if (audioUrl.startsWith('http')) {
//         // Download the audio file
//         return await _downloadAudio(audioUrl);
//       } else {
//         // Local file path
//         return audioUrl;
//       }
//     } catch (e) {
//       print('Error preparing audio file: $e');
//       return null;
//     }
//   }
//
//   static Future<String?> _downloadAudio(String url) async {
//     try {
//       // Implement audio download logic here
//       // You can use dio package or http package
//       print('Downloading audio from: $url');
//
//       // For now, returning the URL (assuming it's accessible)
//       return url;
//     } catch (e) {
//       print('Error downloading audio: $e');
//       return null;
//     }
//   }
// }
//
// // IMAGE CREATION SERVICE (Enhanced)
// class ImageCreationService {
//   static Future<String?> createImageFromContent({
//     required GlobalKey contentKey,
//     required String fileName,
//   }) async {
//     try {
//       print('Creating image from content...');
//
//       // Ensure the widget is built and rendered
//       await Future.delayed(const Duration(milliseconds: 100));
//
//       if (contentKey.currentContext == null) {
//         throw Exception('Content key context is null');
//       }
//
//       // Get the render boundary
//       RenderObject? renderObject = contentKey.currentContext!.findRenderObject();
//       if (renderObject == null) {
//         throw Exception('Render object not found');
//       }
//
//       if (renderObject is! RenderRepaintBoundary) {
//         throw Exception('Render object is not a RenderRepaintBoundary');
//       }
//
//       RenderRepaintBoundary boundary = renderObject;
//
//       // Convert to image with high quality
//       ui.Image image = await boundary.toImage(pixelRatio: 3.0); // Higher quality
//       ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
//
//       if (byteData == null) {
//         throw Exception('Failed to convert image to byte data');
//       }
//
//       Uint8List pngBytes = byteData.buffer.asUint8List();
//       print('Image captured, size: ${pngBytes.length} bytes');
//
//       // Get app documents directory
//       Directory appDir = await getApplicationDocumentsDirectory();
//       String imagesDirPath = '${appDir.path}/story_images';
//       Directory imagesDir = Directory(imagesDirPath);
//
//       // Create directory if it doesn't exist
//       if (!await imagesDir.exists()) {
//         await imagesDir.create(recursive: true);
//       }
//
//       // Save as PNG image
//       String imagePath = '${imagesDir.path}/${fileName}_story.png';
//       File imageFile = File(imagePath);
//       await imageFile.writeAsBytes(pngBytes);
//
//       print('Image saved to: $imagePath');
//
//       // Verify the saved file
//       if (await imageFile.exists() && await imageFile.length() > 0) {
//         return imagePath;
//       } else {
//         throw Exception('Failed to save image file');
//       }
//     } catch (e) {
//       print('Error creating image: $e');
//       return null;
//     }
//   }
// }
//
// class CustomVideoTime {
//   static VideoPlayerController? _videoPlayerController;
//
//   static Future<int?> onGet(String videoPath) async {
//     try {
//       _videoPlayerController?.dispose();
//       _videoPlayerController = null;
//
//       _videoPlayerController = VideoPlayerController.file(File(videoPath));
//       await _videoPlayerController?.initialize();
//       if (_videoPlayerController!.value.isInitialized) {
//         final videoTime = _videoPlayerController?.value.duration.inSeconds;
//         Utils.showLog("Get Video Time => $videoTime");
//         return videoTime;
//       } else {
//         Utils.showLog("Get Video Time Error => Video Not Initialize");
//         return null;
//       }
//     } catch (e) {
//       Utils.showLog("Get Video Time Error => $e");
//       return null;
//     }
//   }
// }
import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:audioplayers/audioplayers.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/ffprobe_kit.dart';
import 'package:ffmpeg_kit_flutter_new/log.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shortie/pages/create_reels_page/api/fetch_all_sound_api.dart';
import 'package:shortie/pages/create_reels_page/api/fetch_favorite_sound_api.dart';
import 'package:shortie/pages/create_reels_page/api/search_sound_api.dart';
import 'package:shortie/pages/create_reels_page/model/fetch_all_sound_model.dart';
import 'package:shortie/pages/create_reels_page/model/fetch_favorite_sound_model.dart';
import 'package:shortie/pages/create_reels_page/model/search_sound_model.dart';
import 'package:shortie/pages/splash_screen_page/api/upload_file_api.dart';
import 'package:shortie/pages/story_page/api/upload_story_api.dart';
import 'package:shortie/story_design/selected_bottom_sheet.dart';
import 'package:shortie/utils/database.dart';
import 'package:shortie/utils/utils.dart';
import 'package:video_player/video_player.dart';

import 'add_story_select_music_bottomsheet.dart';

class AddStoryController extends GetxController {
//  >>>>> >>>>> >>>>>  Duration Management <<<<< <<<<< <<<<<

  int selectedDuration = 10; // Default duration in seconds
  final List<int> availableDurations = [5, 10, 15, 20]; // Available duration options
  double? selectedStartTime;
  double? selectedEndTime;
  Timer? playbackTimer;

  void updateSelectedDuration(int duration) {
    selectedDuration = duration;
    update(["onChangeDuration"]);
    Utils.showLog("Duration updated to: ${duration}s");
  }

  void resetDuration() {
    selectedDuration = 10; // Reset to default
    update(["onChangeDuration"]);
  }

  // Get current duration
  int getCurrentDuration() {
    return selectedDuration;
  }

  // Check if duration is selected
  bool isDurationSelected(int duration) {
    return selectedDuration == duration;
  }

  Future<void> playMusicFromTime({required String musicUrl, double startTime = 0.0, int? durationSeconds, required bool isAutoPlay}) async {
    try {
      print('Playing music from: $startTime seconds');

      // Stop any currently playing audio
      await onPauseAudio();

      // Set audio source
      await audioPlayer.setSourceUrl(musicUrl);

      // Seek to start time
      if (startTime > 0) {
        await audioPlayer.seek(Duration(milliseconds: (startTime * 1000).toInt()));
      }

      // Start playing
      if (isAutoPlay) await audioPlayer.resume();

      // If duration is specified, stop after that time
      if (durationSeconds != null) {
        playbackTimer?.cancel();
        playbackTimer = Timer(Duration(seconds: durationSeconds), () {
          onPauseAudio();
        });
      }
    } catch (e) {
      print('Error playing music from time: $e');
    }
  }

  void updateSelectedMusicWithTiming(Map<String, dynamic> musicData) {
    selectedSound = {
      'id': musicData['musicId'],
      'name': musicData['musicName'],
      'image': musicData['musicImage'],
      'link': musicData['musicUrl'],
      'singer': selectedSound?['singer'] ?? 'Unknown Artist',
      'duration': selectedSound?['duration'] ?? '',
      'startTime': musicData['startTime'],
      'endTime': musicData['endTime'],
    };

    selectedStartTime = musicData['startTime']?.toDouble();
    selectedEndTime = musicData['endTime']?.toDouble();
    selectedDuration = musicData['duration'];

    // Play music from selected time

    playMusicFromTime(
      musicUrl: musicData['musicUrl'],
      startTime: selectedStartTime ?? 0.0,
      durationSeconds: selectedDuration,
      isAutoPlay: false,
    );

    update(["onChangeSound"]);
  }

  Map<String, dynamic> getCurrentMusicTiming() {
    return {
      'audioUrl': selectedSound?['link'],
      'audioId': selectedSound?['id'],
      'startTime': selectedStartTime,
      'endTime': selectedEndTime,
      'duration': selectedDuration,
    };
  }

  Future<void> handleMusicSelection({required bool isAutoPlay}) async {
    if (selectedSound == null) return;

    Utils.showLog("555555555 => ${selectedSound}");

    final result = await SelectedMusicBottomSheet.show(
      context: Get.context!,
      selectedMusic: {
        'id': selectedSound?['id'],
        'name': selectedSound?['name'],
        'image': selectedSound?['image'],
        'link': selectedSound?['link'],
        'singer': selectedSound?['singer'] ?? 'Unknown Artist',
        'duration': selectedSound?['duration'] ?? '',
      },
      preSelectedDuration: selectedDuration,
      isAutoPlay: isAutoPlay,
    );

    print("//////////////// => ${result}");

    if (result != null) {
      updateSelectedMusicWithTiming(result);
    }
  }

  //  >>>>> >>>>> >>>>>  Music Bottom Sheet <<<<< <<<<< <<<<<

  Map? selectedSound;

  int selectedTabIndex = 0;
  TextEditingController searchController = TextEditingController();
  final List soundTabPages = [const DiscoverTabUi(), const FavouriteTabUi()];

  bool isLoadingSound = true;
  bool isLoadingMoreSound = false;
  bool hasMoreSound = true;
  List<AllSongs> mainSoundCollection = [];
  FetchAllSoundModel? fetchAllSoundModel;

  bool isLoadingFavoriteSound = true;
  List<FavoriteSongs> favoriteSoundCollection = [];
  FetchFavoriteSoundModel? fetchFavoriteSoundModel;
  ScrollController favoriteSoundController = ScrollController();

  bool isSearching = false;
  SearchSoundModel? searchSoundModel;
  List<SearchData> searchSounds = [];
  bool isSearchLoading = false;
  num videoduration = 0;
  @override
  void onInit() {
    log("onInit add story ");
    super.onInit();
    setupAudioListeners();
  }

  @override
  void onClose() {
    log("add story  onClose ");
    selectedSound = null;

    stopAllAudio();
    audioPlayer.dispose();
    searchController.dispose();
    favoriteSoundController.dispose();
    super.onClose();
  }

  Future<void> onChangeTabBar(int index) async {
    selectedTabIndex = index;
    if (index == 0) {
      initAllSound();
    } else if (index == 1) {
      initFavoriteSound();
    }
    update(["onChangeTabBar"]);
  }

  void onChangeSearchEvent() {
    if (searchController.text.trim().isEmpty) {
      isSearching = false;
      update(["onChangeSearchEvent"]);
    } else if (searchController.text.trim().length == 1) {
      isSearching = true;
      update(["onChangeSearchEvent"]);
    }
  }

  Future<void> onSearchSound() async {
    onChangeSearchEvent();
    if (searchController.text.trim().isNotEmpty) {
      Utils.showLog("Search Sound Method Calling...");

      isSearchLoading = true;
      update(["onSearchSound"]);

      searchSoundModel = await SearchSoundApi.callApi(loginUserId: Database.loginUserId, searchText: searchController.text);

      if (searchSoundModel?.searchData != null) {
        searchSounds.clear();
        searchSounds.addAll(searchSoundModel?.searchData ?? []);
        isSearchLoading = false;
        update(["onSearchSound"]);
      }
    }
  }

  Future<void> initAllSound() async {
    mainSoundCollection.clear();
    FetchAllSoundApi.startPagination = 0;
    hasMoreSound = true;

    onGetAllSound();
  }

  Future<void> onGetAllSound() async {
    if (!hasMoreSound) return;

    if (mainSoundCollection.isEmpty) {
      isLoadingSound = true;
      update(["onGetAllSound"]);
    } else {
      isLoadingMoreSound = true;
      update(["onGetAllSound"]);
    }

    fetchAllSoundModel = null;
    fetchAllSoundModel = await FetchAllSoundApi.callApi(loginUserId: Database.loginUserId);

    if (fetchAllSoundModel?.songs != null) {
      final newSongs = fetchAllSoundModel?.songs ?? [];
      isLoadingSound = false;
      isLoadingMoreSound = false;
      mainSoundCollection.addAll(newSongs);

      if (newSongs.length < FetchAllSoundApi.limitPagination) {
        hasMoreSound = false;
      } else {
        FetchAllSoundApi.startPagination += FetchAllSoundApi.limitPagination;
      }

      Utils.showLog("All Sound Length => ${mainSoundCollection.length}");
    } else {
      isLoadingSound = false;
      isLoadingMoreSound = false;
    }
    update(["onGetAllSound"]);
  }

  Future<void> initFavoriteSound() async {
    favoriteSoundCollection.clear();
    FetchFavoriteSoundApi.startPagination = 0;
    onGetFavoriteSound();
  }

  Future<void> onGetFavoriteSound() async {
    if (favoriteSoundCollection.isEmpty) {
      isLoadingFavoriteSound = true;
      update(["onGetFavoriteSound"]);
    }

    fetchFavoriteSoundModel = null;
    fetchFavoriteSoundModel = await FetchFavoriteSoundApi.callApi(loginUserId: Database.loginUserId);

    if (fetchFavoriteSoundModel?.songs != null) {
      isLoadingFavoriteSound = false;

      favoriteSoundCollection.addAll(fetchFavoriteSoundModel?.songs ?? []);

      Utils.showLog("Favorite Sound Length => ${favoriteSoundCollection.length}");
    }
    update(["onGetFavoriteSound"]);
  }

  AudioPlayer audioPlayer = AudioPlayer();

  // // Audio handling improvements
  // Future<void> onChangeSound(Map sound) async {
  //   if (selectedSound?["id"] == sound["id"]) {
  //     await onPauseAudio();
  //     selectedSound = null;
  //     update(["onChangeSound"]);
  //   } else {
  //     await onPauseAudio();
  //     selectedSound = {
  //       "id": sound["id"],
  //       "name": sound["name"],
  //       "image": sound["image"],
  //       "link": sound["link"],
  //     };
  //     update(["onChangeSound"]);
  //     await initAudio(sound["link"]);
  //     await onResumeAudio();
  //   }
  // }

  Future<void> onChangeSound(Map<String, dynamic> soundData) async {
    log("Selected Sound Data: $soundData");

    log("Selected Sound Data: ${soundData["link"]}");

    selectedSound = soundData;

    initAudio(soundData["link"]);

    // Play the new audio
    onResumeAudio();
    update(["onChangeSound"]);

    // Close the current bottom sheet first
    Get.back();

    // Show the selected music sheet with pre-selected duration
    handleMusicSelection(isAutoPlay: true);
  }

  Future<void> initAudio(String audio) async {
    try {
      await audioPlayer.stop();

      await audioPlayer.setSource(UrlSource(audio));
      Utils.showLog("Audio initialized successfully =>  $audio");
    } catch (e) {
      Utils.showLog("Audio initialization failed: $e");
      // Handle initialization failure gracefully
      selectedSound = null;
      update(["onChangeSound"]);
    }
  }

  // Enhanced pause method
  Future<void> onPauseAudio() async {
    try {
      if (audioPlayer.state == PlayerState.playing) {
        await audioPlayer.pause();
        Utils.showLog("Audio paused successfully");
      }
    } catch (e) {
      Utils.showLog("Audio Pause Error => $e");
    }
  }

  // Enhanced resume method
  Future<void> onResumeAudio() async {
    try {
      if (selectedSound != null && audioPlayer.state == PlayerState.paused) {
        await audioPlayer.resume();
        Utils.showLog("Audio resumed successfully");
      }
    } catch (e) {
      Utils.showLog("Audio Resume Error => $e");
    }
  }

  // Enhanced restart method
  Future<void> onRestartAudio() async {
    try {
      if (selectedSound != null) {
        await audioPlayer.seek(const Duration(milliseconds: 0));
        await audioPlayer.resume();
        Utils.showLog("Audio restarted successfully");
      }
    } catch (e) {
      Utils.showLog("Audio Restart Error => $e");
    }
  }

  // Method to get audio file path for video composition
  String? getSelectedAudioPath() {
    return selectedSound?["link"];
  }

  // Method to stop all audio (useful when creating video)
  Future<void> stopAllAudio() async {
    try {
      await audioPlayer.stop();
      Utils.showLog("All audio stopped");
    } catch (e) {
      Utils.showLog("Error stopping audio: $e");
    }
  }

  Future<void> onPlayAudio(String audioPath) async {
    try {
      update();

      // Stop current audio if playing
      await audioPlayer.stop();

      // Play new audio
      if (audioPath.startsWith('http')) {
        await audioPlayer.play(UrlSource(audioPath));
      } else {
        await audioPlayer.play(DeviceFileSource(audioPath));
      }

      update();

      print('Audio playing: $audioPath');
    } catch (e) {
      update(["onChangeSound", "audioControls"]);
      print('Error playing audio: $e');
    }
  }

  // Enhanced audio listener setup
  void setupAudioListeners() {
    // Listen for when audio completes
    audioPlayer.onPlayerComplete.listen((event) {
      // Restart the audio when it completes (loop)
      onRestartAudio();
      update(["onChangeSound"]);
    });

    // Listen for audio state changes
    audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      Utils.showLog("Audio state changed: $state");
      update(["onChangeSound"]);
    });

    // Listen for audio duration changes
    audioPlayer.onDurationChanged.listen((Duration duration) {
      Utils.showLog("Audio duration: ${duration.inSeconds}s");
    });

    // Listen for position changes
    audioPlayer.onPositionChanged.listen((Duration position) {
      // You can use this for progress indicators if needed
    });
  }

  Future<void> uploadStoryToServer({
    required String outputPath,
    required bool isVideo,
    required String backgroundSong,
    required int duration,
  }) async {
    try {
      print('Starting upload to server...');

      // You'll need to get the current user ID - replace this with your actual user ID logic
      String userId = Database.loginUserId; // You need to implement this method

      // First, upload the file to your storage service
      String? uploadedUrl = await _uploadFileToStorage(outputPath, isVideo);

      if (uploadedUrl != null) {
        print('File uploaded to storage: $uploadedUrl');

        // Call the API to save story details
        final result = await UploadStoryApi.callApi(
          userId: userId,
          backgroundSong: backgroundSong,
          mediaImageUrl: uploadedUrl,
          mediaVideoUrl: "",
          isVideo: isVideo,
          duration: duration,
        );

        if (result != null) {
          print('Story uploaded successfully');

          // Show success message

          Utils.showToast("Story uploaded successfully");
          Get.close(3);

          // Call the original onDone callback if needed
          // widget.onDone!(outputPath);

          // Optionally navigate back or to another screen
          // Navigator.of(context).pop();
        } else {
          _showErrorDialog('Failed to upload story. Please try again.');
        }
      } else {
        _showErrorDialog('Failed to upload file. Please check your internet connection.');
      }
    } catch (e) {
      print('Error uploading story: $e');
      _showErrorDialog('Upload failed: ${e.toString()}');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: Get.context!,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<String?> _uploadFileToStorage(String filePath, bool isVideo) async {
    try {
      print('Uploading file to storage: $filePath');

      // Create a unique key name for the file
      String keyName = 'story_${DateTime.now().millisecondsSinceEpoch}_${isVideo ? 'video' : 'image'}';

      // Use fileType 8 for story content (based on your fileUploadType method)
      int fileType = 8; // This corresponds to Api.storyContent

      // Call your existing upload API
      String? uploadedUrl = await UploadFileApi.callApi(
        filePath: filePath,
        fileType: fileType,
        keyName: keyName,
      );

      if (uploadedUrl != null && uploadedUrl.isNotEmpty) {
        print('File uploaded successfully: $uploadedUrl');
        return uploadedUrl;
      } else {
        print('Upload failed: No URL returned');
        return null;
      }
    } catch (e) {
      print('Error uploading file: $e');
      return null;
    }
  }
}

class VideoCompositionService {
  //NEW METHOD: Create video with music (replacing original audio)
  // static Future<String?> createVideoWithMusic({
  //   required String videoPath,
  //   required String audioPath,
  //   required String fileName,
  // }) async {
  //   try {
  //     print('Starting video creation with music merge...');
  //
  //     // Get app documents directory
  //     Directory appDir = await getApplicationDocumentsDirectory();
  //     String tempDirPath = '${appDir.path}/temp_videos';
  //     Directory tempDir = Directory(tempDirPath);
  //
  //     if (!await tempDir.exists()) {
  //       await tempDir.create(recursive: true);
  //     }
  //
  //     String outputPath = '${tempDir.path}/${fileName}_with_music.mp4';
  //
  //     // Remove output file if it exists
  //     File outputFile = File(outputPath);
  //     if (await outputFile.exists()) {
  //       await outputFile.delete();
  //     }
  //
  //     // First, get video duration
  //     int? videoDuration = await _getVideoDuration(videoPath);
  //     if (videoDuration == null) {
  //       throw Exception('Could not determine video duration');
  //     }
  //
  //     print('Video duration: ${videoDuration}s');
  //
  //     // FFmpeg command to replace video audio with selected music
  //     List<String> ffmpegArgs = [
  //       '-y', // Overwrite output file
  //
  //       // Input 1: Original video
  //       '-i', videoPath,
  //
  //       // Input 2: Music audio
  //       '-i', audioPath,
  //
  //       // Map video from input 0, audio from input 1
  //       '-map', '0:v', // Video from first input
  //       '-map', '1:a', // Audio from second input
  //
  //       // Video codec settings (copy to avoid re-encoding)
  //       '-c:v', 'copy',
  //
  //       // Audio codec settings
  //       '-c:a', 'aac',
  //       '-b:a', '192k',
  //       '-ar', '44100',
  //
  //       // Set video duration (trim if audio is longer)
  //       '-t', videoDuration.toString(),
  //
  //       // Use shortest stream (video or audio)
  //       '-shortest',
  //
  //       // Output file
  //       outputPath
  //     ];
  //
  //     print('FFmpeg command: ffmpeg ${ffmpegArgs.join(' ')}');
  //
  //     // Execute FFmpeg command
  //     var session = await FFmpegKit.executeWithArguments(ffmpegArgs);
  //     var returnCode = await session.getReturnCode();
  //     var logs = await session.getAllLogs();
  //
  //     print('FFmpeg return code: ${returnCode?.getValue()}');
  //
  //     // Print logs for debugging
  //     for (Log log in logs) {
  //       String message = log.getMessage();
  //       if (message.contains('Duration:') || message.contains('Stream #') || message.contains('time=') || message.contains('Error') || message.contains('Warning')) {
  //         print('FFmpeg: $message');
  //       }
  //     }
  //
  //     if (ReturnCode.isSuccess(returnCode)) {
  //       if (await File(outputPath).exists()) {
  //         int outputSize = await File(outputPath).length();
  //         print('Video with music created successfully: $outputPath (${outputSize} bytes)');
  //         return outputPath;
  //       } else {
  //         throw Exception('Output video file was not created');
  //       }
  //     } else {
  //       String errorLogs =
  //           logs.where((log) => log.getMessage().contains('Error') || log.getMessage().contains('failed') || log.getMessage().contains('Invalid')).map((log) => log.getMessage()).join('\n');
  //
  //       throw Exception('FFmpeg failed with return code: ${returnCode?.getValue()}\nErrors: $errorLogs');
  //     }
  //   } catch (e) {
  //     print('Error in createVideoWithMusic: $e');
  //     return null;
  //   }
  // }

  // static Future<String?> createVideoWithMusic({
  //   required String videoPath,
  //   required String audioPath,
  //   required String fileName,
  // }) async {
  //   try {
  //     final Directory appDir = await getTemporaryDirectory();
  //     final String outputPath = "${appDir.path}/$fileName";
  //
  //     // Fix: -y to overwrite output, map streams properly
  //     final String command = '''
  //       -y -i "$videoPath" -i "$audioPath" -c:v copy -c:a aac -map 0:v:0 -map 1:a:0 -shortest "$outputPath"
  //     ''';
  //
  //     final session = await FFmpegKit.execute(command);
  //     final returnCode = await session.getReturnCode();
  //
  //     if (returnCode?.isValueSuccess() == true && File(outputPath).existsSync()) {
  //       return outputPath;
  //     } else {
  //       final logs = await session.getAllLogsAsString();
  //       print("FFmpeg failed: $logs");
  //     }
  //   } catch (e) {
  //     print("Error merging video and audio: $e");
  //   }
  //   return null;
  // }

  static Future<String?> createVideoWithMusic({
    required String videoPath,
    required String audioPath,
    required String fileName,
  }) async {
    final String path = '${(await getTemporaryDirectory()).path}/FV_${DateTime.now().millisecondsSinceEpoch}.mp4';

    final double? videoTime = (await CustomVideoTime.onGet(videoPath) ?? 0).toDouble();
    final double soundTime = await onGetSoundTime(audioPath) ?? 0.0;

    if (soundTime != 0 && videoTime != null && videoTime != 0) {
      final num minTime = (videoTime < soundTime) ? videoTime : soundTime;

      final String command = '-y -i "$videoPath" -i "$audioPath" -t $minTime -c:v copy -c:a aac -map 0:v:0 -map 1:a:0 -shortest "$path"';

      final session = await FFmpegKit.execute(command);
      final returnCode = await session.getReturnCode();

      if (returnCode?.isValueSuccess() == true && File(path).existsSync()) {
        return path;
      } else {
        final logs = await session.getAllLogsAsString();
        print("FFmpeg failed: $logs");
      }
    }

    return null;
  }

  static Future<double?> onGetSoundTime(String videoPath) async {
    try {
      final session = await FFprobeKit.getMediaInformation(videoPath);
      final info = session.getMediaInformation();
      if (info != null) {
        final durationStr = info.getDuration(); // e.g. "12.345"
        final duration = double.tryParse(durationStr ?? "");
        print("🎥 Video Duration: $duration seconds");
        return duration;
      } else {
        print("❌ Could not get video info");
        return null;
      }
    } catch (e) {
      print("❌ Error getting video duration: $e");
      return null;
    }
  }

  static Future<String?> createVideoWithMusicFromUrl({
    required String videoPath,
    required String audioUrl,
    required String fileName,
  }) async {
    try {
      // Step 1: Get temp directory
      final tempDir = await getTemporaryDirectory();

      // Step 2: Download audio
      final audioResponse = await http.get(Uri.parse(audioUrl));
      if (audioResponse.statusCode != 200) {
        throw Exception('Failed to download audio. Status: ${audioResponse.statusCode}');
      }

      final audioFilePath = p.join(tempDir.path, '${fileName}_downloaded_audio.m4a');
      final audioFile = File(audioFilePath);
      await audioFile.writeAsBytes(audioResponse.bodyBytes);

      print(' music created successfully: $audioFilePath ,  video: $videoPath  File: $fileName');

      // Step 3: Call createVideoWithMusic with the downloaded audio
      return await createVideoWithMusic(
            videoPath: videoPath,
            audioPath: audioFilePath,
            fileName: fileName,
          ) ??
          "";
    } catch (e) {
      print('❌ Error in createVideoWithMusicFromUrl: $e');
      return null;
    }
  }

  // METHOD: Create video with music (looped if shorter than video)
  static Future<String?> createVideoWithLoopedMusic({
    required String videoPath,
    required String audioPath,
    required String fileName,
  }) async {
    try {
      print('Starting video creation with looped music...');

      Directory appDir = await getApplicationDocumentsDirectory();
      String tempDirPath = '${appDir.path}/temp_videos';
      Directory tempDir = Directory(tempDirPath);

      if (!await tempDir.exists()) {
        await tempDir.create(recursive: true);
      }

      String outputPath = '${tempDir.path}/${fileName}_with_looped_music.mp4';

      // Remove output file if it exists
      File outputFile = File(outputPath);
      if (await outputFile.exists()) {
        await outputFile.delete();
      }

      // Get video duration
      int? videoDuration = await _getVideoDuration(videoPath);
      if (videoDuration == null) {
        throw Exception('Could not determine video duration');
      }

      // FFmpeg command with looped audio
      List<String> ffmpegArgs = [
        '-y',

        // Input 1: Video
        '-i', videoPath,

        // Input 2: Audio (with infinite loop)
        '-stream_loop', '-1',
        '-i', audioPath,

        // Map streams
        '-map', '0:v',
        '-map', '1:a',

        // Codecs
        '-c:v', 'copy',
        '-c:a', 'aac',
        '-b:a', '192k',

        // Duration (match video length)
        '-t', videoDuration.toString(),

        // Stop when shortest stream ends
        '-shortest',

        outputPath
      ];

      print('FFmpeg command: ffmpeg ${ffmpegArgs.join(' ')}');

      var session = await FFmpegKit.executeWithArguments(ffmpegArgs);
      var returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        if (await File(outputPath).exists()) {
          print('Video with looped music created successfully: $outputPath');
          return outputPath;
        }
      }

      throw Exception('Failed to create video with looped music');
    } catch (e) {
      print('Error in createVideoWithLoopedMusic: $e');
      return null;
    }
  }

  // METHOD: Mix video audio with music (both audible)
  static Future<String?> createVideoWithMixedAudio({
    required String videoPath,
    required String audioPath,
    required String fileName,
    double videoVolume = 0.3, // 30% original video audio
    double musicVolume = 0.7, // 70% music audio
  }) async {
    try {
      print('Starting video creation with mixed audio...');

      Directory appDir = await getApplicationDocumentsDirectory();
      String tempDirPath = '${appDir.path}/temp_videos';
      Directory tempDir = Directory(tempDirPath);

      if (!await tempDir.exists()) {
        await tempDir.create(recursive: true);
      }

      String outputPath = '${tempDir.path}/${fileName}_mixed_audio.mp4';

      // Remove output file if it exists
      File outputFile = File(outputPath);
      if (await outputFile.exists()) {
        await outputFile.delete();
      }

      // Get video duration
      int? videoDuration = await _getVideoDuration(videoPath);
      if (videoDuration == null) {
        throw Exception('Could not determine video duration');
      }

      // Complex FFmpeg command for audio mixing
      List<String> ffmpegArgs = [
        '-y',

        // Input 1: Video with original audio
        '-i', videoPath,

        // Input 2: Music audio (looped)
        '-stream_loop', '-1',
        '-i', audioPath,

        // Video codec
        '-c:v', 'copy',

        // Audio filter: mix both audio streams
        '-filter_complex',
        '[0:a]volume=${videoVolume}[a1];[1:a]volume=${musicVolume}[a2];[a1][a2]amix=inputs=2:duration=first:dropout_transition=2',

        // Audio codec
        '-c:a', 'aac',
        '-b:a', '192k',

        // Duration
        '-t', videoDuration.toString(),

        outputPath
      ];

      print('FFmpeg command: ffmpeg ${ffmpegArgs.join(' ')}');

      var session = await FFmpegKit.executeWithArguments(ffmpegArgs);
      var returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        if (await File(outputPath).exists()) {
          print('Video with mixed audio created successfully: $outputPath');
          return outputPath;
        }
      }

      throw Exception('Failed to create video with mixed audio');
    } catch (e) {
      print('Error in createVideoWithMixedAudio: $e');
      return null;
    }
  }

  // HELPER METHOD: Get video duration in seconds
  static Future<int?> _getVideoDuration(String videoPath) async {
    try {
      var session = await FFmpegKit.execute('-i "$videoPath" -f null -');
      var logs = await session.getAllLogs();

      for (Log log in logs) {
        String message = log.getMessage();
        if (message.contains('Duration:')) {
          // Extract duration from format: Duration: 00:00:10.50
          RegExp regExp = RegExp(r'Duration: (\d{2}):(\d{2}):(\d{2})\.(\d{2})');
          Match? match = regExp.firstMatch(message);

          if (match != null) {
            int hours = int.parse(match.group(1)!);
            int minutes = int.parse(match.group(2)!);
            int seconds = int.parse(match.group(3)!);

            int totalSeconds = (hours * 3600) + (minutes * 60) + seconds;
            print('Video duration extracted: ${totalSeconds}s');
            return totalSeconds;
          }
        }
      }

      return null;
    } catch (e) {
      print('Error getting video duration: $e');
      return null;
    }
  }

  // ORIGINAL METHOD: Create video from image and audio (for stories)
  static Future<String?> createVideoWithImageAndAudio({
    required GlobalKey contentKey,
    required String? audioPath,
    required int durationInSeconds,
    required String fileName,
    bool useDirectUrl = true,
    double? startTime,
    double? endTime,
  }) async {
    try {
      print('Starting video creation process...');
      if (startTime != null && endTime != null) {
        audioPath = await _trimAudio(audioPath ?? "", startTime, endTime);
      }
      // Step 1: Capture the current design as image
      String imagePath = await _captureDesignAsImage(contentKey, fileName);
      print('Image captured at: $imagePath');

      // Verify image file exists and has content
      File imageFile = File(imagePath);
      if (!await imageFile.exists()) {
        throw Exception('Captured image file does not exist');
      }

      int imageSize = await imageFile.length();
      print('Image file size: $imageSize bytes');

      if (imageSize == 0) {
        throw Exception('Captured image file is empty');
      }

      // Step 2: Create video from image and audio
      String videoPath = await _createVideoFromImageAndAudio(
        imagePath: imagePath,
        audioPath: audioPath,
        durationInSeconds: durationInSeconds,
        fileName: fileName,
        useDirectUrl: useDirectUrl,
      );

      return videoPath;
    } catch (e) {
      print('Error creating video: $e');
      return null;
    }
  }

  static Future<String> _trimAudio(String audioPath, double startTime, double endTime) async {
    try {
      // Use FFmpeg or similar to trim audio
      // This is a placeholder - implement according to your audio processing library

      Directory appDir = await getApplicationDocumentsDirectory();
      String trimmedPath = '${appDir.path}/trimmed_audio_${DateTime.now().millisecondsSinceEpoch}.mp3';

      // Example FFmpeg command (if you're using ffmpeg_kit_flutter):
      await FFmpegKit.execute('-i "$audioPath" -ss $startTime -t ${endTime - startTime} -c copy "$trimmedPath"');

      return trimmedPath;
    } catch (e) {
      print('Error trimming audio: $e');
      return audioPath; // Return original if trimming fails
    }
  }

  static Future<String> _captureDesignAsImage(GlobalKey contentKey, String fileName) async {
    try {
      print('Capturing design as image...');

      // Ensure the widget is built and rendered
      await Future.delayed(const Duration(milliseconds: 100));

      if (contentKey.currentContext == null) {
        throw Exception('Content key context is null');
      }

      // Get the render boundary
      RenderObject? renderObject = contentKey.currentContext!.findRenderObject();
      if (renderObject == null) {
        throw Exception('Render object not found');
      }

      if (renderObject is! RenderRepaintBoundary) {
        throw Exception('Render object is not a RenderRepaintBoundary');
      }

      RenderRepaintBoundary boundary = renderObject;

      // Convert to image with high quality
      ui.Image image = await boundary.toImage(pixelRatio: 2.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        throw Exception('Failed to convert image to byte data');
      }

      Uint8List pngBytes = byteData.buffer.asUint8List();
      print('Image captured, size: ${pngBytes.length} bytes');

      // Get app documents directory for better file management
      Directory appDir = await getApplicationDocumentsDirectory();
      String tempDirPath = '${appDir.path}/temp_videos';
      Directory tempDir = Directory(tempDirPath);

      // Create directory if it doesn't exist
      if (!await tempDir.exists()) {
        await tempDir.create(recursive: true);
      }

      String imagePath = '${tempDir.path}/${fileName}_design.png';
      File imageFile = File(imagePath);
      await imageFile.writeAsBytes(pngBytes);

      print('Image saved to: $imagePath');
      return imagePath;
    } catch (e) {
      print('Error capturing design as image: $e');
      throw Exception('Failed to capture design as image: $e');
    }
  }

  static Future<String> _createVideoFromImageAndAudio({
    required String imagePath,
    required String? audioPath,
    required int durationInSeconds,
    required String fileName,
    bool useDirectUrl = true,
  }) async {
    try {
      print('Creating video from image and audio...');
      print('Image path: $imagePath');
      print('Audio path: $audioPath');
      print('Duration: ${durationInSeconds}s');

      // Get app documents directory
      Directory appDir = await getApplicationDocumentsDirectory();
      String tempDirPath = '${appDir.path}/temp_videos';
      Directory tempDir = Directory(tempDirPath);

      if (!await tempDir.exists()) {
        await tempDir.create(recursive: true);
      }

      String outputPath = '${tempDir.path}/${fileName}_final_video.mp4';

      // Remove output file if it exists
      File outputFile = File(outputPath);
      if (await outputFile.exists()) {
        await outputFile.delete();
      }

      List<String> ffmpegArgs = [];

      if (audioPath != null && audioPath.isNotEmpty) {
        // CORRECTED: Proper FFmpeg command for video with audio
        ffmpegArgs = [
          '-y', // Overwrite output file

          // Input 1: Image (looped)
          '-loop', '1',
          '-i', imagePath,

          // Input 2: Audio
          '-i', audioPath,

          // Video encoding settings
          '-c:v', 'libx264',
          '-tune', 'stillimage',
          '-pix_fmt', 'yuv420p',
          '-r', '30', // Frame rate

          // Video filters (scaling and padding)
          '-vf', 'scale=1080:1920:force_original_aspect_ratio=decrease,pad=1080:1920:(ow-iw)/2:(oh-ih)/2:black',

          // Audio encoding settings
          '-c:a', 'aac',
          '-b:a', '192k',
          '-ar', '44100', // Audio sample rate

          // IMPORTANT: Duration control - this ensures video is exactly the specified duration
          '-t', durationInSeconds.toString(),

          // Map streams explicitly
          '-map', '0:v', // Map video from input 0 (image)
          '-map', '1:a', // Map audio from input 1 (audio file)

          // Output file
          outputPath
        ];
      } else {
        // Create silent video
        ffmpegArgs = [
          '-y',
          '-loop',
          '1',
          '-i',
          imagePath,
          '-c:v',
          'libx264',
          '-tune',
          'stillimage',
          '-pix_fmt',
          'yuv420p',
          '-vf',
          'scale=1080:1920:force_original_aspect_ratio=decrease,pad=1080:1920:(ow-iw)/2:(oh-ih)/2:black',
          '-r',
          '30',
          '-t',
          durationInSeconds.toString(),
          outputPath
        ];
      }

      print('FFmpeg command: ffmpeg ${ffmpegArgs.join(' ')}');

      // Execute FFmpeg command
      var session = await FFmpegKit.executeWithArguments(ffmpegArgs);
      var returnCode = await session.getReturnCode();
      var logs = await session.getAllLogs();

      print('FFmpeg return code: ${returnCode?.getValue()}');

      // Print logs for debugging
      for (Log log in logs) {
        String message = log.getMessage();
        if (message.contains('Duration:') || message.contains('Stream #') || message.contains('time=') || message.contains('Error') || message.contains('Warning')) {
          print('FFmpeg: $message');
        }
      }

      if (ReturnCode.isSuccess(returnCode)) {
        if (await File(outputPath).exists()) {
          int outputSize = await File(outputPath).length();
          print('Video created successfully: $outputPath (${outputSize} bytes)');

          // Verify the video duration using FFprobe (optional but helpful for debugging)
          await _verifyVideoDuration(outputPath, durationInSeconds);

          // Clean up temporary image file
          try {
            await File(imagePath).delete();
            print('Temporary image file deleted');
          } catch (e) {
            print('Warning: Could not delete temporary image file: $e');
          }

          return outputPath;
        } else {
          throw Exception('Output video file was not created');
        }
      } else {
        String errorLogs =
            logs.where((log) => log.getMessage().contains('Error') || log.getMessage().contains('failed') || log.getMessage().contains('Invalid')).map((log) => log.getMessage()).join('\n');

        throw Exception('FFmpeg failed with return code: ${returnCode?.getValue()}\nErrors: $errorLogs');
      }
    } catch (e) {
      print('Error in _createVideoFromImageAndAudio: $e');
      throw Exception('Failed to create video: $e');
    }
  }

  static Future<void> _verifyVideoDuration(String videoPath, int expectedDuration) async {
    try {
      var session = await FFmpegKit.execute('-i "$videoPath" -f null -');
      var logs = await session.getAllLogs();

      for (Log log in logs) {
        String message = log.getMessage();
        if (message.contains('Duration:')) {
          print('Video info: $message');
          break;
        }
      }
    } catch (e) {
      print('Could not verify video duration: $e');
    }
  }

  // METHOD: Extract audio from video
  static Future<String?> extractAudioFromVideo({
    required String videoPath,
    required String fileName,
  }) async {
    try {
      print('Extracting audio from video...');

      Directory appDir = await getApplicationDocumentsDirectory();
      String tempDirPath = '${appDir.path}/temp_videos';
      Directory tempDir = Directory(tempDirPath);

      if (!await tempDir.exists()) {
        await tempDir.create(recursive: true);
      }

      String outputPath = '${tempDir.path}/${fileName}_extracted_audio.aac';

      // Remove output file if it exists
      File outputFile = File(outputPath);
      if (await outputFile.exists()) {
        await outputFile.delete();
      }

      List<String> ffmpegArgs = [
        '-y',
        '-i', videoPath,
        '-vn', // No video
        '-acodec', 'aac',
        '-b:a', '192k',
        outputPath
      ];

      var session = await FFmpegKit.executeWithArguments(ffmpegArgs);
      var returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        if (await File(outputPath).exists()) {
          print('Audio extracted successfully: $outputPath');
          return outputPath;
        }
      }

      throw Exception('Failed to extract audio from video');
    } catch (e) {
      print('Error extracting audio: $e');
      return null;
    }
  }

  // METHOD: Get audio duration
  static Future<int?> getAudioDuration(String audioPath) async {
    try {
      var session = await FFmpegKit.execute('-i "$audioPath" -f null -');
      var logs = await session.getAllLogs();

      for (Log log in logs) {
        String message = log.getMessage();
        if (message.contains('Duration:')) {
          // Extract duration from format: Duration: 00:00:10.50
          RegExp regExp = RegExp(r'Duration: (\d{2}):(\d{2}):(\d{2})\.(\d{2})');
          Match? match = regExp.firstMatch(message);

          if (match != null) {
            int hours = int.parse(match.group(1)!);
            int minutes = int.parse(match.group(2)!);
            int seconds = int.parse(match.group(3)!);

            int totalSeconds = (hours * 3600) + (minutes * 60) + seconds;
            print('Audio duration extracted: ${totalSeconds}s');
            return totalSeconds;
          }
        }
      }

      return null;
    } catch (e) {
      print('Error getting audio duration: $e');
      return null;
    }
  }

  // METHOD: Trim audio to specific duration
  static Future<String?> trimAudio({
    required String audioPath,
    required int startSeconds,
    required int durationSeconds,
    required String fileName,
  }) async {
    try {
      print('Trimming audio: start=${startSeconds}s, duration=${durationSeconds}s');

      Directory appDir = await getApplicationDocumentsDirectory();
      String tempDirPath = '${appDir.path}/temp_videos';
      Directory tempDir = Directory(tempDirPath);

      if (!await tempDir.exists()) {
        await tempDir.create(recursive: true);
      }

      String outputPath = '${tempDir.path}/${fileName}_trimmed.aac';

      // Remove output file if it exists
      File outputFile = File(outputPath);
      if (await outputFile.exists()) {
        await outputFile.delete();
      }

      List<String> ffmpegArgs = [
        '-y',
        '-ss', startSeconds.toString(), // Start time
        '-i', audioPath,
        '-t', durationSeconds.toString(), // Duration
        '-c:a', 'aac',
        '-b:a', '192k',
        outputPath
      ];

      var session = await FFmpegKit.executeWithArguments(ffmpegArgs);
      var returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        if (await File(outputPath).exists()) {
          print('Audio trimmed successfully: $outputPath');
          return outputPath;
        }
      }

      throw Exception('Failed to trim audio');
    } catch (e) {
      print('Error trimming audio: $e');
      return null;
    }
  }

  // METHOD: Clean up temporary files
  static Future<void> cleanupTempFiles() async {
    try {
      Directory appDir = await getApplicationDocumentsDirectory();
      String tempDirPath = '${appDir.path}/temp_videos';
      Directory tempDir = Directory(tempDirPath);

      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
        print('Temporary files cleaned up');
      }
    } catch (e) {
      print('Error cleaning up temporary files: $e');
    }
  }
}

// UTILITY CLASS: Audio Management
class AudioManagementService {
  // Download audio from URL if needed
  static Future<String?> prepareAudioFile(String audioUrl) async {
    try {
      if (audioUrl.startsWith('http')) {
        // Download the audio file
        return await _downloadAudio(audioUrl);
      } else {
        // Local file path
        return audioUrl;
      }
    } catch (e) {
      print('Error preparing audio file: $e');
      return null;
    }
  }

  static Future<String?> _downloadAudio(String url) async {
    try {
      // Implement audio download logic here
      // You can use dio package or http package
      print('Downloading audio from: $url');

      // For now, returning the URL (assuming it's accessible)
      return url;
    } catch (e) {
      print('Error downloading audio: $e');
      return null;
    }
  }
}

// IMAGE CREATION SERVICE (Enhanced)
class ImageCreationService {
  static Future<String?> createImageFromContent({
    required GlobalKey contentKey,
    required String fileName,
  }) async {
    try {
      print('Creating image from content...');

      // Ensure the widget is built and rendered
      await Future.delayed(const Duration(milliseconds: 100));

      if (contentKey.currentContext == null) {
        throw Exception('Content key context is null');
      }

      // Get the render boundary
      RenderObject? renderObject = contentKey.currentContext!.findRenderObject();
      if (renderObject == null) {
        throw Exception('Render object not found');
      }

      if (renderObject is! RenderRepaintBoundary) {
        throw Exception('Render object is not a RenderRepaintBoundary');
      }

      RenderRepaintBoundary boundary = renderObject;

      // Convert to image with high quality
      ui.Image image = await boundary.toImage(pixelRatio: 3.0); // Higher quality
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        throw Exception('Failed to convert image to byte data');
      }

      Uint8List pngBytes = byteData.buffer.asUint8List();
      print('Image captured, size: ${pngBytes.length} bytes');

      // Get app documents directory
      Directory appDir = await getApplicationDocumentsDirectory();
      String imagesDirPath = '${appDir.path}/story_images';
      Directory imagesDir = Directory(imagesDirPath);

      // Create directory if it doesn't exist
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }

      // Save as PNG image
      String imagePath = '${imagesDir.path}/${fileName}_story.png';
      File imageFile = File(imagePath);
      await imageFile.writeAsBytes(pngBytes);

      print('Image saved to: $imagePath');

      // Verify the saved file
      if (await imageFile.exists() && await imageFile.length() > 0) {
        return imagePath;
      } else {
        throw Exception('Failed to save image file');
      }
    } catch (e) {
      print('Error creating image: $e');
      return null;
    }
  }
}

class CustomVideoTime {
  static VideoPlayerController? _videoPlayerController;

  static Future<int?> onGet(String videoPath) async {
    try {
      _videoPlayerController?.dispose();
      _videoPlayerController = null;

      _videoPlayerController = VideoPlayerController.file(File(videoPath));
      await _videoPlayerController?.initialize();
      if (_videoPlayerController!.value.isInitialized) {
        final videoTime = _videoPlayerController?.value.duration.inSeconds;
        Utils.showLog("Get Video Time => $videoTime");
        return videoTime;
      } else {
        Utils.showLog("Get Video Time Error => Video Not Initialize");
        return null;
      }
    } catch (e) {
      Utils.showLog("Get Video Time Error => $e");
      return null;
    }
  }
}
