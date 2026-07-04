import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:help_out/app/app_navigator.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/shared/widgets/app_icon.dart";

class AppTopBar extends StatelessWidget {
  const AppTopBar({
    required this.title,
    this.showBackButton = false,
    super.key,
  });

  final String title;
  final bool showBackButton;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      if (showBackButton) ...[
        GestureDetector(
          onTap: appNavigator.back,
          child: AppIcon(
            "left_back",
            size: 20,
            color: context.colorTokens.primary,
          ),
        ),
        const Gap(12),
      ],
      Text(title, style: context.textStyles.titleFont),
    ],
  );
}
