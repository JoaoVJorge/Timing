import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:get/get.dart";
import "package:timing/core/domain/entities/daily_task_entity.dart";
import "package:timing/core/utils/extensions/context_extensions.dart";
import "package:timing/presentation/daily_goals/daily_goals_controller.dart";
import "package:timing/presentation/daily_goals/widgets/add_task_tile.dart";
import "package:timing/presentation/daily_goals/widgets/daily_task_tile.dart";
import "package:timing/shared/widgets/app_scaffold.dart";
import "package:timing/shared/widgets/app_section_header.dart";
import "package:timing/shared/widgets/app_top_bar.dart";
import "package:timing/shared/widgets/illustrated_empty_state.dart";
import "package:timing/theme/app_spacing.dart";

class DailyGoalsPage extends StatelessWidget {
  const DailyGoalsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final DailyGoalsController controller = Get.find();

    return AppScaffold(
      topBar: AppTopBar(
        title: context.l10n.homeTasksSection,
        showBackButton: true,
      ),
      body: Obx(() {
        final List<DailyTaskEntity> pending = controller.pendingTasks;
        final List<DailyTaskEntity> completed = controller.completedTasks;

        if (controller.tasks.isEmpty) {
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(
                top: AppSpacing.betweenRelated,
                bottom: AppSpacing.betweenSections,
              ),
              child: IllustratedEmptyState(
                title: context.l10n.dailyGoalsNoGoalsYetTitle,
                description: context.l10n.dailyGoalsNoGoalsYetDescription,
                actionLabel: context.l10n.addTaskButton,
                onTapAction: controller.onTapAddTask,
                suggestionsTitle: context.l10n.dailyGoalsSuggestionsTitle,
                suggestions: [
                  context.l10n.dailyGoalsSuggestionStudy,
                  context.l10n.dailyGoalsSuggestionRead,
                  context.l10n.dailyGoalsSuggestionTrain,
                ],
                onTapSuggestion: controller.onTapSuggestion,
              ),
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.only(bottom: AppSpacing.betweenSections),
          children: [
            if (pending.isNotEmpty) ...[
              AppSectionHeader(
                title: context.l10n.dailyGoalsPendingSection,
                badge: context.l10n.homeGoalsProgress(
                  controller.doneTodayCount,
                  controller.tasks.length,
                ),
              ),
              const Gap(AppSpacing.betweenRelated),
              _AnimatedTaskSection(
                tasks: pending,
                onEdit: controller.onEditTask,
                onToggle: controller.onToggleTask,
                onDelete: controller.onDeleteTask,
              ),
            ],
            if (completed.isNotEmpty) ...[
              if (pending.isNotEmpty)
                const Gap(
                  AppSpacing.betweenSections - AppSpacing.betweenRelated,
                ),
              AppSectionHeader(
                title: context.l10n.dailyGoalsCompletedSection,
                badge: context.l10n.homeGoalsProgress(
                  controller.doneTodayCount,
                  controller.tasks.length,
                ),
              ),
              const Gap(AppSpacing.betweenRelated),
              _AnimatedTaskSection(
                tasks: completed,
                onEdit: controller.onEditTask,
                onToggle: controller.onToggleTask,
                onDelete: controller.onDeleteTask,
              ),
            ],
            const Gap(AppSpacing.titleToDescription),
            AddTaskTile(onTap: controller.onTapAddTask),
          ],
        );
      }),
    );
  }
}

class _AnimatedTaskSection extends StatefulWidget {
  const _AnimatedTaskSection({
    required this.tasks,
    required this.onEdit,
    required this.onToggle,
    required this.onDelete,
  });

  final List<DailyTaskEntity> tasks;
  final ValueChanged<DailyTaskEntity> onEdit;
  final Future<void> Function(DailyTaskEntity task) onToggle;
  final ValueChanged<DailyTaskEntity> onDelete;

  @override
  State<_AnimatedTaskSection> createState() => _AnimatedTaskSectionState();
}

class _AnimatedTaskSectionState extends State<_AnimatedTaskSection>
    with TickerProviderStateMixin {
  static const Duration _duration = Duration(milliseconds: 260);

  late final List<_TaskListItem> _items = [
    for (final DailyTaskEntity task in widget.tasks)
      _TaskListItem(task: task, isVisible: true),
  ];

  @override
  void didUpdateWidget(_AnimatedTaskSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncItems();
  }

  void _syncItems() {
    final Set<String> nextIds = widget.tasks.map((task) => task.id).toSet();
    final Map<String, DailyTaskEntity> nextById = {
      for (final DailyTaskEntity task in widget.tasks) task.id: task,
    };

    for (final _TaskListItem item in _items) {
      final DailyTaskEntity? nextTask = nextById[item.task.id];
      if (nextTask == null) {
        item.isVisible = false;
      } else {
        item.task = nextTask;
      }
    }

    final Set<String> currentIds = _items.map((item) => item.task.id).toSet();
    for (int index = 0; index < widget.tasks.length; index++) {
      final DailyTaskEntity task = widget.tasks[index];
      if (currentIds.contains(task.id)) {
        continue;
      }
      final _TaskListItem item = _TaskListItem(task: task, isVisible: false);
      _items.insert(index.clamp(0, _items.length), item);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() => item.isVisible = true);
        }
      });
    }

    _items.sort((a, b) {
      final int aIndex = widget.tasks.indexWhere(
        (task) => task.id == a.task.id,
      );
      final int bIndex = widget.tasks.indexWhere(
        (task) => task.id == b.task.id,
      );
      if (aIndex == -1 && bIndex == -1) {
        return 0;
      }
      if (aIndex == -1) {
        return 1;
      }
      if (bIndex == -1) {
        return -1;
      }
      return aIndex.compareTo(bIndex);
    });

    setState(() {});
    Future<void>.delayed(_duration, () {
      if (!mounted) {
        return;
      }
      setState(() {
        _items.removeWhere(
          (item) => !item.isVisible && !nextIds.contains(item.task.id),
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) => Column(
    children: [
      for (final _TaskListItem item in _items) ...[
        _AnimatedTaskEntry(
          key: ValueKey(item.task.id),
          isVisible: item.isVisible,
          duration: _duration,
          child: DailyTaskTile(
            task: item.task,
            onEdit: () => widget.onEdit(item.task),
            onToggle: () => widget.onToggle(item.task),
            onDelete: () => widget.onDelete(item.task),
          ),
        ),
        AnimatedSize(
          duration: _duration,
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: item.isVisible
              ? const Gap(AppSpacing.betweenRelated)
              : const SizedBox.shrink(),
        ),
      ],
    ],
  );
}

class _AnimatedTaskEntry extends StatelessWidget {
  const _AnimatedTaskEntry({
    required this.isVisible,
    required this.duration,
    required this.child,
    super.key,
  });

  final bool isVisible;
  final Duration duration;
  final Widget child;

  @override
  Widget build(BuildContext context) => AnimatedSize(
    duration: duration,
    curve: Curves.easeOutCubic,
    alignment: Alignment.topCenter,
    child: AnimatedOpacity(
      duration: duration,
      curve: Curves.easeOut,
      opacity: isVisible ? 1 : 0,
      child: AnimatedSlide(
        duration: duration,
        curve: Curves.easeOutCubic,
        offset: isVisible ? Offset.zero : const Offset(0.08, -0.08),
        child: isVisible ? child : SizedBox(height: 0, child: child),
      ),
    ),
  );
}

class _TaskListItem {
  _TaskListItem({required this.task, required this.isVisible});

  DailyTaskEntity task;
  bool isVisible;
}
