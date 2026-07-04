import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:get/get.dart";
import "package:help_out/core/domain/enums/time_category_type.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/presentation/home/home_controller.dart";
import "package:help_out/presentation/home/widgets/category_card.dart";

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find();

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(
            () => Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: context.colorTokens.primaryGradient,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(28),
                ),
              ),
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: MediaQuery.of(context).padding.top + 8,
                bottom: 20,
              ),
              child: Text(
                controller.userName.value.isEmpty
                    ? context.l10n.homeGreetingDefault
                    : context.l10n.homeGreetingWithName(
                        controller.userName.value,
                      ),
                style: context.textStyles.titleFont.copyWith(
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
              itemCount: TimeCategoryType.values.length,
              separatorBuilder: (context, index) => const Gap(12),
              itemBuilder: (context, index) {
                final TimeCategoryType category =
                    TimeCategoryType.values[index];
                return CategoryCard(
                  category: category,
                  onTapPlay: () => controller.onTapCategory(category),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
