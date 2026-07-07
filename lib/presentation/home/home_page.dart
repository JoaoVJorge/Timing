import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:get/get.dart";
import "package:help_out/core/domain/enums/time_category_type.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/presentation/home/home_controller.dart";
import "package:help_out/presentation/home/widgets/category_card.dart";
import "package:help_out/presentation/home/widgets/last_activity_card.dart";
import "package:help_out/shared/extensions/enum_localization_extensions.dart";

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find();

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          16,
          32 + context.mediaQuery.padding.top,
          16,
          24,
        ),
        children: [
          Obx(
            () => Text(
              controller.userName.value.isEmpty
                  ? context.l10n.homeGreetingDefault
                  : context.l10n.homeGreetingWithName(
                      controller.userName.value,
                    ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: context.textStyles.extraBold24.copyWith(
                color: context.colorTokens.primary,
              ),
            ),
          ),
          const Gap(4),
          Text(
            context.l10n.homeSubtitle,
            style: context.textStyles.bodyMedium.copyWith(
              color: context.colorTokens.textHint,
            ),
          ),
          const Gap(12),
          for (final TimeCategoryType category in TimeCategoryType.values) ...[
            CategoryCard(
              iconName: category.iconName,
              label: category.localizedLabel(context),
              onTapPlay: () => controller.onTapCategory(category),
            ),
            const Gap(12),
            if (category == TimeCategoryType.studying) ...[
              CategoryCard(
                iconName: "trophy",
                label: context.l10n.homeTasksSection,
                onTapPlay: controller.onTapDailyGoals,
              ),
              const Gap(12),
            ],
          ],
          const Gap(12),
          Obx(
            () => LastActivityCard(lastActivity: controller.lastActivity.value),
          ),
        ],
      ),
    );
  }
}
