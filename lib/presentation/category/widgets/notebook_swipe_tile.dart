import "package:flutter/material.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/shared/widgets/app_icon.dart";

/// Horizontal swipe tile with two reveals: drag right for notes, drag left to
/// delete. The revealed action stays open until tapped or swiped back.
class NotebookSwipeTile extends StatefulWidget {
  const NotebookSwipeTile({
    required this.child,
    required this.onTapNotes,
    required this.onTapEdit,
    required this.onDelete,
    super.key,
  });

  final Widget child;
  final VoidCallback onTapNotes;
  final VoidCallback onTapEdit;
  final VoidCallback onDelete;

  @override
  State<NotebookSwipeTile> createState() => _NotebookSwipeTileState();
}

class _NotebookSwipeTileState extends State<NotebookSwipeTile>
    with SingleTickerProviderStateMixin {
  static const double _leadingRevealWidth = 144;
  static const double _trailingRevealWidth = 72;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
    lowerBound: -_trailingRevealWidth,
    upperBound: _leadingRevealWidth,
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
      -_trailingRevealWidth,
      _leadingRevealWidth,
    );
  }

  void _onDragEnd(DragEndDetails details) {
    final double target = _controller.value > _leadingRevealWidth / 2
        ? _leadingRevealWidth
        : _controller.value < -_trailingRevealWidth / 2
        ? -_trailingRevealWidth
        : 0;
    _controller.animateTo(target, curve: Curves.easeOut);
  }

  void _onTapNotes() {
    widget.onTapNotes();
    _controller.animateTo(0, curve: Curves.easeOut);
  }

  void _onTapEdit() {
    widget.onTapEdit();
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
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _RevealAction(
                      iconPath: "note",
                      gradient: context.colorTokens.primaryGradient,
                      iconColor: context.colorTokens.white,
                      onTap: _onTapNotes,
                    ),
                    _RevealAction(
                      iconData: Icons.edit_rounded,
                      color: context.colorTokens.surface,
                      iconColor: context.colorTokens.primary,
                      onTap: _onTapEdit,
                    ),
                  ],
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
    required this.onTap,
    this.iconPath,
    this.iconData,
    this.iconColor,
    this.color,
    this.gradient,
  }) : assert(iconPath != null || iconData != null);

  static const double _revealWidth = 72;
  static const double _gap = 8;

  final String? iconPath;
  final IconData? iconData;
  final Color? iconColor;
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
      child: iconPath != null
          ? AppIcon(iconPath!, color: iconColor ?? Colors.white, size: 28)
          : Icon(iconData, color: iconColor ?? Colors.white, size: 28),
    ),
  );
}
