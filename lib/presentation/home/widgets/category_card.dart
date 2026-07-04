import "package:flutter/material.dart";
import "package:help_out/core/domain/enums/time_category_type.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/shared/extensions/enum_localization_extensions.dart";
import "package:help_out/shared/widgets/app_button.dart";
import "package:help_out/shared/widgets/app_icon.dart";

class CategoryCard extends StatelessWidget {
  const CategoryCard({required this.category, required this.onTapPlay, super.key});

  final TimeCategoryType category;
  final VoidCallback onTapPlay;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    decoration: BoxDecoration(color: context.colorTokens.surface, borderRadius: BorderRadius.circular(20)),
    child: Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(color: context.colorTokens.primaryVeryLight, shape: BoxShape.circle),
          child: Center(child: AppIcon(category.iconName, size: 24, color: context.colorTokens.primary)),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(category.localizedLabel(context), style: context.textStyles.extraBold20),
        ),
        AppButton(svgName: "play", onTap: onTapPlay, size: 44),
      ],
    ),
  );
}
