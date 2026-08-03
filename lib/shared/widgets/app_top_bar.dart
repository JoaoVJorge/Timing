import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:help_out/app/app_navigator.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/shared/widgets/app_icon.dart";
import "package:help_out/theme/app_spacing.dart";

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

    return Row(
      children: [
        if (showBackButton) ...[
          Semantics(
            button: true,
            label: MaterialLocalizations.of(context).backButtonTooltip,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onBack ?? appNavigator.back,
              child: const SizedBox(
                width: AppSpacing.minTapTarget,
                height: AppSpacing.minTapTarget,
                child: Center(child: _BackIcon(size: iconSize)),
              ),
            ),
          ),
        ],
        Expanded(
          child: Semantics(
            header: true,
            child: Text(
              title,
              // Titles like "Perguntas frequentes" get clipped on narrow
              // screens when forced onto a single line.
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: context.textStyles.pageTitle.copyWith(fontSize: 24),
            ),
          ),
        ),
        if (trailing != null) ...[
          const Gap(AppSpacing.titleToDescription),
          trailing!,
        ],
      ],
    );
  }
}

class _BackIcon extends StatelessWidget {
  const _BackIcon({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) =>
      AppIcon("left_back", size: size, color: context.colorTokens.primary);
}
