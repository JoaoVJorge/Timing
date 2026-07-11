import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:gap/gap.dart";
import "package:get/get.dart";
import "package:help_out/app/app_navigator.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/presentation/create_task/create_task_controller.dart";
import "package:help_out/shared/widgets/app_icon.dart";
import "package:help_out/shared/widgets/bounce_tap.dart";
import "package:help_out/theme/subject_colors.dart";

class CreateTaskPage extends StatelessWidget {
  const CreateTaskPage({super.key});

  @override
  Widget build(BuildContext context) {
    final CreateTaskController controller = Get.find();

    return Scaffold(
      backgroundColor: context.createTaskPageBackground,
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
                      _TargetDaysSection(controller: controller),
                      const Gap(12),
                      _ColorSection(controller: controller),
                    ],
                  ),
                ),
              ),
              Obx(
                () => _SubmitButton(
                  label: context.l10n.addButton,
                  isLoading: controller.isSaving.value,
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
}

class _HeroHeader extends StatelessWidget {
  const _HeroHeader({required this.controller});

  final CreateTaskController controller;

  @override
  Widget build(BuildContext context) => Obx(() {
    final Color accent = controller.selectedColor.value;
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: 248,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(left: 0, top: 0, child: _BackButton(accent: accent)),
          Positioned(
            right: -28,
            top: 8,
            child: _HeroBubble(
              accent: accent,
              isDarkMode: isDarkMode,
              child: Image.asset(
                "assets/images/goal.png",
                width: 226,
                height: 226,
                fit: BoxFit.contain,
              ),
            ),
          ),
          Positioned(
            left: 0,
            top: 74,
            right: 150,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.createTaskHeroTitle,
                  style: context.textStyles.black32.copyWith(
                    color: accent,
                    fontSize: 36,
                    height: 1.02,
                  ),
                ),
                const Gap(12),
                Text(
                  context.createTaskSubtitle,
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
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.accent});

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
        boxShadow: [context.softShadow],
      ),
      child: Center(child: AppIcon("left_back", size: 20, color: accent)),
    ),
  );
}

class _HeroBubble extends StatelessWidget {
  const _HeroBubble({
    required this.accent,
    required this.isDarkMode,
    required this.child,
  });

  final Color accent;
  final bool isDarkMode;
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    width: 270,
    height: 214,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: accent.withValues(alpha: isDarkMode ? 0.18 : 0.2),
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

  final CreateTaskController controller;

  @override
  Widget build(BuildContext context) => Obx(() {
    final Color accent = controller.selectedColor.value;

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: context.createTaskCardDecoration(accent),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: accent.withValues(alpha: 0.65)),
            ),
            child: Icon(Icons.flag_rounded, color: accent, size: 22),
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
                hintText: context.l10n.taskNameHint,
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

class _TargetDaysSection extends StatelessWidget {
  const _TargetDaysSection({required this.controller});

  final CreateTaskController controller;

  @override
  Widget build(BuildContext context) => Obx(() {
    final Color accent = controller.selectedColor.value;

    return _ConfigCard(
      accent: accent,
      header: _SectionHeader(
        icon: Icons.track_changes_rounded,
        label: context.l10n.targetDaysLabel,
        accent: accent,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final int days in CreateTaskController.targetDaysOptions)
                _SelectableChip(
                  label: context.l10n.targetDaysChip(days),
                  isSelected: days == controller.targetDays.value,
                  accent: accent,
                  onTap: () => controller.onSelectTargetDays(days),
                ),
            ],
          ),
          const Gap(12),
          _CustomDaysInput(controller: controller, accent: accent),
        ],
      ),
    );
  });
}

class _CustomDaysInput extends StatelessWidget {
  const _CustomDaysInput({required this.controller, required this.accent});

  final CreateTaskController controller;
  final Color accent;

  @override
  Widget build(BuildContext context) => Container(
    height: 50,
    padding: const EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(
      color: context.colorTokens.scaffold.withValues(alpha: 0.36),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: context.colorTokens.borderUnfocused),
    ),
    child: Row(
      children: [
        Icon(Icons.calendar_today_rounded, color: accent, size: 19),
        const Gap(12),
        Expanded(
          child: TextField(
            controller: controller.customDaysController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: controller.onCustomDaysChanged,
            style: TextStyle(
              color: context.colorTokens.textBody,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
            decoration: InputDecoration(
              hintText: context.l10n.targetDaysHint,
              suffixText: context.daysSuffix,
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

  final CreateTaskController controller;

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
                isSelected: color.toARGB32() == accent.toARGB32(),
                onTap: () => controller.selectedColor.value = color,
              ),
            )
            .toList(),
      ),
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
    decoration: context.createTaskCardDecoration(accent),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [header, const Gap(12), child],
    ),
  );
}

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
      padding: const EdgeInsets.symmetric(horizontal: 14),
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
        border: Border.all(color: color, width: isSelected ? 2 : 0),
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

class _SubmitButton extends StatelessWidget {
  const _SubmitButton({
    required this.label,
    required this.isLoading,
    required this.accent,
    required this.onTap,
  });

  final String label;
  final bool isLoading;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => AbsorbPointer(
    absorbing: isLoading,
    child: BounceTap(
      onTap: onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 180),
        opacity: isLoading ? 0.7 : 1,
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
