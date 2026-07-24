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
    const double iconSize = 20;
    const double tapTargetSize = 38.4;

    return Row(
      children: [
        if (showBackButton) ...[
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onBack ?? appNavigator.back,
            child: SizedBox(
              width: tapTargetSize,
              height: tapTargetSize,
              child: Center(
                child: AppIcon(
                  "left_back",
                  size: iconSize,
                  color: context.colorTokens.primary,
                ),
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
