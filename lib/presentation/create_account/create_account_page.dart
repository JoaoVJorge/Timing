import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:get/get.dart";
import "package:help_out/app/app_navigator.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/presentation/create_account/create_account_controller.dart";
import "package:help_out/shared/widgets/app_icon.dart";
import "package:help_out/shared/widgets/bounce_tap.dart";

class CreateAccountPage extends StatelessWidget {
  const CreateAccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    final CreateAccountController controller = Get.find();

    return Scaffold(
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
                      Row(
                        children: [
                          IconButton(
                            onPressed: appNavigator.back,
                            icon: const AppIcon(
                              "left_back",
                              size: 20,
                              color: Colors.white,
                            ),
                          ),
                          const Gap(8),
                          Text(
                            context.l10n.createAccountSectionTitle,
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  color: Colors.black38,
                                  blurRadius: 10,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Gap(28),
                      _AccountTextField(
                        controller: controller.nameController,
                        onChanged: controller.onNameChanged,
                        hintText: context.l10n.loginNameHint,
                        icon: "address_book",
                      ),
                      const Gap(16),
                      _AccountTextField(
                        controller: controller.nicknameController,
                        hintText:
                            "${context.l10n.nicknameHint} (${context.l10n.optionalHint})",
                        icon: "special_a",
                      ),
                      const Gap(16),
                      _AccountTextField(
                        controller: controller.phoneController,
                        hintText:
                            "${context.l10n.phoneLabel} (${context.l10n.optionalHint})",
                        icon: null,
                        materialIcon: Icons.call_outlined,
                        keyboardType: TextInputType.phone,
                      ),
                      const Spacer(),
                      Obx(() {
                        final bool canSubmit = controller.canSubmit.value;
                        final Widget button = Container(
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ElevatedButton(
                            onPressed: canSubmit ? controller.onSubmit : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: context.colorTokens.primary,
                              disabledBackgroundColor:
                                  context.colorTokens.borderUnfocused,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: controller.isSubmitting.value
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: context.colorTokens.primary,
                                    ),
                                  )
                                : Text(
                                    context.l10n.createAccountButton,
                                    style: context.textStyles.bodyLarge,
                                  ),
                          ),
                        );

                        if (!canSubmit) {
                          return button;
                        }
                        return BounceTap(
                          pressedScale: 0.96,
                          onTap: controller.onSubmit,
                          child: button,
                        );
                      }),
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
}

class _AccountTextField extends StatelessWidget {
  const _AccountTextField({
    required this.controller,
    required this.hintText,
    this.icon,
    this.materialIcon,
    this.onChanged,
    this.keyboardType,
  }) : assert(
         icon != null || materialIcon != null,
         "Provide either icon or materialIcon",
       );

  final TextEditingController controller;
  final String hintText;
  final String? icon;
  final IconData? materialIcon;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
    child: TextField(
      controller: controller,
      onChanged: onChanged,
      keyboardType: keyboardType,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.white60),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.08),
        prefixIcon: Padding(
          padding: const EdgeInsets.all(14),
          child: icon != null
              ? AppIcon(icon!, size: 18, color: Colors.white70)
              : Icon(materialIcon, size: 20, color: Colors.white70),
        ),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 44,
          minHeight: 44,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Colors.white.withValues(alpha: 0.55),
            width: 1.4,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Colors.white.withValues(alpha: 0.55),
            width: 1.4,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.white, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    ),
  );
}
