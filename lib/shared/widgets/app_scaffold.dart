import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:timing/core/utils/extensions/context_extensions.dart";

import "package:timing/theme/app_spacing.dart";

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    required this.body,
    this.topBar,
    this.bottomBar,
    this.padding,
    this.backgroundColor,
    this.resizeToAvoidBottomInset,
    super.key,
  });

  final Widget body;
  final Widget? topBar;
  final Widget? bottomBar;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final bool? resizeToAvoidBottomInset;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: backgroundColor ?? context.colorTokens.scaffold,
    resizeToAvoidBottomInset: resizeToAvoidBottomInset,
    body: SafeArea(
      child: Column(
        children: [
          Expanded(
            child: topBar == null
                ? Padding(padding: _bodyPadding, child: body)
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Gap(8),
                      Padding(padding: _topBarPadding, child: topBar!),
                      const Gap(8),
                      Expanded(
                        child: Padding(padding: _bodyPadding, child: body),
                      ),
                    ],
                  ),
          ),
          if (bottomBar != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.page,
                12,
                AppSpacing.page,
                16,
              ),
              child: bottomBar!,
            ),
        ],
      ),
    ),
  );

  EdgeInsetsGeometry get _bodyPadding =>
      padding ?? const EdgeInsets.symmetric(horizontal: AppSpacing.page);

  static const EdgeInsetsGeometry _topBarPadding = EdgeInsets.symmetric(
    horizontal: AppSpacing.page,
  );
}
