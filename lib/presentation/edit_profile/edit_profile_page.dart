import "dart:typed_data";

import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:get/get.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/presentation/edit_profile/edit_profile_controller.dart";
import "package:help_out/shared/widgets/app_icon.dart";
import "package:help_out/shared/widgets/app_scaffold.dart";
import "package:help_out/shared/widgets/app_top_bar.dart";
import "package:help_out/shared/widgets/bounce_tap.dart";
import "package:help_out/shared/widgets/centered_wrap_grid.dart";
import "package:help_out/theme/accent_presets.dart";
import "package:help_out/theme/avatar_presets.dart";
import "package:help_out/theme/decoration.dart";

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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: _ProfilePhotoPreview(controller: controller)),
            const Gap(18),
            Text(context.l10n.avatarLabel, style: context.textStyles.bodyLarge),
            const Gap(12),
            Obx(
              () => CenteredWrapGrid(
                itemsPerRow: 4,
                children: List.generate(AppAvatarPresets.values.length, (
                  index,
                ) {
                  final bool isSelected =
                      index == controller.avatarIconIndex.value;
                  return BounceTap(
                    onTap: () => controller.onSelectAvatarIcon(index),
                    child: Container(
                      width: 48,
                      height: 48,
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
                      ),
                    ),
                  );
                }),
              ),
            ),
            const Gap(16),
            Text(context.l10n.nameLabel, style: context.textStyles.bodyLarge),
            const Gap(8),
            TextField(
              controller: controller.nameController,
              decoration: AppInputDecoration.withBorder(
                tokens: context.colorTokens,
                hintText: context.l10n.yourNameHint,
                prefixIcon: AppIcon(
                  "user",
                  size: 20,
                  color: context.colorTokens.textHint,
                ),
              ),
            ),
            const Gap(16),
            Text(
              context.l10n.nicknameLabel,
              style: context.textStyles.bodyLarge,
            ),
            const Gap(8),
            TextField(
              controller: controller.nickNameController,
              decoration: AppInputDecoration.withBorder(
                tokens: context.colorTokens,
                hintText: context.l10n.nicknameHint,
                prefixIcon: AppIcon(
                  "special_a",
                  size: 20,
                  color: context.colorTokens.textHint,
                ),
              ),
            ),
            const Gap(16),
            Text(context.l10n.emailLabel, style: context.textStyles.bodyLarge),
            const Gap(8),
            TextField(
              controller: controller.emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: AppInputDecoration.withBorder(
                tokens: context.colorTokens,
                hintText: context.l10n.optionalHint,
                prefixIcon: AppIcon(
                  "mail",
                  size: 18,
                  color: context.colorTokens.textHint,
                ),
              ),
            ),
            const Gap(16),
            Text(context.l10n.phoneLabel, style: context.textStyles.bodyLarge),
            const Gap(8),
            TextField(
              controller: controller.phoneController,
              keyboardType: TextInputType.phone,
              decoration: AppInputDecoration.withBorder(
                tokens: context.colorTokens,
                hintText: context.l10n.optionalHint,
                prefixIcon: AppIcon(
                  "phone",
                  size: 20,
                  color: context.colorTokens.textHint,
                ),
              ),
            ),
            const Gap(24),
            Text(
              context.l10n.themeColorLabel,
              style: context.textStyles.bodyLarge,
            ),
            const Gap(12),
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
                      width: 44,
                      height: 44,
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
            const Gap(28),
            Obx(
              () => BounceTap(
                pressedScale: 0.97,
                onTap: controller.isSaving.value ? () {} : controller.onTapSave,
                child: Container(
                  width: double.infinity,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: context.colorTokens.primaryGradient,
                    borderRadius: BorderRadius.circular(16),
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
                            const AppIcon(
                              "check",
                              size: 16,
                              color: Colors.white,
                            ),
                            const Gap(8),
                            Text(
                              context.l10n.saveChangesButton,
                              style: context.textStyles.textPrimaryButton,
                            ),
                          ],
                        ),
                ),
              ),
            ),
            const Gap(24),
          ],
        ),
      ),
    );
  }
}

class _ProfilePhotoPreview extends StatelessWidget {
  const _ProfilePhotoPreview({required this.controller});

  final EditProfileController controller;

  @override
  Widget build(BuildContext context) => Obx(() {
    final Uint8List? photoBytes = controller.profilePhotoBytes;

    return SizedBox(
      width: 100,
      height: 100,
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
                        size: 44,
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
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: context.colorTokens.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: context.colorTokens.surfaceShadow,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.photo_camera_rounded,
                  color: Colors.white,
                  size: 17,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  });
}
