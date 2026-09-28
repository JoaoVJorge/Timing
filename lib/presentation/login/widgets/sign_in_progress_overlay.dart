import "package:flutter/material.dart";
import "package:flutter_svg/flutter_svg.dart";
import "package:gap/gap.dart";
import "package:timing/app/app_constants.dart";
import "package:timing/core/utils/extensions/context_extensions.dart";
import "package:timing/presentation/login/login_palette.dart";
import "package:timing/presentation/login/sign_in_step.dart";

class SignInProgressOverlay extends StatelessWidget {
  const SignInProgressOverlay({super.key, required this.step});

  final SignInStep step;

  static const Duration _transitionDuration = Duration(milliseconds: 240);

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: LoginPalette.background,
    child: SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(AppConstants.appLogoFull, width: 64, height: 64),
              const Gap(32),
              const SizedBox(
                width: 36,
                height: 36,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: LoginPalette.blue,
                ),
              ),
              const Gap(24),
              Text(
                context.l10n.signInProgressTitle,
                textAlign: TextAlign.center,
                style: context.textStyles.black28.copyWith(
                  color: LoginPalette.navy,
                  fontSize: 24,
                  height: 1.1,
                ),
              ),
              const Gap(8),
              Semantics(
                liveRegion: true,
                child: AnimatedSwitcher(
                  duration: _transitionDuration,
                  child: Text(
                    _stepLabel(context),
                    key: ValueKey(step),
                    textAlign: TextAlign.center,
                    style: context.textStyles.bodyLarge.copyWith(
                      color: LoginPalette.muted,
                      fontSize: 15,
                      height: 1.32,
                    ),
                  ),
                ),
              ),
              const Gap(24),
              _StepTrack(step: step),
            ],
          ),
        ),
      ),
    ),
  );

  String _stepLabel(BuildContext context) => switch (step) {
    SignInStep.confirmingAccount =>
      context.l10n.signInProgressConfirmingAccount,
    SignInStep.loadingProfile => context.l10n.signInProgressLoadingProfile,
    SignInStep.preparingHome => context.l10n.signInProgressPreparingHome,
  };
}

class _StepTrack extends StatelessWidget {
  const _StepTrack({required this.step});

  final SignInStep step;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      for (final SignInStep each in SignInStep.values) ...[
        if (each != SignInStep.values.first) const Gap(8),
        AnimatedContainer(
          duration: SignInProgressOverlay._transitionDuration,
          width: 28,
          height: 6,
          decoration: BoxDecoration(
            color: each.index <= step.index
                ? LoginPalette.blue
                : LoginPalette.blue.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ],
    ],
  );
}
