import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:timing/core/domain/entities/daily_task_entity.dart";
import "package:timing/core/utils/extensions/context_extensions.dart";
import "package:timing/shared/widgets/app_icon.dart";
import "package:timing/shared/widgets/bounce_tap.dart";
import "package:timing/shared/widgets/swipe_reveal_actions.dart";

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

class _DailyTaskTileState extends State<DailyTaskTile> {
  bool? _optimisticChecked;
  bool _isToggling = false;

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

    return SwipeRevealActions(
      actions: [
        SwipeRevealAction(
          iconData: Icons.edit_rounded,
          background: context.colorTokens.surface,
          iconColor: taskColor,
          locked: widget.task.isFromGroup,
          onTap: widget.onEdit,
        ),
        SwipeRevealAction(
          iconPath: "trash",
          iconSize: 20,
          background: context.colorTokens.error,
          iconColor: context.colorTokens.white,
          locked: widget.task.isFromGroup,
          onTap: widget.onDelete,
        ),
      ],
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.colorTokens.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            BounceTap(
              pressedScale: 0.88,
              onTap: _onTapToggle,
              behavior: HitTestBehavior.opaque,
              child: Container(
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
                child: isCheckedToday
                    ? const Center(
                        child: AppIcon("check", size: 14, color: Colors.white),
                      )
                    : null,
              ),
            ),
            const Gap(12),
            Expanded(
              child: Opacity(
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
            Opacity(
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
