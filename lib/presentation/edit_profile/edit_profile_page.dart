import "dart:typed_data";

import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:get/get.dart";
import "package:timing/core/utils/extensions/context_extensions.dart";
import "package:timing/presentation/edit_profile/edit_profile_controller.dart";
import "package:timing/shared/widgets/app_icon.dart";
import "package:timing/shared/widgets/app_scaffold.dart";
import "package:timing/shared/widgets/app_top_bar.dart";
import "package:timing/shared/widgets/bounce_tap.dart";
import "package:timing/shared/widgets/centered_wrap_grid.dart";
import "package:timing/theme/accent_presets.dart";
import "package:timing/theme/avatar_presets.dart";
import "package:timing/theme/decoration.dart";

class EditProfilePage extends StatelessWidget {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final EditProfileController controller = Get.find();

    return AppScaffold(
      topBar: AppTopBar(
        title: context.l10n.myProfileTitle,
        showBackButton: true,
      ),
      bottomBar: _SaveChangesButton(controller: controller),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Gap(4),
            Center(child: _ProfilePhotoPreview(controller: controller)),
            const Gap(22),
            _ProfileSection(
              title: context.l10n.avatarLabel,
              children: [
                Obx(
                  () => CenteredWrapGrid(
                    itemsPerRow: 4,
                    spacing: 18,
                    runSpacing: 18,
                    children: List.generate(AppAvatarPresets.values.length, (
                      index,
                    ) {
                      final bool isSelected =
                          index == controller.avatarIconIndex.value;
                      return BounceTap(
                        onTap: () => controller.onSelectAvatarIcon(index),
                        child: Container(
                          width: 54,
                          height: 54,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? context.colorTokens.primaryVeryLight
                                : context.colorTokens.surfaceInnerLayer,
                            shape: BoxShape.circle,
                            border: isSelected
                                ? Border.all(
                                    color: context.colorTokens.primary,
                                    width: 2,
                                  )
                                : null,
                          ),
                          child: Icon(
                            AppAvatarPresets.values[index],
                            color: isSelected
                                ? context.colorTokens.primary
                                : context.colorTokens.textHint,
                            size: 27,
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
            const Gap(14),
            _ProfileSection(
              title: context.l10n.personalInformationTitle,
              children: [
                _ProfileTextField(
                  controller: controller.nameController,
                  labelText: context.l10n.nameLabel,
                  hintText: context.l10n.yourNameHint,
                  iconName: "user",
                ),
                const Gap(14),
                _ProfileTextField(
                  controller: controller.nickNameController,
                  labelText: context.l10n.nicknameLabel,
                  hintText: context.l10n.nicknameHint,
                  iconName: "special_a",
                ),
                const Gap(14),
                _ProfileTextField(
                  controller: controller.emailController,
                  keyboardType: TextInputType.emailAddress,
                  readOnly: true,
                  canRequestFocus: false,
                  labelText: context.l10n.emailLabel,
                  hintText: context.l10n.optionalHint,
                  iconName: "mail",
                  iconSize: 18,
                  style: context.textStyles.bodyLarge.copyWith(
                    color: context.colorTokens.borderUnfocused,
                    fontWeight: FontWeight.w700,
                    fontSize: 17,
                  ),
                ),
              ],
            ),
            const Gap(14),
            _ProfileSection(
              title: context.l10n.connectedAccountsSection,
              children: [_LinkedAuthCard(controller: controller)],
            ),
            const Gap(14),
            _ProfileSection(
              title: context.l10n.contactSection,
              children: [
                _ProfileTextField(
                  controller: controller.phoneController,
                  keyboardType: TextInputType.phone,
                  labelText: context.l10n.phoneLabel,
                  hintText: context.l10n.optionalHint,
                  iconName: "phone",
                ),
              ],
            ),
            const Gap(14),
            _ProfileSection(
              title: context.l10n.themeColorLabel,
              children: [
                Obx(
                  () => CenteredWrapGrid(
                    itemsPerRow: 4,
                    spacing: 16,
                    runSpacing: 16,
                    children: AppAccentPresets.values.map((color) {
                      final bool isSelected =
                          controller.accentColor.value.toARGB32() ==
                          color.toARGB32();
                      return BounceTap(
                        onTap: () => controller.onSelectAccentColor(color),
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                          child: isSelected
                              ? const Center(
                                  child: AppIcon(
                                    "check",
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                )
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileTextField extends StatelessWidget {
  const _ProfileTextField({
    required this.controller,
    required this.labelText,
    required this.hintText,
    required this.iconName,
    this.keyboardType,
    this.readOnly = false,
    this.canRequestFocus = true,
    this.iconSize = 20,
    this.style,
  });

  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final String iconName;
  final TextInputType? keyboardType;
  final bool readOnly;
  final bool canRequestFocus;
  final double iconSize;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final TextStyle labelStyle = context.textStyles.bodySmall.copyWith(
      color: context.colorTokens.primary,
      fontWeight: FontWeight.w900,
      fontSize: 14,
    );
    final TextStyle inputStyle =
        style ??
        context.textStyles.inputText.copyWith(fontSize: 17, height: 1.2);

    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      canRequestFocus: canRequestFocus,
      style: inputStyle,
      decoration:
          AppInputDecoration.withBorder(
            tokens: context.colorTokens,
            labelText: labelText,
            hintText: hintText,
            prefixIcon: AppIcon(
              iconName,
              size: iconSize,
              color: context.colorTokens.primary,
            ),
          ).copyWith(
            labelStyle: labelStyle,
            floatingLabelStyle: labelStyle,
            hintStyle: context.textStyles.hintText.copyWith(fontSize: 17),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 18,
            ),
          ),
    );
  }
}

class _ProfileSection extends StatelessWidget {
  const _ProfileSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
    decoration: BoxDecoration(
      color: context.colorTokens.surface,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: context.colorTokens.borderUnfocused.withValues(alpha: 0.32),
      ),
      boxShadow: [
        BoxShadow(
          color: context.colorTokens.surfaceShadow.withValues(alpha: 0.08),
          blurRadius: 18,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 14),
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textStyles.bodySmall.copyWith(
              color: context.colorTokens.textHint,
              fontWeight: FontWeight.w900,
              fontSize: 14,
            ),
          ),
        ),
        ...children,
      ],
    ),
  );
}

class _SaveChangesButton extends StatelessWidget {
  const _SaveChangesButton({required this.controller});

  final EditProfileController controller;

  @override
  Widget build(BuildContext context) => Obx(
    () => BounceTap(
      pressedScale: 0.97,
      onTap: controller.isSaving.value ? () {} : controller.onTapSave,
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          gradient: context.colorTokens.primaryGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: context.colorTokens.primary.withValues(alpha: 0.24),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: controller.isSaving.value
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const AppIcon("check", size: 16, color: Colors.white),
                  const Gap(8),
                  Text(
                    context.l10n.saveChangesButton,
                    style: context.textStyles.textPrimaryButton,
                  ),
                ],
              ),
      ),
    ),
  );
}

class _LinkedAuthCard extends StatelessWidget {
  const _LinkedAuthCard({required this.controller});

  final EditProfileController controller;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    decoration: BoxDecoration(
      color: context.colorTokens.surface,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(
        color: context.colorTokens.borderUnfocused.withValues(alpha: 0.72),
      ),
    ),
    child: Column(
      children: [
        Obx(
          () => _LinkedAuthRow(
            icon: const AppIcon("google", size: 18, color: Color(0xFF4285F4)),
            title: context.l10n.linkGoogleAccountTitle,
            subtitle: controller.isGoogleLinked.value
                ? context.l10n.linkedAccountsSubtitle
                : context.l10n.linkGoogleAccountSubtitle,
            trailingText: controller.isGoogleLinked.value
                ? context.l10n.authProviderConnected
                : null,
            tint: const Color(0xFF4285F4),
            isLoading: controller.isLinkingGoogle.value,
            onTap: controller.onTapLinkGoogle,
          ),
        ),
        Divider(height: 1, color: context.colorTokens.divider),
        Obx(
          () => _LinkedAuthRow(
            icon: Icon(
              Icons.apple_rounded,
              size: 20,
              color: context.colorTokens.textBody,
            ),
            title: context.l10n.linkAppleAccountTitle,
            subtitle: controller.isAppleLinked.value
                ? context.l10n.linkedAccountsSubtitle
                : context.l10n.linkAppleAccountSubtitle,
            trailingText: controller.isAppleLinked.value
                ? context.l10n.authProviderConnected
                : null,
            tint: context.colorTokens.textBody,
            isLoading: controller.isLinkingApple.value,
            onTap: controller.onTapLinkApple,
          ),
        ),
      ],
    ),
  );
}

class _LinkedAuthRow extends StatelessWidget {
  const _LinkedAuthRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.tint,
    required this.isLoading,
    required this.onTap,
    this.trailingText,
  });

  final Widget icon;
  final String title;
  final String subtitle;
  final Color tint;
  final bool isLoading;
  final VoidCallback onTap;
  final String? trailingText;

  @override
  Widget build(BuildContext context) => BounceTap(
    pressedScale: 0.98,
    onTap: isLoading ? () {} : onTap,
    child: Container(
      constraints: const BoxConstraints(minHeight: 76),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: context.colorTokens.transparent,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: tint.withValues(
                alpha: Theme.of(context).brightness == Brightness.dark
                    ? 0.18
                    : 0.12,
              ),
              shape: BoxShape.circle,
            ),
            child: Center(child: icon),
          ),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textStyles.cardTitle,
                ),
                const Gap(2),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.textStyles.caption.copyWith(
                    color: context.colorTokens.textHint,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const Gap(12),
          if (isLoading)
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2.4,
                strokeCap: StrokeCap.round,
                color: tint,
              ),
            )
          else if (trailingText != null)
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 92),
              child: Text(
                trailingText!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
                style: context.textStyles.caption.copyWith(fontSize: 13),
              ),
            )
          else
            Icon(
              Icons.chevron_right_rounded,
              size: 22,
              color: context.colorTokens.textHint,
            ),
        ],
      ),
    ),
  );
}

class _ProfilePhotoPreview extends StatelessWidget {
  const _ProfilePhotoPreview({required this.controller});

  final EditProfileController controller;

  @override
  Widget build(BuildContext context) => Obx(() {
    final Uint8List? photoBytes = controller.profilePhotoBytes;

    return SizedBox(
      width: 112,
      height: 112,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: BounceTap(
              onTap: controller.onTapSelectPhoto,
              child: Container(
                decoration: BoxDecoration(
                  gradient: photoBytes == null
                      ? context.colorTokens.primaryGradient
                      : null,
                  shape: BoxShape.circle,
                ),
                clipBehavior: Clip.antiAlias,
                child: photoBytes == null
                    ? Icon(
                        AppAvatarPresets.byIndex(
                          controller.avatarIconIndex.value,
                        ),
                        color: Colors.white,
                        size: 50,
                      )
                    : Image.memory(
                        photoBytes,
                        fit: BoxFit.cover,
                        cacheWidth:
                            (100 * MediaQuery.devicePixelRatioOf(context))
                                .round(),
                      ),
              ),
            ),
          ),
          Positioned(
            right: 2,
            bottom: 2,
            child: BounceTap(
              onTap: controller.onTapProfilePhoto,
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: context.colorTokens.primary,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: context.colorTokens.scaffold,
                    width: 2.5,
                  ),
                ),
                child: const Icon(
                  Icons.photo_camera_rounded,
                  color: Colors.white,
                  size: 19,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  });
}
