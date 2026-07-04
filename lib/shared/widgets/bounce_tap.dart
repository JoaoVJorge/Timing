import "package:flutter/material.dart";

class BounceTap extends StatefulWidget {
  const BounceTap({
    required this.onTap,
    required this.child,
    this.pressedScale = 0.9,
    super.key,
  });

  final VoidCallback onTap;
  final Widget child;
  final double pressedScale;

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
