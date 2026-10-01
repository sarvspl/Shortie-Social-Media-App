import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:math' as math;
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shortie/main.dart';
import 'package:shortie/ui/app_button_ui.dart';
import 'package:shortie/utils/color.dart';
import 'package:shortie/utils/font_style.dart';

class SelectedMusicSheet extends StatelessWidget {
  final Map<String, dynamic> selectedMusic;
  final int preSelectedDuration; // Duration to select (e.g., 10 seconds)
  final bool isAutoPlay;

  const SelectedMusicSheet({
    super.key,
    required this.selectedMusic,
    required this.preSelectedDuration,
    required this.isAutoPlay,
  });

  @override
  Widget build(BuildContext context) {
    log("selectedMusic>>>>> ${selectedMusic["link"]}");

    print("4545454545 => ${Get.isRegistered<SelectedMusicSheetController>()}");

    final controller = Get.put(SelectedMusicSheetController());

    controller.init(preSelectedDuration: preSelectedDuration, selectedMusic: selectedMusic, isAutoPlay: isAutoPlay);

    return WillPopScope(
      onWillPop: () async {
        controller.onContinueTap();

        return true;
      },
      child: Container(
        height: 430,
        margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        const SizedBox(width: 20),
                        _buildAlbumArt(),
                        const SizedBox(width: 12),
                        _buildMusicInfo(),
                        const SizedBox(width: 22),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        _buildPlayButton(controller),
                        20.width,
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.grey[200]),
                            child: _buildWaveSlider(controller),
                          ),
                        ),
                      ],
                    ).paddingSymmetric(horizontal: 20),
                    const SizedBox(height: 12),
                    _buildDurationDisplay(controller),
                    const SizedBox(height: 40),
                    _buildContinueButton(controller),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 40),
          const Text(
            'Select Music',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Get.back(),
          ),
        ],
      ),
    );
  }

  Widget _buildAlbumArt() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: selectedMusic['image'] != null
            ? Image.network(
                selectedMusic['image'],
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildPlaceholderIcon(),
              )
            : _buildPlaceholderIcon(),
      ),
    );
  }

  Widget _buildPlaceholderIcon() {
    return Container(
      color: Colors.grey[200],
      child: const Icon(Icons.music_note, size: 50, color: Colors.grey),
    );
  }

  Widget _buildMusicInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          selectedMusic['name'] ?? 'Unknown Track',
          style: AppFontStyle.styleW500(Colors.black87, 16),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          '${selectedMusic['singer'] ?? 'Unknown Artist'} • ${_formatDuration(_getTotalDuration())}',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w300,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildDurationDisplay(SelectedMusicSheetController controller) {
    return Obx(() => AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: controller.isPlaying.value ? 0 : 1,
          child: Container(
            height: 30,
            width: 100,
            padding: const EdgeInsets.symmetric(horizontal: 22),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(30),
            ),
            alignment: Alignment.center,
            child: Text(
              _formatDuration((controller.audioStartInMilliSec.value / 1000).toInt()),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.black87,
              ),
            ),
          ).paddingSymmetric(horizontal: 20),
        ));
  }

  Widget _buildWaveSlider(SelectedMusicSheetController controller) {
    return Obx(() {
      if (controller.isDownloading.value) {
        return Container(
          height: 60,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 25, width: 25, child: const CircularProgressIndicator()),
              const SizedBox(height: 8),
              Text(
                'Downloading... ${(controller.downloadProgress.value * 100).toInt()}%',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        );
      }

      if (!controller.isPlayerReady.value) {
        return Container(
          height: 60,
          child: const Center(child: CircularProgressIndicator()),
        );
      }

      return WaveSlider(
        controller: controller,
        audioDuration: controller.durationInMilliSec.value,
        videoDuration: preSelectedDuration,
      );
    });
  }

  Widget _buildPlayButton(SelectedMusicSheetController controller) {
    return Obx(() {
      return InkWell(
        onTap: controller.isDownloading.value ? null : controller.togglePlayback,
        child: Container(
          height: 57,
          width: 57,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: controller.isDownloading.value ? Colors.grey[400] : Colors.grey[200],
          ),
          child: controller.isDownloading.value
              ? const CircularProgressIndicator()
              : Icon(
                  controller.isPlaying.value ? Icons.pause : Icons.play_arrow,
                  size: 35,
                  color: Colors.black87,
                ),
        ),
      );
    });
  }

  Widget _buildContinueButton(SelectedMusicSheetController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        width: double.infinity,
        child: AppButtonUi(
          callback: controller.onContinueTap,
          title: 'Continue',
          height: 50,
          gradient: AppColor.primaryLinearGradient,
          fontSize: 16,
          fontWeight: FontWeight.bold,
          fontColor: Colors.white,
        ),
      ),
    );
  }

  int _getTotalDuration() {
    return selectedMusic['duration'].toInt() ?? 180; // Default to 3 minutes
  }

  String _formatDuration(int seconds) {
    final minutes = (seconds / 60).floor();
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}

class WaveSlider extends StatelessWidget {
  final int audioDuration; // Total audio duration in milliseconds
  final int videoDuration; // Selected duration in seconds (e.g., 10)
  final SelectedMusicSheetController controller;

  const WaveSlider({
    super.key,
    required this.audioDuration,
    required this.videoDuration,
    required this.controller,
  });

  void _onWaveformTap(TapDownDetails details) {
    final localPosition = details.localPosition;

    // Calculate tap position relative to the waveform
    final screenWidth = Get.context!.size!.width;
    // final waveformCenterOffset = (screenWidth / 2) - (controller.boxWidth / 2);

    // Calculate which part of the audio was tapped
    // final totalAudioDuration = controller.durationInMilliSec.value;
    // final maxStartTime = totalAudioDuration - (videoDuration * 1000);

    // Update scroll position based on tap
    final scrollController = controller.scrollController;
    if (scrollController != null && scrollController.hasClients) {
      final maxScroll = scrollController.position.maxScrollExtent;
      final tapProgress = (localPosition.dx / screenWidth).clamp(0.0, 1.0);
      final targetScroll = tapProgress * maxScroll;

      scrollController.animateTo(
        targetScroll,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background with gradient for selected area
          Stack(
            alignment: AlignmentDirectional.centerStart,
            children: [
              Container(
                width: controller.boxWidth,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: AppColor.primaryLinearGradient,
                ),
              ),
              // White overlay that moves to show selection
              SizedBox(
                width: controller.boxWidth,
                height: 50,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    alignment: Alignment.centerRight,
                    width: controller.boxWidth - 4,
                    height: 46,
                    child: Obx(() => AnimatedContainer(
                          duration: Duration(milliseconds: controller.currentProgress.value == 0.0 ? 0 : 100),
                          curve: Curves.easeInOut,
                          width: math.max(0, (controller.boxWidth - 8) * (1 - controller.currentProgress.value)),
                          height: 46,
                          decoration: BoxDecoration(borderRadius: BorderRadius.only(bottomRight: Radius.circular(10), topRight: Radius.circular(10)), color: Colors.white),
                        ).paddingOnly(right: 3)),
                  ),
                ),
              ),
            ],
          ),
          // Wave bars that scroll horizontally
          NotificationListener<ScrollNotification>(
            onNotification: (scrollInfo) {
              if (scrollInfo is ScrollStartNotification) {
                controller.pauseForScroll();
              } else if (scrollInfo is ScrollEndNotification) {
                controller.resumeAfterScroll();
              }
              return true;
            },
            child: GestureDetector(
              onTapDown: (details) => _onWaveformTap(details),
              child: SingleChildScrollView(
                controller: controller.scrollController,
                dragStartBehavior: DragStartBehavior.down,
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: (MediaQuery.of(context).size.width / 2) - (controller.boxWidth / 2) - 60,
                      height: 10,
                    ),
                    ConstrainedBox(
                      constraints: BoxConstraints(minWidth: controller.boxWidth),
                      child: Obx(() => Row(
                            children: List.generate(
                              controller.waves.length,
                              (index) {
                                return Container(
                                  height: controller.waves[index],
                                  margin: EdgeInsets.symmetric(horizontal: controller.barHorizontalMargin),
                                  width: controller.barWidth,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.grey[400],
                                  ),
                                );
                              },
                            ),
                          )),
                    ),
                    SizedBox(
                      width: (MediaQuery.of(context).size.width / 2) - (controller.boxWidth / 2) - 60,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SelectedMusicSheetController extends GetxController {
  Map<String, dynamic> selectedMusic = {};
  int preSelectedDuration = 0;
  bool isAutoPlay = false;

  PlayerController? playerController;
  ScrollController? scrollController;

  final RxInt audioStartInMilliSec = 0.obs;
  final RxInt durationInMilliSec = 0.obs;
  final RxBool isPlaying = false.obs;
  final RxBool isPlayerReady = false.obs;
  final RxBool isDownloading = false.obs;
  final RxDouble downloadProgress = 0.0.obs;
  final RxDouble currentProgress = 0.0.obs;

  // Scroll-related variables
  final RxBool isScrolling = false.obs;
  bool wasPlayingBeforeScroll = false;
  Timer? scrollEndTimer;

  String? localFilePath;
  Timer? _playbackTimer;
  StreamSubscription? _positionSubscription;

  // Wave slider properties
  final double boxWidth = 150.0;
  final double borderWidth = 4.0;
  final double barWidth = 2.0;
  final double barHorizontalMargin = 1.0;
  final RxList<double> waves = <double>[].obs;

  @override
  void onInit() {
    super.onInit();
  }

  void init({
    required Map<String, dynamic> selectedMusic,
    required int preSelectedDuration,
    required bool isAutoPlay,
  }) async {
    this.selectedMusic = selectedMusic;
    this.preSelectedDuration = preSelectedDuration;
    this.isAutoPlay = isAutoPlay;

    await onDispose();
    initAudioPlayer();
  }

  Future<void> onDispose() async {
    await _cleanup();
  }

  initAudioPlayer() async {
    playerController = PlayerController();
    scrollController = ScrollController();
    await initPlayer();
    if (isPlaying.value == false && isAutoPlay) togglePlayback();
  }

  void _setupScrollListener() {
    scrollController?.addListener(() {
      onScrollUpdate();
    });
  }

  @override
  void onClose() {
    super.onClose();
  }

  Future<void> _cleanup() async {
    _playbackTimer?.cancel();
    await _positionSubscription?.cancel();
    scrollEndTimer?.cancel();
    scrollController?.dispose();
    await playerController?.release();
    playerController?.dispose();
  }

  void pauseForScroll() {
    if (isPlaying.value) {
      wasPlayingBeforeScroll = true;
      pause();
    }
    isScrolling.value = true;

    // Cancel any existing timer
    scrollEndTimer?.cancel();
  }

  // Scroll બંધ થયા પછી music resume કરવા માટે
  void resumeAfterScroll() {
    // 300ms delay આપીએ છીએ scroll completely બંધ થવા માટે
    scrollEndTimer?.cancel();
    scrollEndTimer = Timer(const Duration(milliseconds: 300), () {
      isScrolling.value = false;
      if (wasPlayingBeforeScroll) {
        playPause();
        wasPlayingBeforeScroll = false;
      }
    });
  }

  void _generateWaves() {
    // Generate wave bars representing the full audio
    // Calculate exact number of bars needed
    final totalDurationSeconds = (durationInMilliSec.value / 1000).ceil();
    final barsPerSecond = 6; // Increased for smoother look
    final totalBars = math.max(150, totalDurationSeconds * barsPerSecond);

    final random = math.Random();
    waves.value = List.generate(totalBars, (index) {
      // Create more varied wave heights for realistic look
      final baseHeight = 12.0;
      final variation = random.nextDouble() * 20;
      return (baseHeight + variation).clamp(8.0, 32.0);
    });
  }

  void onScrollUpdate() {
    if (scrollController != null && !scrollController!.hasClients) return;

    // Calculate the selected start position based on scroll
    final scrollOffset = scrollController?.offset ?? 0;
    final maxScroll = scrollController?.position.maxScrollExtent ?? 0;
    final totalAudioDuration = durationInMilliSec.value;

    if (maxScroll > 0) {
      final scrollProgress = (scrollOffset / maxScroll).clamp(0.0, 1.0);
      final maxStartTime = totalAudioDuration - (preSelectedDuration * 1000);
      audioStartInMilliSec.value = (scrollProgress * maxStartTime).toInt();
    }
  }

  Future<void> initPlayer() async {
    try {
      await _downloadMusicFile();

      if (localFilePath == null) {
        throw Exception('Failed to download music file');
      }

      await playerController?.preparePlayer(
        path: localFilePath!,
        shouldExtractWaveform: true,
        noOfSamples: 100,
        volume: 1.0,
      );

      final duration = await playerController?.getDuration();

      if (duration != null && duration > 0) {
        durationInMilliSec.value = duration;
        _generateWaves(); // Generate waves after getting duration
        _setupScrollListener(); // Setup scroll listener after waves are generated
        isPlayerReady.value = true;
        print("Player ready! Duration: ${duration}ms");
      } else {
        throw Exception('Could not get audio duration');
      }
    } catch (e) {
      print("Error initializing player: $e");
      _showError("Failed to load audio: $e");
      isPlayerReady.value = false;
    }
  }

  Future<void> _downloadMusicFile() async {
    try {
      isDownloading.value = true;
      downloadProgress.value = 0.0;

      String audioUrl = selectedMusic['link'] ?? '';

      final appDir = await getApplicationDocumentsDirectory();
      final fileName = 'music_${selectedMusic['id']}.mp3';
      final filePath = '${appDir.path}/$fileName';

      final file = File(filePath);
      if (await file.exists()) {
        localFilePath = filePath;
        isDownloading.value = false;
        return;
      }

      final response = await http.get(Uri.parse(audioUrl));

      if (response.statusCode == 200) {
        await file.writeAsBytes(response.bodyBytes);
        localFilePath = filePath;
        downloadProgress.value = 1.0;
      } else {
        throw Exception('Failed to download: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Download failed: $e');
    } finally {
      isDownloading.value = false;
    }
  }

  void _showError(String message) {
    Get.snackbar(
      'Audio Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.withValues(alpha:0.8),
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
    );
  }

  Future<void> togglePlayback() async {
    if (!isPlayerReady.value || isScrolling.value) return;

    if (isPlaying.value) {
      await pause();
    } else {
      await playPause();
    }
  }

  Future<void> playPause() async {
    try {
      if (isPlaying.value) {
        await playerController?.pausePlayer();
        isPlaying.value = false;
        _playbackTimer?.cancel();
        _positionSubscription?.cancel();
      } else {
        // Seek to selected start position
        await playerController?.seekTo(audioStartInMilliSec.value);
        await playerController?.startPlayer();

        isPlaying.value = true;
        _startPositionUpdates();

        // Stop after preSelectedDuration seconds
        _playbackTimer?.cancel();
        _playbackTimer = Timer(
          Duration(seconds: preSelectedDuration),
          () => pause(),
        );
      }
    } catch (e) {
      print("Error in playPause: $e");
      _showError("Playback error: $e");
    }
  }

  Future<void> pause() async {
    try {
      await playerController?.pausePlayer();
      isPlaying.value = false;
      _playbackTimer?.cancel();
      _positionSubscription?.cancel();
    } catch (e) {
      print("Error pausing audio: $e");
    }
  }

  void _startPositionUpdates() {
    _positionSubscription?.cancel();
    _positionSubscription = playerController?.onCurrentDurationChanged.listen((currentDuration) {
      final currentMs = currentDuration.milliseconds.inMilliseconds;
      final relativePosition = currentMs - audioStartInMilliSec.value;
      final progress = (relativePosition / (preSelectedDuration * 1000)).clamp(0.0, 1.0);

      currentProgress.value = progress;

      if (progress >= 1.0) {
        pause();
      }
    });
  }

  void onContinueTap() {
    if (isPlaying.value) togglePlayback();

    final startTime = audioStartInMilliSec.value;
    final endTime = startTime + (preSelectedDuration * 1000);

    final result = {
      'musicId': selectedMusic['id'],
      'musicUrl': localFilePath ?? selectedMusic['link'],
      'musicName': selectedMusic['name'],
      'musicImage': selectedMusic['image'],
      'startTime': startTime / 1000,
      'endTime': endTime / 1000,
      'duration': preSelectedDuration,
    };

    Get.back(result: result);
  }
}

class SelectedMusicBottomSheet {
  static Future<Map<String, dynamic>?> show({
    required BuildContext context,
    required Map<String, dynamic> selectedMusic,
    required int preSelectedDuration,
    required bool isAutoPlay,
  }) async {
    return await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SelectedMusicSheet(
        selectedMusic: selectedMusic,
        preSelectedDuration: preSelectedDuration,
        isAutoPlay: isAutoPlay,
      ),
    );
  }
}
