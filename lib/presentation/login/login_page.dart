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
                  colors: [context.colorTokens.primary, context.colorTokens.primaryPastel, context.colorTokens.primaryVeryLight],
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(flex: 2),
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
                  const Text(
                    "Let's Start",
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1.1,
                      shadows: [Shadow(color: Colors.black38, blurRadius: 10, offset: Offset(0, 3))],
                    ),
                  ),
                  const Gap(12),
                  const Text(
                    "What should we call you?",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white70,
                      shadows: [Shadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2))],
                    ),
                  ),
                  const Gap(24),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.28), blurRadius: 24, offset: const Offset(0, 12))],
                    ),
                    child: TextField(
                      controller: controller.nameController,
                      onChanged: controller.onNameChanged,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Your name",
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
                  const Spacer(flex: 3),
                  Obx(() {
                    final bool canSubmit = controller.canSubmit.value;
                    final Widget button = Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.35), blurRadius: 20, offset: const Offset(0, 10))],
                      ),
                      child: ElevatedButton(
                        onPressed: canSubmit ? controller.onSubmit : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: context.colorTokens.primary,
                          disabledBackgroundColor: Colors.white.withValues(alpha: 0.4),
                          elevation: 0,
                          side: BorderSide(color: context.colorTokens.primary.withValues(alpha: 0.15), width: 1),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text("Let's Start", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                      ),
                    );

                    if (!canSubmit) {
                      return button;
                    }
                    return BounceTap(pressedScale: 0.96, onTap: controller.onSubmit, child: button);
                  }),
                  const Gap(32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
