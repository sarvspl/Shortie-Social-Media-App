import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_typedefs/rx_typedefs.dart';

import '../utils/color.dart';
import '../utils/font_style.dart';

class CircleIconButtonUi extends StatelessWidget {
  const CircleIconButtonUi({
    super.key,
    required this.icon,
    required this.callback,
    this.circleSize,
    this.iconSize,
    this.color,
    this.gradient,
    this.iconColor,
    this.padding,
    this.border,
    this.onLongPressStart,
    this.onLongPressEnd,
  });

  final String icon;
  final Callback callback;

  final double? circleSize;
  final double? iconSize;

  final Color? color;
  final Color? iconColor;
  final Gradient? gradient;
  final BoxBorder? border;
  final EdgeInsetsGeometry? padding;

  final Function(LongPressStartDetails)? onLongPressStart;
  final Function(LongPressEndDetails)? onLongPressEnd;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: callback,
      onLongPressStart: onLongPressStart,
      onLongPress: () {},
      onLongPressEnd: onLongPressEnd,
      child: Container(
        height: circleSize ?? 42,
        width: circleSize ?? 42,
        padding: padding,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color, gradient: gradient, border: border),
        child: Center(
          child: Image.asset(
            icon,
            height: iconSize ?? 22,
            width: iconSize ?? 22,
            color: iconColor,
          ),
        ),
      ),
    );
  }
}

class LabeledCircleIconButton extends StatelessWidget {
  const LabeledCircleIconButton({
    super.key,
    required this.icon,
    required this.label,
    required this.callback,
    this.circleSize,
    this.iconSize,
    this.color,
    this.gradient,
    this.iconColor,
    this.padding,
    this.border,
    this.labelColor,
    this.labelStyle,
    this.onLongPressStart,
    this.onLongPressEnd,
  });

  final String icon;
  final String label;
  final Callback callback;

  final double? circleSize;
  final double? iconSize;

  final Color? color;
  final Color? iconColor;
  final Color? labelColor;
  final TextStyle? labelStyle;
  final Gradient? gradient;
  final BoxBorder? border;
  final EdgeInsetsGeometry? padding;

  final Function(LongPressStartDetails)? onLongPressStart;
  final Function(LongPressEndDetails)? onLongPressEnd;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: callback,
      onLongPressStart: onLongPressStart,
      onLongPress: () {},
      onLongPressEnd: onLongPressEnd,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 28,
            height: 28,
            child: Center(
              child: Image.asset(
                icon,
                height: iconSize ?? 28,
                width: iconSize ?? 28,
                color: iconColor ?? null,
              ),
            ),
          ),
          // const SizedBox(height: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppFontStyle.styleW500(AppColor.white, 12),
          ),
        ],
      ),
    );
  }
}
