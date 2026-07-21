import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:help_out/app/app_navigator.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/shared/widgets/app_icon.dart";

class AppTopBar extends StatelessWidget {
  const AppTopBar({
    required this.title,
    this.showBackButton = false,
    this.onBack,
    this.trailing,
    super.key,
  });

  final String title;
  final bool showBackButton;
  final VoidCallback? onBack;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    const double size = 20;

    return Row(
      children: [
        if (showBackButton) ...[
          GestureDetector(
            onTap: onBack ?? appNavigator.back,
            child: Container(
              width: size,
              height: size,
              alignment: Alignment.center,
              color: Colors.transparent,
              child: AppIcon(
                "left_back",
                size: size,
                color: context.colorTokens.primary,
              ),
            ),
          ),
          const Gap(8),
        ],
        Expanded(
          child: Text(
            title,
            style: context.textStyles.titleFont,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (trailing != null) ...[const Gap(8), trailing!],
      ],
    );
  }
}
