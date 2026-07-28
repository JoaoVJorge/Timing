import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:gap/gap.dart";
import "package:get/get.dart";
import "package:help_out/app/app_navigator.dart";
import "package:help_out/core/services/supabase/supabase_service.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/presentation/groups/widgets/group_member_avatar.dart";
import "package:help_out/shared/widgets/app_scaffold.dart";
import "package:help_out/shared/widgets/bounce_tap.dart";
import "package:share_plus/share_plus.dart";

class FriendsPage extends StatefulWidget {
  const FriendsPage({super.key});

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  final TextEditingController searchController = TextEditingController();
  final SupabaseService supabaseService = Get.find();

  final List<_FriendProfile> requests = [];
  final List<_FriendProfile> friends = [];
  String inviteCode = "";
  String query = "";
  bool isLoading = true;

  List<_FriendProfile> get filteredFriends {
    final String normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) {
      return friends;
    }
    return friends
        .where(
          (friend) =>
              friend.name.toLowerCase().contains(normalizedQuery) ||
              friend.handle.toLowerCase().contains(normalizedQuery),
        )
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _loadFriends();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AppScaffold(
    body: SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.only(top: 16, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _BackButton(onTap: () => Navigator.of(context).maybePop()),
          const Gap(20),
          Text(
            _title(context),
            style: context.textStyles.black32.copyWith(fontSize: 32),
          ),
          const Gap(2),
          Text(
            _subtitle(context),
            style: context.textStyles.bodyMedium.copyWith(
              color: context.colorTokens.textHint,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Gap(18),
          _SearchField(
            controller: searchController,
            hint: _searchHint(context),
            onChanged: (value) => setState(() => query = value),
          ),
          const Gap(18),
          _InviteCodeCard(
            code: inviteCode.isEmpty ? "..." : inviteCode,
            onCopy: () => _copyInviteCode(context),
            onShare: () => _shareInviteCode(context),
          ),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(child: CircularProgressIndicator()),
            )
          else ...[
            if (query.trim().isEmpty) ...[
              const Gap(22),
              _RequestsSection(
                requests: requests,
                onDecline: _removeRequest,
                onAccept: _acceptRequest,
              ),
            ],
            const Gap(22),
            _FriendsSection(
              friends: filteredFriends,
              totalFriends: friends.length,
            ),
          ],
          const Gap(20),
          _TipPill(text: _tip(context)),
        ],
      ),
    ),
  );

  Future<void> _loadFriends() async {
    final String? userId = supabaseService.currentUserId;
    if (userId == null) {
      setState(() => isLoading = false);
      return;
    }

    try {
      final Map<String, dynamic>? profileRow = await supabaseService
          .requireClient
          .from("profiles")
          .select("friend_code")
          .eq("id", userId)
          .maybeSingle();
      final List<Map<String, dynamic>> requestRows = await _selectRows(
        table: "friendships",
        filters: (query) =>
            query.eq("addressee_id", userId).eq("status", "pending"),
      );
      final List<Map<String, dynamic>> friendRows = await _selectRows(
        table: "friendships",
        filters: (query) => query
            .eq("status", "accepted")
            .or("requester_id.eq.$userId,addressee_id.eq.$userId"),
      );
      final Set<String> profileIds = {
        for (final Map<String, dynamic> row in requestRows)
          row["requester_id"] as String,
        for (final Map<String, dynamic> row in friendRows)
          row["requester_id"] == userId
              ? row["addressee_id"] as String
              : row["requester_id"] as String,
      };
      final Map<String, Map<String, dynamic>> profilesById =
          await _profilesById(profileIds.toList());

      if (!mounted) {
        return;
      }
      setState(() {
        inviteCode =
            profileRow?["friend_code"] as String? ??
            userId.substring(0, 8).toUpperCase();
        requests
          ..clear()
          ..addAll(
            requestRows.map((row) {
              final String requesterId = row["requester_id"] as String;
              return _friendFromRow(
                userId: requesterId,
                friendshipId: row["id"] as String,
                profileRow: profilesById[requesterId],
              );
            }),
          );
        friends
          ..clear()
          ..addAll(
            friendRows.map((row) {
              final String friendId = row["requester_id"] == userId
                  ? row["addressee_id"] as String
                  : row["requester_id"] as String;
              return _friendFromRow(
                userId: friendId,
                friendshipId: row["id"] as String,
                profileRow: profilesById[friendId],
              );
            }),
          );
        isLoading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() => isLoading = false);
      appNavigator.showErrorSnackBar();
    }
  }

  Future<void> _removeRequest(_FriendProfile profile) async {
    await supabaseService.requireClient
        .from("friendships")
        .delete()
        .eq("id", profile.friendshipId);
    setState(() => requests.remove(profile));
  }

  Future<void> _acceptRequest(_FriendProfile profile) async {
    await supabaseService.requireClient
        .from("friendships")
        .update({"status": "accepted"})
        .eq("id", profile.friendshipId);
    setState(() {
      requests.remove(profile);
      if (!friends.any((friend) => friend.id == profile.id)) {
        friends.insert(0, profile);
      }
    });
  }

  Future<void> _copyInviteCode(BuildContext context) async {
    final String message = _copied(context);
    await Clipboard.setData(ClipboardData(text: inviteCode));
    appNavigator.showSuccessSnackBar(message);
  }

  Future<void> _shareInviteCode(BuildContext context) async {
    await SharePlus.instance.share(
      ShareParams(text: _shareText(context, inviteCode)),
    );
  }

  Future<List<Map<String, dynamic>>> _selectRows({
    required String table,
    required dynamic Function(dynamic query) filters,
  }) async {
    final dynamic response = await filters(
      supabaseService.requireClient.from(table).select(),
    );
    return (response as List<dynamic>)
        .map((row) => Map<String, dynamic>.from(row as Map))
        .toList();
  }

  Future<Map<String, Map<String, dynamic>>> _profilesById(
    List<String> ids,
  ) async {
    if (ids.isEmpty) {
      return const {};
    }
    final List<Map<String, dynamic>> rows = await _selectRows(
      table: "profiles",
      filters: (query) => query.inFilter("id", ids),
    );
    return {for (final Map<String, dynamic> row in rows) row["id"]: row};
  }

  _FriendProfile _friendFromRow({
    required String userId,
    required String friendshipId,
    required Map<String, dynamic>? profileRow,
  }) {
    final String nickName = profileRow?["nick_name"] as String? ?? "";
    final String userName = profileRow?["user_name"] as String? ?? "";
    final String name = nickName.trim().isNotEmpty
        ? nickName.trim()
        : userName.trim().isNotEmpty
        ? userName.trim()
        : "User";
    return _FriendProfile(
      id: userId,
      friendshipId: friendshipId,
      name: name,
      handle:
          "@${(profileRow?["friend_code"] as String? ?? userId.substring(0, 8)).toLowerCase()}",
      colorValue:
          (profileRow?["accent_color_value"] as num?)?.toInt() ?? 0xFFFFC107,
    );
  }

  static String _title(BuildContext context) => switch (context.languageCode) {
    "es" => "Amigos",
    "pt" => "Amigos",
    _ => "Friends",
  };

  static String _subtitle(BuildContext context) =>
      switch (context.languageCode) {
        "es" => "Gestiona tus conexiones e invitaciones",
        "pt" => "Gerencie suas conexões e convites",
        _ => "Manage your connections and invites",
      };

  static String _searchHint(BuildContext context) =>
      switch (context.languageCode) {
        "es" => "Buscar por nombre o @usuario",
        "pt" => "Buscar por nome ou @usuário",
        _ => "Search by name or @username",
      };

  static String _copied(BuildContext context) => switch (context.languageCode) {
    "es" => "Código copiado",
    "pt" => "Código copiado",
    _ => "Code copied",
  };

  static String _shareText(BuildContext context, String code) =>
      switch (context.languageCode) {
        "es" => "Agrégame en HelpOut con mi código: $code",
        "pt" => "Me adicione no HelpOut com meu código: $code",
        _ => "Add me on HelpOut with my code: $code",
      };

  static String _tip(BuildContext context) => switch (context.languageCode) {
    "es" => "Tip: agrega amigos para crear grupos y seguir el progreso",
    "pt" => "Dica: adicione amigos para criar grupos e acompanhar progresso",
    _ => "Tip: add friends to create groups and track progress",
  };
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => BounceTap(
    onTap: onTap,
    child: Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: context.colorTokens.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: context.colorTokens.borderUnfocused.withValues(alpha: 0.45),
        ),
      ),
      child: Icon(
        Icons.arrow_back_rounded,
        color: context.colorTokens.textBody,
        size: 22,
      ),
    ),
  );
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.hint,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) => Container(
    height: 50,
    padding: const EdgeInsets.symmetric(horizontal: 14),
    decoration: _cardDecoration(
      context,
    ).copyWith(borderRadius: BorderRadius.circular(18)),
    child: Row(
      children: [
        Icon(
          Icons.search_rounded,
          color: context.colorTokens.textHint,
          size: 23,
        ),
        const Gap(10),
        Expanded(
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            textInputAction: TextInputAction.search,
            style: context.textStyles.bodyMedium.copyWith(
              color: context.colorTokens.textBody,
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hint,
              hintStyle: context.textStyles.bodyMedium.copyWith(
                color: context.colorTokens.textHint,
                fontWeight: FontWeight.w600,
              ),
              isDense: true,
            ),
          ),
        ),
      ],
    ),
  );
}

class _InviteCodeCard extends StatelessWidget {
  const _InviteCodeCard({
    required this.code,
    required this.onCopy,
    required this.onShare,
  });

  final String code;
  final VoidCallback onCopy;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: context.colorTokens.surface,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(
        color: context.colorTokens.primary.withValues(alpha: 0.14),
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: context.colorTokens.primaryVeryLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.qr_code_rounded,
                color: context.colorTokens.primary,
                size: 25,
              ),
            ),
            const Gap(12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _inviteLabel(context),
                    style: context.textStyles.bodySmall.copyWith(
                      color: context.colorTokens.textHint,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Gap(2),
                  Text(
                    code,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textStyles.black20.copyWith(
                      color: context.colorTokens.primary,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const Gap(12),
        Row(
          children: [
            Expanded(
              child: _InviteAction(
                icon: Icons.copy_rounded,
                label: _copyLabel(context),
                onTap: onCopy,
              ),
            ),
            const Gap(10),
            Expanded(
              child: _InviteAction(
                icon: Icons.ios_share_rounded,
                label: _shareLabel(context),
                onTap: onShare,
              ),
            ),
          ],
        ),
      ],
    ),
  );

  String _inviteLabel(BuildContext context) => switch (context.languageCode) {
    "es" => "Tu código de invitación",
    "pt" => "Seu código de convite",
    _ => "Your invite code",
  };

  String _copyLabel(BuildContext context) => switch (context.languageCode) {
    "es" => "Copiar",
    "pt" => "Copiar",
    _ => "Copy",
  };

  String _shareLabel(BuildContext context) => switch (context.languageCode) {
    "es" => "Compartir",
    "pt" => "Compartilhar",
    _ => "Share",
  };
}

class _InviteAction extends StatelessWidget {
  const _InviteAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => BounceTap(
    pressedScale: 0.96,
    onTap: onTap,
    child: Container(
      height: 38,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: context.colorTokens.primary,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 19, color: context.colorTokens.primaryForeground),
          const Gap(6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textStyles.bodySmall.copyWith(
                color: context.colorTokens.primaryForeground,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _RequestsSection extends StatelessWidget {
  const _RequestsSection({
    required this.requests,
    required this.onDecline,
    required this.onAccept,
  });

  final List<_FriendProfile> requests;
  final ValueChanged<_FriendProfile> onDecline;
  final ValueChanged<_FriendProfile> onAccept;

  @override
  Widget build(BuildContext context) {
    if (requests.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(_title(context), style: context.textStyles.extraBold20),
            const Gap(8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
              decoration: BoxDecoration(
                color: context.colorTokens.primaryVeryLight,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                "${requests.length}",
                style: context.textStyles.bodySmall.copyWith(
                  color: context.colorTokens.primary,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
        const Gap(10),
        for (final _FriendProfile request in requests) ...[
          _RequestCard(
            profile: request,
            onDecline: () => onDecline(request),
            onAccept: () => onAccept(request),
          ),
          if (request != requests.last) const Gap(8),
        ],
      ],
    );
  }

  String _title(BuildContext context) => switch (context.languageCode) {
    "es" => "Solicitudes",
    "pt" => "Solicitações",
    _ => "Requests",
  };
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({
    required this.profile,
    required this.onDecline,
    required this.onAccept,
  });

  final _FriendProfile profile;
  final VoidCallback onDecline;
  final VoidCallback onAccept;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
    decoration: _cardDecoration(
      context,
    ).copyWith(borderRadius: BorderRadius.circular(18)),
    child: Row(
      children: [
        GroupMemberAvatar(
          name: profile.name,
          colorValue: profile.colorValue,
          size: 42,
        ),
        const Gap(10),
        Expanded(child: _FriendTexts(profile: profile)),
        const Gap(8),
        _OutlineAction(label: _declineLabel(context), onTap: onDecline),
        const Gap(6),
        _PrimaryAction(label: _acceptLabel(context), onTap: onAccept),
      ],
    ),
  );

  String _declineLabel(BuildContext context) => switch (context.languageCode) {
    "es" => "Rechazar",
    "pt" => "Recusar",
    _ => "Decline",
  };

  String _acceptLabel(BuildContext context) => switch (context.languageCode) {
    "es" => "Aceptar",
    "pt" => "Aceitar",
    _ => "Accept",
  };
}

class _FriendsSection extends StatelessWidget {
  const _FriendsSection({required this.friends, required this.totalFriends});

  final List<_FriendProfile> friends;
  final int totalFriends;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Expanded(
            child: Text(_title(context), style: context.textStyles.extraBold20),
          ),
          Text(
            _totalLabel(context, totalFriends),
            style: context.textStyles.bodyMedium.copyWith(
              color: context.colorTokens.textHint,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      const Gap(10),
      if (friends.isEmpty)
        _EmptySearchCard(text: _emptySearch(context))
      else
        Container(
          decoration: _cardDecoration(
            context,
          ).copyWith(borderRadius: BorderRadius.circular(18)),
          child: Column(
            children: [
              for (int index = 0; index < friends.length; index++) ...[
                _FriendRow(profile: friends[index]),
                if (index < friends.length - 1)
                  Divider(
                    height: 1,
                    indent: 64,
                    endIndent: 18,
                    color: context.colorTokens.divider,
                  ),
              ],
            ],
          ),
        ),
    ],
  );

  String _title(BuildContext context) => switch (context.languageCode) {
    "es" => "Tus amigos",
    "pt" => "Seus amigos",
    _ => "Your friends",
  };

  String _totalLabel(BuildContext context, int count) =>
      switch (context.languageCode) {
        "es" => "$count amigos",
        "pt" => "$count amigos",
        _ => "$count friends",
      };

  String _emptySearch(BuildContext context) => switch (context.languageCode) {
    "es" => "Ningún amigo encontrado",
    "pt" => "Nenhum amigo encontrado",
    _ => "No friends found",
  };
}

class _FriendRow extends StatelessWidget {
  const _FriendRow({required this.profile});

  final _FriendProfile profile;

  @override
  Widget build(BuildContext context) => BounceTap(
    pressedScale: 0.98,
    onTap: () {},
    child: Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Row(
        children: [
          GroupMemberAvatar(
            name: profile.name,
            colorValue: profile.colorValue,
            size: 42,
          ),
          const Gap(10),
          Expanded(child: _FriendTexts(profile: profile)),
          Icon(
            Icons.chevron_right_rounded,
            size: 26,
            color: context.colorTokens.textHint,
          ),
        ],
      ),
    ),
  );
}

class _FriendTexts extends StatelessWidget {
  const _FriendTexts({required this.profile});

  final _FriendProfile profile;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        profile.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: context.textStyles.bodyMedium.copyWith(
          color: context.colorTokens.textBody,
          fontWeight: FontWeight.w900,
        ),
      ),
      const Gap(1),
      Text(
        profile.handle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: context.textStyles.bodySmall.copyWith(
          color: context.colorTokens.textHint,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );
}

class _OutlineAction extends StatelessWidget {
  const _OutlineAction({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => BounceTap(
    pressedScale: 0.96,
    onTap: onTap,
    child: Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: context.colorTokens.surface,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: context.colorTokens.borderUnfocused),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: context.textStyles.bodySmall.copyWith(
          color: context.colorTokens.textHint,
          fontWeight: FontWeight.w900,
        ),
      ),
    ),
  );
}

class _PrimaryAction extends StatelessWidget {
  const _PrimaryAction({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => BounceTap(
    pressedScale: 0.96,
    onTap: onTap,
    child: Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: context.colorTokens.primaryGradient,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: context.textStyles.textPrimaryButton.copyWith(fontSize: 12),
      ),
    ),
  );
}

class _TipPill extends StatelessWidget {
  const _TipPill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Center(
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: context.colorTokens.surface.withValues(alpha: 0.80),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: context.colorTokens.borderUnfocused.withValues(alpha: 0.60),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.auto_awesome_rounded,
            size: 16,
            color: context.colorTokens.primary,
          ),
          const Gap(7),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textStyles.bodySmall.copyWith(
                color: context.colorTokens.textHint,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _EmptySearchCard extends StatelessWidget {
  const _EmptySearchCard({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(18),
    decoration: _cardDecoration(
      context,
    ).copyWith(borderRadius: BorderRadius.circular(18)),
    alignment: Alignment.center,
    child: Text(
      text,
      style: context.textStyles.bodyMedium.copyWith(
        color: context.colorTokens.textHint,
      ),
    ),
  );
}

class _FriendProfile {
  const _FriendProfile({
    required this.id,
    required this.friendshipId,
    required this.name,
    required this.handle,
    required this.colorValue,
  });

  final String id;
  final String friendshipId;
  final String name;
  final String handle;
  final int colorValue;
}

BoxDecoration _cardDecoration(BuildContext context) => BoxDecoration(
  color: context.colorTokens.surface,
  borderRadius: BorderRadius.circular(18),
  border: Border.all(
    color: context.colorTokens.borderUnfocused.withValues(alpha: 0.55),
  ),
);
