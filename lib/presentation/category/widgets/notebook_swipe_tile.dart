import "package:flutter/material.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/shared/widgets/app_icon.dart";

/// Horizontal swipe tile with two reveals: drag right for notes, drag left to
/// delete. The revealed action stays open until tapped or swiped back.
class NotebookSwipeTile extends StatefulWidget {
  const NotebookSwipeTile({
    required this.child,
    required this.onTapNotes,
    required this.onDelete,
    super.key,
  });

  final Widget child;
  final VoidCallback onTapNotes;
  final VoidCallback onDelete;

  @override
  State<NotebookSwipeTile> createState() => _NotebookSwipeTileState();
}

class _NotebookSwipeTileState extends State<NotebookSwipeTile>
    with SingleTickerProviderStateMixin {
  static const double _revealWidth = 72;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
    lowerBound: -_revealWidth,
    upperBound: _revealWidth,
    // Start centered — without this the controller defaults to lowerBound,
    // opening every tile with the delete action already revealed.
    value: 0,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    _controller.value = (_controller.value + details.delta.dx).clamp(
      -_revealWidth,
      _revealWidth,
    );
  }

  void _onDragEnd(DragEndDetails details) {
    final double target = _controller.value > _revealWidth / 2
        ? _revealWidth
        : _controller.value < -_revealWidth / 2
        ? -_revealWidth
        : 0;
    _controller.animateTo(target, curve: Curves.easeOut);
  }

  void _onTapNotes() {
    widget.onTapNotes();
    _controller.animateTo(0, curve: Curves.easeOut);
  }

  void _onTapDelete() {
    _controller.animateTo(0, curve: Curves.easeOut);
    widget.onDelete();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _controller,
    builder: (context, child) {
      final double value = _controller.value;
      return Stack(
        children: [
          if (value > 0)
            Positioned.fill(
              child: Align(
                alignment: Alignment.centerLeft,
                child: _RevealAction(
                  iconPath: "note",
                  gradient: context.colorTokens.primaryGradient,
                  onTap: _onTapNotes,
                ),
              ),
            ),
          if (value < 0)
            Positioned.fill(
              child: Align(
                alignment: Alignment.centerRight,
                child: _RevealAction(
                  iconPath: "trash",
                  color: context.colorTokens.error,
                  onTap: _onTapDelete,
                ),
              ),
            ),
          GestureDetector(
            onHorizontalDragUpdate: _onDragUpdate,
            onHorizontalDragEnd: _onDragEnd,
            child: Transform.translate(offset: Offset(value, 0), child: child),
          ),
        ],
      );
    },
    child: widget.child,
  );
}

class _RevealAction extends StatelessWidget {
  const _RevealAction({
    required this.iconPath,
    required this.onTap,
    this.color,
    this.gradient,
  });

  static const double _revealWidth = 72;
  static const double _gap = 8;

  final String iconPath;
  final VoidCallback onTap;
  final Color? color;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: _revealWidth - _gap,
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: color,
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.center,
      child: AppIcon(iconPath, color: Colors.white, size: 28),
    ),
  );
}
