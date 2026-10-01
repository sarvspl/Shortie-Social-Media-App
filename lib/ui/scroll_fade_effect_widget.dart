import 'package:flutter/material.dart';

class ScrollFadeEffectWidget extends StatelessWidget {
  const ScrollFadeEffectWidget({super.key, required this.child, required this.axis});

  final Widget child;
  final Axis axis;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return LinearGradient(
          begin: axis == Axis.horizontal ? Alignment.centerLeft : Alignment.topCenter,
          end: axis == Axis.horizontal ? Alignment.centerRight : Alignment.bottomCenter,
          colors: [
            axis == Axis.horizontal ? Colors.white : Colors.transparent,
            Colors.white,
            Colors.white,
            Colors.transparent,
          ],
          stops: const [0.0, 0.1, 0.9, 1.0],
        ).createShader(bounds);
      },
      blendMode: BlendMode.dstIn,
      child: child,
    );
  }
}

class HorizantalScrollFadeEffectWidget extends StatelessWidget {
  const HorizantalScrollFadeEffectWidget({super.key, required this.child, required this.axis});

  final Widget child;
  final Axis axis;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return LinearGradient(
          begin: axis == Axis.horizontal ? Alignment.centerLeft : Alignment.topCenter,
          end: axis == Axis.horizontal ? Alignment.centerRight : Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.white,
            Colors.white,
            Colors.transparent,
          ],
          stops: const [0.0, 0.1, 0.9, 1.0],
        ).createShader(bounds);
      },
      blendMode: BlendMode.dstIn,
      child: child,
    );
  }
}
