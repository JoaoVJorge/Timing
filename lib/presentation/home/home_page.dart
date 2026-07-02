import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:get/get.dart";
import "package:help_out/core/domain/enums/time_category_type.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/presentation/home/home_controller.dart";
import "package:help_out/presentation/home/widgets/category_card.dart";
import "package:help_out/shared/widgets/app_scaffold.dart";

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find();

    return AppScaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Gap(16),
          Obx(
            () => Text(
              controller.userName.value.isEmpty ? "Let's Start" : "Let's Start, ${controller.userName.value}",
              style: context.textStyles.titleFont,
            ),
          ),
          const Gap(24),
          Expanded(
            child: ListView.separated(
              itemCount: TimeCategoryType.values.length,
              separatorBuilder: (context, index) => const Gap(16),
              itemBuilder: (context, index) {
                final TimeCategoryType category = TimeCategoryType.values[index];
                return CategoryCard(category: category, onTapPlay: () => controller.onTapCategory(category));
              },
            ),
          ),
        ],
      ),
    );
  }
}
