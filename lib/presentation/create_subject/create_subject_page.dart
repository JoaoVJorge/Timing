import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:gap/gap.dart";
import "package:get/get.dart";
import "package:help_out/app/app_navigator.dart";
import "package:help_out/core/domain/enums/time_category_type.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/presentation/create_subject/create_subject_controller.dart";
import "package:help_out/shared/widgets/app_icon.dart";
import "package:help_out/shared/widgets/bounce_tap.dart";
import "package:help_out/theme/subject_colors.dart";
import "package:help_out/theme/subject_icons.dart";
import "package:help_out/theme/timer_wallpapers.dart";

class CreateSubjectPage extends StatelessWidget {
  const CreateSubjectPage({super.key});

  @override
  Widget build(BuildContext context) {
    final CreateSubjectController controller = Get.find();

    return Scaffold(
      backgroundColor: _pageBackground(context),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 14),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  clipBehavior: Clip.none,
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _HeroHeader(controller: controller),
                      const Gap(14),
                      _NameField(controller: controller),
                      const Gap(12),
                      _GoalSection(controller: controller),
                      const Gap(12),
                      _RestSection(controller: controller),
                      const Gap(12),
                      _ColorSection(controller: controller),
                      const Gap(12),
                      _IconSection(controller: controller),
                      const Gap(12),
                      _WallpaperSection(controller: controller),
                    ],
                  ),
                ),
              ),
              Obx(
                () => _SubmitButton(
                  label: controller.submitLabel(context),
                  isLoading: controller.isSaving.value,
                  isEnabled: !controller.isSaving.value,
                  accent: controller.selectedColor.value,
                  onTap: controller.onSubmit,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _pageBackground(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.dark) {
      return context.colorTokens.scaffold;
    }

    return Color.lerp(
          context.colorTokens.primaryVeryLight,
          context.colorTokens.white,
          0.74,
        ) ??
        context.colorTokens.scaffold;
  }
}

class _HeroHeader extends StatelessWidget {
  const _HeroHeader({required this.controller});

  final CreateSubjectController controller;

  @override
  Widget build(BuildContext context) => Obx(() {
    final Color color = controller.selectedColor.value;
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: 260,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(left: 0, top: 0, child: _BackButton()),
          Positioned(
            right: -28,
            top: 6,
            child: _HeroBubble(
              color: color,
              isDarkMode: isDarkMode,
              child: Image.asset(
                _heroAsset(controller.category, color),
                width: 238,
                height: 238,
                fit: BoxFit.contain,
              ),
            ),
          ),
          Positioned(
            left: 0,
            top: 72,
            right: 146,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _heroTitle(context),
                  style: context.textStyles.black32.copyWith(
                    color: color,
                    fontSize: 34,
                    height: 1.02,
                  ),
                ),
                const Gap(12),
                Text(
                  controller.subtitle(context),
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
        ],
      ),
    );
  });

  String _heroTitle(BuildContext context) {
    final String title = controller.title(context);
    if (controller.category == TimeCategoryType.exercises) {
      return title.replaceFirst(" atividade ", "\natividade\n");
    }
    if (controller.category == TimeCategoryType.studying) {
      return title.replaceFirst(" ", "\n");
    }
    return title.replaceFirst(" ", "\n");
  }

  String _heroAsset(TimeCategoryType category, Color selectedColor) {
    return switch (category) {
      TimeCategoryType.studying => "assets/images/notebook.png",
      TimeCategoryType.exercises => "assets/images/tenins.png",
      TimeCategoryType.reading => "assets/images/book.png",
      TimeCategoryType.hobbies => "assets/images/godet.png",
    };
  }
}

class _BackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) => BounceTap(
    onTap: appNavigator.back,
    child: Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: context.colorTokens.surface,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: context.colorTokens.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Center(
        child: AppIcon(
          "left_back",
          size: 20,
          color: context.colorTokens.primary,
        ),
      ),
    ),
  );
}

class _HeroBubble extends StatelessWidget {
  const _HeroBubble({
    required this.color,
    required this.isDarkMode,
    required this.child,
  });

  final Color color;
  final bool isDarkMode;
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    width: 270,
    height: 218,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: color.withValues(alpha: isDarkMode ? 0.18 : 0.2),
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(86),
        topRight: Radius.circular(116),
        bottomLeft: Radius.circular(104),
        bottomRight: Radius.circular(72),
      ),
    ),
    child: child,
  );
}

class _NameField extends StatelessWidget {
  const _NameField({required this.controller});

  final CreateSubjectController controller;

  @override
  Widget build(BuildContext context) => Obx(() {
    final Color color = controller.selectedColor.value;
    final String iconName = controller.selectedIconName.value;
    final IconData? icon = SubjectIcons.byName(iconName);

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: context.colorTokens.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: context.colorTokens.borderUnfocused.withValues(alpha: 0.48),
        ),
        boxShadow: [_softShadow(context)],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withValues(alpha: 0.65)),
            ),
            child: Center(
              child: icon == null
                  ? AppIcon(iconName, color: color, size: 22)
                  : Icon(icon, color: color, size: 22),
            ),
          ),
          const Gap(12),
          Expanded(
            child: TextField(
              controller: controller.nameController,
              autofocus: true,
              style: TextStyle(
                color: context.colorTokens.textBody,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
              decoration: InputDecoration(
                hintText: controller.nameHint(context),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
                hintStyle: TextStyle(
                  color: context.colorTokens.textHint.withValues(alpha: 0.62),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  });
}

class _GoalSection extends StatelessWidget {
  const _GoalSection({required this.controller});

  final CreateSubjectController controller;

  @override
  Widget build(BuildContext context) => Obx(() {
    final Color accent = controller.selectedColor.value;

    return _ConfigCard(
      accent: accent,
      header: _SectionHeader(
        icon: Icons.track_changes_rounded,
        label: controller.isPageBased
            ? context.l10n.createSubjectPagesGoalLabel
            : context.l10n.createSubjectTimeGoalLabel,
        accent: accent,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PresetRow(
            children:
                (controller.isPageBased
                        ? controller.pageGoalPresets
                        : controller.timeGoalPresets)
                    .map(
                      (value) => _SelectableChip(
                        label: controller.isPageBased
                            ? context.l10n.metricPagesValue(value.toInt())
                            : context.l10n.createSubjectHoursValue(
                                value.toInt(),
                              ),
                        isSelected:
                            controller.goal.value.trim() == value.toString(),
                        accent: accent,
                        onTap: () => controller.setGoalPreset(value),
                      ),
                    )
                    .toList(),
          ),
          const Gap(12),
          _GoalInput(controller: controller, accent: accent),
        ],
      ),
    );
  });
}

class _GoalInput extends StatelessWidget {
  const _GoalInput({required this.controller, required this.accent});

  final CreateSubjectController controller;
  final Color accent;

  @override
  Widget build(BuildContext context) => Container(
    height: 52,
    padding: const EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(
      color: context.colorTokens.scaffold.withValues(alpha: 0.36),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: context.colorTokens.borderUnfocused),
    ),
    child: Row(
      children: [
        Icon(Icons.access_time_rounded, color: accent, size: 20),
        const Gap(12),
        Expanded(
          child: TextField(
            controller: controller.goalController,
            keyboardType: controller.isPageBased
                ? TextInputType.number
                : const TextInputType.numberWithOptions(decimal: true),
            style: TextStyle(
              color: context.colorTokens.textBody,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
            decoration: InputDecoration(
              hintText: controller.isPageBased
                  ? context.l10n.goalPagesHint
                  : context.l10n.estimatedHoursGoalHint,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
              hintStyle: TextStyle(
                color: context.colorTokens.textHint.withValues(alpha: 0.62),
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

class _RestSection extends StatelessWidget {
  const _RestSection({required this.controller});

  final CreateSubjectController controller;

  @override
  Widget build(BuildContext context) => Obx(() {
    final Color accent = controller.selectedColor.value;

    return _ConfigCard(
      accent: accent,
      header: _SectionHeader(
        icon: Icons.emoji_food_beverage_rounded,
        label: context.l10n.createSubjectRestLabel,
        accent: accent,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PresetRow(
            children: controller.restMinutesOptions
                .map(
                  (minutes) => _SelectableChip(
                    label: context.l10n.restMinutesChip(minutes),
                    isSelected: minutes == controller.restMinutes.value,
                    accent: accent,
                    onTap: () => controller.setRestMinutes(minutes),
                  ),
                )
                .toList(),
          ),
          const Gap(12),
          _RestMinutesInput(controller: controller, accent: accent),
        ],
      ),
    );
  });
}

class _RestMinutesInput extends StatelessWidget {
  const _RestMinutesInput({required this.controller, required this.accent});

  final CreateSubjectController controller;
  final Color accent;

  @override
  Widget build(BuildContext context) => Container(
    height: 48,
    padding: const EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(
      color: context.colorTokens.scaffold.withValues(alpha: 0.36),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: context.colorTokens.borderUnfocused),
    ),
    child: Row(
      children: [
        Icon(Icons.timer_outlined, color: accent, size: 20),
        const Gap(12),
        Expanded(
          child: TextField(
            controller: controller.restMinutesController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: TextStyle(
              color: context.colorTokens.textBody,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
            decoration: InputDecoration(
              hintText: "Pausa personalizada (min)",
              suffixText: "min",
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
              hintStyle: TextStyle(
                color: context.colorTokens.textHint.withValues(alpha: 0.62),
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

class _ColorSection extends StatelessWidget {
  const _ColorSection({required this.controller});

  final CreateSubjectController controller;

  @override
  Widget build(BuildContext context) => Obx(() {
    final Color accent = controller.selectedColor.value;

    return _ConfigCard(
      accent: accent,
      header: _SectionHeader(
        icon: Icons.palette_outlined,
        label: context.l10n.colorLabel,
        accent: accent,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: SubjectColors.values
            .map(
              (color) => _ColorChoice(
                color: color,
                isSelected:
                    color.toARGB32() ==
                    controller.selectedColor.value.toARGB32(),
                onTap: () => controller.selectedColor.value = color,
              ),
            )
            .toList(),
      ),
    );
  });
}

class _IconSection extends StatelessWidget {
  const _IconSection({required this.controller});

  final CreateSubjectController controller;

  @override
  Widget build(BuildContext context) => Obx(() {
    final Color accent = controller.selectedColor.value;

    return _ConfigCard(
      accent: accent,
      header: _SectionHeader(
        icon: Icons.star_border_rounded,
        label: context.l10n.iconLabel,
        accent: accent,
      ),
      child: _IconSelector(controller: controller, accent: accent),
    );
  });
}

class _WallpaperSection extends StatelessWidget {
  const _WallpaperSection({required this.controller});

  final CreateSubjectController controller;

  @override
  Widget build(BuildContext context) => Obx(() {
    final Color accent = controller.selectedColor.value;

    return _ConfigCard(
      accent: accent,
      header: _SectionHeader(
        icon: Icons.image_outlined,
        label: context.l10n.wallpaperLabel,
        accent: accent,
      ),
      child: _WallpaperSelector(controller: controller, accent: accent),
    );
  });
}

class _ConfigCard extends StatelessWidget {
  const _ConfigCard({
    required this.header,
    required this.child,
    required this.accent,
  });

  final Widget header;
  final Widget child;
  final Color accent;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: context.colorTokens.surface,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: accent.withValues(alpha: 0.16)),
      boxShadow: [_softShadow(context)],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [header, const Gap(12), child],
    ),
  );
}

BoxShadow _softShadow(BuildContext context) => BoxShadow(
  color: context.colorTokens.black.withValues(
    alpha: Theme.of(context).brightness == Brightness.dark ? 0.18 : 0.055,
  ),
  blurRadius: 18,
  offset: const Offset(0, 9),
);

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon,
    required this.label,
    required this.accent,
  });

  final IconData icon;
  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, size: 24, color: accent),
      const Gap(10),
      Expanded(
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: context.colorTokens.textBody,
            fontSize: 15,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    ],
  );
}

class _PresetRow extends StatelessWidget {
  const _PresetRow({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      for (int index = 0; index < children.length; index++) ...[
        Expanded(child: children[index]),
        if (index != children.length - 1) const Gap(8),
      ],
    ],
  );
}

class _SelectableChip extends StatelessWidget {
  const _SelectableChip({
    required this.label,
    required this.isSelected,
    required this.accent,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => BounceTap(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isSelected ? accent : context.colorTokens.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isSelected ? accent : context.colorTokens.borderUnfocused,
          width: 1,
        ),
        boxShadow: [
          if (isSelected)
            BoxShadow(
              color: accent.withValues(alpha: 0.24),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
        ],
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          label,
          maxLines: 1,
          style: TextStyle(
            color: isSelected
                ? context.colorTokens.white
                : context.colorTokens.textBody,
            fontSize: 13,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    ),
  );
}

class _ColorChoice extends StatelessWidget {
  const _ColorChoice({
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => BounceTap(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 30,
      height: 30,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? color.withValues(alpha: 0.2) : color,
        border: Border.all(
          color: isSelected ? color : color,
          width: isSelected ? 2 : 0,
        ),
        boxShadow: [
          if (isSelected)
            BoxShadow(
              color: color.withValues(alpha: 0.32),
              blurRadius: 10,
              spreadRadius: 1,
              offset: Offset.zero,
            ),
        ],
      ),
      child: isSelected
          ? DecoratedBox(
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              child: const Center(
                child: AppIcon("check", size: 14, color: Colors.white),
              ),
            )
          : null,
    ),
  );
}

class _IconSelector extends StatelessWidget {
  const _IconSelector({required this.controller, required this.accent});

  final CreateSubjectController controller;
  final Color accent;

  @override
  Widget build(BuildContext context) => Obx(
    () => Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final String iconName in controller.iconSuggestions)
          _IconChoice(
            iconName: iconName,
            icon: SubjectIcons.byName(iconName),
            isSelected: iconName == controller.selectedIconName.value,
            accent: accent,
            onTap: () => controller.selectedIconName.value = iconName,
          ),
      ],
    ),
  );
}

class _WallpaperSelector extends StatelessWidget {
  const _WallpaperSelector({required this.controller, required this.accent});

  final CreateSubjectController controller;
  final Color accent;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      const double gap = 8;
      final double itemWidth =
          (constraints.maxWidth - gap * (TimerWallpapers.values.length - 1)) /
          TimerWallpapers.values.length;

      return Obx(() {
        return Row(
          children: List.generate(TimerWallpapers.values.length, (index) {
            final bool isSelected = index == controller.wallpaperIndex.value;
            return Padding(
              padding: EdgeInsets.only(
                right: index == TimerWallpapers.values.length - 1 ? 0 : gap,
              ),
              child: BounceTap(
                onTap: () => controller.wallpaperIndex.value = index,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: itemWidth,
                  height: 74,
                  decoration: BoxDecoration(
                    gradient: TimerWallpapers.byIndex(index),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? accent
                          : context.colorTokens.borderUnfocused,
                      width: isSelected ? 3 : 1,
                    ),
                  ),
                  child: isSelected
                      ? const Center(
                          child: AppIcon(
                            "check",
                            size: 18,
                            color: Colors.white,
                          ),
                        )
                      : null,
                ),
              ),
            );
          }),
        );
      });
    },
  );
}

class _IconChoice extends StatelessWidget {
  const _IconChoice({
    required this.iconName,
    required this.isSelected,
    required this.onTap,
    required this.accent,
    this.icon,
  });

  final String iconName;
  final IconData? icon;
  final bool isSelected;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => BounceTap(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 48,
      height: 46,
      decoration: BoxDecoration(
        color: isSelected
            ? accent.withValues(alpha: 0.12)
            : context.colorTokens.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isSelected ? accent : context.colorTokens.borderUnfocused,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: context.colorTokens.black.withValues(alpha: 0.035),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: icon == null
            ? AppIcon(
                iconName,
                size: 22,
                color: isSelected ? accent : context.colorTokens.iconDisabled,
              )
            : Icon(
                icon,
                size: 22,
                color: isSelected ? accent : context.colorTokens.iconDisabled,
              ),
      ),
    ),
  );
}

class _SubmitButton extends StatelessWidget {
  const _SubmitButton({
    required this.label,
    required this.isEnabled,
    required this.isLoading,
    required this.accent,
    required this.onTap,
  });

  final String label;
  final bool isEnabled;
  final bool isLoading;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => AbsorbPointer(
    absorbing: !isEnabled || isLoading,
    child: BounceTap(
      onTap: onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 180),
        opacity: isEnabled ? 1 : 0.62,
        child: Container(
          width: double.infinity,
          height: 60,
          padding: const EdgeInsets.only(left: 56, right: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                accent,
                Color.lerp(accent, context.colorTokens.white, 0.22) ?? accent,
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(999),
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha: 0.28),
                blurRadius: 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: isLoading
              ? Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: context.colorTokens.white,
                    ),
                  ),
                )
              : Row(
                  children: [
                    Expanded(
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: context.colorTokens.white,
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: context.colorTokens.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        color: accent,
                        size: 28,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    ),
  );
}
