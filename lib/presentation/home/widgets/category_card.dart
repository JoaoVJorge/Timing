import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:help_out/core/domain/enums/time_category_type.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/shared/extensions/enum_localization_extensions.dart";
import "package:help_out/shared/widgets/app_icon.dart";

class CategoryCard extends StatelessWidget {
  const CategoryCard({
    required this.category,
    required this.onTapPlay,
    super.key,
  });

  final TimeCategoryType category;
  final VoidCallback onTapPlay;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTapPlay,
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colorTokens.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: context.colorTokens.primaryVeryLight,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: AppIcon(
                category.iconName,
                size: 24,
                color: context.colorTokens.primary,
              ),
            ),
          ),
          Gap(16),
          Expanded(
            child: Text(
              category.localizedLabel(context),
              style: context.textStyles.extraBold20,
            ),
          ),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: context.colorTokens.primaryGradient,
              boxShadow: [
                BoxShadow(
                  color: context.colorTokens.primary.withValues(alpha: 0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: AppIcon("play", size: 20, color: Colors.white),
            ),
          ),
        ],
      ),
    ),
  );
}
