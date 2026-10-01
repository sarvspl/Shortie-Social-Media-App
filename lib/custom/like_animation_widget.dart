import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shortie/custom/custom_gradient_icon.dart';
import 'package:shortie/utils/asset.dart';
import 'package:shortie/utils/color.dart';

class LikeAnimationWidget extends StatefulWidget {
  const LikeAnimationWidget({
    super.key,
    required Offset position,
    required Offset endPosition,
    required double leftRightPosition,
    required VoidCallback onLikeCalled,
    required OverlayEntry overlayEntry,
    required double startSize,
    required double endSize,
  })  : _position = position,
        _endPosition = endPosition,
        _leftRightPosition = leftRightPosition,
        _onLikeCalled = onLikeCalled,
        _startSize = startSize,
        _endSize = endSize,
        _overlayEntry = overlayEntry;

  final Offset _position;
  final Offset _endPosition;
  final double _leftRightPosition;
  final OverlayEntry _overlayEntry;
  final VoidCallback _onLikeCalled;
  final double _startSize;

  final double _endSize;

  @override
  State<LikeAnimationWidget> createState() => _LikeAnimationWidgetState();
}

class _LikeAnimationWidgetState extends State<LikeAnimationWidget> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  double _opacity = 1.0;

  late final Animation<double> _rotation;

  late final Tween<Offset> _positionTween;
  late final Animation<Offset> _position;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));

    _controller.addListener(() {
      if (_controller.isCompleted) {
        _opacity = 0.0;
        setState(() {});
        widget._onLikeCalled.call();

        Future.delayed(const Duration(milliseconds: 100), () => widget._overlayEntry.remove());
      } else {
        setState(() {});
      }
    });

    /// RANDOM ROTATION
    final random = Random();
    final xAxisValue = random.nextDouble() * 0.5 * (random.nextBool() ? 1 : -1);

    _rotation = _controller.drive(TweenSequence([
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: xAxisValue), weight: 30),
      TweenSequenceItem(tween: Tween<double>(begin: xAxisValue, end: 0.0), weight: 30),
    ]));

    /// MOVEMENT
    _positionTween = Tween<Offset>(begin: const Offset(0, -45));

    _position = TweenSequence<Offset>([
      TweenSequenceItem(tween: ConstantTween(const Offset(0, -45)), weight: 50),
      TweenSequenceItem(tween: _positionTween, weight: 50),
    ]).animate(_controller);

    _controller.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final dx = widget._endPosition.dx - widget._position.dx;
    final dy = widget._endPosition.dy - widget._position.dy;

    _positionTween.end = Offset(dx, dy);
  }

  @override
  Widget build(BuildContext context) {
    final double iconSize = lerpDouble(widget._startSize, widget._endSize, _controller.value)!;

    return Positioned(
      left: widget._position.dx - widget._leftRightPosition,
      top: widget._position.dy - widget._leftRightPosition,
      child: Transform.translate(
        offset: _position.value,
        child: Transform.rotate(
          angle: _rotation.value,
          child: AnimatedOpacity(
            opacity: _opacity,
            duration: const Duration(milliseconds: 250),
            child: GradientIcon(
              icon: AppAsset.icLike,
              size: iconSize, // ✅ Static size animation
              gradient: AppColor.primaryLinearGradient,
            ),
          ),
        ),
      ),
    );
  }
}
