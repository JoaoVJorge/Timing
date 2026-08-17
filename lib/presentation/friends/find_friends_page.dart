import "dart:async";

import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:gap/gap.dart";
import "package:get/get.dart";
import "package:timing/core/domain/entities/friend_suggestion_entity.dart";
import "package:timing/core/utils/extensions/context_extensions.dart";
import "package:timing/presentation/friends/friends_controller.dart";
import "package:timing/presentation/friends/widgets/friends_shared.dart";
import "package:timing/presentation/groups/widgets/group_member_avatar.dart";
import "package:timing/shared/widgets/app_scaffold.dart";
import "package:timing/shared/widgets/app_top_bar.dart";
import "package:timing/shared/widgets/bounce_tap.dart";

class FindFriendsPage extends StatefulWidget {
  const FindFriendsPage({super.key});

  @override
  State<FindFriendsPage> createState() => _FindFriendsPageState();
}

class _FindFriendsPageState extends State<FindFriendsPage> {
  static const Duration _searchDebounceDuration = Duration(milliseconds: 550);

  final TextEditingController codeController = TextEditingController();
  final FriendsController controller = Get.find();
  Timer? _searchDebounce;

  @override
  void dispose() {
    _searchDebounce?.cancel();
    codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AppScaffold(
    topBar: AppTopBar(
      title: context.l10n.addFriendTitle,
      showBackButton: true,
      onBack: () => Navigator.of(context).maybePop(),
    ),
    body: ListView(
      padding: const EdgeInsets.only(bottom: 14),
      children: [
        _InviteLookupCard(
          controller: codeController,
          isSearching: controller.isSearching,
          onPaste: _pasteCode,
          onChanged: _scheduleSearch,
          onSearch: _searchNow,
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
                _CodeNotFoundCard(text: context.l10n.friendCodeNotFound),
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
    _scheduleSearch(codeController.text);
  }

  void _scheduleSearch(String code) {
    _searchDebounce?.cancel();
    if (code.trim().replaceAll("@", "").isEmpty) {
      controller.resetSearch();
      return;
    }
    _searchDebounce = Timer(
      _searchDebounceDuration,
      () => controller.findByCode(code),
    );
  }

  void _searchNow() {
    _searchDebounce?.cancel();
    controller.findByCode(codeController.text);
  }
}

class _InviteLookupCard extends StatelessWidget {
  const _InviteLookupCard({
    required this.controller,
    required this.isSearching,
    required this.onPaste,
    required this.onChanged,
    required this.onSearch,
  });

  final TextEditingController controller;
  final RxBool isSearching;
  final VoidCallback onPaste;
  final ValueChanged<String> onChanged;
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
                context.l10n.friendInviteCodeTitle,
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
          context.l10n.friendInviteCodeFieldLabel,
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
                  onChanged: onChanged,
                  style: context.textStyles.black32.copyWith(
                    color: context.colorTokens.textBody,
                    fontSize: 17,
                    letterSpacing: 0.8,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: context.l10n.friendInviteCodeFieldHint,
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
                        context.l10n.pasteButton,
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
        Obx(
          () => FriendWidePrimaryButton(
            label: context.l10n.searchCodeButton,
            isLoading: isSearching.value,
            onTap: onSearch,
            icon: Icons.search_rounded,
          ),
        ),
      ],
    ),
  );
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
  Widget build(BuildContext context) {
    final Widget action = isSent
        ? FriendSentChip(label: context.l10n.sentLabel)
        : FriendAddButton(label: context.l10n.addButton, onTap: onAdd);

    return Column(
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
            Expanded(
              child: Text(
                context.l10n.friendUserFoundTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textStyles.extraBold24.copyWith(
                  color: context.colorTokens.textBody,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        const Gap(8),
        Container(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          decoration: friendsSurfaceDecoration(context, radius: 18),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final bool isCompact = constraints.maxWidth < 330;

              return Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GroupMemberAvatar(
                        name: profile.name,
                        colorValue: profile.colorValue,
                        size: 52,
                      ),
                      const Gap(12),
                      Expanded(child: _FoundUserInfo(profile: profile)),
                      if (!isCompact) ...[const Gap(10), action],
                    ],
                  ),
                  if (isCompact) ...[
                    const Gap(12),
                    Align(alignment: Alignment.centerRight, child: action),
                  ],
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _FoundUserInfo extends StatelessWidget {
  const _FoundUserInfo({required this.profile});

  final FriendSuggestionEntity profile;

  @override
  Widget build(BuildContext context) => Column(
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
      Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
              Flexible(
                child: Text(
                  context.l10n.friendFoundByCode,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textStyles.bodySmall.copyWith(
                    color: const Color(0xFF3D8B4D),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
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
                  context.l10n.friendHowItWorksTitle,
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
              text: context.l10n.friendHowItWorksStepOne,
              isLast: false,
            ),
            _HowStep(
              icon: Icons.content_paste_rounded,
              text: context.l10n.friendHowItWorksStepTwo,
              isLast: false,
            ),
            _HowStep(
              icon: Icons.person_add_alt_1_rounded,
              text: context.l10n.friendHowItWorksStepThree,
              isLast: true,
            ),
          ],
        ],
      ),
    ),
  );
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
