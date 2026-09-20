import "dart:async";

import "package:flutter/material.dart";
import "package:timing/core/utils/extensions/context_extensions.dart";

/// Wraps a freshly created subject's tile with a callout that teaches the
/// swipe gesture right when the tile is born, instead of hiding the
/// explanation behind an info button nobody taps.
///
/// Always mounted (per tile) so toggling [visible] animates the bubble in
/// and out via [AnimatedSwitcher] instead of the tile popping out of the
/// tree the instant the hint is dismissed.
class SubjectCreationHintBubble extends StatefulWidget {
  const SubjectCreationHintBubble({
    required this.visible,
    required this.message,
    required this.child,
    required this.onAutoDismiss,
    super.key,
  });

  final bool visible;
  final String message;
  final Widget child;
  final VoidCallback onAutoDismiss;

  @override
  State<SubjectCreationHintBubble> createState() =>
      _SubjectCreationHintBubbleState();
}

class _SubjectCreationHintBubbleState extends State<SubjectCreationHintBubble> {
  static const Duration _autoDismissDelay = Duration(seconds: 5);
  static const Duration _transitionDuration = Duration(milliseconds: 220);

  Timer? _autoDismissTimer;

  @override
  void initState() {
    super.initState();
    if (widget.visible) {
      _scheduleAutoDismiss();
    }
  }

  @override
  void didUpdateWidget(covariant SubjectCreationHintBubble oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.visible && !oldWidget.visible) {
      _scheduleAutoDismiss();
    } else if (!widget.visible && oldWidget.visible) {
      _autoDismissTimer?.cancel();
    }
  }

  void _scheduleAutoDismiss() {
    _autoDismissTimer?.cancel();
    _autoDismissTimer = Timer(_autoDismissDelay, widget.onAutoDismiss);
  }

  @override
  void dispose() {
    _autoDismissTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      widget.child,
      AnimatedSwitcher(
        duration: _transitionDuration,
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: SizeTransition(
            sizeFactor: animation,
            alignment: Alignment.topCenter,
            child: child,
          ),
        ),
        child: widget.visible
            ? Padding(
                key: const ValueKey("visible"),
                padding: const EdgeInsets.only(top: 8),
                child: _Bubble(message: widget.message),
              )
            : const SizedBox.shrink(key: ValueKey("hidden")),
      ),
    ],
  );
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      Padding(
        padding: const EdgeInsets.only(right: 16),
        child: CustomPaint(
          size: const Size(12, 6),
          painter: _PointerPainter(color: context.colorTokens.primary),
        ),
      ),
      Container(
        constraints: const BoxConstraints(maxWidth: 260),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: context.colorTokens.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: context.textStyles.bodySmall.copyWith(
            color: context.colorTokens.primaryForeground,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    ],
  );
}

class _PointerPainter extends CustomPainter {
  const _PointerPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..color = color;
    final Path path = Path()
      ..moveTo(0, size.height)
      ..lineTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _PointerPainter oldDelegate) =>
      oldDelegate.color != color;
}
