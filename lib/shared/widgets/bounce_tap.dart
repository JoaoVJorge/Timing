import "package:flutter/material.dart";

class BounceTap extends StatefulWidget {
  const BounceTap({
    required this.onTap,
    required this.child,
    this.pressedScale = 0.9,
    this.behavior = HitTestBehavior.deferToChild,
    super.key,
  });

  final VoidCallback onTap;
  final Widget child;
  final double pressedScale;

  /// Use [HitTestBehavior.opaque] when the visual is smaller than the tap
  /// target it should own — padding around it stays tappable.
  final HitTestBehavior behavior;

  @override
  State<BounceTap> createState() => _BounceTapState();
}

class _BounceTapState extends State<BounceTap> {
  bool _isPressed = false;

  void _setPressed({required bool isPressed}) =>
      setState(() => _isPressed = isPressed);

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: widget.onTap,
    behavior: widget.behavior,
    onTapDown: (details) => _setPressed(isPressed: true),
    onTapUp: (details) => _setPressed(isPressed: false),
    onTapCancel: () => _setPressed(isPressed: false),
    child: AnimatedScale(
      scale: _isPressed ? widget.pressedScale : 1,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: widget.child,
    ),
  );
}
