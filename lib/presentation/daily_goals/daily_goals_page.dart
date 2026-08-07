import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:get/get.dart";
import "package:help_out/core/domain/entities/daily_task_entity.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/presentation/daily_goals/daily_goals_controller.dart";
import "package:help_out/presentation/daily_goals/widgets/add_task_tile.dart";
import "package:help_out/presentation/daily_goals/widgets/daily_task_tile.dart";
import "package:help_out/shared/widgets/app_scaffold.dart";
import "package:help_out/shared/widgets/app_section_header.dart";
import "package:help_out/shared/widgets/app_top_bar.dart";
import "package:help_out/shared/widgets/illustrated_empty_state.dart";
import "package:help_out/theme/app_spacing.dart";

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
                title: _emptyTitle(context),
                description: _emptyDescription(context),
                actionLabel: _addGoalLabel(context),
                onTapAction: controller.onTapAddTask,
                suggestionsTitle: _suggestionsTitle(context),
                suggestions: _suggestions(context),
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
              for (final DailyTaskEntity task in pending) ...[
                DailyTaskTile(
                  task: task,
                  onEdit: () => controller.onEditTask(task),
                  onToggle: () => controller.onToggleTask(task),
                  onDelete: () => controller.onDeleteTask(task),
                ),
                const Gap(AppSpacing.betweenRelated),
              ],
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
              for (final DailyTaskEntity task in completed) ...[
                DailyTaskTile(
                  task: task,
                  onEdit: () => controller.onEditTask(task),
                  onToggle: () => controller.onToggleTask(task),
                  onDelete: () => controller.onDeleteTask(task),
                ),
                const Gap(AppSpacing.betweenRelated),
              ],
            ],
            const Gap(AppSpacing.titleToDescription),
            AddTaskTile(onTap: controller.onTapAddTask),
          ],
        );
      }),
    );
  }
}

String _emptyTitle(BuildContext context) => switch (context.languageCode) {
  "pt" => "Nenhuma meta ainda",
  "es" => "Ninguna meta todavía",
  "fr" => "Aucun objectif pour l’instant",
  "de" => "Noch kein Ziel",
  "ar" => "لا توجد أهداف بعد",
  _ => "No goals yet",
};

String _emptyDescription(
  BuildContext context,
) => switch (context.languageCode) {
  "pt" =>
    "Adicione sua primeira meta para organizar o dia e acompanhar suas conquistas.",
  "es" => "Agrega tu primera meta para organizar el día y seguir tus logros.",
  "fr" =>
    "Ajoutez votre premier objectif pour organiser la journée et suivre vos réussites.",
  "de" =>
    "Füge dein erstes Ziel hinzu, um den Tag zu organisieren und Erfolge zu verfolgen.",
  "ar" => "أضف هدفك الأول لتنظيم يومك ومتابعة إنجازاتك.",
  _ => "Add your first goal to organize the day and track your wins.",
};

String _addGoalLabel(BuildContext context) => switch (context.languageCode) {
  "pt" => "Adicionar meta",
  "es" => "Agregar meta",
  "fr" => "Ajouter un objectif",
  "de" => "Ziel hinzufügen",
  "ar" => "إضافة هدف",
  _ => "Add goal",
};

String _suggestionsTitle(BuildContext context) =>
    switch (context.languageCode) {
      "pt" => "Sugestões para começar",
      "es" => "Sugerencias para empezar",
      "fr" => "Suggestions pour commencer",
      "de" => "Vorschläge für den Anfang",
      "ar" => "اقتراحات للبدء",
      _ => "Suggestions to start",
    };

List<String> _suggestions(BuildContext context) =>
    switch (context.languageCode) {
      "pt" => const ["Estudar 30 min", "Ler 10 páginas", "Treinar"],
      "es" => const ["Estudiar 30 min", "Leer 10 páginas", "Entrenar"],
      "fr" => const ["Étudier 30 min", "Lire 10 pages", "S’entraîner"],
      "de" => const ["30 min lernen", "10 Seiten lesen", "Trainieren"],
      "ar" => const ["دراسة 30 د", "قراءة 10 صفحات", "تدريب"],
      _ => const ["Study 30 min", "Read 10 pages", "Train"],
    };
