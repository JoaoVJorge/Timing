import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:get/get.dart";
import "package:help_out/app/app_constants.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/presentation/login/login_controller.dart";
import "package:help_out/shared/widgets/app_icon.dart";
import "package:help_out/shared/widgets/bounce_tap.dart";

const Color _authBlue = Color(0xFF2F6FF2);
const Color _authBlueLight = Color(0xFF67A2FF);
const Color _authNavy = Color(0xFF082A5F);
const Color _authMuted = Color(0xFF67748E);
const Color _authCardShadow = Color(0x332F6FF2);
const LinearGradient _authBlueGradient = LinearGradient(
  colors: [_authBlueLight, _authBlue],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final LoginController controller = Get.find();

    return Scaffold(
      backgroundColor: const Color(0xFFF7FBFF),
      body: Stack(
        children: [
          const _LoginBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
              child: Column(
                children: [
                  const Gap(4),
                  const _Brand(),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const _HeroIllustration(),
                        const Gap(10),
                        Text(
                          context.l10n.loginHeadline,
                          textAlign: TextAlign.center,
                          style: context.textStyles.black32.copyWith(
                            color: _authNavy,
                            fontSize: 34,
                            height: 1.08,
                          ),
                        ),
                        const Gap(8),
                        const _PageIndicator(),
                        const Gap(10),
                        Text(
                          context.l10n.loginSubtitle,
                          textAlign: TextAlign.center,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: context.textStyles.bodyLarge.copyWith(
                            color: _authMuted,
                            fontSize: 15,
                            height: 1.32,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Gap(8),
                  _AuthCard(controller: controller),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginBackground extends StatelessWidget {
  const _LoginBackground();

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      Positioned(
        right: -58,
        top: 118,
        child: _SoftBlob(size: 170, color: _authBlue.withValues(alpha: 0.08)),
      ),
      Positioned(
        left: -84,
        top: 218,
        child: _SoftBlob(size: 190, color: _authBlue.withValues(alpha: 0.06)),
      ),
      Positioned(
        left: -64,
        bottom: 170,
        child: _SoftBlob(size: 160, color: _authBlue.withValues(alpha: 0.05)),
      ),
    ],
  );
}

class _SoftBlob extends StatelessWidget {
  const _SoftBlob({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}

class _Brand extends StatelessWidget {
  const _Brand();

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: _authBlueGradient,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
              color: _authCardShadow,
              blurRadius: 14,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: const AppIcon("open_book", size: 26, color: Colors.white),
      ),
      const Gap(10),
      Text(
        AppConstants.appTitle,
        style: context.textStyles.black28.copyWith(
          color: _authNavy,
          fontSize: 28,
          height: 1,
        ),
      ),
    ],
  );
}

class _HeroIllustration extends StatelessWidget {
  const _HeroIllustration();

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 238,
    width: double.infinity,
    child: Image.asset(
      "assets/images/login_page.png",
      fit: BoxFit.cover,
      alignment: Alignment.center,
    ),
  );
}

class _PageIndicator extends StatelessWidget {
  const _PageIndicator();

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 54,
        height: 6,
        decoration: BoxDecoration(
          gradient: _authBlueGradient,
          borderRadius: BorderRadius.circular(999),
        ),
      ),
      const Gap(8),
      Container(
        width: 10,
        height: 10,
        decoration: const BoxDecoration(
          color: _authBlue,
          shape: BoxShape.circle,
        ),
      ),
    ],
  );
}

class _AuthCard extends StatelessWidget {
  const _AuthCard({required this.controller});

  final LoginController controller;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(30),
      boxShadow: const [
        BoxShadow(
          color: _authCardShadow,
          blurRadius: 34,
          offset: Offset(0, 14),
        ),
      ],
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Obx(
          () => _SignInButton(
            leading: Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const AppIcon("google", size: 23),
            ),
            label: context.l10n.continueWithGoogleButton,
            onTap: controller.onTapGoogleSignIn,
            isLoading: controller.isGoogleSubmitting.value,
            isPrimary: true,
          ),
        ),
        const Gap(10),
        _SignInButton(
          leading: Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE8ECF3)),
            ),
            child: const Icon(Icons.apple, size: 28, color: Colors.black),
          ),
          label: context.l10n.continueWithAppleButton,
          onTap: controller.onTapAppleSignIn,
          isPrimary: false,
        ),
        const Gap(12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline_rounded, size: 16, color: _authMuted),
            const Gap(6),
            Flexible(
              child: Text(
                _securityNote(context),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textStyles.bodySmall.copyWith(
                  color: _authMuted,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

String _securityNote(BuildContext context) => switch (context.languageCode) {
  "pt" => "Seus dados estão protegidos e seguros.",
  "es" => "Tus datos están protegidos y seguros.",
  "fr" => "Vos données sont protégées et sécurisées.",
  _ => "Your data is protected and secure.",
};

class _SignInButton extends StatelessWidget {
  const _SignInButton({
    required this.leading,
    required this.label,
    required this.onTap,
    required this.isPrimary,
    this.isLoading = false,
  });

  final Widget leading;
  final String label;
  final VoidCallback onTap;
  final bool isPrimary;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final Color foreground = isPrimary ? Colors.white : _authNavy;

    return BounceTap(
      pressedScale: 0.98,
      onTap: isLoading ? () {} : onTap,
      child: Container(
        width: double.infinity,
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          gradient: isPrimary ? _authBlueGradient : null,
          color: isPrimary ? null : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: isPrimary ? null : Border.all(color: const Color(0xFFE8ECF3)),
          boxShadow: isPrimary
              ? const [
                  BoxShadow(
                    color: _authCardShadow,
                    blurRadius: 18,
                    offset: Offset(0, 8),
                  ),
                ]
              : const [
                  BoxShadow(
                    color: Color(0x0F082A5F),
                    blurRadius: 16,
                    offset: Offset(0, 8),
                  ),
                ],
        ),
        child: Row(
          children: [
            leading,
            const Gap(10),
            Expanded(
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textStyles.textPrimaryButton.copyWith(
                  color: foreground,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            if (isLoading)
              SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.3,
                  color: foreground,
                ),
              )
            else
              Icon(
                Icons.chevron_right_rounded,
                size: 26,
                color: isPrimary ? foreground : const Color(0xFF717B8D),
              ),
          ],
        ),
      ),
    );
  }
}
