import "package:flutter/material.dart";
import "package:help_out/core/domain/enums/time_category_type.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/shared/widgets/app_button.dart";

class CategoryCard extends StatelessWidget {
  const CategoryCard({required this.category, required this.onTapPlay, super.key});

  final TimeCategoryType category;
  final VoidCallback onTapPlay;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    decoration: BoxDecoration(
      color: context.colorTokens.primaryVeryLight,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      children: [
        Icon(category.icon, color: context.colorTokens.primary, size: 28),
        const SizedBox(width: 16),
        Expanded(
          child: Text(category.label, style: context.textStyles.extraBold20),
        ),
        AppButton(icon: Icons.play_arrow_rounded, onTap: onTapPlay, size: 48),
      ],
    ),
  );
}
