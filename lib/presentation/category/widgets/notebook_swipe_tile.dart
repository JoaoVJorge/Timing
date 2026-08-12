import "package:flutter/material.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/presentation/category/widgets/group_activity_lock_badge.dart";
import "package:help_out/shared/widgets/app_icon.dart";

/// Horizontal swipe tile with two reveals: drag right for notes/statistics,
/// drag left to edit/delete. The reveal stays open until tapped or swiped back.
class NotebookSwipeTile extends StatefulWidget {
  const NotebookSwipeTile({
    required this.child,
    required this.accent,
    required this.onTapNotes,
    required this.onTapStats,
    required this.onTapEdit,
    required this.onDelete,
    this.isDeleteLocked = false,
    super.key,
  });

  final Widget child;
  final Color accent;
  final VoidCallback onTapNotes;
  final VoidCallback onTapStats;
  final VoidCallback onTapEdit;
  final VoidCallback onDelete;
  final bool isDeleteLocked;

  @override
  State<NotebookSwipeTile> createState() => _NotebookSwipeTileState();
}

class _NotebookSwipeTileState extends State<NotebookSwipeTile>
    with SingleTickerProviderStateMixin {
  static const double _leadingRevealWidth = 132;
  static const double _trailingRevealWidth = 132;

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

  void _onTapStats() {
    widget.onTapStats();
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
                      gradient: LinearGradient(
                        colors: [
                          widget.accent,
                          Color.lerp(
                                widget.accent,
                                context.colorTokens.white,
                                0.16,
                              ) ??
                              widget.accent,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      iconColor: context.colorTokens.white,
                      onTap: _onTapNotes,
                    ),
                    const SizedBox(width: _RevealAction.gap),
                    _RevealAction(
                      iconData: Icons.bar_chart_rounded,
                      color: context.colorTokens.surface,
                      iconColor: widget.accent,
                      onTap: _onTapStats,
                    ),
                  ],
                ),
              ),
            ),
          if (value < 0)
            Positioned.fill(
              child: Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _RevealAction(
                      iconData: Icons.edit_rounded,
                      color: context.colorTokens.surface,
                      iconColor: widget.accent,
                      onTap: _onTapEdit,
                    ),
                    const SizedBox(width: _RevealAction.gap),
                    _RevealAction(
                      iconPath: "trash",
                      color: context.colorTokens.surfaceInnerLayer,
                      iconColor: context.colorTokens.textHint,
                      showLock: widget.isDeleteLocked,
                      onTap: _onTapDelete,
                    ),
                  ],
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
    this.showLock = false,
  }) : assert(iconPath != null || iconData != null);

  static const double _revealWidth = 58;
  static const double gap = 8;

  final String? iconPath;
  final IconData? iconData;
  final Color? iconColor;
  final VoidCallback onTap;
  final Color? color;
  final Gradient? gradient;
  final bool showLock;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: _revealWidth,
          margin: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: color,
            gradient: gradient,
            borderRadius: BorderRadius.circular(14),
          ),
          alignment: Alignment.center,
          child: iconPath != null
              ? AppIcon(iconPath!, color: iconColor ?? Colors.white, size: 25)
              : Icon(iconData, color: iconColor ?? Colors.white, size: 25),
        ),
        if (showLock)
          Positioned(
            top: -2,
            right: -2,
            child: GroupActivityLockBadge(
              size: 20,
              iconSize: 12,
              backgroundColor: context.colorTokens.surface,
              iconColor: context.colorTokens.borderFocused,
            ),
          ),
      ],
    ),
  );
}
