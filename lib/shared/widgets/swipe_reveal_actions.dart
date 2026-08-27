import "package:flutter/material.dart";
import "package:timing/core/utils/extensions/context_extensions.dart";
import "package:timing/shared/widgets/app_icon.dart";

/// One action button revealed behind a [SwipeRevealActions] row.
class SwipeRevealAction {
  const SwipeRevealAction({
    required this.background,
    required this.onTap,
    this.iconPath,
    this.iconData,
    this.iconColor,
    this.borderColor,
    this.locked = false,
  }) : assert(iconPath != null || iconData != null);

  final Color background;
  final VoidCallback onTap;
  final String? iconPath;
  final IconData? iconData;
  final Color? iconColor;

  /// Optional outline, so a light button stays visible on a light surface.
  final Color? borderColor;

  /// Renders the button greyed out with a small lock badge — used for actions
  /// that are unavailable here (e.g. a group-owned item that can't be deleted
  /// directly). The [onTap] still fires so the caller can explain why.
  final bool locked;
}

/// Swipe a row to the left to reveal a fixed set of trailing actions (edit,
/// delete, …). Shared so every list in the app — daily goals, schedule — uses
/// the exact same reveal gesture and motion.
class SwipeRevealActions extends StatefulWidget {
  const SwipeRevealActions({
    required this.child,
    required this.actions,
    super.key,
  });

  final Widget child;
  final List<SwipeRevealAction> actions;

  @override
  State<SwipeRevealActions> createState() => _SwipeRevealActionsState();
}

class _SwipeRevealActionsState extends State<SwipeRevealActions>
    with SingleTickerProviderStateMixin {
  static const double _actionWidth = 58;
  static const double _actionGap = 8;
  static const double _leadingGap = 8;

  late final double _revealWidth =
      widget.actions.length * _actionWidth +
      (widget.actions.length - 1) * _actionGap +
      _leadingGap;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
    lowerBound: -_revealWidth,
    upperBound: 0,
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
      0,
    );
  }

  void _onDragEnd(DragEndDetails details) {
    final double target = _controller.value < -_revealWidth / 2
        ? -_revealWidth
        : 0;
    _controller.animateTo(target, curve: Curves.easeOut);
  }

  void _close() => _controller.animateTo(0, curve: Curves.easeOut);

  void _onTapAction(SwipeRevealAction action) {
    _close();
    action.onTap();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _controller,
    builder: (context, child) => Stack(
      children: [
        if (_controller.value < 0)
          Positioned.fill(
            child: Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (
                    int index = 0;
                    index < widget.actions.length;
                    index++
                  ) ...[
                    if (index > 0) const SizedBox(width: _actionGap),
                    _RevealActionButton(
                      action: widget.actions[index],
                      onTap: () => _onTapAction(widget.actions[index]),
                    ),
                  ],
                ],
              ),
            ),
          ),
        GestureDetector(
          onHorizontalDragUpdate: _onDragUpdate,
          onHorizontalDragEnd: _onDragEnd,
          child: Transform.translate(
            offset: Offset(_controller.value, 0),
            child: child,
          ),
        ),
      ],
    ),
    child: widget.child,
  );
}

class _RevealActionButton extends StatelessWidget {
  const _RevealActionButton({required this.action, required this.onTap});

  static const double _width = _SwipeRevealActionsState._actionWidth;
  static const double _defaultIconSize = 25;
  static const double _trashIconSize = 20;

  final SwipeRevealAction action;
  final VoidCallback onTap;

  double get _iconSize =>
      action.iconPath == "trash" ? _trashIconSize : _defaultIconSize;

  @override
  Widget build(BuildContext context) {
    final bool locked = action.locked;
    final Color background = locked
        ? context.colorTokens.surfaceInnerLayer
        : action.background;
    final Color iconColor = locked
        ? context.colorTokens.textHint
        : (action.iconColor ?? context.colorTokens.white);

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: _width,
            margin: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(14),
              boxShadow: action.borderColor == null || locked
                  ? null
                  : [
                      BoxShadow(
                        color: context.colorTokens.surfaceShadow,
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
            ),
            alignment: Alignment.center,
            child: action.iconPath != null
                ? AppIcon(action.iconPath!, color: iconColor, size: _iconSize)
                : Icon(action.iconData, color: iconColor, size: _iconSize),
          ),
          if (locked) const Positioned(top: -2, right: -2, child: _LockBadge()),
        ],
      ),
    );
  }
}

class _LockBadge extends StatelessWidget {
  const _LockBadge();

  @override
  Widget build(BuildContext context) => Container(
    width: 20,
    height: 20,
    decoration: BoxDecoration(
      color: context.colorTokens.surface,
      shape: BoxShape.circle,
      boxShadow: [
        BoxShadow(
          color: context.colorTokens.surfaceShadow.withValues(alpha: 0.08),
          blurRadius: 10,
          offset: const Offset(2, 2),
        ),
      ],
    ),
    alignment: Alignment.center,
    child: Icon(
      Icons.lock_rounded,
      size: 12,
      color: context.colorTokens.textHint,
    ),
  );
}
