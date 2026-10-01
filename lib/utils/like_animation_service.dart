import 'package:flutter/material.dart';
import 'package:shortie/custom/like_animation_widget.dart';

class LikeAnimationService {
  LikeAnimationService._();

  static final instance = LikeAnimationService._();

  like(
    TapDownDetails details, {
    required GlobalKey likeKey,
    required BuildContext context,
    required double leftRightPosition,
    required double startSize,
    required double endSize,
    required Function() onLike,
  }) {
    final RenderBox? box = likeKey.currentContext?.findRenderObject() as RenderBox?;

    if (box == null) return;
    final Offset likeButtonPosition = box.localToGlobal(Offset.zero);

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => LikeAnimationWidget(
        position: details.globalPosition,
        endPosition: likeButtonPosition,
        overlayEntry: entry,
        leftRightPosition: leftRightPosition,
        onLikeCalled: () => onLike(),
        startSize: startSize,
        endSize: endSize,
      ),
    );

    Overlay.of(context).insert(entry);
  }
}
