import "package:flutter/material.dart";
import "package:flutter/services.dart";

class BounceTap extends StatefulWidget {
  const BounceTap({
    required this.onTap,
    required this.child,
    this.pressedScale = 0.9,
    this.behavior = HitTestBehavior.deferToChild,
    this.enableHaptics = true,
    super.key,
  });

  final VoidCallback onTap;
  final Widget child;
  final double pressedScale;

  /// Use [HitTestBehavior.opaque] when the visual is smaller than the tap
  /// target it should own — padding around it stays tappable.
  final HitTestBehavior behavior;

  /// A light selection tick fired the moment the press lands, so every card and
  /// row in the app answers back. Turn off where taps repeat in quick bursts.
  final bool enableHaptics;

  @override
  State<BounceTap> createState() => _BounceTapState();
}

class _BounceTapState extends State<BounceTap> {
  bool _isPressed = false;

  void _setPressed({required bool isPressed}) =>
      setState(() => _isPressed = isPressed);

  void _onTapDown() {
    if (widget.enableHaptics) {
      HapticFeedback.selectionClick();
    }
    _setPressed(isPressed: true);
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: widget.onTap,
    behavior: widget.behavior,
    onTapDown: (details) => _onTapDown(),
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
