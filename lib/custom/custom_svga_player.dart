import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svga/flutter_svga.dart';
import 'package:get/get_rx/src/rx_typedefs/rx_typedefs.dart';
import 'package:shortie/utils/utils.dart';

class CustomSVGAPlayer extends StatefulWidget {
  final String giftUrl;
  final Callback? callBack;

  const CustomSVGAPlayer({super.key, required this.giftUrl, this.callBack});

  @override
  State<CustomSVGAPlayer> createState() => _CustomSVGAPlayerState();
}

class _CustomSVGAPlayerState extends State<CustomSVGAPlayer> with SingleTickerProviderStateMixin {
  bool isLoading = false;
  SVGAAnimationController? animationController;

  bool isComplete = false;

  @override
  void initState() {
    super.initState();
    log("CustomSVGAPlayer initState => ${widget.giftUrl}");
    animationController = SVGAAnimationController(vsync: this);
     _loadAndPlaySVGA();
  }

  void _playOnceAndAutoHide() {
    if (animationController?.isCompleted == true) {
      // Utils.showToast("SVGA DONE");
      animationController?.stop();
      widget.callBack?.call();
    }

    animationController?.addListener(
      () {
        if (animationController?.isCompleted == true && isComplete == false) {
          // Utils.showToast("SVGA DONE");
          isComplete = true;
          widget.callBack?.call();
        }
      },
    );

    animationController?.forward(from: 0.0).whenComplete(() {
      if (mounted) {
        setState(() {
          isLoading = false; // Go back to image when SVGA completes
        });
      }
    });
  }

  void _loadAndPlaySVGA() async {
    try {
      Utils.showLog("widget.giftUrl => ${widget.giftUrl}");
      final MovieEntity videoItem = await _loadVideoItem(widget.giftUrl);

      if (!mounted) return;

      setState(() {
        isLoading = true;
        animationController?.videoItem = videoItem;
      });

      _playOnceAndAutoHide();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading SVGA: $e');
      }
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        widget.callBack?.call();
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(
        //     content: Text('Failed to load SVGA: ${e.toString()}'),
        //     backgroundColor: Colors.yellow,
        //     duration: Duration(seconds: 1),
        //   ),
        // );
      }
    }
  }

  Future _loadVideoItem(String image) {
    Future Function(String) decoder;
    if (image.startsWith(RegExp(r'https?://'))) {
      decoder = SVGAParser.shared.decodeFromURL;
    } else {
      decoder = SVGAParser.shared.decodeFromAssets;
    }
    return decoder(image);
  }

  @override
  void dispose() {
    animationController?.dispose();
    animationController = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        log("CustomSVGAPlayer tapped");
        if (!isLoading) {
          // _loadAndPlaySVGA(); // Play SVGA when image tapped
        }
      },
      child: SizedBox(
        height: 80,
        width: 80,
        child: isLoading
            ? SVGAImage(
                animationController!,
                fit: BoxFit.contain,
                clearsAfterStop: true,
                allowDrawingOverflow: false,
                filterQuality: FilterQuality.low,
                preferredSize: Size(80, 80),
              )
            : Offstage(),
      ),
    );
  }
}
