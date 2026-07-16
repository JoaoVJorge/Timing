import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:gap/gap.dart";
import "package:get/get.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/presentation/phone_login/country_codes.dart";
import "package:help_out/presentation/phone_login/phone_login_controller.dart";
import "package:help_out/shared/widgets/auth_onboarding_widgets.dart";
import "package:help_out/shared/widgets/bounce_tap.dart";

class PhoneLoginPage extends StatelessWidget {
  const PhoneLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final PhoneLoginController controller = Get.find();

    return AuthOnboardingScaffold(
      showBackButton: true,
      title: context.l10n.phoneLoginTitle,
      subtitle: context.l10n.phoneLoginSubtitle,
      topVisual: const AuthHeroPlaceholder(icon: Icons.assignment_rounded),
      bottom: Obx(
        () => AuthPrimaryButton(
          label: context.l10n.sendCodeButton,
          enabled: controller.canSubmit.value,
          isLoading: controller.isSubmitting.value,
          onTap: controller.onTapSendCode,
        ),
      ),
      children: [
        _PhoneInputCard(controller: controller),
        const Gap(16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.verified_user_outlined,
              color: AuthOnboardingColors.yellowDark,
              size: 24,
            ),
            const Gap(8),
            Flexible(
              child: Text(
                context.l10n.phoneSecurityNote,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AuthOnboardingColors.textMuted,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  height: 1.25,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PhoneInputCard extends StatelessWidget {
  const _PhoneInputCard({required this.controller});

  final PhoneLoginController controller;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    decoration: AuthOnboardingDecorations.card,
    child: Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AuthOnboardingColors.navy.withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        children: [
          BounceTap(
            onTap: () => _showCountryPicker(context),
            child: Obx(
              () => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    controller.selectedCountry.value.flag,
                    style: const TextStyle(fontSize: 22),
                  ),
                  const Gap(4),
                  Text(
                    controller.selectedCountry.value.dialCode,
                    style: const TextStyle(
                      color: AuthOnboardingColors.navy,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0,
                    ),
                  ),
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: AuthOnboardingColors.navy,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
          const Gap(8),
          Container(
            width: 1,
            height: 24,
            color: AuthOnboardingColors.navy.withValues(alpha: 0.1),
          ),
          const Gap(12),
          Expanded(
            child: Obx(
              () => TextField(
                controller: controller.phoneController,
                onChanged: controller.onPhoneChanged,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r"[0-9()\-\s]")),
                ],
                style: AuthOnboardingTextStyles.fieldValue,
                decoration: InputDecoration(
                  hintText: controller.selectedCountry.value.hint,
                  hintStyle: AuthOnboardingTextStyles.fieldHint,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );

  Future<void> _showCountryPicker(BuildContext context) async {
    final CountryCode? selected = await showModalBottomSheet<CountryCode>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _CountryPickerSheet(),
    );
    if (selected != null) {
      controller.onSelectCountry(selected);
    }
  }
}

class _CountryPickerSheet extends StatefulWidget {
  const _CountryPickerSheet();

  @override
  State<_CountryPickerSheet> createState() => _CountryPickerSheetState();
}

class _CountryPickerSheetState extends State<_CountryPickerSheet> {
  String _query = "";

  List<CountryCode> get _filteredCountries {
    final String query = _query.trim().toLowerCase();
    if (query.isEmpty) {
      return CountryCodes.values;
    }
    return CountryCodes.values
        .where(
          (country) =>
              country.name.toLowerCase().contains(query) ||
              country.dialCode.contains(query),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final List<CountryCode> countries = _filteredCountries;

    return Container(
      height: MediaQuery.sizeOf(context).height * 0.72,
      decoration: const BoxDecoration(
        color: AuthOnboardingColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        children: [
          const Gap(12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AuthOnboardingColors.navy.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const Gap(16),
          Text(
            context.l10n.selectCountryTitle,
            style: const TextStyle(
              color: AuthOnboardingColors.navy,
              fontSize: 20,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
          const Gap(16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AuthOnboardingColors.navy.withValues(alpha: 0.12),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.search_rounded,
                    color: AuthOnboardingColors.textMuted,
                    size: 22,
                  ),
                  const Gap(8),
                  Expanded(
                    child: TextField(
                      autofocus: false,
                      onChanged: (value) => setState(() => _query = value),
                      style: AuthOnboardingTextStyles.fieldValue,
                      decoration: InputDecoration(
                        hintText: context.l10n.searchCountryHint,
                        hintStyle: AuthOnboardingTextStyles.fieldHint,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Gap(8),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              itemCount: countries.length,
              itemBuilder: (context, index) {
                final CountryCode country = countries[index];
                return _CountryTile(
                  country: country,
                  onTap: () => Navigator.of(context).pop(country),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CountryTile extends StatelessWidget {
  const _CountryTile({required this.country, required this.onTap});

  final CountryCode country;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => BounceTap(
    pressedScale: 0.98,
    onTap: onTap,
    child: Container(
      height: 52,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AuthOnboardingColors.navy.withValues(alpha: 0.06),
        ),
      ),
      child: Row(
        children: [
          Text(country.flag, style: const TextStyle(fontSize: 24)),
          const Gap(12),
          Expanded(
            child: Text(
              country.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AuthOnboardingColors.navy,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: 0,
              ),
            ),
          ),
          const Gap(8),
          Text(
            country.dialCode,
            style: const TextStyle(
              color: AuthOnboardingColors.textMuted,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    ),
  );
}
