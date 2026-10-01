import 'package:flutter/material.dart';

class DoubleTapDetector extends StatefulWidget {
  const DoubleTapDetector({
    super.key,
    required Widget child,
    required GestureTapDownCallback onDoubleTap,
    this.onTap,
    this.behavior,
    this.onHorizontalDragEnd,
  })  : _child = child,
        _onDoubleTap = onDoubleTap;

  final Widget _child;
  final GestureTapDownCallback _onDoubleTap;
  final VoidCallback? onTap;
  final HitTestBehavior? behavior;
  final void Function(dynamic details)? onHorizontalDragEnd;

  @override
  State<DoubleTapDetector> createState() => _DoubleTapDetectorState();
}

class _DoubleTapDetectorState extends State<DoubleTapDetector> {
  TapDownDetails? _tapDownDetails;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      behavior: widget.behavior ?? HitTestBehavior.translucent, // ✅
      onDoubleTapCancel: () => _tapDownDetails = null,
      onDoubleTapDown: (details) => _tapDownDetails = details,
      // ✅ conditionally register — null હોય તો arena માં enter જ નહીં થાય
      onHorizontalDragEnd: widget.onHorizontalDragEnd != null ? (details) => widget.onHorizontalDragEnd!.call(details) : null,
      onDoubleTap: () {
        if (_tapDownDetails == null) return;
        widget._onDoubleTap(_tapDownDetails!);
      },
      child: widget._child,
    );
  }
}
