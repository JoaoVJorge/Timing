import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:get/get.dart";
import "package:help_out/app/app_constants.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/presentation/login/login_controller.dart";
import "package:help_out/shared/widgets/bounce_tap.dart";

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final LoginController controller = Get.find();

    return Scaffold(
      body: Stack(
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
                  colors: [Colors.black.withValues(alpha: 0.04), Colors.black.withValues(alpha: 0.3)],
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppConstants.appTitle,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                      shadows: [Shadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2))],
                    ),
                  ),
                  const Gap(8),
                  Text(
                    context.l10n.loginHeadline,
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1.1,
                      shadows: [Shadow(color: Colors.black38, blurRadius: 10, offset: Offset(0, 3))],
                    ),
                  ),
                  const Gap(12),
                  Text(
                    context.l10n.loginSubtitle,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white70,
                      shadows: [Shadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2))],
                    ),
                  ),
                  const Gap(32),
                  _SocialSignInButton(
                    icon: const _GoogleMark(),
                    label: context.l10n.continueWithGoogleButton,
                    onTap: controller.onTapGoogleSignIn,
                  ),
                  const Gap(12),
                  _SocialSignInButton(
                    icon: const Icon(Icons.apple, size: 22, color: Colors.black87),
                    label: context.l10n.continueWithAppleButton,
                    onTap: controller.onTapAppleSignIn,
                  ),
                  const Gap(24),
                  Row(
                    children: [
                      Expanded(child: Container(height: 1, color: Colors.white.withValues(alpha: 0.4))),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          context.l10n.orSeparator,
                          style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w700, fontSize: 12),
                        ),
                      ),
                      Expanded(child: Container(height: 1, color: Colors.white.withValues(alpha: 0.4))),
                    ],
                  ),
                  const Gap(24),
                  Text(
                    context.l10n.createAccountSectionTitle,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      shadows: [Shadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2))],
                    ),
                  ),
                  const Gap(12),
                  Container(
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
                    child: TextField(
                      controller: controller.nameController,
                      onChanged: controller.onNameChanged,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
                      decoration: InputDecoration(
                        hintText: context.l10n.loginNameHint,
                        hintStyle: const TextStyle(color: Colors.white60),
                        filled: true,
                        fillColor: Colors.black.withValues(alpha: 0.18),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.55), width: 1.4),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.55), width: 1.4),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: Colors.white, width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      ),
                    ),
                  ),
                  const Gap(20),
                  Obx(() {
                    final bool canSubmit = controller.canSubmit.value;
                    final Widget button = Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
                      child: ElevatedButton(
                        onPressed: canSubmit ? controller.onSubmit : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: context.colorTokens.primary,
                          disabledBackgroundColor: context.colorTokens.borderUnfocused,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Text(context.l10n.loginButton, style: context.textStyles.bodyLarge),
                      ),
                    );

                    if (!canSubmit) {
                      return button;
                    }
                    return BounceTap(pressedScale: 0.96, onTap: controller.onSubmit, child: button);
                  }),
                  const Gap(12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SocialSignInButton extends StatelessWidget {
  const _SocialSignInButton({required this.icon, required this.label, required this.onTap});

  final Widget icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => BounceTap(
    pressedScale: 0.97,
    onTap: onTap,
    child: Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon,
          const Gap(12),
          Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.black87)),
        ],
      ),
    ),
  );
}

class _GoogleMark extends StatelessWidget {
  const _GoogleMark();

  @override
  Widget build(BuildContext context) => const Text(
    "G",
    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF4285F4)),
  );
}
