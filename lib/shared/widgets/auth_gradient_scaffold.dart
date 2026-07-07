import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:help_out/app/app_navigator.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/shared/widgets/app_icon.dart";

/// Shared full-screen gradient background used across the phone sign-in flow
/// (phone entry, SMS code, credentials). Renders a back button, a large title
/// and subtitle, the page [children], and an optional pinned [bottom] action.
class AuthGradientScaffold extends StatelessWidget {
  const AuthGradientScaffold({
    required this.title,
    required this.subtitle,
    required this.children,
    this.bottom,
    this.onBack,
    super.key,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;
  final Widget? bottom;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) => Scaffold(
    resizeToAvoidBottomInset: true,
    body: SizedBox.expand(
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    context.colorTokens.primary,
                    context.colorTokens.primaryPastel,
                    context.colorTokens.primaryVeryLight,
                  ],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.04),
                    Colors.black.withValues(alpha: 0.3),
                  ],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        onPressed: onBack ?? appNavigator.back,
                        icon: const AppIcon(
                          "left_back",
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const Gap(12),
                    // Scrolls when the keyboard shrinks the viewport, so the
                    // title, subtitle and fields never overflow.
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                height: 1.1,
                                shadows: [
                                  Shadow(
                                    color: Colors.black38,
                                    blurRadius: 10,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                            ),
                            const Gap(12),
                            Text(
                              subtitle,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.white70,
                                shadows: [
                                  Shadow(
                                    color: Colors.black26,
                                    blurRadius: 6,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                            const Gap(28),
                            ...children,
                          ],
                        ),
                      ),
                    ),
                    if (bottom != null) ...[const Gap(16), bottom!],
                    const Gap(12),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
