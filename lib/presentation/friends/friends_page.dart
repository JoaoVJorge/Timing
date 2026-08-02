import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:gap/gap.dart";
import "package:get/get.dart";
import "package:help_out/app/app_navigator.dart";
import "package:help_out/core/services/supabase/supabase_service.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/presentation/groups/widgets/group_member_avatar.dart";
import "package:help_out/shared/widgets/app_scaffold.dart";
import "package:help_out/shared/widgets/app_top_bar.dart";
import "package:help_out/shared/widgets/bounce_tap.dart";
import "package:share_plus/share_plus.dart";

const Color _socialText = Color(0xFF1F2329);
const Color _socialMuted = Color(0xFF7A7E87);
const Color _socialBorder = Color(0xFFE7E7E7);

class FriendsPage extends StatefulWidget {
  const FriendsPage({super.key});

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  final TextEditingController searchController = TextEditingController();
  final SupabaseService supabaseService = Get.find();

  final List<_FriendProfile> requests = [];
  final List<_FriendProfile> sentRequests = [];
  final List<_FriendProfile> friends = [];
  final Set<String> sentRequestIds = {};
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
    _loadSocial();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AppScaffold(
    backgroundColor: context.colorTokens.scaffold,
    body: RefreshIndicator(
      color: context.colorTokens.primary,
      onRefresh: _loadSocial,
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: 18, bottom: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(onInviteTap: _openAddFriendPage),
            const Gap(12),
            _SearchField(
              controller: searchController,
              hint: _searchHint(context),
              onChanged: (value) => setState(() => query = value),
            ),
            const Gap(14),
            _InviteCodeCard(
              code: inviteCode.isEmpty ? "..." : inviteCode,
              onCopy: () => _copyInviteCode(context),
              onShare: () => _shareInviteCode(context),
            ),
            if (isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(child: CircularProgressIndicator()),
              )
            else ...[
              const Gap(14),
              _ActivityShortcuts(
                onPendingTap: _openPendingRequestsPage,
                onSentTap: _openSentRequestsPage,
              ),
              const Gap(18),
              _FriendsSection(
                friends: filteredFriends,
                totalFriends: friends.length,
                query: query,
                onShare: () => _shareInviteCode(context),
              ),
            ],
          ],
        ),
      ),
    ),
  );

  Future<void> _loadSocial() async {
    final String? userId = supabaseService.currentUserId;
    if (userId == null) {
      setState(() {
        isLoading = false;
        inviteCode = "";
      });
      return;
    }

    setState(() => isLoading = true);

    try {
      final Map<String, dynamic>? profileRow = await supabaseService
          .requireClient
          .from("profiles")
          .select("friend_code")
          .eq("id", userId)
          .maybeSingle();
      final List<Map<String, dynamic>> incomingRows = await _selectRows(
        table: "friendships",
        filters: (query) =>
            query.eq("addressee_id", userId).eq("status", "pending"),
      );
      final List<Map<String, dynamic>> outgoingRows = await _selectRows(
        table: "friendships",
        filters: (query) =>
            query.eq("requester_id", userId).eq("status", "pending"),
      );
      final List<Map<String, dynamic>> friendRows = await _selectRows(
        table: "friendships",
        filters: (query) => query
            .eq("status", "accepted")
            .or("requester_id.eq.$userId,addressee_id.eq.$userId"),
      );
      final Set<String> profileIds = {
        for (final Map<String, dynamic> row in incomingRows)
          row["requester_id"] as String,
        for (final Map<String, dynamic> row in outgoingRows)
          row["addressee_id"] as String,
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
            incomingRows.map((row) {
              final String requesterId = row["requester_id"] as String;
              return _friendFromRow(
                userId: requesterId,
                friendshipId: row["id"] as String,
                profileRow: profilesById[requesterId],
              );
            }),
          );
        sentRequestIds
          ..clear()
          ..addAll(outgoingRows.map((row) => row["addressee_id"] as String));
        sentRequests
          ..clear()
          ..addAll(
            outgoingRows.map((row) {
              final String addresseeId = row["addressee_id"] as String;
              return _friendFromRow(
                userId: addresseeId,
                friendshipId: row["id"] as String,
                profileRow: profilesById[addresseeId],
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

  Future<void> _sendFriendRequest(_FriendSuggestion profile) async {
    final String? userId = supabaseService.currentUserId;
    if (userId == null || sentRequestIds.contains(profile.id)) {
      return;
    }
    final String successMessage = _requestSent(context);

    try {
      await supabaseService.requireClient.from("friendships").insert({
        "requester_id": userId,
        "addressee_id": profile.id,
        "status": "pending",
      });
      if (!mounted) {
        return;
      }
      setState(() {
        sentRequestIds.add(profile.id);
        sentRequests.add(
          _FriendProfile(
            id: profile.id,
            friendshipId: "",
            name: profile.name,
            handle: profile.handle,
            colorValue: profile.colorValue,
          ),
        );
      });
      appNavigator.showSuccessSnackBar(successMessage);
    } catch (_) {
      appNavigator.showErrorSnackBar();
    }
  }

  Future<void> _acceptRequest(_FriendProfile profile) async {
    try {
      await supabaseService.requireClient
          .from("friendships")
          .update({"status": "accepted"})
          .eq("id", profile.friendshipId);
      if (!mounted) {
        return;
      }
      setState(() {
        requests.removeWhere((request) => request.id == profile.id);
        if (!friends.any((friend) => friend.id == profile.id)) {
          friends.insert(0, profile);
        }
      });
    } catch (_) {
      appNavigator.showErrorSnackBar();
    }
  }

  Future<void> _declineRequest(_FriendProfile profile) async {
    try {
      await supabaseService.requireClient
          .from("friendships")
          .delete()
          .eq("id", profile.friendshipId);
      if (!mounted) {
        return;
      }
      setState(() {
        requests.removeWhere((request) => request.id == profile.id);
      });
    } catch (_) {
      appNavigator.showErrorSnackBar();
    }
  }

  Future<void> _cancelSentRequest(_FriendProfile profile) async {
    try {
      if (profile.friendshipId.isNotEmpty) {
        await supabaseService.requireClient
            .from("friendships")
            .delete()
            .eq("id", profile.friendshipId);
      } else {
        final String? userId = supabaseService.currentUserId;
        if (userId != null) {
          await supabaseService.requireClient
              .from("friendships")
              .delete()
              .eq("requester_id", userId)
              .eq("addressee_id", profile.id)
              .eq("status", "pending");
        }
      }
      if (!mounted) {
        return;
      }
      setState(() {
        sentRequestIds.remove(profile.id);
        sentRequests.removeWhere((request) => request.id == profile.id);
      });
    } catch (_) {
      appNavigator.showErrorSnackBar();
    }
  }

  Future<void> _openAddFriendPage() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => _FindFriendsPage(
          sentRequestIds: sentRequestIds,
          onSendRequest: _sendFriendRequest,
        ),
      ),
    );
    await _loadSocial();
  }

  Future<void> _openPendingRequestsPage() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => _FriendRequestsPage(
          title: _pendingPageTitle(context),
          initialMode: _FriendRequestsMode.incoming,
          incomingRequests: requests,
          sentRequests: sentRequests,
          onAccept: _acceptRequest,
          onDecline: _declineRequest,
          onCancel: _cancelSentRequest,
        ),
      ),
    );
  }

  Future<void> _openSentRequestsPage() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => _FriendRequestsPage(
          title: _sentPageTitle(context),
          initialMode: _FriendRequestsMode.sent,
          incomingRequests: requests,
          sentRequests: sentRequests,
          onAccept: _acceptRequest,
          onDecline: _declineRequest,
          onCancel: _cancelSentRequest,
        ),
      ),
    );
  }

  Future<void> _copyInviteCode(BuildContext context) async {
    if (inviteCode.isEmpty) {
      return;
    }
    final String message = _copied(context);
    await Clipboard.setData(ClipboardData(text: inviteCode));
    appNavigator.showSuccessSnackBar(message);
  }

  Future<void> _shareInviteCode(BuildContext context) async {
    if (inviteCode.isEmpty) {
      return;
    }
    final String text = _shareText(context, inviteCode);
    await SharePlus.instance.share(ShareParams(text: text));
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
    final String name = _profileName(profileRow);
    return _FriendProfile(
      id: userId,
      friendshipId: friendshipId,
      name: name,
      handle:
          "@${(profileRow?["friend_code"] as String? ?? userId.substring(0, 8)).toLowerCase()}",
      colorValue:
          (profileRow?["accent_color_value"] as num?)?.toInt() ??
          context.colorTokens.primary.toARGB32(),
    );
  }

  String _profileName(Map<String, dynamic>? row) {
    final String nickName = row?["nick_name"] as String? ?? "";
    final String userName = row?["user_name"] as String? ?? "";
    if (userName.trim().isNotEmpty) {
      return userName.trim();
    }
    if (nickName.trim().isNotEmpty) {
      return nickName.trim();
    }
    return "HelpOut User";
  }

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

  static String _requestSent(BuildContext context) =>
      switch (context.languageCode) {
        "es" => "Solicitud enviada",
        "pt" => "Solicitação enviada",
        _ => "Request sent",
      };

  static String _pendingPageTitle(BuildContext context) =>
      switch (context.languageCode) {
        "es" => "Solicitudes",
        "pt" => "Solicitações",
        _ => "Requests",
      };

  static String _sentPageTitle(BuildContext context) =>
      switch (context.languageCode) {
        "es" => "Invitaciones",
        "pt" => "Convites",
        _ => "Invites",
      };

  static String _shareText(BuildContext context, String code) =>
      switch (context.languageCode) {
        "es" => "Agrégame en HelpOut con mi código: $code",
        "pt" => "Me adicione no HelpOut com meu código: $code",
        _ => "Add me on HelpOut with my code: $code",
      };
}

class _Header extends StatelessWidget {
  const _Header({required this.onInviteTap});

  final VoidCallback onInviteTap;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _title(context),
              style: context.textStyles.black32.copyWith(
                color: context.colorTokens.primary,
                fontSize: 23,
                height: 1.05,
              ),
            ),
            const Gap(4),
            Text(
              _subtitle(context),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textStyles.bodySmall.copyWith(
                color: _socialMuted,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
      BounceTap(
        onTap: onInviteTap,
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: context.colorTokens.primaryVeryLight,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Icon(
            Icons.person_add_alt_1_rounded,
            color: context.colorTokens.primary,
            size: 23,
          ),
        ),
      ),
    ],
  );

  String _title(BuildContext context) => switch (context.languageCode) {
    "es" => "Amigos",
    "pt" => "Amigos",
    _ => "Friends",
  };

  String _subtitle(BuildContext context) => switch (context.languageCode) {
    "es" => "Gestiona tus conexiones e invitaciones.",
    "pt" => "Gerencie suas conexões e convites.",
    _ => "Manage your connections and invites.",
  };
}

class _FindFriendsPage extends StatefulWidget {
  const _FindFriendsPage({
    required this.sentRequestIds,
    required this.onSendRequest,
  });

  final Set<String> sentRequestIds;
  final Future<void> Function(_FriendSuggestion profile) onSendRequest;

  @override
  State<_FindFriendsPage> createState() => _FindFriendsPageState();
}

class _FindFriendsPageState extends State<_FindFriendsPage> {
  final TextEditingController codeController = TextEditingController();
  final SupabaseService supabaseService = Get.find();
  late final Set<String> sentRequestIds = Set.of(widget.sentRequestIds);
  _FriendSuggestion? foundUser;
  bool isLoading = false;
  bool hasSearched = false;

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
          isLoading: isLoading,
          onPaste: _pasteCode,
          onSearch: _findByCode,
        ),
        if (foundUser != null) ...[
          const Gap(14),
          _FoundUserSection(
            profile: foundUser!,
            isSent: sentRequestIds.contains(foundUser!.id),
            onAdd: () => _send(foundUser!),
          ),
        ] else if (hasSearched && !isLoading) ...[
          const Gap(14),
          _CodeNotFoundCard(text: _notFoundText(context)),
        ],
        const Gap(12),
        _HowItWorksCard(),
      ],
    ),
  );

  String _addFriendTitle(BuildContext context) =>
      switch (context.languageCode) {
        "es" => "Adicionar amigo",
        "pt" => "Adicionar amigo",
        _ => "Add friend",
      };

  Future<void> _pasteCode() async {
    final ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
    final String text = data?.text?.trim() ?? "";
    if (text.isEmpty) {
      return;
    }
    codeController.text = text.toUpperCase();
  }

  Future<void> _findByCode() async {
    final String code = codeController.text.trim().replaceAll("@", "");
    if (code.isEmpty || isLoading) {
      return;
    }
    setState(() {
      isLoading = true;
      hasSearched = true;
      foundUser = null;
    });
    try {
      final dynamic response = await supabaseService.requireClient.rpc(
        "find_profile_by_friend_code",
        params: {"lookup_code": code},
      );
      final List<dynamic> rows = response as List<dynamic>;
      final _FriendSuggestion? profile = rows.isEmpty
          ? null
          : _suggestionFromRow(Map<String, dynamic>.from(rows.first as Map));
      if (!mounted) {
        return;
      }
      setState(() {
        foundUser = profile;
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

  Future<void> _send(_FriendSuggestion profile) async {
    await widget.onSendRequest(profile);
    if (!mounted) {
      return;
    }
    setState(() => sentRequestIds.add(profile.id));
  }

  _FriendSuggestion _suggestionFromRow(Map<String, dynamic> row) {
    final String id = row["id"] as String;
    final String friendCode =
        row["friend_code"] as String? ?? id.substring(0, 8);
    return _FriendSuggestion(
      id: id,
      name: _profileName(row),
      handle: "@${friendCode.toLowerCase()}",
      colorValue:
          (row["accent_color_value"] as num?)?.toInt() ??
          context.colorTokens.primary.toARGB32(),
    );
  }

  String _profileName(Map<String, dynamic>? row) {
    final String userName = row?["user_name"] as String? ?? "";
    final String nickName = row?["nick_name"] as String? ?? "";
    if (userName.trim().isNotEmpty) {
      return userName.trim();
    }
    if (nickName.trim().isNotEmpty) {
      return nickName.trim();
    }
    return "HelpOut User";
  }

  String _notFoundText(BuildContext context) => switch (context.languageCode) {
    "es" => "No encontramos ningún usuario con este código.",
    "pt" => "Não encontramos nenhum usuário com este código.",
    _ => "We could not find a user with this code.",
  };
}

class _InviteLookupCard extends StatelessWidget {
  const _InviteLookupCard({
    required this.controller,
    required this.isLoading,
    required this.onPaste,
    required this.onSearch,
  });

  final TextEditingController controller;
  final bool isLoading;
  final VoidCallback onPaste;
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
    decoration: _surfaceDecoration(radius: 18),
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
            color: _socialMuted,
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
                      color: _socialMuted,
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
        _WidePrimaryButton(
          label: _searchLabel(context),
          isLoading: isLoading,
          onTap: onSearch,
          icon: Icons.search_rounded,
        ),
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
    "es" => "Ej.: HELPOUT42",
    "pt" => "Ex.: HELPOUT42",
    _ => "E.g. HELPOUT42",
  };

  String _pasteLabel(BuildContext context) => switch (context.languageCode) {
    "es" => "Pegar",
    "pt" => "Colar",
    _ => "Paste",
  };

  String uniqueLabel(BuildContext context) => switch (context.languageCode) {
    "es" => "Cada usuario tiene un código único",
    "pt" => "Cada usuário possui um código único",
    _ => "Each user has a unique code",
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

  final _FriendSuggestion profile;
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
        decoration: _surfaceDecoration(radius: 18),
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
                      color: _socialMuted,
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
                ? _SentChip(label: _sentLabel(context))
                : _AddButton(label: _addLabel(context), onTap: onAdd),
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
    decoration: _surfaceDecoration(radius: 18),
    child: Text(
      text,
      textAlign: TextAlign.center,
      style: context.textStyles.bodyMedium.copyWith(color: _socialMuted),
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
      decoration: _surfaceDecoration(radius: 16),
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
                    color: _socialMuted,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              AnimatedRotation(
                turns: isExpanded ? 0.5 : 0,
                duration: const Duration(milliseconds: 180),
                child: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: _socialMuted,
                ),
              ),
            ],
          ),
          if (isExpanded) ...[
            const Gap(12),
            HowStep(
              icon: Icons.chat_bubble_outline_rounded,
              text: stepOne(context),
              isLast: false,
            ),
            HowStep(
              icon: Icons.content_paste_rounded,
              text: stepTwo(context),
              isLast: false,
            ),
            HowStep(
              icon: Icons.person_add_alt_1_rounded,
              text: stepThree(context),
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

  String stepOne(BuildContext context) => switch (context.languageCode) {
    "es" => "Pide el código a tu amigo",
    "pt" => "Peça o código ao seu amigo",
    _ => "Ask your friend for their code",
  };

  String stepTwo(BuildContext context) => switch (context.languageCode) {
    "es" => "Pega el código para encontrar el perfil",
    "pt" => "Cole o código para encontrar o perfil",
    _ => "Paste the code to find the profile",
  };

  String stepThree(BuildContext context) => switch (context.languageCode) {
    "es" => "Envía la solicitud para agregar",
    "pt" => "Envie a solicitação para adicionar",
    _ => "Send the request to add them",
  };
}

class HowStep extends StatelessWidget {
  const HowStep({
    required this.icon,
    required this.text,
    required this.isLast,
    super.key,
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

class _WidePrimaryButton extends StatelessWidget {
  const _WidePrimaryButton({
    required this.label,
    required this.isLoading,
    required this.onTap,
    required this.icon,
  });

  final String label;
  final bool isLoading;
  final VoidCallback onTap;
  final IconData icon;

  @override
  Widget build(BuildContext context) => BounceTap(
    pressedScale: 0.97,
    onTap: isLoading ? () {} : onTap,
    child: Container(
      width: double.infinity,
      height: 46,
      decoration: BoxDecoration(
        gradient: context.colorTokens.primaryGradient,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isLoading)
            const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2.4,
              ),
            )
          else
            Icon(icon, color: Colors.white, size: 21),
          const Gap(8),
          Text(
            label,
            style: context.textStyles.textPrimaryButton.copyWith(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    ),
  );
}

enum _FriendRequestsMode { incoming, sent }

class _FriendRequestsPage extends StatefulWidget {
  const _FriendRequestsPage({
    required this.title,
    required this.initialMode,
    required this.incomingRequests,
    required this.sentRequests,
    this.onAccept,
    this.onDecline,
    this.onCancel,
  });

  final String title;
  final _FriendRequestsMode initialMode;
  final List<_FriendProfile> incomingRequests;
  final List<_FriendProfile> sentRequests;
  final Future<void> Function(_FriendProfile profile)? onAccept;
  final Future<void> Function(_FriendProfile profile)? onDecline;
  final Future<void> Function(_FriendProfile profile)? onCancel;

  @override
  State<_FriendRequestsPage> createState() => _FriendRequestsPageState();
}

class _FriendRequestsPageState extends State<_FriendRequestsPage> {
  late final List<_FriendProfile> incomingRequests = List.of(
    widget.incomingRequests,
  );
  late final List<_FriendProfile> sentRequests = List.of(widget.sentRequests);
  late _FriendRequestsMode selectedMode = widget.initialMode;

  List<_FriendProfile> get currentRequests => switch (selectedMode) {
    _FriendRequestsMode.incoming => incomingRequests,
    _FriendRequestsMode.sent => sentRequests,
  };

  @override
  Widget build(BuildContext context) => AppScaffold(
    topBar: AppTopBar(
      title: widget.title,
      showBackButton: true,
      onBack: () => Navigator.of(context).maybePop(),
    ),
    body: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _RequestsModeTabs(
          selectedMode: selectedMode,
          onSelect: (mode) => setState(() => selectedMode = mode),
        ),
        const Gap(18),
        Text(
          _sectionTitle(context, currentRequests.length),
          style: context.textStyles.bodyMedium.copyWith(
            color: _socialText,
            fontSize: 15,
            fontWeight: FontWeight.w900,
          ),
        ),
        const Gap(10),
        Expanded(
          child: currentRequests.isEmpty
              ? _RequestEmptyState(mode: selectedMode)
              : ListView.separated(
                  itemCount: currentRequests.length,
                  separatorBuilder: (context, index) => const Gap(12),
                  itemBuilder: (context, index) {
                    final _FriendProfile profile = currentRequests[index];
                    return _RequestProfileCard(
                      profile: profile,
                      mode: selectedMode,
                      onAccept: () => _runAction(profile, widget.onAccept),
                      onDecline: () => _runAction(profile, widget.onDecline),
                      onCancel: () => _runAction(profile, widget.onCancel),
                    );
                  },
                ),
        ),
        if (selectedMode == _FriendRequestsMode.incoming) ...[
          const Gap(12),
          _SafetyNotice(),
        ],
      ],
    ),
  );

  Future<void> _runAction(
    _FriendProfile profile,
    Future<void> Function(_FriendProfile profile)? action,
  ) async {
    if (action == null) {
      return;
    }
    await action(profile);
    if (!mounted) {
      return;
    }
    setState(() {
      incomingRequests.removeWhere((item) => item.id == profile.id);
      sentRequests.removeWhere((item) => item.id == profile.id);
    });
  }

  String _sectionTitle(BuildContext context, int count) {
    final String label = switch (selectedMode) {
      _FriendRequestsMode.incoming => switch (context.languageCode) {
        "es" => "Recibidas",
        "pt" => "Recebidas",
        _ => "Received",
      },
      _FriendRequestsMode.sent => switch (context.languageCode) {
        "es" => "Enviadas",
        "pt" => "Enviadas",
        _ => "Sent",
      },
    };
    return "$label ($count)";
  }

  String acceptLabel(BuildContext context) => switch (context.languageCode) {
    "es" => "Aceptar",
    "pt" => "Aceitar",
    _ => "Accept",
  };

  String declineLabel(BuildContext context) => switch (context.languageCode) {
    "es" => "Negar",
    "pt" => "Negar",
    _ => "Decline",
  };

  String cancelLabel(BuildContext context) => switch (context.languageCode) {
    "es" => "Cancelar",
    "pt" => "Cancelar",
    _ => "Cancel",
  };
}

class _RequestsModeTabs extends StatelessWidget {
  const _RequestsModeTabs({required this.selectedMode, required this.onSelect});

  final _FriendRequestsMode selectedMode;
  final ValueChanged<_FriendRequestsMode> onSelect;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: _RequestModeTab(
          icon: Icons.download_rounded,
          label: _receivedLabel(context),
          isSelected: selectedMode == _FriendRequestsMode.incoming,
          onTap: () => onSelect(_FriendRequestsMode.incoming),
        ),
      ),
      const Gap(10),
      Expanded(
        child: _RequestModeTab(
          icon: Icons.send_rounded,
          label: _sentLabel(context),
          isSelected: selectedMode == _FriendRequestsMode.sent,
          onTap: () => onSelect(_FriendRequestsMode.sent),
        ),
      ),
    ],
  );

  String _receivedLabel(BuildContext context) => switch (context.languageCode) {
    "es" => "Recibidas",
    "pt" => "Recebidas",
    _ => "Received",
  };

  String _sentLabel(BuildContext context) => switch (context.languageCode) {
    "es" => "Enviadas",
    "pt" => "Enviadas",
    _ => "Sent",
  };
}

class _RequestModeTab extends StatelessWidget {
  const _RequestModeTab({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => BounceTap(
    onTap: onTap,
    pressedScale: 0.96,
    child: Container(
      height: 38,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: isSelected ? context.colorTokens.primaryGradient : null,
        color: isSelected ? null : context.colorTokens.surfaceInnerLayer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: isSelected ? Colors.white : _socialMuted),
          const Gap(7),
          Text(
            label,
            style: context.textStyles.bodySmall.copyWith(
              color: isSelected ? Colors.white : _socialMuted,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    ),
  );
}

class _RequestProfileCard extends StatelessWidget {
  const _RequestProfileCard({
    required this.profile,
    required this.mode,
    required this.onAccept,
    required this.onDecline,
    required this.onCancel,
  });

  final _FriendProfile profile;
  final _FriendRequestsMode mode;
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
    decoration: _surfaceDecoration(radius: 18),
    child: Column(
      children: [
        Row(
          children: [
            GroupMemberAvatar(
              name: profile.name,
              colorValue: profile.colorValue,
              size: 48,
            ),
            const Gap(12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _NameBlock(name: profile.name, handle: profile.handle),
                  const Gap(5),
                  Row(
                    children: [
                      Icon(
                        mode == _FriendRequestsMode.incoming
                            ? Icons.group_rounded
                            : Icons.schedule_rounded,
                        color: _socialMuted,
                        size: 15,
                      ),
                      const Gap(5),
                      Expanded(
                        child: Text(
                          mode == _FriendRequestsMode.incoming
                              ? _mutualFriends(context)
                              : _pendingLabel(context),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.textStyles.bodySmall.copyWith(
                            color: mode == _FriendRequestsMode.incoming
                                ? _socialMuted
                                : context.colorTokens.warning,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const Gap(14),
        if (mode == _FriendRequestsMode.incoming)
          Row(
            children: [
              Expanded(
                child: _RequestActionButton(
                  label: _declineLabel(context),
                  isPrimary: false,
                  onTap: onDecline,
                ),
              ),
              const Gap(10),
              Expanded(
                child: _RequestActionButton(
                  label: _acceptLabel(context),
                  isPrimary: true,
                  onTap: onAccept,
                ),
              ),
            ],
          )
        else
          Align(
            alignment: Alignment.centerRight,
            child: _RequestActionButton(
              label: _cancelLabel(context),
              isPrimary: false,
              onTap: onCancel,
            ),
          ),
      ],
    ),
  );

  String _mutualFriends(BuildContext context) => switch (context.languageCode) {
    "es" => "3 amigos en común",
    "pt" => "3 amigos em comum",
    _ => "3 mutual friends",
  };

  String _pendingLabel(BuildContext context) => switch (context.languageCode) {
    "es" => "Pendiente",
    "pt" => "Pendente",
    _ => "Pending",
  };

  String _acceptLabel(BuildContext context) => switch (context.languageCode) {
    "es" => "Aceptar",
    "pt" => "Aceitar",
    _ => "Accept",
  };

  String _declineLabel(BuildContext context) => switch (context.languageCode) {
    "es" => "Rechazar",
    "pt" => "Recusar",
    _ => "Decline",
  };

  String _cancelLabel(BuildContext context) => switch (context.languageCode) {
    "es" => "Cancelar",
    "pt" => "Cancelar",
    _ => "Cancel",
  };
}

class _RequestEmptyState extends StatelessWidget {
  const _RequestEmptyState({required this.mode});

  final _FriendRequestsMode mode;

  @override
  Widget build(BuildContext context) => Center(
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 30, 20, 28),
      decoration: _surfaceDecoration(radius: 18),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PinkBadge(
            icon: mode == _FriendRequestsMode.incoming
                ? Icons.inbox_rounded
                : Icons.send_rounded,
            size: 64,
            iconSize: 34,
          ),
          const Gap(14),
          Text(
            _title(context),
            textAlign: TextAlign.center,
            style: context.textStyles.extraBold20.copyWith(
              color: _socialText,
              fontSize: 17,
            ),
          ),
          const Gap(6),
          Text(
            _subtitle(context),
            textAlign: TextAlign.center,
            style: context.textStyles.bodyMedium.copyWith(
              color: _socialMuted,
              fontSize: 13,
              height: 1.25,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ),
  );

  String _title(BuildContext context) => switch (mode) {
    _FriendRequestsMode.incoming => switch (context.languageCode) {
      "es" => "Ninguna solicitud recibida",
      "pt" => "Nenhuma solicitação recebida",
      _ => "No received requests",
    },
    _FriendRequestsMode.sent => switch (context.languageCode) {
      "es" => "Ninguna invitación enviada",
      "pt" => "Nenhum convite enviado",
      _ => "No sent invites",
    },
  };

  String _subtitle(BuildContext context) => switch (mode) {
    _FriendRequestsMode.incoming => switch (context.languageCode) {
      "es" => "Las solicitudes aparecerán aquí.",
      "pt" => "As solicitações aparecerão aqui.",
      _ => "Requests will appear here.",
    },
    _FriendRequestsMode.sent => switch (context.languageCode) {
      "es" => "Tus invitaciones enviadas aparecerán aquí.",
      "pt" => "Seus convites enviados aparecerão aqui.",
      _ => "Your sent invites will appear here.",
    },
  };
}

class _SafetyNotice extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
    decoration: _surfaceDecoration(radius: 16),
    child: Row(
      children: [
        _PinkBadge(icon: Icons.shield_outlined, size: 34, iconSize: 19),
        const Gap(10),
        Expanded(
          child: Text(
            _text(context),
            style: context.textStyles.bodySmall.copyWith(
              color: _socialMuted,
              fontWeight: FontWeight.w700,
              height: 1.25,
            ),
          ),
        ),
      ],
    ),
  );

  String _text(BuildContext context) => switch (context.languageCode) {
    "es" => "Acepta solo personas que conoces y confías.",
    "pt" => "Aceite apenas pessoas que você conhece e confia.",
    _ => "Only accept people you know and trust.",
  };
}

class SimpleEmptyState extends StatelessWidget {
  const SimpleEmptyState({required this.text, super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Center(
    child: Text(
      text,
      textAlign: TextAlign.center,
      style: context.textStyles.bodyMedium.copyWith(color: _socialMuted),
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
    height: 46,
    padding: const EdgeInsets.symmetric(horizontal: 14),
    decoration: _surfaceDecoration(radius: 18),
    child: Row(
      children: [
        const Icon(Icons.search_rounded, color: _socialMuted, size: 21),
        const Gap(10),
        Expanded(
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            textInputAction: TextInputAction.search,
            style: context.textStyles.bodyMedium.copyWith(
              color: _socialText,
              fontWeight: FontWeight.w700,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hint,
              hintStyle: context.textStyles.bodyMedium.copyWith(
                color: _socialMuted,
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
    padding: const EdgeInsets.fromLTRB(12, 12, 10, 12),
    decoration: _surfaceDecoration(radius: 18),
    child: Row(
      children: [
        _PinkBadge(icon: Icons.qr_code_rounded, size: 46, iconSize: 24),
        const Gap(12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _label(context),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textStyles.bodySmall.copyWith(
                  color: _socialMuted,
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
                  fontSize: 18,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),
        BounceTap(
          onTap: onCopy,
          pressedScale: 0.95,
          child: _InviteIconButton(icon: Icons.copy_rounded),
        ),
        const Gap(8),
        BounceTap(
          onTap: onShare,
          pressedScale: 0.95,
          child: _InviteIconButton(icon: Icons.share_rounded),
        ),
      ],
    ),
  );

  String _label(BuildContext context) => switch (context.languageCode) {
    "es" => "Tu código de invitación",
    "pt" => "Seu código de convite",
    _ => "Your invite code",
  };
}

class _InviteIconButton extends StatelessWidget {
  const _InviteIconButton({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) => Container(
    width: 38,
    height: 38,
    decoration: BoxDecoration(
      color: context.colorTokens.surface,
      shape: BoxShape.circle,
      border: Border.all(color: _socialBorder),
    ),
    child: Icon(icon, color: context.colorTokens.primary, size: 20),
  );
}

class _ActivityShortcuts extends StatelessWidget {
  const _ActivityShortcuts({
    required this.onPendingTap,
    required this.onSentTap,
  });

  final VoidCallback onPendingTap;
  final VoidCallback onSentTap;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: _ShortcutTile(
          icon: Icons.download_rounded,
          title: _pendingLabel(context),
          onTap: onPendingTap,
        ),
      ),
      const Gap(8),
      Expanded(
        child: _ShortcutTile(
          icon: Icons.send_rounded,
          title: _sentLabel(context),
          onTap: onSentTap,
        ),
      ),
    ],
  );

  String _pendingLabel(BuildContext context) => switch (context.languageCode) {
    "es" => "Solicitudes",
    "pt" => "Solicita\u00e7\u00f5es",
    _ => "Requests",
  };

  String _sentLabel(BuildContext context) => switch (context.languageCode) {
    "es" => "Invitaciones",
    "pt" => "Convites",
    _ => "Invites",
  };
}

class _ShortcutTile extends StatelessWidget {
  const _ShortcutTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => BounceTap(
    pressedScale: 0.98,
    onTap: onTap,
    child: Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 9),
      decoration: BoxDecoration(
        color: context.colorTokens.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _socialBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: context.colorTokens.primary, size: 17),
          const Gap(6),
          Flexible(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textStyles.bodySmall.copyWith(
                color: _socialMuted,
                fontWeight: FontWeight.w900,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _FriendsSection extends StatelessWidget {
  const _FriendsSection({
    required this.friends,
    required this.totalFriends,
    required this.query,
    required this.onShare,
  });

  final List<_FriendProfile> friends;
  final int totalFriends;
  final String query;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _SectionHeader(
        title: _title(context, totalFriends),
        action: friends.isEmpty ? null : _seeAll(context),
      ),
      const Gap(12),
      if (friends.isEmpty)
        _EmptyFriendsCard(hasQuery: query.trim().isNotEmpty, onShare: onShare)
      else
        Container(
          decoration: _surfaceDecoration(radius: 18),
          child: Column(
            children: [
              for (int index = 0; index < friends.length; index++) ...[
                _FriendRow(profile: friends[index], index: index),
                if (index < friends.length - 1)
                  const Divider(
                    height: 1,
                    indent: 58,
                    endIndent: 14,
                    color: _socialBorder,
                  ),
              ],
            ],
          ),
        ),
    ],
  );

  String _title(BuildContext context, int count) =>
      switch (context.languageCode) {
        "es" => "Tus amigos ($count)",
        "pt" => "Seus amigos ($count)",
        _ => "Your friends ($count)",
      };

  String _seeAll(BuildContext context) => switch (context.languageCode) {
    "es" => "Ver todos",
    "pt" => "Ver todos",
    _ => "View all",
  };
}

class _FriendRow extends StatelessWidget {
  const _FriendRow({required this.profile, required this.index});

  final _FriendProfile profile;
  final int index;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
    child: Row(
      children: [
        GroupMemberAvatar(
          name: profile.name,
          colorValue: profile.colorValue,
          size: 40,
        ),
        const Gap(10),
        Expanded(
          child: _NameBlock(name: profile.name, handle: profile.handle),
        ),
        Text(
          _statusLabel(context, index),
          style: context.textStyles.bodySmall.copyWith(
            color: index < 2 ? const Color(0xFF25A85A) : _socialMuted,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Gap(8),
        const Icon(Icons.more_vert_rounded, color: _socialMuted, size: 20),
      ],
    ),
  );

  String _statusLabel(BuildContext context, int index) {
    if (index < 2) {
      return "Online";
    }
    return switch (context.languageCode) {
      "es" => "Hace ${index + 1} min",
      "pt" => "Há ${index + 1} min",
      _ => "${index + 1} min ago",
    };
  }
}

class _EmptyFriendsCard extends StatelessWidget {
  const _EmptyFriendsCard({required this.hasQuery, required this.onShare});

  final bool hasQuery;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.fromLTRB(18, 26, 18, 18),
    decoration: _surfaceDecoration(radius: 18),
    child: Column(
      children: [
        Container(
          width: 88,
          height: 62,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: context.colorTokens.primaryVeryLight,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Icon(
            Icons.diversity_3_rounded,
            color: context.colorTokens.primary,
            size: 42,
          ),
        ),
        const Gap(14),
        Text(
          hasQuery ? _notFoundTitle(context) : _emptyTitle(context),
          textAlign: TextAlign.center,
          style: context.textStyles.extraBold20.copyWith(
            color: _socialText,
            fontSize: 17,
          ),
        ),
        const Gap(6),
        Text(
          hasQuery ? _notFoundSubtitle(context) : _emptySubtitle(context),
          textAlign: TextAlign.center,
          style: context.textStyles.bodyMedium.copyWith(
            color: _socialMuted,
            height: 1.28,
          ),
        ),
        if (!hasQuery) ...[
          const Gap(18),
          _ShareButton(onTap: onShare, label: _shareLabel(context)),
        ],
      ],
    ),
  );

  String _emptyTitle(BuildContext context) => switch (context.languageCode) {
    "es" => "Aún no tienes amigos",
    "pt" => "Você ainda não tem amigos",
    _ => "You do not have friends yet",
  };

  String _emptySubtitle(BuildContext context) => switch (context.languageCode) {
    "es" => "Busca personas arriba o comparte tu código de invitación.",
    "pt" => "Busque pessoas acima ou compartilhe seu código de convite.",
    _ => "Search people above or share your invite code.",
  };

  String _notFoundTitle(BuildContext context) => switch (context.languageCode) {
    "es" => "Nadie encontrado",
    "pt" => "Ninguém encontrado",
    _ => "No one found",
  };

  String _notFoundSubtitle(BuildContext context) =>
      switch (context.languageCode) {
        "es" => "Intenta buscar por otro nombre o @usuario.",
        "pt" => "Tente buscar por outro nome ou @usuário.",
        _ => "Try another name or @username.",
      };

  String _shareLabel(BuildContext context) => switch (context.languageCode) {
    "es" => "Compartir código",
    "pt" => "Compartilhar código",
    _ => "Share code",
  };
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.action});

  final String title;
  final String? action;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(
          title,
          style: context.textStyles.bodyMedium.copyWith(
            color: _socialText,
            fontSize: 15,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      if (action != null)
        Text(
          action!,
          style: context.textStyles.bodySmall.copyWith(
            color: context.colorTokens.primary,
            fontWeight: FontWeight.w900,
          ),
        ),
    ],
  );
}

class _NameBlock extends StatelessWidget {
  const _NameBlock({required this.name, required this.handle});

  final String name;
  final String handle;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: context.textStyles.bodyMedium.copyWith(
          color: _socialText,
          fontWeight: FontWeight.w900,
        ),
      ),
      const Gap(1),
      Text(
        handle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: context.textStyles.bodySmall.copyWith(
          color: _socialMuted,
          fontWeight: FontWeight.w700,
        ),
      ),
    ],
  );
}

class _PinkBadge extends StatelessWidget {
  const _PinkBadge({
    required this.icon,
    required this.size,
    required this.iconSize,
  });

  final IconData icon;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: context.colorTokens.primaryVeryLight,
      shape: BoxShape.circle,
    ),
    child: Icon(icon, color: context.colorTokens.primary, size: iconSize),
  );
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => BounceTap(
    pressedScale: 0.96,
    onTap: onTap,
    child: Container(
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: context.colorTokens.primaryGradient,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: context.textStyles.bodySmall.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w900,
        ),
      ),
    ),
  );
}

class _SentChip extends StatelessWidget {
  const _SentChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Container(
    height: 30,
    padding: const EdgeInsets.symmetric(horizontal: 14),
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: const Color(0xFFE9E9E9),
      borderRadius: BorderRadius.circular(999),
    ),
    child: Row(
      children: [
        const Icon(Icons.check_rounded, size: 16, color: _socialMuted),
        const Gap(4),
        Text(
          label,
          style: context.textStyles.bodySmall.copyWith(
            color: _socialMuted,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    ),
  );
}

class _RequestActionButton extends StatelessWidget {
  const _RequestActionButton({
    required this.label,
    required this.isPrimary,
    required this.onTap,
  });

  final String label;
  final bool isPrimary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => BounceTap(
    pressedScale: 0.96,
    onTap: onTap,
    child: Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: isPrimary ? context.colorTokens.primaryGradient : null,
        color: isPrimary ? null : context.colorTokens.surface,
        borderRadius: BorderRadius.circular(999),
        border: isPrimary ? null : Border.all(color: _socialBorder),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: context.textStyles.bodySmall.copyWith(
          color: isPrimary ? Colors.white : _socialMuted,
          fontWeight: FontWeight.w900,
        ),
      ),
    ),
  );
}

class _ShareButton extends StatelessWidget {
  const _ShareButton({required this.onTap, required this.label});

  final VoidCallback onTap;
  final String label;

  @override
  Widget build(BuildContext context) => BounceTap(
    onTap: onTap,
    pressedScale: 0.96,
    child: Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 22),
      decoration: BoxDecoration(
        border: Border.all(color: context.colorTokens.primary),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.ios_share_rounded,
            color: context.colorTokens.primary,
            size: 18,
          ),
          const Gap(8),
          Text(
            label,
            style: context.textStyles.bodyMedium.copyWith(
              color: context.colorTokens.primary,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
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

class _FriendSuggestion {
  const _FriendSuggestion({
    required this.id,
    required this.name,
    required this.handle,
    required this.colorValue,
  });

  final String id;
  final String name;
  final String handle;
  final int colorValue;
}

BoxDecoration _surfaceDecoration({required double radius}) => BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(radius),
  border: Border.all(color: _socialBorder),
  boxShadow: const [
    BoxShadow(color: Color(0x08000000), blurRadius: 10, offset: Offset(0, 4)),
  ],
);
