import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:get/get.dart";
import "package:help_out/app/app_navigator.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/presentation/category/category_controller.dart";
import "package:help_out/presentation/category/widgets/subject_tile.dart";
import "package:help_out/shared/widgets/app_scaffold.dart";

class CategoryPage extends StatelessWidget {
  const CategoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final CategoryController controller = Get.find();

    return AppScaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Gap(16),
          Row(
            children: [
              IconButton(
                onPressed: appNavigator.back,
                icon: Icon(Icons.arrow_back, color: context.colorTokens.textBody),
              ),
              Text(controller.category.label, style: context.textStyles.titleFont),
            ],
          ),
          const Gap(16),
          Expanded(
            child: Obx(
              () => ListView.separated(
                itemCount: controller.subjects.length + 1,
                separatorBuilder: (context, index) => const Gap(12),
                itemBuilder: (context, index) {
                  if (index == controller.subjects.length) {
                    return _AddSubjectTile(onTap: controller.onTapAddSubject);
                  }

                  final subject = controller.subjects[index];
                  return SubjectTile(subject: subject, onTapPlay: () => controller.onTapSubject(subject));
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddSubjectTile extends StatelessWidget {
  const _AddSubjectTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(18),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        border: Border.all(color: context.colorTokens.borderUnfocused, width: 1.5),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add, color: context.colorTokens.primary),
          const Gap(8),
          Text("Add Subject", style: context.textStyles.textButtonMedium),
        ],
      ),
    ),
  );
}
