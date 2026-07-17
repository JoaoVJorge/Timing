import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:gap/gap.dart";
import "package:get/get.dart";
import "package:help_out/app/app_constants.dart";
import "package:help_out/shared/widgets/app_icon.dart";
import "package:help_out/shared/widgets/bounce_tap.dart";
import "package:help_out/theme/auth_onboarding_theme.dart";

export "package:help_out/theme/auth_onboarding_theme.dart";

class AuthOnboardingScaffold extends StatelessWidget {
  const AuthOnboardingScaffold({
    required this.title,
    required this.subtitle,
    required this.children,
    this.showBackButton = false,
    this.topVisual,
    this.bottom,
    super.key,
  });

  final String title;
  final String subtitle;
  final bool showBackButton;
  final Widget? topVisual;
  final List<Widget> children;
  final Widget? bottom;

  @override
  Widget build(BuildContext context) {
    final EdgeInsets safePadding = MediaQuery.paddingOf(context);

    return Scaffold(
      backgroundColor: AuthOnboardingColors.background,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AuthOnboardingColors.background,
                AuthOnboardingColors.backgroundWarm,
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    left: 22,
                    right: 22,
                    top: safePadding.top > 0 ? 6 : 12,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const AuthBrand(),
                      if (showBackButton)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: AuthBackButton(onTap: Get.back<void>),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(22, 20, 22, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (topVisual != null) ...[topVisual!, const Gap(14)],
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: AuthOnboardingTextStyles.title,
                        ),
                        const Gap(8),
                        Text(
                          subtitle,
                          textAlign: TextAlign.center,
                          style: AuthOnboardingTextStyles.subtitle,
                        ),
                        const Gap(18),
                        ...children,
                      ],
                    ),
                  ),
                ),
                if (bottom != null)
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      22,
                      8,
                      22,
                      12 + safePadding.bottom,
                    ),
                    child: bottom!,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AuthBrand extends StatelessWidget {
  const AuthBrand({super.key});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: AuthOnboardingColors.yellowGradient,
          borderRadius: BorderRadius.circular(9),
        ),
        child: const AppIcon("open_book", size: 20, color: Colors.white),
      ),
      const Gap(8),
      Text(AppConstants.appTitle, style: AuthOnboardingTextStyles.brand),
    ],
  );
}

class AuthBackButton extends StatelessWidget {
  const AuthBackButton({required this.onTap, super.key});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => BounceTap(
    onTap: onTap,
    child: const SizedBox(
      width: 38,
      height: 38,
      child: Icon(
        Icons.arrow_back_rounded,
        color: AuthOnboardingColors.navy,
        size: 30,
      ),
    ),
  );
}

class AuthPrimaryButton extends StatelessWidget {
  const AuthPrimaryButton({
    required this.label,
    required this.onTap,
    this.enabled = true,
    this.isLoading = false,
    super.key,
  });

  final String label;
  final VoidCallback onTap;
  final bool enabled;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final bool isActive = enabled && !isLoading;

    final Widget button = AnimatedOpacity(
      duration: const Duration(milliseconds: 160),
      opacity: isActive ? 1 : 0.56,
      child: Container(
        width: double.infinity,
        height: 56,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: AuthOnboardingColors.yellowGradient,
          borderRadius: BorderRadius.circular(16),
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: AuthOnboardingColors.navy,
                  strokeWidth: 2.4,
                ),
              )
            : Text(label, style: AuthOnboardingTextStyles.button),
      ),
    );

    if (!isActive) {
      return button;
    }

    return BounceTap(pressedScale: 0.97, onTap: onTap, child: button);
  }
}

class AuthTextLink extends StatelessWidget {
  const AuthTextLink({
    required this.label,
    required this.onTap,
    this.color = AuthOnboardingColors.navy,
    super.key,
  });

  final String label;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) => BounceTap(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: AuthOnboardingTextStyles.link.copyWith(color: color),
      ),
    ),
  );
}

class AuthHeroPlaceholder extends StatelessWidget {
  const AuthHeroPlaceholder({
    required this.icon,
    this.large = false,
    super.key,
  });

  final IconData icon;
  final bool large;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    height: large ? 170 : 145,
    child: Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
          left: -40,
          right: -40,
          bottom: 14,
          child: Container(
            height: large ? 72 : 62,
            decoration: BoxDecoration(
              color: AuthOnboardingColors.yellowLight.withValues(alpha: 0.54),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ),
        Positioned(
          left: 24,
          bottom: 30,
          child: _FloatingIcon(
            icon: Icons.edit_note_rounded,
            size: large ? 52 : 46,
          ),
        ),
        Positioned(
          right: 24,
          bottom: 28,
          child: _FloatingIcon(
            icon: Icons.calendar_month_rounded,
            size: large ? 50 : 44,
          ),
        ),
        Positioned(
          top: 12,
          left: 46,
          child: _DecorativeDot(size: 12, color: AuthOnboardingColors.yellow),
        ),
        Positioned(
          top: 24,
          right: 76,
          child: _DecorativeDot(size: 9, color: AuthOnboardingColors.navy),
        ),
        Positioned(
          top: 34,
          left: 104,
          child: Text("+", style: AuthOnboardingTextStyles.sparkle),
        ),
        Positioned(
          top: 36,
          right: 38,
          child: Text("+", style: AuthOnboardingTextStyles.sparkle),
        ),
        Container(
          width: large ? 96 : 86,
          height: large ? 96 : 86,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.86),
          ),
          child: Icon(
            icon,
            size: large ? 50 : 44,
            color: AuthOnboardingColors.yellow,
          ),
        ),
      ],
    ),
  );
}

class AuthFieldCard extends StatelessWidget {
  const AuthFieldCard({
    required this.icon,
    required this.label,
    this.controller,
    this.valueText,
    this.hintText,
    this.onChanged,
    this.keyboardType,
    this.inputFormatters,
    this.readOnly = false,
    this.onTap,
    super.key,
  });

  final IconData icon;
  final String label;
  final TextEditingController? controller;
  final String? valueText;
  final String? hintText;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool readOnly;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Widget child = Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 68),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: AuthOnboardingDecorations.card,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AuthOnboardingColors.yellowLight.withValues(alpha: 0.48),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AuthOnboardingColors.yellow.withValues(alpha: 0.16),
              ),
            ),
            child: Icon(icon, color: AuthOnboardingColors.yellowDark, size: 22),
          ),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label, style: AuthOnboardingTextStyles.fieldLabel),
                const Gap(2),
                if (readOnly)
                  Text(
                    valueText ?? hintText ?? "",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: valueText == null
                        ? AuthOnboardingTextStyles.fieldHint
                        : AuthOnboardingTextStyles.fieldValue,
                  )
                else
                  TextField(
                    controller: controller,
                    onChanged: onChanged,
                    keyboardType: keyboardType,
                    inputFormatters: inputFormatters,
                    style: AuthOnboardingTextStyles.fieldValue,
                    decoration: InputDecoration(
                      hintText: hintText,
                      hintStyle: AuthOnboardingTextStyles.fieldHint,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );

    if (onTap == null) {
      return child;
    }

    return BounceTap(onTap: onTap!, child: child);
  }
}

class _FloatingIcon extends StatelessWidget {
  const _FloatingIcon({required this.icon, required this.size});

  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.82),
      borderRadius: BorderRadius.circular(15),
    ),
    child: Icon(
      icon,
      color: AuthOnboardingColors.yellowDark,
      size: size * 0.48,
    ),
  );
}

class _DecorativeDot extends StatelessWidget {
  const _DecorativeDot({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(shape: BoxShape.circle, color: color),
  );
}
