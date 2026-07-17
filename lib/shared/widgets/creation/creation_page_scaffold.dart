import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:help_out/app/app_navigator.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/shared/widgets/app_icon.dart";
import "package:help_out/shared/widgets/bounce_tap.dart";

/// Shared chrome for the "create ..." flows (subject, task, ...).
///
/// Provides the tinted page background, tap-to-dismiss keyboard, a scrollable
/// content column and a submit button pinned to the bottom that does NOT move
/// with the keyboard.
class CreationPageScaffold extends StatelessWidget {
  const CreationPageScaffold({
    required this.children,
    required this.submitButton,
    super.key,
  });

  final List<Widget> children;
  final Widget submitButton;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
    behavior: HitTestBehavior.opaque,
    child: Scaffold(
      backgroundColor: context.creationPageBackground,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 14),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  clipBehavior: Clip.none,
                  // Keep the submit button pinned (the Scaffold does not resize
                  // for the keyboard), but let the scrollable content clear the
                  // keyboard so lower fields stay reachable.
                  padding: EdgeInsets.only(
                    bottom: 14 + MediaQuery.viewInsetsOf(context).bottom,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: children,
                  ),
                ),
              ),
              submitButton,
            ],
          ),
        ),
      ),
    ),
  );
}

/// Hero block shared by the creation flows: a back button, a headline + short
/// description on the left, and a tinted illustration bubble on the right.
///
/// Text and image live in a [Row] so the copy never overlaps the illustration.
class CreationHeroHeader extends StatelessWidget {
  const CreationHeroHeader({
    required this.accent,
    required this.imageAsset,
    required this.title,
    required this.subtitle,
    super.key,
  });

  final Color accent;
  final String imageAsset;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      CreationBackButton(accent: accent),
      const Gap(16),
      Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.textStyles.black32.copyWith(
                    color: accent,
                    fontSize: 32,
                    height: 1.05,
                  ),
                ),
                const Gap(10),
                Text(
                  subtitle,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: context.textStyles.bodyMedium.copyWith(
                    color: context.colorTokens.textBody.withValues(alpha: 0.78),
                    fontSize: 14,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const Gap(12),
          _CreationHeroBubble(
            accent: accent,
            child: Image.asset(
              imageAsset,
              width: 128,
              height: 128,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    ],
  );
}

class CreationBackButton extends StatelessWidget {
  const CreationBackButton({required this.accent, super.key});

  final Color accent;

  @override
  Widget build(BuildContext context) => BounceTap(
    onTap: appNavigator.back,
    child: Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: context.colorTokens.surface,
        shape: BoxShape.circle,
      ),
      child: Center(child: AppIcon("left_back", size: 20, color: accent)),
    ),
  );
}

class _CreationHeroBubble extends StatelessWidget {
  const _CreationHeroBubble({required this.accent, required this.child});

  final Color accent;
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    width: 148,
    height: 148,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: accent.withValues(alpha: context.isDarkMode ? 0.18 : 0.2),
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(52),
        topRight: Radius.circular(64),
        bottomLeft: Radius.circular(58),
        bottomRight: Radius.circular(40),
      ),
    ),
    child: child,
  );
}
