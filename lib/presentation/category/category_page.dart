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
                return _AddSubjectCard(
                  category: controller.category,
                  onTap: controller.onTapAddSubject,
                );
              }

              final SubjectEntity subject = subjects[index];
              return HobbySubjectCard(
                subject: subject,
                onTapPlay: () => controller.onTapSubject(subject),
              );
            },
          );
        }

        return ListView.separated(
          itemCount: subjects.length + 1,
          separatorBuilder: (context, index) => const Gap(12),
          itemBuilder: (context, index) {
            if (index == subjects.length) {
              return _AddSubjectTile(
                category: controller.category,
                onTap: controller.onTapAddSubject,
              );
            }

            final SubjectEntity subject = subjects[index];
            return NotebookSwipeTile(
              onTapNotes: () => controller.onTapNotes(subject),
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

class _AddSubjectTile extends StatelessWidget {
  const _AddSubjectTile({required this.category, required this.onTap});

  final TimeCategoryType category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        border: Border.all(
          color: context.colorTokens.borderUnfocused,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppIcon("plus", size: 16, color: context.colorTokens.primary),
          const Gap(8),
          Flexible(
            child: Text(
              context.l10n.addItemButton(category.itemNoun(context)),
              overflow: TextOverflow.ellipsis,
              style: context.textStyles.textButtonMedium,
            ),
          ),
        ],
      ),
    ),
  );
}

class _AddSubjectCard extends StatelessWidget {
  const _AddSubjectCard({required this.category, required this.onTap});

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
