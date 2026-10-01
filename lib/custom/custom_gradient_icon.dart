import 'package:flutter/material.dart';

class GradientIcon extends StatelessWidget {
  final String icon;
  final double size;
  final Gradient gradient;

  const GradientIcon({
    super.key,
    required this.icon,
    required this.size,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => gradient.createShader(bounds),
      child: SizedBox(
        width: size,
        height: size,
        child: Image.asset(icon, color: Colors.white),
      ),
    );
  }
}
