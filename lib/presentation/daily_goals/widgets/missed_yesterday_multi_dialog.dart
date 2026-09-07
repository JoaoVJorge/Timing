import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:timing/app/app_navigator.dart";
import "package:timing/core/domain/entities/daily_task_entity.dart";
import "package:timing/core/utils/extensions/context_extensions.dart";
import "package:timing/shared/widgets/bounce_tap.dart";

class MissedYesterdayMultiDialog extends StatefulWidget {
  const MissedYesterdayMultiDialog({
    required this.tasks,
    this.onConfirm,
    super.key,
  });

  final List<DailyTaskEntity> tasks;

  /// Used by isolated previews and widget tests. In the app, omitting this
  /// callback closes the dialog and returns the selected task ids.
  final ValueChanged<Set<String>>? onConfirm;

  @override
  State<MissedYesterdayMultiDialog> createState() =>
      _MissedYesterdayMultiDialogState();
}

class _MissedYesterdayMultiDialogState
    extends State<MissedYesterdayMultiDialog> {
  final Set<String> _selectedIds = <String>{};

  void _toggle(String taskId) {
    setState(() {
      if (!_selectedIds.remove(taskId)) {
        _selectedIds.add(taskId);
      }
    });
  }

  void _confirm() {
    final Set<String> selectedIds = Set<String>.of(_selectedIds);
    final ValueChanged<Set<String>>? onConfirm = widget.onConfirm;
    if (onConfirm != null) {
      onConfirm(selectedIds);
      return;
    }
    appNavigator.back<Set<String>>(result: selectedIds);
  }

  @override
  Widget build(BuildContext context) {
    final Color accent = context.colorTokens.primary;

    return Dialog(
      elevation: 0,
      backgroundColor: context.colorTokens.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 34),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 390),
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
        decoration: BoxDecoration(
          color: context.colorTokens.dialogSurface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: context.colorTokens.black.withValues(alpha: 0.16),
              blurRadius: 28,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
              child: Icon(
                Icons.history_rounded,
                color: context.colorTokens.white,
                size: 28,
              ),
            ),
            const Gap(14),
            Text(
              context.l10n.missedYesterdayMultiTitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: context.textStyles.extraBold24.copyWith(
                color: context.colorTokens.dialogText,
                fontSize: 21,
                height: 1.12,
              ),
            ),
            const Gap(10),
            Text(
              context.l10n.missedYesterdayMultiContent,
              textAlign: TextAlign.center,
              style: context.textStyles.bodyLarge.copyWith(
                color: context.colorTokens.dialogTextMuted,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                height: 1.38,
              ),
            ),
            const Gap(22),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 280),
              child: ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: widget.tasks.length,
                separatorBuilder: (_, _) => const Gap(10),
                itemBuilder: (context, index) {
                  final DailyTaskEntity task = widget.tasks[index];
                  return _MissedTaskCheckRow(
                    label: task.name,
                    selected: _selectedIds.contains(task.id),
                    taskColor: Color(task.colorValue),
                    onTap: () => _toggle(task.id),
                  );
                },
              ),
            ),
            const Gap(22),
            SizedBox(
              width: double.infinity,
              child: _MissedDialogButton(
                label: context.l10n.missedYesterdayMultiConfirmButton,
                foreground: context.colorTokens.white,
                gradient: context.colorTokens.primaryGradient,
                onTap: _confirm,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MissedTaskCheckRow extends StatelessWidget {
  const _MissedTaskCheckRow({
    required this.label,
    required this.selected,
    required this.taskColor,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color taskColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color outlineColor = taskColor.withValues(alpha: selected ? 1 : 0.62);
    final double outlineWidth = selected ? 2 : 1.5;

    return BounceTap(
      pressedScale: 0.98,
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 54),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? taskColor.withValues(alpha: 0.12)
              : context.colorTokens.dialogSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: outlineColor, width: outlineWidth),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: selected ? taskColor : context.colorTokens.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: outlineColor, width: outlineWidth),
              ),
              child: selected
                  ? Icon(
                      Icons.check_rounded,
                      size: 16,
                      color: context.colorTokens.white,
                    )
                  : null,
            ),
            const Gap(12),
            Expanded(
              child: Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: context.textStyles.bodyLarge.copyWith(
                  color: taskColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MissedDialogButton extends StatelessWidget {
  const _MissedDialogButton({
    required this.label,
    required this.foreground,
    required this.onTap,
    this.gradient,
  });

  final String label;
  final Color foreground;
  final VoidCallback onTap;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) => BounceTap(
    pressedScale: 0.97,
    onTap: onTap,
    child: Container(
      height: 50,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: context.textStyles.bodyLarge.copyWith(
          color: foreground,
          fontSize: 16,
          fontWeight: FontWeight.w800,
        ),
      ),
    ),
  );
}
