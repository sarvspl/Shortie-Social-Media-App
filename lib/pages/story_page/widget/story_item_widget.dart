import 'package:flutter/material.dart';
import 'package:shortie/pages/story_page/model/fetch_story_model.dart';
import 'package:shortie/utils/color.dart';
import 'package:shortie/utils/utils.dart';
import 'package:story_view/controller/story_controller.dart';
import 'package:story_view/widgets/story_view.dart';
import 'package:video_player/video_player.dart';

StoryItem onStoryItem({
  required StoryController controller,
  required Stories itemData,
}) {
  final seconds = itemData.duration == 0 ? 15 : (itemData.duration ?? 10);

  if (itemData.storyType == 2) {
    return StoryItem(
      _VideoPlayerWidget(
        videoUrl: itemData.mediaVideoUrl ?? "",
        controller: controller,
      ),
      duration: Duration(seconds: seconds),
    );
  } else if (itemData.storyType == 1) {
    // return StoryItem.pageImage(
    //   url: itemData.mediaImageUrl ?? "",
    //   controller: controller,
    //   imageFit: BoxFit.cover,
    //   loadingWidget: CircularProgressIndicator(color: AppColor.colorPendingYellow,),
    //   duration: Duration(seconds: seconds),
    //
    // );

    return StoryItem(
      _StoryImageWidget(
        imageUrl: itemData.mediaImageUrl ?? "",
        controller: controller,
        onLoadingChanged: (value) {
Utils.showLog("Call Loading $value");
        },
      ),
      duration: Duration(seconds: seconds),
    );
  } else {
    return StoryItem.text(
      title: "ERROR",
      backgroundColor: AppColor.primary,
      duration: Duration(seconds: seconds),
    );
  }
}

class _VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  final StoryController controller;

  const _VideoPlayerWidget({
    required this.videoUrl,
    required this.controller,
  });

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<_VideoPlayerWidget> {
  late VideoPlayerController _videoController;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    widget.controller.pause();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    _videoController = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));

    try {
      await _videoController.initialize();
      await _videoController.setLooping(true);
      await _videoController.play();
      widget.controller.play();
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      print('Error initializing video: $e');
    }
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black,
      child: _isInitialized
          ? AspectRatio(
              aspectRatio: _videoController.value.aspectRatio,
              child: VideoPlayer(_videoController),
            )
          : Center(child: CircularProgressIndicator(color: AppColor.white,)),
    );
  }
}




class _StoryImageWidget extends StatefulWidget {
  final String imageUrl;
  final StoryController controller;
  final ValueChanged<bool> onLoadingChanged;

  const _StoryImageWidget({
    required this.imageUrl,
    required this.controller,
    required this.onLoadingChanged,
  });

  @override
  State<_StoryImageWidget> createState() => _StoryImageWidgetState();
}

class _StoryImageWidgetState extends State<_StoryImageWidget> {
  ImageProvider? _imageProvider;
  ImageStream? _imageStream;
  ImageStreamListener? _listener;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(covariant _StoryImageWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl) {
      _resetAndReload();
    }
  }

  void _resetAndReload() {
    _removeListener();
    _isLoading = true;
    widget.onLoadingChanged(true);
    widget.controller.pause();
    _loadImage();
  }

  void _loadImage() {
    _imageProvider = NetworkImage(widget.imageUrl);
    _imageStream = _imageProvider!.resolve(const ImageConfiguration());

    _listener = ImageStreamListener(
          (ImageInfo info, bool _) {
        if (!mounted) return;
        widget.onLoadingChanged(false);
        widget.controller.play();
        setState(() => _isLoading = false);
      },
      onError: (error, stackTrace) {
        widget.onLoadingChanged(false);
        widget.controller.next();
      },
    );

    _imageStream!.addListener(_listener!);
  }

  void _removeListener() {
    if (_imageStream != null && _listener != null) {
      _imageStream!.removeListener(_listener!);
    }
  }

  @override
  void dispose() {
    _removeListener();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColor.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (_imageProvider != null)
            Image(
              image: _imageProvider!,
              fit: BoxFit.cover,
            ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(
                color: AppColor.white,
              ),
            ),
        ],
      ),
    );
  }
}