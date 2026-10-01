import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svga/flutter_svga.dart';
import 'package:shortie/utils/api.dart';

class GiftAnimationWidget extends StatefulWidget {
  final String giftUrl;
  final String imageUrl; // placeholder image url

  const GiftAnimationWidget({
    Key? key,
    required this.giftUrl,
    required this.imageUrl,
  }) : super(key: key);

  @override
  State<GiftAnimationWidget> createState() => _GiftAnimationWidgetState();
}

class _GiftAnimationWidgetState extends State<GiftAnimationWidget> with SingleTickerProviderStateMixin {
  bool isLoading = true;
  SVGAAnimationController? animationController;

  @override
  void initState() {
    super.initState();
    log("GiftAnimationWidget initState => ${Api.baseUrl + widget.giftUrl}");
    animationController = SVGAAnimationController(vsync: this);
    _loadAndPlaySVGA();
  }

  void _playOnceAndAutoHide() {
    if (animationController?.isCompleted == true) {
      animationController?.stop();
    }

    animationController?.forward(from: 0.0).whenComplete(() {
      if (mounted) {
        setState(() {
          isLoading = true; // Go back to image when SVGA completes
        });
      }
    });
  }

  void _loadAndPlaySVGA() async {
    try {
      final videoItem = await _loadVideoItem(Api.baseUrl + widget.giftUrl);
      if (!mounted) return;

      setState(() {
        isLoading = false;
        animationController?.videoItem = videoItem;
      });

      _playOnceAndAutoHide();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading SVGA: $e');
      }
      if (mounted) {
        setState(() {
          isLoading = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load SVGA: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
          ),
        );
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
        log("GiftAnimationWidget tapped");
        if (isLoading) {
          _loadAndPlaySVGA(); // Play SVGA when image tapped
        }
      },
      child: Container(
        height: 80,
        width: 80,
        child: !isLoading
            ? SVGAImage(
                animationController!,
                fit: BoxFit.contain,
                clearsAfterStop: true,
                allowDrawingOverflow: false,
                filterQuality: FilterQuality.low,
                preferredSize: Size(80, 80),
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  widget.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
      ),
    );
  }
}

class GiftingReminder extends StatelessWidget {
  final String creatorName;
  final Duration timeUntilEvent;

  const GiftingReminder({
    required this.creatorName,
    required this.timeUntilEvent,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple, Colors.blue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.card_giftcard, color: Colors.white),
              SizedBox(width: 8),
              Text(
                "MULTIPLE GIFTING BONUS!",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            "🔥 Bonus Gifting Round is Almost Here! "
            "Prepare to support $creatorName with gifts! 🎁✨",
            style: TextStyle(color: Colors.white),
          ),
          SizedBox(height: 8),
          // Add a countdown if needed
          Text(
            "⏳ Starts in: ${timeUntilEvent.inSeconds} seconds",
            style: TextStyle(
              color: Colors.yellowAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class CustomEmojiPicker extends StatelessWidget {
  final void Function(String) onEmojiSelected;

  CustomEmojiPicker({required this.onEmojiSelected});

  final List<String> _emojis = [
    // Smileys & Emotion
    '😀', '😁', '😂', '🤣', '😃', '😄', '😅', '😆', '😉', '😊',
    '😋', '😎', '😍', '😘', '😗', '😙', '😚', '☺️', '🙂', '🤗',
    '🤩', '🤔', '🤨', '😐', '😑', '😶', '🙄', '😏', '😣', '😥',
    '😮', '🤐', '😯', '😪', '😫', '🥱', '😴', '😌', '😛', '😜',
    '😝', '🤤', '😒', '😓', '😔', '😕', '🙃', '🤑', '😲', '☹️',
    '🙁', '😖', '😞', '😟', '😤', '😢', '😭', '😦', '😧', '😨',
    '😩', '🤯', '😬', '😰', '😱', '🥵', '🥶', '😳', '🤪', '😵',
    '😡', '😠', '🤬', '😷', '🤒', '🤕', '🤢', '🤮', '🤧', '🥴',
    '😇', '🥳', '🥺', '🤠', '🤡', '👻', '💀', '☠️', '👽', '👾',

    // Gestures
    '👍', '👎', '👊', '✊', '🤛', '🤜', '🤞', '✌️', '🤟', '🤘',
    '👌', '🤏', '👈', '👉', '👆', '👇', '☝️', '✋', '🤚', '🖐️',
    '🖖', '👋', '🤙', '💪', '🙏', '👏', '👐', '🤲', '🙌', '🤝',
    '🫶', '🫵', '🫱', '🫲', '🫳', '🫴',

    // Symbols
    '❤️', '🧡', '💛', '💚', '💙', '💜', '🖤', '🤍', '🤎', '💔',
    '❣️', '💕', '💞', '💓', '💗', '💖', '💘', '💝', '💟', '💯',
    '💢', '💤', '💥', '💫', '💦', '💨', '🕳️', '🔥', '🌟', '⭐',

    // Objects / Celebration
    '🎉', '🎊', '🎈', '🎂', '🍰', '🎁', '🥂', '🍾', '🍻', '🥳',
    '⚽', '🏀', '🏈', '⚾', '🎾', '🏐', '🎱', '🏓', '🏸',

    // Animals (a few)
    '🐶', '🐱', '🐭', '🐹', '🐰', '🦊', '🐻', '🐼', '🐨', '🐯',
    '🦁', '🐮', '🐷', '🐸', '🐵', '🙈', '🙉', '🙊',

    // Weather
    '☀️', '🌤️', '⛅', '🌦️', '🌧️', '⛈️', '🌩️', '🌨️', '❄️', '🌈',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade200,
      height: 250,
      child: GridView.builder(
        padding: EdgeInsets.all(8),
        itemCount: _emojis.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 8,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
        ),
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => onEmojiSelected(_emojis[index]),
            child: Center(
              child: Text(
                _emojis[index],
                style: TextStyle(fontSize: 28),
              ),
            ),
          );
        },
      ),
    );
  }
}
