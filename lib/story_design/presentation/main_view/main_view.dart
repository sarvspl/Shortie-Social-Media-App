// ignore_for_file: must_be_immutable, library_private_types_in_public_api, no_leading_underscores_for_local_identifiers

import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
// import 'package:shortie/custom/custom_thumbnail.dart';
import 'package:shortie/main.dart';
import 'package:shortie/pages/splash_screen_page/api/upload_file_api.dart';
import 'package:shortie/pages/story_page/widget/upload_story_process.dart';
import 'package:shortie/story_design/add_story_controller.dart';
import 'package:shortie/story_design/add_story_select_music_bottomsheet.dart';
import 'package:shortie/story_design/domain/models/editable_items.dart';
import 'package:shortie/story_design/domain/models/painting_model.dart';
import 'package:shortie/story_design/domain/providers/notifiers/control_provider.dart';
import 'package:shortie/story_design/domain/providers/notifiers/draggable_widget_notifier.dart';
import 'package:shortie/story_design/domain/providers/notifiers/gradient_notifier.dart';
import 'package:shortie/story_design/domain/providers/notifiers/painting_notifier.dart';
// import 'package:shortie/story_design/domain/providers/notifiers/rendering_notifier.dart';
import 'package:shortie/story_design/domain/providers/notifiers/scroll_notifier.dart';
import 'package:shortie/story_design/domain/providers/notifiers/text_editing_notifier.dart';
import 'package:shortie/story_design/presentation/draggable_items/delete_item.dart';
import 'package:shortie/story_design/presentation/draggable_items/draggable_widget.dart';
// import 'package:shortie/story_design/presentation/main_view/widgets/rendering_indicator.dart';
import 'package:shortie/story_design/presentation/painting_view/painting.dart';
import 'package:shortie/story_design/presentation/painting_view/widgets/sketcher.dart';
import 'package:shortie/story_design/presentation/text_editor_view/TextEditor.dart';
import 'package:shortie/story_design/presentation/utils/constants/item_type.dart';
// import 'package:shortie/story_design/presentation/utils/constants/render_state.dart';
import 'package:shortie/story_design/presentation/utils/modal_sheets.dart';
import 'package:shortie/story_design/presentation/widgets/animated_onTap_button.dart';
import 'package:shortie/story_design/presentation/widgets/scrollable_pageView.dart';
import 'package:shortie/story_design/vs_story_designer.dart';
import 'package:shortie/utils/color.dart';
import 'package:shortie/utils/constant.dart';
import 'package:shortie/utils/enums.dart';
import 'package:shortie/utils/utils.dart';
import 'package:vs_media_picker/vs_media_picker.dart';


class MainView extends StatefulWidget {
  /// editor custom font families
  final List<FontType>? fontFamilyList;

  /// editor custom font families package
  final bool? isCustomFontList;

  /// you can pass a folderName where media files will be saved to instead of default folder
  final String? fileName;

  /// giphy api key
  final String giphyKey;

  /// editor custom color gradients
  final List<List<Color>>? gradientColors;

  /// editor custom logo
  final Widget? middleBottomWidget;

  /// on done
  final Function(String)? onDone;

  /// on done button Text
  final Widget? onDoneButtonStyle;

  /// on back pressed
  final Future<bool>? onBackPress;

  /// editor background color
  Color? editorBackgroundColor;

  /// gallery thumbnail quality
  final int? galleryThumbnailQuality;

  /// editor custom color palette list
  List<Color>? colorList;
  // Text appearing on center of design screen
  final String? centerText;

// theme type
  final ThemeType? themeType;

// share image file path
  final String? mediaPath;

  MainView(
      {super.key,
      this.themeType,
      required this.giphyKey,
      required this.onDone,
      this.middleBottomWidget,
      this.colorList,
      this.fileName,
      this.isCustomFontList,
      this.fontFamilyList,
      this.gradientColors,
      this.onBackPress,
      this.onDoneButtonStyle,
      this.editorBackgroundColor,
      this.galleryThumbnailQuality,
      this.centerText,
      this.mediaPath});

  @override
  _MainViewState createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  /// content container key
  final GlobalKey contentKey = GlobalKey();

  ///Editable item
  EditableItem? _activeItem;

  /// Gesture Detector listen changes
  Offset _initPos = const Offset(0, 0);
  Offset _currentPos = const Offset(0, 0);
  double _currentScale = 1;
  double _currentRotation = 0;

  /// delete position
  bool _isDeletePosition = false;
  bool _inAction = false;

  /// screen size
  final _screenSize = MediaQueryData.fromView(WidgetsBinding.instance.window);

  bool _isProcessing = false; // Add this flag

  /// recorder controller
  // final WidgetRecorderController _recorderController =
  //     WidgetRecorderController();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      var _control = Provider.of<ControlNotifier>(context, listen: false);
      var _tempItemProvider = Provider.of<DraggableWidgetNotifier>(context, listen: false);

      /// initialize control variable provider
      _control.giphyKey = widget.giphyKey;
      _control.folderName = widget.fileName ?? "VS_Story_Designer";
      _control.middleBottomWidget = widget.middleBottomWidget;
      _control.isCustomFontList = widget.isCustomFontList ?? false;
      _control.themeType = widget.themeType ?? ThemeType.dark;
      if (widget.mediaPath != null) {
        _control.mediaPath = widget.mediaPath!;
        _tempItemProvider.draggableWidget.insert(
            0,
            EditableItem()
              ..type = ItemType.image
              ..position = const Offset(0.0, 0));
      }
      if (widget.gradientColors != null) {
        _control.gradientColors = widget.gradientColors;
      }
      if (widget.fontFamilyList != null) {
        _control.fontList = widget.fontFamilyList;
      }
      if (widget.colorList != null) {
        _control.colorList = widget.colorList;
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Utils.onChangeStatusBar(brightness: Brightness.light, delay: 300);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final shouldPop = await _popScope();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Material(
        color: widget.editorBackgroundColor == Colors.transparent ? Colors.black : widget.editorBackgroundColor ?? Colors.black,
        child: Consumer6<ControlNotifier, DraggableWidgetNotifier, ScrollNotifier, GradientNotifier, PaintingNotifier, TextEditingNotifier>(
          builder: (context, controlNotifier, itemProvider, scrollProvider, colorProvider, paintingProvider, editingProvider, child) {
            return SafeArea(
              child: Stack(
                children: [
                  ScrollablePageView(
                    scrollPhysics: controlNotifier.mediaPath.isEmpty && itemProvider.draggableWidget.isEmpty && !controlNotifier.isPainting && !controlNotifier.isTextEditing,
                    pageController: scrollProvider.pageController,
                    gridController: scrollProvider.gridController,
                    mainView: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Main content area
                        GestureDetector(
                          onScaleStart: _onScaleStart,
                          onScaleUpdate: _onScaleUpdate,
                          onTap: () {
                            controlNotifier.isTextEditing = !controlNotifier.isTextEditing;
                          },
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(25),
                              child: SizedBox(
                                width: _screenSize.size.width,
                                height: Platform.isIOS ? (_screenSize.size.height - 135) - _screenSize.viewPadding.top : (_screenSize.size.height - 132),
                                child: RepaintBoundary(
                                  key: contentKey,
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    decoration: BoxDecoration(
                                        gradient: controlNotifier.mediaPath.isEmpty
                                            ? LinearGradient(
                                                colors: controlNotifier.gradientColors![controlNotifier.gradientIndex],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              )
                                            : LinearGradient(
                                                colors: [colorProvider.color1, colorProvider.color2],
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                              )),
                                    child: GestureDetector(
                                      onScaleStart: _onScaleStart,
                                      onScaleUpdate: _onScaleUpdate,
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          // Photo view container
                                          PhotoView.customChild(
                                            backgroundDecoration: const BoxDecoration(color: Colors.transparent),
                                            child: Container(),
                                          ),

                                          // List items
                                          ...itemProvider.draggableWidget.map((editableItem) => DraggableWidget(
                                                context: context,
                                                draggableWidget: editableItem,
                                                onPointerDown: (details) {
                                                  _updateItemPosition(editableItem, details);
                                                },
                                                onPointerUp: (details) {
                                                  _deleteItemOnCoordinates(editableItem, details);
                                                },
                                                onPointerMove: (details) {
                                                  _deletePosition(editableItem, details);
                                                },
                                              )),

                                          // Finger paint
                                          IgnorePointer(
                                            ignoring: true,
                                            child: Align(
                                              alignment: Alignment.topCenter,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(25),
                                                ),
                                                child: RepaintBoundary(
                                                  child: SizedBox(
                                                    width: MediaQuery.of(context).size.width,
                                                    height: MediaQuery.of(context).size.height - 132,
                                                    child: StreamBuilder<List<PaintingModel>>(
                                                      stream: paintingProvider.linesStreamController.stream,
                                                      builder: (context, snapshot) {
                                                        return CustomPaint(
                                                          painter: Sketcher(
                                                            lines: paintingProvider.lines,
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        // TOP UI ELEMENTS - Only show when NOT in painting or text editing mode
                        if (!controlNotifier.isPainting && !controlNotifier.isTextEditing) ...[
                          // Top Bar with Back Button and Song Info
                          Positioned(
                            top: 20,
                            left: 0,
                            right: 0,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // Back Button
                                  GetBuilder(
                                      id: "onChangeSound",
                                      init: AddStoryController(),
                                    builder: (AddStoryController controller) {
                                      return AnimatedOnTapButton(
                                        onTap: () async {
                                          final shouldPop = await _popScope();
                                          if (shouldPop && context.mounted) {
                                            Navigator.of(context).pop();
                                          }
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(14),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withValues(alpha:0.6),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.arrow_back_ios_rounded,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                        ),
                                      );
                                    }
                                  ),

                                  // Next/Done Button
                                  AnimatedOnTapButton(
                                    onTap: _isProcessing
                                        ? () {}
                                        : () async {
                                            await _handleVideoCreation();
                                          },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                                      decoration: BoxDecoration(
                                        gradient: _isProcessing ? null : AppColor.primaryLinearGradient,
                                        color: _isProcessing ? Colors.grey : null,
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                      child: _isProcessing
                                          ? Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                SizedBox(
                                                  width: 16,
                                                  height: 16,
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  'Processing...',
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            )
                                          : widget.onDoneButtonStyle ??
                                              Text(
                                                EnumLocal.txtNext.name.tr,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Next/Done Button (Top Right)
                        ],
                        // Selected Song (if any)
                        Positioned(
                          top: 25,
                          left: 0,
                          right: 0,
                          child: GetBuilder<AddStoryController>(
                            id: "onChangeSound",
                            init: AddStoryController(),
                            builder: (AddStoryController controller) {
                              log("Selected Sound: ${controller.selectedSound?.toString() ?? ""}");

                              return Visibility(
                                visible: controller.selectedSound != null,
                                child: Align(
                                  alignment: Alignment.topCenter,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                    child: GestureDetector(
                                      onTap: () async {
                                        controller.onPauseAudio();
                                        await controller.handleMusicSelection(isAutoPlay: false);
                                      },
                                      child: Container(
                                        height: 36,
                                        width: Get.width * 0.35,
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withValues(alpha:0.6),
                                          borderRadius: BorderRadius.circular(18),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            // Music icon
                                            const Icon(Icons.music_note, color: Colors.white, size: 16),
                                            const SizedBox(width: 6),
                                            // Song name (truncated)
                                            Expanded(
                                              child: Text(
                                                controller.selectedSound?['name'] ?? '',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            // remove music
                                            5.width,
                                            GestureDetector(
                                                onTap: () {
                                                  controller.selectedSound = null;
                                                  controller.update(['onChangeSound']);
                                                },
                                                child: const Icon(Icons.close, color: Colors.white, size: 16)),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        if (!controlNotifier.isPainting && !controlNotifier.isTextEditing)
                          Positioned(
                            bottom: 120,
                            child: Center(
                              child: GetBuilder<AddStoryController>(
                                init: AddStoryController(),
                                id: "onChangeDuration",
                                builder: (storyController) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha:0.1),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: Colors.white, width: 0.5),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: storyController.availableDurations.map((duration) {
                                        return _buildDurationButton(
                                          '${duration}s',
                                          storyController.isDurationSelected(duration),
                                          () {
                                            storyController.updateSelectedDuration(duration);
                                          },
                                        );
                                      }).toList(),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),

                        // Delete item position indicator
                        DeleteItem(
                          activeItem: _activeItem,
                          animationsDuration: const Duration(milliseconds: 300),
                          isDeletePosition: _isDeletePosition,
                        ),

                        // Bottom Tools
                        if (!kIsWeb)
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: Visibility(
                              visible: !controlNotifier.isTextEditing && !controlNotifier.isPainting,
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                // decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), border: Border.all(color: Colors.white, width: 0.5), borderRadius: BorderRadius.circular(40)),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    AnimatedOnTapButton(
                                      onTap: () {
                                        setState(() {
                                          controlNotifier.gradientIndex = (controlNotifier.gradientIndex + 1) % controlNotifier.gradientColors!.length;
                                        });
                                      },
                                      child: Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withValues(alpha:0.2),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Container(
                                            width: 30,
                                            height: 30,
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: controlNotifier.gradientColors![controlNotifier.gradientIndex]),
                                              shape: BoxShape.circle,
                                            ),
                                          )),
                                    ),
                                    // Text Tool
                                    _buildBottomToolButton(
                                      icon: Icons.text_fields,
                                      onTap: () {
                                        controlNotifier.isTextEditing = true;

                                        final controller = Get.find<AddStoryController>();
                                        controller.onPauseAudio();
                                      },
                                    ),

                                    // Painting Tool
                                    _buildBottomToolButton(
                                      icon: Icons.brush,
                                      onTap: () {
                                        controlNotifier.isPainting = true;
                                        final controller = Get.find<AddStoryController>();
                                        controller.onPauseAudio();
                                      },
                                    ),

                                    // Music Button
                                    _buildBottomToolButton(
                                      icon: Icons.music_note,
                                      onTap: () {
                                        final controller = Get.find<AddStoryController>();
                                        controller.onPauseAudio();
                                        AddStorySelectMusicBottomSheet.show(context: context);
                                      },
                                    ),

                                    // Photo Gallery
                                    _buildBottomToolButton(
                                      icon: Icons.photo_library,
                                      onTap: () {
                                        AddStoryController controller = Get.find<AddStoryController>();
                                        controller.onPauseAudio();

                                        scrollProvider.pageController.animateToPage(
                                          1,
                                          duration: const Duration(milliseconds: 300),
                                          curve: Curves.easeIn,
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                        // Text Editor
                        Visibility(
                          visible: controlNotifier.isTextEditing,
                          child: TextEditor(
                            context: context,
                          ),
                        ),

                        // Painting View
                        Visibility(
                          visible: controlNotifier.isPainting,
                          child: const Painting(),
                        ),
                      ],
                    ),
                    gallery: VSMediaPicker(
                      gridViewController: scrollProvider.gridController,
                      thumbnailQuality: widget.galleryThumbnailQuality,
                      singlePick: true,
                      onlyImages: true,
                      appBarColor: widget.editorBackgroundColor ?? Colors.black,
                      gridViewPhysics: itemProvider.draggableWidget.isEmpty ? const NeverScrollableScrollPhysics() : const ScrollPhysics(),
                      pathList: (path) {
                        // Clear any existing images first
                        itemProvider.draggableWidget.removeWhere((item) => item.type == ItemType.image);

                        // Add the selected image
                        controlNotifier.mediaPath = path[0].path!;
                        if (controlNotifier.mediaPath.isNotEmpty) {
                          itemProvider.draggableWidget.insert(
                              0,
                              EditableItem()
                                ..type = ItemType.image
                                ..position = const Offset(0.0, 0));
                        }
                        scrollProvider.pageController.animateToPage(0, duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
                      },
                      appBarLeadingWidget: Padding(
                        padding: const EdgeInsets.only(bottom: 15, right: 15),
                        child: Align(
                          alignment: Alignment.bottomRight,
                          child: AnimatedOnTapButton(
                            onTap: () {
                              scrollProvider.pageController.animateToPage(0, duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 1.2,
                                  )),
                              child: const Text(
                                'Cancel',
                                style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w400),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // Helper method to format time
  String _formatTime(double seconds) {
    int minutes = (seconds / 60).floor();
    int remainingSeconds = (seconds % 60).floor();
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

// Add this helper method in your _MainViewState class:
  // Add these helper methods to your _MainViewState class
  Future<void> _playMusicFromSelectedTime(AddStoryController controller, Map<String, dynamic> result) async {
    try {
      String musicUrl = result['musicUrl'] ?? '';
      double startTime = result['startTime']?.toDouble() ?? 0.0;

      // Set the audio source
      await controller.audioPlayer.setSourceUrl(musicUrl);

      // Seek to the selected start time
      await controller.audioPlayer.seek(Duration(milliseconds: (startTime * 1000).toInt()));

      // Play the audio
      await controller.audioPlayer.resume();

      // Stop after selected duration
      Timer(Duration(seconds: result['duration']), () {
        controller.onPauseAudio();
      });
    } catch (e) {
      print('Error playing selected music: $e');
    }
  }

  Widget _buildBottomToolButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return AnimatedOnTapButton(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha:0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 22,
        ),
      ),
    );
  }

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
  }

/*  Future<void> _handleVideoCreation(ControlNotifier controlNotifier) async {
    try {
      setState(() {
        _isProcessing = true;
      });

      print('Starting creation process...');

      // Get the selected audio path from AddStoryController
      AddStoryController addStoryController = Get.find<AddStoryController>();
      String? audioUrl = addStoryController.selectedSound?["link"];

      print('Selected audio URL: $audioUrl');
      print('Selected duration: ${controlNotifier.selectedDuration} seconds');

      // Create unique filename
      String fileName = 'story_${DateTime.now().millisecondsSinceEpoch}';

      String? outputPath;

      // Check if audio is selected
      if (audioUrl != null && audioUrl.isNotEmpty) {
        // Create video with audio
        print('Creating video with audio');

        outputPath = await VideoCompositionService.createVideoWithImageAndAudio(
          contentKey: contentKey,
          audioPath: audioUrl,
          durationInSeconds: controlNotifier.selectedDuration,
          fileName: fileName,
          useDirectUrl: true,
        );
      } else {
        // Create only image (no video)
        print('Creating image only (no audio selected)');

        outputPath = await ImageCreationService.createImageFromContent(
          contentKey: contentKey,
          fileName: fileName,
        );
      }

      if (outputPath != null) {
        print('Output created successfully: $outputPath');

        // Stop any playing audio
        addStoryController.onPauseAudio();

        // Verify file exists and has content
        File outputFile = File(outputPath);
        if (await outputFile.exists()) {
          int fileSize = await outputFile.length();
          print('Final file size: $fileSize bytes');

          if (fileSize > 0) {
            // Call the onDone callback with the output path
            widget.onDone!(outputPath);
          } else {
            _showErrorDialog('Created file is empty. Please try again.');
          }
        } else {
          _showErrorDialog('File was not created. Please try again.');
        }
      } else {
        // Handle error case
        _showErrorDialog('Failed to create output. Please try again.');
      }
    } catch (e) {
      print('Error in creation process: $e');
      _showErrorDialog('An error occurred: ${e.toString()}');
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }*/

  Future<void> _handleVideoCreation() async {
    try {
      setState(() {
        _isProcessing = true;
      });

      print('Starting creation process...');

      // Get the story controller instance
      AddStoryController addStoryController = Get.find<AddStoryController>();

      String audioUrl = addStoryController.selectedSound?["link"] ?? '';
      String audioId = addStoryController.selectedSound?["id"] ?? "";

      // Get timing information if available
      double? startTime = addStoryController.selectedSound?["startTime"]?.toDouble();
      double? endTime = addStoryController.selectedSound?["endTime"]?.toDouble();

      // Use duration from controller
      int selectedDuration = addStoryController.getCurrentDuration();

      print('Selected audio URL: $audioUrl');
      print('Selected duration: ${selectedDuration} seconds');
      print('Start time: $startTime, End time: $endTime');

      // Create unique filename
      String fileName = 'story_${DateTime.now().millisecondsSinceEpoch}';
      final localPath = await ImageCreationService.createImageFromContent(contentKey: contentKey, fileName: fileName) ?? '';

      UploadStoryServices.onStoryUploadProcess(
        isVideo: false,
        localPath: localPath,
        audioUrl: audioUrl,
        songId: audioId,
        duration: selectedDuration,
        startTime: startTime,
        endTime: endTime,
      );

      final controller = Get.find<AddStoryController>();
      controller.onPauseAudio();

      controller.selectedSound = null;

      Get.back();

      /*// Check if audio is selected
      if (audioUrl != null && audioUrl.isNotEmpty) {
        // Create video with audio
        print('Creating video with audio');
        isVideo = true;

        outputPath = await VideoCompositionService.createVideoWithImageAndAudio(
          contentKey: contentKey,
          audioPath: audioUrl,
          durationInSeconds: selectedDuration,
          fileName: fileName,
          useDirectUrl: true,
          startTime: startTime, // Pass start time for trimming
          endTime: endTime, // Pass end time for trimming
        );
      } else {
        // Create only image (no video)
        print('Creating image only (no audio selected)');
        isVideo = false;

        outputPath = await ImageCreationService.createImageFromContent(
          contentKey: contentKey,
          fileName: fileName,
        );
      }

      if (outputPath != null) {
        print('Output created successfully: $outputPath');

        // Stop any playing audio
        addStoryController.onPauseAudio();

        // Verify file exists and has content
        File outputFile = File(outputPath);
        if (await outputFile.exists()) {
          int fileSize = await outputFile.length();
          print('Final file size: $fileSize bytes');

          if (fileSize > 0) {
            // Upload the story to server
            await _uploadStoryToServer(
              outputPath: outputPath,
              isVideo: isVideo,
              backgroundSong: audioId ?? '',
              duration: selectedDuration, // Use controller duration
            );
          } else {
            _showErrorDialog('Created file is empty. Please try again.');
          }
        } else {
          _showErrorDialog('File was not created. Please try again.');
        }
      } else {
        // Handle error case
        _showErrorDialog('Failed to create output. Please try again.');
      }*/
    } catch (e) {
      print('Error in creation process: $e');
      _showErrorDialog('An error occurred: ${e.toString()}');
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

// Helper method to prepare audio with timing
  Future<String?> _prepareAudioWithTiming({
    required String audioUrl,
    required double startTime,
    required double endTime,
  }) async {
    try {
      print('Preparing audio with timing: $startTime - $endTime');

      // First download the full audio file
      String? localAudioPath = await _downloadAudioFile(audioUrl);

      if (localAudioPath == null) {
        print('Failed to download audio file');
        return null;
      }

      // Create trimmed audio file path
      Directory appDir = await getApplicationDocumentsDirectory();
      String trimmedPath = '${appDir.path}/trimmed_audio_${DateTime.now().millisecondsSinceEpoch}.mp3';

      // Here you would use FFmpeg or similar to trim the audio
      // For now, we'll return the original path
      // In production, implement audio trimming:

      await FFmpegKit.execute('-i "$localAudioPath" -ss $startTime -t ${endTime - startTime} -c copy "$trimmedPath"');

      print('Audio trimming would be implemented here');
      return localAudioPath; // Return original for now
    } catch (e) {
      print('Error preparing audio with timing: $e');
      return null;
    }
  }

  /*Future<void> _uploadStoryToServer({
    required String outputPath,
    required bool isVideo,
    required String backgroundSong,
    required int duration,
  }) async {
    try {
      print('Starting upload to server...');

      // You'll need to get the current user ID - replace this with your actual user ID logic
      String userId = Database.loginUserId; // You need to implement this method
      String? thumbnail = await CustomThumbnail.onGet(outputPath);
      String? thumbnailUrl = await _uploadFileToStorage(thumbnail ?? '', false) ?? "";

      // First, upload the file to your storage service
      String? uploadedUrl = await _uploadFileToStorage(outputPath, isVideo);

      if (uploadedUrl != null) {
        print('File uploaded to storage: $uploadedUrl');

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
          print('Story uploaded successfully');

          // Show success message

          Utils.showToast("Story uploaded successfully");
          Get.close(1);

          // Call the original onDone callback if needed
          widget.onDone!(outputPath);

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
  }*/

// Upload file using your existing UploadFileApi
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

// Keep this method as backup for when direct URL doesn't work
  Future<String?> _downloadAudioFile(String audioUrl) async {
    try {
      print('Downloading audio from: $audioUrl');

      // Use HTTP client to download the audio file
      final http = HttpClient();
      final request = await http.getUrl(Uri.parse(audioUrl));
      final response = await request.close();

      if (response.statusCode == 200) {
        // Get app documents directory
        Directory appDir = await getApplicationDocumentsDirectory();
        String tempDirPath = '${appDir.path}/temp_audio';
        Directory tempDir = Directory(tempDirPath);

        if (!await tempDir.exists()) {
          await tempDir.create(recursive: true);
        }

        // Create local file path
        String fileName = 'audio_${DateTime.now().millisecondsSinceEpoch}.mp3';
        String localPath = '${tempDir.path}/$fileName';

        // Write the response to file
        File file = File(localPath);
        await file.openWrite().addStream(response);

        // Verify file was written
        if (await file.exists() && await file.length() > 0) {
          print('Audio downloaded successfully: $localPath');
          return localPath;
        } else {
          throw Exception('Downloaded audio file is empty');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: Failed to download audio');
      }
    } catch (e) {
      print('Error downloading audio: $e');
      return null;
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
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

  /*Future<String> _captureCurrentState() async {
    // try {
    //   // Use your existing contentKey to capture the widget
    //   RenderRepaintBoundary boundary = contentKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    //   var image = await boundary.toImage(pixelRatio: 2.0);
    //   var byteData = await image.toByteData(format: ImageByteFormat.png);
    //   var pngBytes = byteData!.buffer.asUint8List();
    //
    //   // Save to file and return path - implement your existing save logic
    //   return "path_to_saved_image";
    // } catch (e) {
    //   throw Exception('Failed to capture: $e');
    // }
    return "";
  }*/

  /// recording and save mp4 widget
  // void startRecording(
  //     {required ControlNotifier controlNotifier,
  //     required RenderingNotifier renderingNotifier,
  //     required bool saveOnGallery}) {
  //   Duration seg = const Duration(seconds: 1);
  //   _recorderController.start(
  //       controlNotifier: controlNotifier, renderingNotifier: renderingNotifier);
  //   Timer.periodic(seg, (timer) async {
  //     if (renderingNotifier.recordingDuration == 0) {
  //       setState(() {
  //         _recorderController.stop(
  //             controlNotifier: controlNotifier,
  //             renderingNotifier: renderingNotifier);
  //         timer.cancel();
  //       });
  //       var path = await _recorderController.export(
  //           controlNotifier: controlNotifier,
  //           renderingNotifier: renderingNotifier);
  //       if (path['success']) {
  //         if (saveOnGallery) {
  //           setState(() {
  //             renderingNotifier.renderState = RenderState.saving;
  //           });
  //           await ImageGallerySaver.saveFile(path['outPath'],
  //                   name: "${DateTime.now()}")
  //               .then((value) {
  //             if (value['isSuccess']) {
  //               debugPrint(value['filePath']);
  //               Fluttertoast.showToast(msg: 'Recording successfully saved');
  //             } else {
  //               debugPrint('Gallery saver error: ${value['errorMessage']}');
  //               Fluttertoast.showToast(msg: 'Gallery saver error');
  //             }
  //           }).whenComplete(() {
  //             setState(() {
  //               controlNotifier.isRenderingWidget = false;
  //               renderingNotifier.renderState = RenderState.none;
  //               renderingNotifier.recordingDuration = 3;
  //             });
  //           });
  //         } else {
  //           setState(() {
  //             controlNotifier.isRenderingWidget = false;
  //             renderingNotifier.renderState = RenderState.none;
  //             renderingNotifier.recordingDuration = 3;
  //             widget.onDone!(path['outPath']);
  //           });
  //         }
  //       } else {
  //         setState(() {
  //           renderingNotifier.renderState = RenderState.none;
  //           Fluttertoast.showToast(msg: 'Something was wrong.');
  //         });
  //       }
  //     } else {
  //       setState(() {
  //         renderingNotifier.recordingDuration--;
  //       });
  //     }
  //   });
  // }

  /// validate pop scope gesture
  Future<bool> _popScope() async {
    final controlNotifier = Provider.of<ControlNotifier>(context, listen: false);

    AddStoryController? addStoryController;
    if (Get.isRegistered<AddStoryController>()) {
      addStoryController = Get.find<AddStoryController>();
    }

    bool songWasCleared = false;

    /// 1️⃣ Clear song BUT do not stop back flow
    if (addStoryController?.selectedSound != null) {
      addStoryController!.selectedSound = null;
      addStoryController.update(['onChangeSound']);
      addStoryController.onPauseAudio();
      songWasCleared = true;
    }

    /// 2️⃣ Exit text editing (still stop here)
    if (controlNotifier.isTextEditing) {
      controlNotifier.isTextEditing = false;
      return false;
    }

    /// 3️⃣ Exit painting (still stop here)
    if (controlNotifier.isPainting) {
      controlNotifier.isPainting = false;
      return false;
    }

    /// 4️⃣ Show dialog (even if song was cleared)
    final bool shouldExit = await (
        widget.onBackPress ??
            exitDialog(
              context: context,
              contentKey: contentKey,
              themeType: widget.themeType ?? ThemeType.dark,
            )
    );

    return shouldExit;
  }

  /// start item scale
  void _onScaleStart(ScaleStartDetails details) {
    if (_activeItem == null) {
      return;
    }
    _initPos = details.focalPoint;
    _currentPos = _activeItem!.position;
    _currentScale = _activeItem!.scale;
    _currentRotation = _activeItem!.rotation;
  }

  /// update item scale
  void _onScaleUpdate(ScaleUpdateDetails details) {
    if (_activeItem == null) {
      return;
    }
    final delta = details.focalPoint - _initPos;

    final left = (delta.dx / _screenSize.size.width) + _currentPos.dx;
    final top = (delta.dy / _screenSize.size.height) + _currentPos.dy;

    setState(() {
      _activeItem!.position = Offset(left, top);
      _activeItem!.rotation = details.rotation + _currentRotation;
      _activeItem!.scale = details.scale * _currentScale;
    });
  }

  /// active delete widget with offset position
  void _deletePosition(EditableItem item, PointerMoveEvent details) {
    // For all item types, check if they're in the top 25% of the screen
    bool isInDeleteZone = item.position.dy >= 0.75;

    setState(() {
      _isDeletePosition = isInDeleteZone;
      item.deletePosition = isInDeleteZone;
    });
  }

  /// delete item widget with offset position
  void _deleteItemOnCoordinates(EditableItem item, PointerUpEvent details) {
    var _itemProvider = Provider.of<DraggableWidgetNotifier>(context, listen: false).draggableWidget;
    var controlNotifier = Provider.of<ControlNotifier>(context, listen: false);
    _inAction = false;
    bool shouldDelete = false;

    if (item.type == ItemType.text || item.type == ItemType.image) {
      shouldDelete = item.position.dy >= 0.32 && item.position.dx >= -0.122 && item.position.dx <= 0.122;
    } else if (item.type == ItemType.gif) {
      shouldDelete = item.position.dy >= 0.21 && item.position.dx >= -0.25 && item.position.dx <= 0.25;
    }
    if (shouldDelete) {
      setState(() {
        _itemProvider.removeAt(_itemProvider.indexOf(item));
        HapticFeedback.heavyImpact();
        controlNotifier.mediaPath = '';
      });
    }
    setState(() {
      _activeItem = null;
    });
  }

  /// update item position, scale, rotation
  void _updateItemPosition(EditableItem item, PointerDownEvent details) {
    if (_inAction) {
      return;
    }

    _inAction = true;
    _activeItem = item;
    _initPos = details.position;
    _currentPos = item.position;
    _currentScale = item.scale;
    _currentRotation = item.rotation;

    /// set vibrate
    HapticFeedback.lightImpact();
  }
}
