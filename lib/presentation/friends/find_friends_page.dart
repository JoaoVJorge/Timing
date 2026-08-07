import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:gap/gap.dart";
import "package:get/get.dart";
import "package:help_out/core/domain/entities/friend_suggestion_entity.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/presentation/friends/friends_controller.dart";
import "package:help_out/presentation/friends/widgets/friends_shared.dart";
import "package:help_out/presentation/groups/widgets/group_member_avatar.dart";
import "package:help_out/shared/widgets/app_scaffold.dart";
import "package:help_out/shared/widgets/app_top_bar.dart";
import "package:help_out/shared/widgets/bounce_tap.dart";

class FindFriendsPage extends StatefulWidget {
  const FindFriendsPage({super.key});

  @override
  State<FindFriendsPage> createState() => _FindFriendsPageState();
}

class _FindFriendsPageState extends State<FindFriendsPage> {
  final TextEditingController codeController = TextEditingController();
  final FriendsController controller = Get.find();

  @override
  void dispose() {
    codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AppScaffold(
    topBar: AppTopBar(
      title: _addFriendTitle(context),
      showBackButton: true,
      onBack: () => Navigator.of(context).maybePop(),
    ),
    body: ListView(
      padding: const EdgeInsets.only(bottom: 14),
      children: [
        _InviteLookupCard(
          controller: codeController,
          onPaste: _pasteCode,
          onSearch: () => controller.findByCode(codeController.text),
        ),
        Obx(() {
          final FriendSuggestionEntity? found = controller.foundUser.value;
          if (found != null) {
            return Column(
              children: [
                const Gap(14),
                _FoundUserSection(
                  profile: found,
                  isSent: controller.isRequestSent(found.id),
                  onAdd: () => controller.sendFriendRequest(found),
                ),
              ],
            );
          }
          if (controller.hasSearched.value && !controller.isSearching.value) {
            return Column(
              children: [
                const Gap(14),
                _CodeNotFoundCard(text: _notFoundText(context)),
              ],
            );
          }
          return const SizedBox.shrink();
        }),
        const Gap(12),
        const _HowItWorksCard(),
      ],
    ),
  );

  Future<void> _pasteCode() async {
    final ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
    final String text = data?.text?.trim() ?? "";
    if (text.isEmpty) {
      return;
    }
    codeController.text = text.toUpperCase();
  }

  String _addFriendTitle(BuildContext context) =>
      switch (context.languageCode) {
        "es" => "Adicionar amigo",
        "pt" => "Adicionar amigo",
        _ => "Add friend",
      };

  String _notFoundText(BuildContext context) => switch (context.languageCode) {
    "es" => "No encontramos ningún usuario con este código.",
    "pt" => "Não encontramos nenhum usuário com este código.",
    _ => "We could not find a user with this code.",
  };
}

class _InviteLookupCard extends StatelessWidget {
  const _InviteLookupCard({
    required this.controller,
    required this.onPaste,
    required this.onSearch,
  });

  final TextEditingController controller;
  final VoidCallback onPaste;
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
    decoration: friendsSurfaceDecoration(context, radius: 18),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: context.colorTokens.primaryVeryLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.confirmation_number_outlined,
                color: context.colorTokens.primary,
                size: 21,
              ),
            ),
            const Gap(12),
            Expanded(
              child: Text(
                _title(context),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textStyles.extraBold24.copyWith(
                  color: context.colorTokens.textBody,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
        const Gap(12),
        Text(
          _fieldLabel(context),
          style: context.textStyles.bodyMedium.copyWith(
            color: context.colorTokens.textHint,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Gap(8),
        Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.colorTokens.primary, width: 1.2),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  textCapitalization: TextCapitalization.characters,
                  style: context.textStyles.black32.copyWith(
                    color: context.colorTokens.textBody,
                    fontSize: 17,
                    letterSpacing: 0.8,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: _fieldHint(context),
                    hintStyle: context.textStyles.bodyMedium.copyWith(
                      color: context.colorTokens.textHint,
                      fontWeight: FontWeight.w700,
                    ),
                    isDense: true,
                  ),
                ),
              ),
              const Gap(8),
              BounceTap(
                onTap: onPaste,
                pressedScale: 0.96,
                child: Container(
                  height: 32,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: context.colorTokens.primaryVeryLight,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.content_paste_rounded,
                        color: context.colorTokens.primary,
                        size: 18,
                      ),
                      const Gap(6),
                      Text(
                        _pasteLabel(context),
                        style: context.textStyles.bodyMedium.copyWith(
                          color: context.colorTokens.primary,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const Gap(12),
        Obx(() {
          final FriendsController friendsController = Get.find();
          return FriendWidePrimaryButton(
            label: _searchLabel(context),
            isLoading: friendsController.isSearching.value,
            onTap: onSearch,
            icon: Icons.search_rounded,
          );
        }),
      ],
    ),
  );

  String _title(BuildContext context) => switch (context.languageCode) {
    "es" => "Código de invitación",
    "pt" => "Código de convite",
    _ => "Invite code",
  };

  String _fieldLabel(BuildContext context) => switch (context.languageCode) {
    "es" => "Escribe o pega el código",
    "pt" => "Digite ou cole o código",
    _ => "Type or paste the code",
  };

  String _fieldHint(BuildContext context) => switch (context.languageCode) {
    "es" => "Como ABCDE12345",
    "pt" => "Como ABCDE12345",
    _ => "Like ABCDE12345",
  };

  String _pasteLabel(BuildContext context) => switch (context.languageCode) {
    "es" => "Pegar",
    "pt" => "Colar",
    _ => "Paste",
  };

  String _searchLabel(BuildContext context) => switch (context.languageCode) {
    "es" => "Buscar código",
    "pt" => "Buscar código",
    _ => "Search code",
  };
}

class _FoundUserSection extends StatelessWidget {
  const _FoundUserSection({
    required this.profile,
    required this.isSent,
    required this.onAdd,
  });

  final FriendSuggestionEntity profile;
  final bool isSent;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          const Icon(
            Icons.check_circle_rounded,
            color: Color(0xFF44A75A),
            size: 28,
          ),
          const Gap(8),
          Text(
            _title(context),
            style: context.textStyles.extraBold24.copyWith(
              color: context.colorTokens.textBody,
              fontSize: 18,
            ),
          ),
        ],
      ),
      const Gap(8),
      Container(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        decoration: friendsSurfaceDecoration(context, radius: 18),
        child: Row(
          children: [
            GroupMemberAvatar(
              name: profile.name,
              colorValue: profile.colorValue,
              size: 52,
            ),
            const Gap(12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textStyles.extraBold24.copyWith(
                      color: context.colorTokens.textBody,
                      fontSize: 18,
                    ),
                  ),
                  const Gap(2),
                  Text(
                    profile.handle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textStyles.bodyMedium.copyWith(
                      color: context.colorTokens.textHint,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Gap(6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5F4E8),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.check_circle_outline_rounded,
                          color: Color(0xFF3D8B4D),
                          size: 16,
                        ),
                        const Gap(5),
                        Text(
                          _foundByCode(context),
                          style: context.textStyles.bodySmall.copyWith(
                            color: const Color(0xFF3D8B4D),
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Gap(10),
            isSent
                ? FriendSentChip(label: _sentLabel(context))
                : FriendAddButton(label: _addLabel(context), onTap: onAdd),
          ],
        ),
      ),
    ],
  );

  String _title(BuildContext context) => switch (context.languageCode) {
    "es" => "Usuario encontrado",
    "pt" => "Usuário encontrado",
    _ => "User found",
  };

  String _foundByCode(BuildContext context) => switch (context.languageCode) {
    "es" => "Encontrado por código",
    "pt" => "Encontrado pelo código",
    _ => "Found by code",
  };

  String _addLabel(BuildContext context) => switch (context.languageCode) {
    "es" => "Agregar",
    "pt" => "Adicionar",
    _ => "Add",
  };

  String _sentLabel(BuildContext context) => switch (context.languageCode) {
    "es" => "Enviado",
    "pt" => "Enviado",
    _ => "Sent",
  };
}

class _CodeNotFoundCard extends StatelessWidget {
  const _CodeNotFoundCard({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: friendsSurfaceDecoration(context, radius: 18),
    child: Text(
      text,
      textAlign: TextAlign.center,
      style: context.textStyles.bodyMedium.copyWith(
        color: context.colorTokens.textHint,
      ),
    ),
  );
}

class _HowItWorksCard extends StatefulWidget {
  const _HowItWorksCard();

  @override
  State<_HowItWorksCard> createState() => _HowItWorksCardState();
}

class _HowItWorksCardState extends State<_HowItWorksCard> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) => BounceTap(
    onTap: () => setState(() => isExpanded = !isExpanded),
    pressedScale: 0.98,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.all(14),
      decoration: friendsSurfaceDecoration(context, radius: 16),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline_rounded,
                color: context.colorTokens.primary,
                size: 20,
              ),
              const Gap(10),
              Expanded(
                child: Text(
                  _title(context),
                  style: context.textStyles.bodyMedium.copyWith(
                    color: context.colorTokens.textHint,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              AnimatedRotation(
                turns: isExpanded ? 0.5 : 0,
                duration: const Duration(milliseconds: 180),
                child: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: context.colorTokens.textHint,
                ),
              ),
            ],
          ),
          if (isExpanded) ...[
            const Gap(12),
            _HowStep(
              icon: Icons.chat_bubble_outline_rounded,
              text: _stepOne(context),
              isLast: false,
            ),
            _HowStep(
              icon: Icons.content_paste_rounded,
              text: _stepTwo(context),
              isLast: false,
            ),
            _HowStep(
              icon: Icons.person_add_alt_1_rounded,
              text: _stepThree(context),
              isLast: true,
            ),
          ],
        ],
      ),
    ),
  );

  String _title(BuildContext context) => switch (context.languageCode) {
    "es" => "Cómo funciona",
    "pt" => "Como funciona",
    _ => "How it works",
  };

  String _stepOne(BuildContext context) => switch (context.languageCode) {
    "es" => "Pide el código a tu amigo",
    "pt" => "Peça o código ao seu amigo",
    _ => "Ask your friend for their code",
  };

  String _stepTwo(BuildContext context) => switch (context.languageCode) {
    "es" => "Pega el código para encontrar el perfil",
    "pt" => "Cole o código para encontrar o perfil",
    _ => "Paste the code to find the profile",
  };

  String _stepThree(BuildContext context) => switch (context.languageCode) {
    "es" => "Envía la solicitud para agregar",
    "pt" => "Envie a solicitação para adicionar",
    _ => "Send the request to add them",
  };
}

class _HowStep extends StatelessWidget {
  const _HowStep({
    required this.icon,
    required this.text,
    required this.isLast,
  });

  final IconData icon;
  final String text;
  final bool isLast;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Row(
        children: [
          SizedBox(
            width: 42,
            child: Icon(icon, color: context.colorTokens.primary, size: 22),
          ),
          const Gap(10),
          Expanded(
            child: Text(
              text,
              style: context.textStyles.bodyMedium.copyWith(
                color: context.colorTokens.textBody,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      if (!isLast)
        Divider(height: 16, indent: 50, color: context.colorTokens.divider),
    ],
  );
}
