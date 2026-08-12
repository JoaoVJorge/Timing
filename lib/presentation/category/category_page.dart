import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:get/get.dart";
import "package:help_out/core/domain/entities/subject_entity.dart";
import "package:help_out/core/domain/enums/time_category_type.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/presentation/category/category_controller.dart";
import "package:help_out/presentation/category/widgets/hobby_subject_card.dart";
import "package:help_out/presentation/category/widgets/notebook_swipe_tile.dart";
import "package:help_out/presentation/category/widgets/reading_subject_tile.dart";
import "package:help_out/presentation/category/widgets/subject_tile.dart";
import "package:help_out/shared/extensions/enum_localization_extensions.dart";
import "package:help_out/shared/widgets/app_icon.dart";
import "package:help_out/shared/widgets/app_scaffold.dart";
import "package:help_out/shared/widgets/app_top_bar.dart";
import "package:help_out/shared/widgets/illustrated_empty_state.dart";
import "package:help_out/theme/app_spacing.dart";

class CategoryPage extends StatelessWidget {
  const CategoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final CategoryController controller = Get.find();

    return AppScaffold(
      topBar: AppTopBar(
        title: controller.category.localizedLabel(context),
        showBackButton: true,
      ),
      body: Obx(() {
        final List<SubjectEntity> subjects = controller.subjects;

        if (subjects.isEmpty) {
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(
                top: AppSpacing.betweenRelated,
                bottom: AppSpacing.betweenSections,
              ),
              child: IllustratedEmptyState(
                title: _emptyTitle(context, controller.category),
                description: _emptyDescription(context, controller.category),
                actionLabel: context.l10n.addItemButton(
                  controller.category.itemNoun(context),
                ),
                onTapAction: controller.onTapAddSubject,
                suggestionsTitle: _suggestionsTitle(context),
                suggestions: _suggestionsFor(context, controller.category),
              ),
            ),
          );
        }

        if (controller.category == TimeCategoryType.hobbies) {
          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 3 / 4,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
            ),
            itemCount: subjects.length + 1,
            itemBuilder: (context, index) {
              if (index == subjects.length) {
                return _AddHobbyCard(
                  category: controller.category,
                  onTap: controller.onTapAddSubject,
                );
              }

              final SubjectEntity subject = subjects[index];
              return HobbySubjectCard(
                subject: subject,
                onTapPlay: () => controller.onTapSubject(subject),
                onTapStats: () => controller.onTapSubjectStats(subject),
                onTapEdit: () => controller.onTapEditSubject(subject),
                onTapPin: () => controller.onPinSubjectToStart(subject),
                onDelete: () => controller.onDeleteSubject(subject),
                isPinned: index == 0,
              );
            },
          );
        }

        return ListView.separated(
          itemCount: subjects.length + 1,
          separatorBuilder: (context, index) => const Gap(12),
          itemBuilder: (context, index) {
            if (index == subjects.length) {
              return _AddListSubjectCard(
                category: controller.category,
                onTap: controller.onTapAddSubject,
              );
            }

            final SubjectEntity subject = subjects[index];
            final Color subjectColor = Color(subject.colorValue);
            return NotebookSwipeTile(
              accent: subjectColor,
              onTapNotes: () => controller.onTapNotes(subject),
              onTapStats: () => controller.onTapSubjectStats(subject),
              onTapEdit: () => controller.onTapEditSubject(subject),
              onDelete: () => controller.onDeleteSubject(subject),
              child: switch (controller.category) {
                TimeCategoryType.reading => ReadingSubjectTile(
                  subject: subject,
                  onTapPlay: () => controller.onTapSubject(subject),
                ),
                _ => SubjectTile(
                  subject: subject,
                  onTapPlay: () => controller.onTapSubject(subject),
                ),
              },
            );
          },
        );
      }),
    );
  }
}

String _emptyTitle(BuildContext context, TimeCategoryType category) =>
    switch (category) {
      TimeCategoryType.studying => context.l10n.categoryEmptyStudyingTitle,
      TimeCategoryType.exercises => context.l10n.categoryEmptyExercisesTitle,
      TimeCategoryType.reading => context.l10n.categoryEmptyReadingTitle,
      TimeCategoryType.hobbies => context.l10n.categoryEmptyHobbiesTitle,
    };

String _emptyDescription(
  BuildContext context,
  TimeCategoryType category,
) => switch (category) {
  TimeCategoryType.studying => context.l10n.categoryEmptyStudyingDescription,
  TimeCategoryType.exercises => context.l10n.categoryEmptyExercisesDescription,
  TimeCategoryType.reading => context.l10n.categoryEmptyReadingDescription,
  TimeCategoryType.hobbies => context.l10n.categoryEmptyHobbiesDescription,
};

String _suggestionsTitle(BuildContext context) =>
    context.l10n.dailyGoalsSuggestionsTitle;

List<String> _suggestionsFor(BuildContext context, TimeCategoryType category) =>
    switch (category) {
      TimeCategoryType.studying => [
        context.l10n.categorySuggestionStudyingOne,
        context.l10n.categorySuggestionStudyingTwo,
        context.l10n.categorySuggestionStudyingThree,
      ],
      TimeCategoryType.exercises => [
        context.l10n.categorySuggestionExercisesOne,
        context.l10n.categorySuggestionExercisesTwo,
        context.l10n.categorySuggestionExercisesThree,
      ],
      TimeCategoryType.reading => [
        context.l10n.categorySuggestionReadingOne,
        context.l10n.categorySuggestionReadingTwo,
        context.l10n.categorySuggestionReadingThree,
      ],
      TimeCategoryType.hobbies => [
        context.l10n.categorySuggestionHobbiesOne,
        context.l10n.categorySuggestionHobbiesTwo,
        context.l10n.categorySuggestionHobbiesThree,
      ],
    };

class _AddHobbyCard extends StatelessWidget {
  const _AddHobbyCard({required this.category, required this.onTap});

  final TimeCategoryType category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: context.colorTokens.borderUnfocused,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppIcon("plus", size: 18, color: context.colorTokens.primary),
            const Gap(8),
            Text(
              context.l10n.addItemButton(category.itemNoun(context)),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: context.textStyles.textButtonMedium,
            ),
          ],
        ),
      ),
    ),
  );
}

class _AddListSubjectCard extends StatelessWidget {
  const _AddListSubjectCard({required this.category, required this.onTap});

  final TimeCategoryType category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(
          color: context.colorTokens.borderUnfocused,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppIcon("plus", size: 18, color: context.colorTokens.primary),
            const Gap(8),
            Text(
              context.l10n.addItemButton(category.itemNoun(context)),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: context.textStyles.textButtonMedium,
            ),
          ],
        ),
      ),
    ),
  );
}
