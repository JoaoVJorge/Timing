import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:get/get.dart";
import "package:timing/core/domain/entities/subject_entity.dart";
import "package:timing/core/domain/enums/time_category_type.dart";
import "package:timing/core/utils/extensions/context_extensions.dart";
import "package:timing/presentation/category/category_controller.dart";
import "package:timing/presentation/category/widgets/hobby_subject_card.dart";
import "package:timing/presentation/category/widgets/notebook_swipe_tile.dart";
import "package:timing/presentation/category/widgets/reading_subject_tile.dart";
import "package:timing/presentation/category/widgets/subject_creation_hint_bubble.dart";
import "package:timing/presentation/category/widgets/subject_tile.dart";
import "package:timing/shared/extensions/enum_localization_extensions.dart";
import "package:timing/shared/widgets/app_icon.dart";
import "package:timing/shared/widgets/app_scaffold.dart";
import "package:timing/shared/widgets/app_skeleton.dart";
import "package:timing/shared/widgets/app_top_bar.dart";
import "package:timing/shared/widgets/bounce_tap.dart";
import "package:timing/shared/widgets/illustrated_empty_state.dart";
import "package:timing/theme/app_spacing.dart";

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
      body: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: (_) => controller.dismissCreationHint(),
        child: Obx(() {
          final List<SubjectEntity> subjects = controller.subjects;
          // Read here (not inside itemBuilder) so Obx actually tracks this
          // value — itemBuilder runs outside Obx's synchronous build, so a
          // .value read there is invisible to its dependency tracking.
          final String? justCreatedSubjectId =
              controller.justCreatedSubjectId.value;

          if (controller.isLoading.value && subjects.isEmpty) {
            return const _CategoryLoadingSkeleton();
          }

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
                  onTapSuggestion: controller.onTapSuggestion,
                ),
              ),
            );
          }

          if (controller.category == TimeCategoryType.hobbies) {
            return GridView.builder(
              padding: const EdgeInsets.only(
                bottom: AppSpacing.betweenSections,
              ),
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
                  onTapNotes: () => controller.onTapNotes(subject),
                  onTapStats: () => controller.onTapSubjectStats(subject),
                  onTapEdit: () => controller.onTapEditSubject(subject),
                  onDelete: () => controller.onDeleteSubject(subject),
                );
              },
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.only(bottom: AppSpacing.betweenSections),
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
              final bool isJustCreated = subject.id == justCreatedSubjectId;

              final Widget tile = NotebookSwipeTile(
                accent: subjectColor,
                isEditLocked: subject.isFromGroup,
                isDeleteLocked: subject.isFromGroup,
                onTapNotes: () => controller.onTapNotes(subject),
                onTapStats: () => controller.onTapSubjectStats(subject),
                onTapEdit: () => controller.onTapEditSubject(subject),
                onDelete: () => controller.onDeleteSubject(subject),
                onDragStart: isJustCreated
                    ? controller.dismissCreationHint
                    : null,
                child: switch (controller.category) {
                  TimeCategoryType.reading => ReadingSubjectTile(
                    subject: subject,
                    currentSeconds: controller.progressSecondsFor(subject),
                    currentPages: controller.progressPagesFor(subject),
                    onTapPlay: () => controller.onTapSubject(subject),
                  ),
                  _ => SubjectTile(
                    subject: subject,
                    currentSeconds: controller.progressSecondsFor(subject),
                    onTapPlay: () => controller.onTapSubject(subject),
                  ),
                },
              );

              return SubjectCreationHintBubble(
                visible: isJustCreated,
                message: context.l10n.activitySwipeHintMessage,
                onAutoDismiss: controller.dismissCreationHint,
                child: tile,
              );
            },
          );
        }),
      ),
    );
  }
}

class _CategoryLoadingSkeleton extends StatelessWidget {
  const _CategoryLoadingSkeleton();

  @override
  Widget build(BuildContext context) => AppSkeleton(
    child: ListView.separated(
      padding: const EdgeInsets.only(bottom: AppSpacing.betweenSections),
      itemCount: 4,
      separatorBuilder: (context, index) => const Gap(12),
      itemBuilder: (context, index) => const _SkeletonSubjectTile(),
    ),
  );
}

class _SkeletonSubjectTile extends StatelessWidget {
  const _SkeletonSubjectTile();

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: context.colorTokens.surface,
      borderRadius: BorderRadius.circular(20),
    ),
    child: const Row(
      children: [
        AppSkeletonCircle(size: 44),
        Gap(12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppSkeletonBox(height: 16, radius: 7),
              Gap(8),
              AppSkeletonBox(width: 148, height: 13, radius: 6),
            ],
          ),
        ),
        Gap(12),
        AppSkeletonCircle(size: 38),
      ],
    ),
  );
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
  Widget build(BuildContext context) => BounceTap(
    pressedScale: 0.97,
    behavior: HitTestBehavior.opaque,
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
  Widget build(BuildContext context) => BounceTap(
    pressedScale: 0.97,
    behavior: HitTestBehavior.opaque,
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(16),
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
