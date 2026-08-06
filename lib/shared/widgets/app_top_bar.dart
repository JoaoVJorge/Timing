import "package:flutter/material.dart";
import "package:help_out/app/app_navigator.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/shared/widgets/app_icon.dart";
import "package:help_out/theme/app_spacing.dart";

class AppTopBar extends StatelessWidget {
  const AppTopBar({
    required this.title,
    this.showBackButton = false,
    this.onBack,
    this.onTitleTap,
    this.trailing,
    this.titleMaxLines = 2,
    super.key,
  });

  final String title;
  final bool showBackButton;
  final VoidCallback? onBack;
  final VoidCallback? onTitleTap;
  final Widget? trailing;
  final int titleMaxLines;

  @override
  Widget build(BuildContext context) {
    const double iconSize = 20;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double titleMaxWidth =
            (constraints.maxWidth - ((AppSpacing.minTapTarget + 8) * 2))
                .clamp(0, constraints.maxWidth)
                .toDouble();

        return ConstrainedBox(
          constraints: const BoxConstraints(minHeight: AppSpacing.minTapTarget),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Align(
                alignment: Alignment.center,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: titleMaxWidth),
                  child: Semantics(
                    header: true,
                    button: onTitleTap != null,
                    child: GestureDetector(
                      behavior: onTitleTap == null
                          ? HitTestBehavior.deferToChild
                          : HitTestBehavior.opaque,
                      onTap: onTitleTap,
                      child: Text(
                        title,
                        // Titles like "Perguntas frequentes" get clipped on narrow
                        // screens when forced onto a single line.
                        maxLines: titleMaxLines,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: context.textStyles.pageTitle.copyWith(
                          fontSize: 24,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              if (showBackButton) ...[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Semantics(
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
                ),
              ],
              if (trailing != null)
                Align(alignment: Alignment.centerRight, child: trailing!),
            ],
          ),
        );
      },
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
