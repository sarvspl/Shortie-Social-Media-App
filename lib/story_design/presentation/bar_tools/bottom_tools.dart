// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shortie/story_design/domain/providers/notifiers/control_provider.dart';
import 'package:shortie/story_design/domain/providers/notifiers/scroll_notifier.dart';
import 'package:shortie/story_design/presentation/widgets/animated_onTap_button.dart';

import '../../../pages/create_reels_page/widget/create_reels_widget.dart';

// import 'package:shortie/story_design/src/presentation/widgets/tool_button.dart';
// In your BottomTools widget, modify the existing bottom tools to include music button

// First, import your AddMusicBottomSheet

class BottomTools extends StatelessWidget {
  final GlobalKey contentKey;
  final Function(String) onDone;
  final Widget? onDoneButtonStyle;
  final Color? editorBackgroundColor;

  const BottomTools({
    Key? key,
    required this.contentKey,
    required this.onDone,
    this.onDoneButtonStyle,
    this.editorBackgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ControlNotifier>(
      builder: (context, controlNotifier, child) {
        return Visibility(
          visible: !controlNotifier.isTextEditing && !controlNotifier.isPainting,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha:0.5),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Text Tool
                _buildToolButton(
                  icon: Icons.text_fields,
                  onTap: () {
                    controlNotifier.isTextEditing = true;
                  },
                ),

                // Painting Tool
                _buildToolButton(
                  icon: Icons.brush,
                  onTap: () {
                    controlNotifier.isPainting = true;
                  },
                ),

                // Music Button (NEW)
                _buildToolButton(
                  icon: Icons.music_note,
                  onTap: () {
                    AddMusicBottomSheet.show(context: context);
                  },
                ),

                // Photo Gallery
                _buildToolButton(
                  icon: Icons.photo_library,
                  onTap: () {
                    // Navigate to gallery
                    final scrollProvider = Provider.of<ScrollNotifier>(context, listen: false);
                    scrollProvider.pageController.animateToPage(
                      1, // Assuming gallery is on page 1
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeIn,
                    );
                  },
                ),

                // Done Button
                _buildDoneButton(context),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildToolButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return AnimatedOnTapButton(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha:0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildDoneButton(BuildContext context) {
    return AnimatedOnTapButton(
      onTap: () async {
        // Capture the content and call onDone
        try {
          // Your existing screenshot/capture logic here
          String capturedImagePath = await _captureWidget();
          onDone(capturedImagePath);
        } catch (e) {
          print('Error capturing widget: $e');
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
          ),
          borderRadius: BorderRadius.circular(25),
        ),
        child: onDoneButtonStyle ??
            const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text(
                  'Done',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
      ),
    );
  }

  Future<String> _captureWidget() async {
    // Your existing widget capture logic
    // This should return the path to the captured image
    // Implementation depends on your existing capture method
    return "captured_image_path";
  }
}
