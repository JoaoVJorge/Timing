import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:timing/core/domain/entities/daily_task_entity.dart";
import "package:timing/core/utils/extensions/context_extensions.dart";
import "package:timing/shared/widgets/app_icon.dart";
import "package:timing/shared/widgets/bounce_tap.dart";

class DailyTaskTile extends StatefulWidget {
  const DailyTaskTile({
    required this.task,
    required this.onEdit,
    required this.onToggle,
    required this.onDelete,
    super.key,
  });

  final DailyTaskEntity task;
  final VoidCallback onEdit;
  final Future<void> Function() onToggle;
  final VoidCallback onDelete;

  @override
  State<DailyTaskTile> createState() => _DailyTaskTileState();
}

class _DailyTaskTileState extends State<DailyTaskTile>
    with SingleTickerProviderStateMixin {
  static const double _trailingRevealWidth = 132;
  bool? _optimisticChecked;
  bool _isToggling = false;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
    lowerBound: -_trailingRevealWidth,
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
      -_trailingRevealWidth,
      0,
    );
  }

  void _onDragEnd(DragEndDetails details) {
    final double target = _controller.value < -_trailingRevealWidth / 2
        ? -_trailingRevealWidth
        : 0;
    _controller.animateTo(target, curve: Curves.easeOut);
  }

  void _onTapEdit() {
    _controller.animateTo(0, curve: Curves.easeOut);
    widget.onEdit();
  }

  void _onTapDelete() {
    _controller.animateTo(0, curve: Curves.easeOut);
    widget.onDelete();
  }

  Future<void> _onTapToggle() async {
    if (_isToggling) {
      return;
    }
    setState(() {
      _isToggling = true;
      _optimisticChecked = !_visualChecked;
    });
    await widget.onToggle();
    if (mounted) {
      setState(() {
        _isToggling = false;
        _optimisticChecked = null;
      });
    }
  }

  bool get _visualChecked =>
      _optimisticChecked ?? widget.task.isDoneForCurrentCycle;

  @override
  Widget build(BuildContext context) {
    final Color taskColor = Color(widget.task.colorValue);
    final bool isCheckedToday = _visualChecked;
    final double contentOpacity = isCheckedToday ? 0.55 : 1;

    return AnimatedBuilder(
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
                    _RevealAction(
                      iconData: Icons.edit_rounded,
                      color: context.colorTokens.surface,
                      iconColor: taskColor,
                      onTap: _onTapEdit,
                    ),
                    const SizedBox(width: _RevealAction.gap),
                    _RevealAction(
                      iconPath: "trash",
                      color: context.colorTokens.error,
                      iconColor: context.colorTokens.white,
                      onTap: _onTapDelete,
                    ),
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
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.colorTokens.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            BounceTap(
              onTap: _onTapToggle,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isCheckedToday ? taskColor : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isCheckedToday
                        ? taskColor
                        : taskColor.withValues(alpha: 0.78),
                    width: 2,
                  ),
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  switchInCurve: Curves.easeOutBack,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, animation) => ScaleTransition(
                    scale: animation,
                    child: FadeTransition(opacity: animation, child: child),
                  ),
                  child: isCheckedToday
                      ? const Center(
                          key: ValueKey("checked"),
                          child: AppIcon(
                            "check",
                            size: 14,
                            color: Colors.white,
                          ),
                        )
                      : const SizedBox.shrink(key: ValueKey("unchecked")),
                ),
              ),
            ),
            const Gap(12),
            Expanded(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                opacity: contentOpacity,
                child: Text(
                  widget.task.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w800,
                    decoration: isCheckedToday
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                    decorationThickness: 2,
                    decorationColor: context.colorTokens.textBody.withValues(
                      alpha: 0.72,
                    ),
                  ),
                ),
              ),
            ),
            const Gap(12),
            AnimatedOpacity(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              opacity: contentOpacity,
              child: widget.task.hasInfiniteTarget
                  ? Text(
                      "${widget.task.currentProgress} ${context.l10n.daysSuffix}",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textStyles.bodyMedium.copyWith(
                        color: taskColor,
                        fontWeight: FontWeight.w900,
                      ),
                    )
                  : Text(
                      "${widget.task.currentProgress}/${widget.task.currentTarget} ${context.l10n.daysSuffix}",
                      style: context.textStyles.bodyMedium.copyWith(
                        color: taskColor,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RevealAction extends StatelessWidget {
  const _RevealAction({
    required this.onTap,
    this.iconPath,
    this.iconData,
    this.iconColor,
    this.color,
  }) : assert(iconPath != null || iconData != null);

  static const double _revealWidth = 58;
  static const double gap = 8;

  final String? iconPath;
  final IconData? iconData;
  final Color? iconColor;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: _revealWidth,
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
      ),
      alignment: Alignment.center,
      child: iconPath != null
          ? AppIcon(iconPath!, color: iconColor ?? Colors.white, size: 25)
          : Icon(iconData, color: iconColor ?? Colors.white, size: 25),
    ),
  );
}
