import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:help_out/core/domain/entities/daily_task_entity.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/shared/widgets/app_icon.dart";
import "package:help_out/shared/widgets/bounce_tap.dart";

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
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  @override
  State<DailyTaskTile> createState() => _DailyTaskTileState();
}

class _DailyTaskTileState extends State<DailyTaskTile>
    with SingleTickerProviderStateMixin {
  static const double _revealWidth = 66;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
    lowerBound: -_revealWidth,
    upperBound: _revealWidth,
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

  void _onTapEdit() {
    _controller.animateTo(0, curve: Curves.easeOut);
    widget.onEdit();
  }

  void _onTapDelete() {
    _controller.animateTo(0, curve: Curves.easeOut);
    widget.onDelete();
  }

  @override
  Widget build(BuildContext context) {
    final Color taskColor = Color(widget.task.colorValue);
    final bool isCheckedToday = widget.task.isCheckedToday;
    final double progress = widget.task.currentTarget == 0
        ? 0
        : (widget.task.currentProgress / widget.task.currentTarget).clamp(
            0.0,
            1.0,
          );

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Stack(
        children: [
          if (_controller.value > 0)
            Positioned.fill(
              child: Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: _onTapEdit,
                  child: Container(
                    width: _revealWidth - 8,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: context.colorTokens.surface,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.edit_rounded,
                      color: context.colorTokens.primary,
                      size: 25,
                    ),
                  ),
                ),
              ),
            ),
          if (_controller.value < 0)
            Positioned.fill(
              child: Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: _onTapDelete,
                  child: Container(
                    width: _revealWidth - 8,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: context.colorTokens.error,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.center,
                    child: const AppIcon(
                      "trash",
                      color: Colors.white,
                      size: 25,
                    ),
                  ),
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
              onTap: widget.onToggle,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isCheckedToday ? taskColor : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(color: taskColor, width: 2),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.task.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Gap(8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      backgroundColor: context.colorTokens.surfaceInnerLayer,
                      valueColor: AlwaysStoppedAnimation<Color>(taskColor),
                    ),
                  ),
                ],
              ),
            ),
            const Gap(12),
            Text(
              widget.task.isCompleted
                  ? context.l10n.taskCompletedLabel
                  : context.l10n.taskDaysProgress(
                      widget.task.currentProgress,
                      widget.task.currentTarget,
                    ),
              style: context.textStyles.bodySmall.copyWith(
                color: widget.task.isCompleted
                    ? context.colorTokens.success
                    : context.colorTokens.textHint,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
