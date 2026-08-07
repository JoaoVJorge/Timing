import "package:dartz/dartz.dart" hide State;
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:gap/gap.dart";
import "package:get/get.dart";
import "package:help_out/app/app_navigator.dart";
import "package:help_out/core/data/repositories/groups_repository.dart";
import "package:help_out/core/domain/entities/group_entity.dart";
import "package:help_out/core/domain/errors/app_error.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/shared/widgets/app_scaffold.dart";
import "package:help_out/shared/widgets/app_top_bar.dart";
import "package:help_out/shared/widgets/bounce_tap.dart";
import "package:help_out/theme/app_spacing.dart";
import "package:help_out/theme/decoration.dart";

class JoinGroupPage extends StatefulWidget {
  const JoinGroupPage({super.key});

  @override
  State<JoinGroupPage> createState() => _JoinGroupPageState();
}

class _JoinGroupPageState extends State<JoinGroupPage> {
  final TextEditingController _codeController = TextEditingController();
  final GroupsRepository _groupsRepository = Get.find();
  bool _isLoading = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AppScaffold(
    topBar: AppTopBar(title: _title(context), showBackButton: true),
    body: ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.only(bottom: AppSpacing.betweenSections),
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: context.colorTokens.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: context.colorTokens.borderUnfocused),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _fieldLabel(context),
                style: context.textStyles.bodyLarge.copyWith(
                  color: context.colorTokens.textBody,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Gap(10),
              TextField(
                controller: _codeController,
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp("[a-zA-Z0-9]")),
                  LengthLimitingTextInputFormatter(12),
                  _UpperCaseTextFormatter(),
                ],
                decoration: AppInputDecoration.withBorder(
                  tokens: context.colorTokens,
                  hintText: _hint(context),
                ),
              ),
              const Gap(16),
              _JoinButton(
                isLoading: _isLoading,
                label: _buttonLabel(context),
                onTap: _join,
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Future<void> _join() async {
    final String code = _codeController.text.trim();
    if (code.isEmpty || _isLoading) {
      return;
    }
    setState(() => _isLoading = true);
    final Either<AppError, GroupEntity> result = await _groupsRepository
        .joinGroupByInviteCode(code);
    if (!mounted) {
      return;
    }
    setState(() => _isLoading = false);
    result.fold(
      (error) => appNavigator.showErrorSnackBar(_errorMessage(context)),
      (group) => appNavigator.back<GroupEntity>(result: group),
    );
  }

  String _title(BuildContext context) => switch (context.languageCode) {
    "pt" => "Entrar em grupo",
    "es" => "Unirse a un grupo",
    _ => "Join group",
  };

  String _fieldLabel(BuildContext context) => switch (context.languageCode) {
    "pt" => "Código de convite",
    "es" => "Código de invitación",
    _ => "Invite code",
  };

  String _hint(BuildContext context) => switch (context.languageCode) {
    "pt" => "Digite o código",
    "es" => "Escribe el código",
    _ => "Enter the code",
  };

  String _buttonLabel(BuildContext context) => switch (context.languageCode) {
    "pt" => "Entrar no grupo",
    "es" => "Unirme al grupo",
    _ => "Join group",
  };

  String _errorMessage(BuildContext context) => switch (context.languageCode) {
    "pt" => "Não foi possível entrar nesse grupo.",
    "es" => "No fue posible unirse a este grupo.",
    _ => "Could not join this group.",
  };
}

class _JoinButton extends StatelessWidget {
  const _JoinButton({
    required this.isLoading,
    required this.label,
    required this.onTap,
  });

  final bool isLoading;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => BounceTap(
    onTap: isLoading ? () {} : onTap,
    pressedScale: isLoading ? 1 : 0.97,
    child: Container(
      height: 54,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: context.colorTokens.primaryGradient,
        borderRadius: BorderRadius.circular(999),
      ),
      child: isLoading
          ? SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.4,
                color: context.colorTokens.primaryForeground,
              ),
            )
          : Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textStyles.textPrimaryButton.copyWith(
                color: context.colorTokens.primaryForeground,
                fontWeight: FontWeight.w900,
              ),
            ),
    ),
  );
}

class _UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) => newValue.copyWith(text: newValue.text.toUpperCase());
}
