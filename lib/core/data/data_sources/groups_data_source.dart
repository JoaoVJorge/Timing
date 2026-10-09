import "dart:async";

import "package:supabase_flutter/supabase_flutter.dart"
    show PostgrestFilterBuilder, PostgrestList, PostgrestTransformBuilder;
import "package:timing/core/data/errors/backend_error.dart";
import "package:timing/core/domain/entities/friend_option.dart";
import "package:timing/core/domain/entities/group_activity_draft.dart";
import "package:timing/core/domain/entities/group_activity_link_options.dart";
import "package:timing/core/domain/entities/group_activity_progress_entity.dart";
import "package:timing/core/domain/entities/group_entity.dart";
import "package:timing/core/domain/entities/group_image_message_entity.dart";
import "package:timing/core/domain/entities/group_image_messages_page.dart";
import "package:timing/core/domain/entities/group_invitation_entity.dart";
import "package:timing/core/domain/entities/group_invite_option_entity.dart";
import "package:timing/core/domain/entities/group_join_request_entity.dart";
import "package:timing/core/domain/entities/group_member_entity.dart";
import "package:timing/core/domain/entities/sent_group_invitation_entity.dart";
import "package:timing/core/domain/enums/group_theme_type.dart";
import "package:timing/core/services/log/app_logger_service.dart";
import "package:timing/core/services/supabase/supabase_service.dart";
import "package:timing/core/utils/extensions/date_time_extensions.dart";
import "package:timing/core/utils/profile_display_name.dart";
import "package:timing/theme/group_colors.dart";

/// The group tables and RPCs on the backend. Every call goes straight to
/// Supabase and throws whatever it fails with: the cached list, the queue of
/// writes waiting for a connection and turning a failure into an `AppError`
/// belong to `GroupsRepository`.
/// What the backend answered when the user used a link or an invitation:
/// which group, its name, and whether the leader still has to approve.
typedef GroupJoinResponse = ({
  String groupId,
  String groupName,
  bool pendingApproval,
});

class GroupsDataSource {
  GroupsDataSource({required this._supabaseService, required this._logger});

  final SupabaseService _supabaseService;
  final AppLoggerService _logger;
  // A remote call must fail fast on a "connected but no real internet"
  // network so its caller can queue the write for retry or surface the
  // offline notice, instead of hanging on the platform's own (much longer)
  // socket timeout.
  static const Duration _remoteCallTimeout = Duration(seconds: 10);
  static const int _imageMessagesPageSize = 50;

  /// The budget of the leaderboard read at the end of [fetchGroups]. A caller
  /// that puts its own timeout around that fetch must stay comfortably above
  /// it.
  static const Duration activityScoresTimeout = Duration(seconds: 8);

  String? get currentUserId => _supabaseService.currentUserId;

  Future<List<GroupActivityLinkOptions>> fetchActivityLinkOptions(
    String groupId,
  ) async {
    final dynamic result = await _supabaseService.requireClient
        .rpc(
          "group_activity_link_options",
          params: {"target_group_id": groupId},
        )
        .timeout(_remoteCallTimeout);
    return (result as List)
        .map(
          (item) => GroupActivityLinkOptions.fromMap(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList();
  }

  Future<void> setActivityLinks({
    required String activityId,
    required List<String> sourceIds,
    bool createNew = false,
  }) async {
    await _supabaseService.requireClient
        .rpc(
          "set_group_activity_links",
          params: {
            "target_activity_id": activityId,
            "source_ids": sourceIds,
            "create_new": createNew,
            "local_date": DateTime.now().toIso8601String().substring(0, 10),
          },
        )
        .timeout(_remoteCallTimeout);
  }

  /// The groups [userId] belongs to, with their members and ranking. Five
  /// requests: memberships, groups, members, every member's profile with its
  /// photo, then the leaderboard.
  Future<List<GroupEntity>> fetchGroups(String userId) async {
    final List<Map<String, dynamic>> currentMemberships = await _selectRows(
      table: "group_members",
      columns: "group_id",
      filters: (query) => query.eq("user_id", userId),
    );
    final List<String> groupIds = currentMemberships
        .map((row) => row["group_id"] as String)
        .toList();
    if (groupIds.isEmpty) {
      return const [];
    }

    final List<Map<String, dynamic>> groupRows = await _selectRows(
      table: "groups",
      columns:
          "id, name, theme, description, owner_id, created_at, "
          "invite_code, privacy",
      filters: (query) => query.inFilter("id", groupIds),
    );
    // Fetch appearance for every group before caching the list, including groups
    // the user has never opened. Keep the first saved activity color per group.
    final List<Map<String, dynamic>> activityRows = await _selectRows(
      table: "group_activities",
      columns: "group_id, payload",
      filters: (query) => query
          .inFilter("group_id", groupIds)
          .order("created_at", ascending: true),
    );
    final Map<String, int> colorsByGroup = {};
    for (final row in activityRows) {
      final dynamic color = (row["payload"] as Map?)?["color_value"];
      if (color is num) {
        colorsByGroup.putIfAbsent(
          row["group_id"] as String,
          () => color.toInt(),
        );
      }
    }
    final List<Map<String, dynamic>> memberRows = await _selectRows(
      table: "group_members",
      columns: "group_id, user_id, role, joined_at",
      filters: (query) => query.inFilter("group_id", groupIds),
    );
    final List<String> memberIds = memberRows
        .map((row) => row["user_id"] as String)
        .toSet()
        .toList();
    final Map<String, Map<String, dynamic>> profilesById = await _profilesById(
      memberIds,
      withPhoto: true,
    );
    final Map<String, Map<String, _PeriodScores>> scoresByGroup =
        await _leaderboardScoresForGroups(groupIds);

    final Map<String, List<Map<String, dynamic>>> membersByGroup = {};
    for (final Map<String, dynamic> row in memberRows) {
      final String groupId = row["group_id"] as String;
      membersByGroup.putIfAbsent(groupId, () => []).add(row);
    }

    return groupRows.map((row) {
      final GroupThemeType theme = GroupThemeType.byName(
        row["theme"] as String?,
      );
      final String groupId = row["id"] as String;
      final Map<String, _PeriodScores> scoresByUser =
          scoresByGroup[groupId] ?? const {};
      final List<GroupMemberEntity> members =
          membersByGroup[groupId]
              ?.map(
                (memberRow) => _memberFromRows(
                  memberRow: memberRow,
                  profileRow: profilesById[memberRow["user_id"]],
                  scoresByUser: scoresByUser,
                ),
              )
              .toList() ??
          [];

      return GroupEntity(
        id: groupId,
        colorValue: colorsByGroup[groupId],
        name: row["name"] as String? ?? "",
        theme: theme,
        members: members,
        description: row["description"] as String? ?? "",
        ownerId: row["owner_id"] as String? ?? "",
        createdAt: DateTime.tryParse(row["created_at"] as String? ?? ""),
        inviteCode: row["invite_code"] as String? ?? "",
        privacy: row["privacy"] as String? ?? "inviteOnly",
        createdActivityId: row["activity_id"] as String?,
      );
    }).toList();
  }

  Future<List<GroupActivityProgressEntity>> fetchGroupActivityProgress(
    String groupId, {
    String? localDate,
  }) async {
    // The progress RPC omits the activity's saved appearance. Load its
    // payload alongside progress so every member sees the group's color; the
    // color is cosmetic, so failing to read it does not fail the progress.
    final Future<List<GroupActivityLinkOptions>> optionsFuture =
        fetchActivityLinkOptions(
          groupId,
        ).catchError((Object _) => const <GroupActivityLinkOptions>[]);
    final dynamic response = await _supabaseService.requireClient
        .rpc(
          "group_activity_progress",
          params: {"target_group_id": groupId, "local_date": localDate},
        )
        .timeout(_remoteCallTimeout);
    _logger.logResponse("rpc public.group_activity_progress", response);
    final List<dynamic> rows = response as List<dynamic>? ?? const [];
    final Map<String, int> colorsByActivity = {
      for (final GroupActivityLinkOptions option in await optionsFuture)
        if (option.payload["color_value"] is num)
          option.activityId: (option.payload["color_value"] as num).toInt(),
    };
    return rows
        .map(
          (row) => GroupActivityProgressEntity.fromMap({
            ...Map<String, dynamic>.from(row as Map),
            if (colorsByActivity.containsKey(row["activity_id"]))
              "color_value": colorsByActivity[row["activity_id"]],
          }),
        )
        .toList();
  }

  /// Scores for the fetch that also loads the groups themselves: the
  /// leaderboard is supplementary there, so a failure leaves every score at
  /// zero instead of losing the groups and their members.
  Future<Map<String, Map<String, _PeriodScores>>> _leaderboardScoresForGroups(
    List<String> groupIds,
  ) async {
    if (groupIds.isEmpty) {
      return const {};
    }
    try {
      return await _fetchLeaderboardScores(groupIds);
    } on TimeoutException catch (error, stackTrace) {
      _logger.logError(
        "Timed out loading group leaderboard scores",
        error: error,
        stackTrace: stackTrace,
      );
      return const {};
    } catch (error, stackTrace) {
      _logger.logError(
        "Failed to load group leaderboard scores",
        error: error,
        stackTrace: stackTrace,
      );
      return const {};
    }
  }

  Future<Map<String, Map<String, _PeriodScores>>> _fetchLeaderboardScores(
    List<String> groupIds,
  ) async {
    final dynamic response = await _supabaseService.requireClient
        .rpc(
          "group_leaderboard_scores",
          params: {
            "target_group_ids": groupIds,
            "today_start": DateTime.now().dateOnly.toUtc().toIso8601String(),
            "week_start": _weekStart().toIso8601String(),
            "month_start": _monthStart().toIso8601String(),
          },
        )
        .timeout(activityScoresTimeout);
    _logger.logResponse("rpc public.group_leaderboard_scores", response);
    final List<dynamic> rows = response as List<dynamic>? ?? const [];
    final Map<String, Map<String, _PeriodScores>> scoresByGroup = {};
    for (final dynamic value in rows) {
      final Map<String, dynamic> row = Map<String, dynamic>.from(value as Map);
      final String? groupId = row["group_id"] as String?;
      final String? userId = row["user_id"] as String?;
      if (groupId == null || userId == null) {
        continue;
      }
      scoresByGroup.putIfAbsent(
        groupId,
        () => <String, _PeriodScores>{},
      )[userId] = _PeriodScores(
        today: _intValue(row["today_score"]),
        week: _intValue(row["week_score"]),
        month: _intValue(row["month_score"]),
        total: _intValue(row["total_score"] ?? row["month_score"]),
      );
    }
    return scoresByGroup;
  }

  /// Re-reads only the leaderboard and applies it to [groups], keeping their
  /// members, names and photos as they are.
  ///
  /// A focus session or a goal check changes nothing but the ranking, yet a
  /// full [fetchGroups] repeats five requests. Unlike that fetch, a failure
  /// here is thrown, not turned into zeros, so the caller can fall back to
  /// the full reload.
  Future<List<GroupEntity>> fetchGroupScores(List<GroupEntity> groups) async {
    final Map<String, Map<String, _PeriodScores>> scores =
        await _fetchLeaderboardScores(groups.map((group) => group.id).toList());
    return [
      for (final GroupEntity group in groups)
        group.copyWithMembers([
          for (final GroupMemberEntity member in group.members)
            _withScores(member, scores[group.id]?[member.id]),
        ]),
    ];
  }

  GroupMemberEntity _withScores(
    GroupMemberEntity member,
    _PeriodScores? scores,
  ) {
    final _PeriodScores applied =
        scores ?? const _PeriodScores(today: 0, week: 0, month: 0);
    return member.withScores(
      today: applied.today,
      week: applied.week,
      month: applied.month,
      total: applied.total,
    );
  }

  Future<List<FriendOption>> fetchInvitableFriends(String userId) async {
    final List<Map<String, dynamic>> friendshipRows = await _selectRows(
      table: "friendships",
      columns: "requester_id, addressee_id",
      filters: (query) => query
          .eq("status", "accepted")
          .or("requester_id.eq.$userId,addressee_id.eq.$userId"),
    );
    final List<String> friendIds = friendshipRows
        .map((row) {
          final String requesterId = row["requester_id"] as String;
          final String addresseeId = row["addressee_id"] as String;
          return requesterId == userId ? addresseeId : requesterId;
        })
        .toSet()
        .toList();
    final Map<String, Map<String, dynamic>> profilesById = await _profilesById(
      friendIds,
      withPhoto: true,
    );

    return friendIds.map((id) {
      final Map<String, dynamic>? profile = profilesById[id];
      return (
        id: id,
        name: profileDisplayName(profile, fallback: "Friend"),
        colorValue:
            (profile?["accent_color_value"] as num?)?.toInt() ??
            GroupAvatarColors.byIndex(id.hashCode.abs()),
        avatarIconIndex: (profile?["avatar_icon_index"] as num?)?.toInt(),
        profilePhotoBase64: profile?["profile_photo_base64"] as String? ?? "",
      );
    }).toList();
  }

  Future<List<GroupInviteOptionEntity>> fetchGroupInviteOptions(
    String groupId,
  ) async {
    final dynamic response = await _supabaseService.requireClient
        .rpc("group_invite_options", params: {"target_group_id": groupId})
        .timeout(_remoteCallTimeout);
    _logger.logResponse("rpc public.group_invite_options", response);
    final List<dynamic> rows = response as List<dynamic>? ?? const [];
    return rows
        .map(
          (row) => GroupInviteOptionEntity.fromMap(
            Map<String, dynamic>.from(row as Map),
          ),
        )
        .toList();
  }

  Future<void> inviteFriendToGroup({
    required String groupId,
    required String friendId,
  }) async {
    final dynamic response = await _supabaseService.requireClient
        .rpc(
          "invite_friend_to_group",
          params: {"target_group_id": groupId, "target_friend_id": friendId},
        )
        .timeout(_remoteCallTimeout);
    _logger.logResponse("rpc public.invite_friend_to_group", response);
  }

  Future<void> cancelGroupInvitation({
    required String groupId,
    required String friendId,
  }) async {
    final dynamic response = await _supabaseService.requireClient
        .rpc(
          "cancel_group_invitation",
          params: {"target_group_id": groupId, "target_friend_id": friendId},
        )
        .timeout(_remoteCallTimeout);
    _logger.logResponse("rpc public.cancel_group_invitation", response);
  }

  /// One page of the group's images, newest last. [before] asks for the page
  /// that precedes that message.
  Future<GroupImageMessagesPage> fetchImageMessages(
    String groupId, {
    GroupImageMessageEntity? before,
  }) async {
    final List<Map<String, dynamic>> rows = await _selectRows(
      table: "group_image_messages",
      columns: "id, group_id, sender_id, image_base64, created_at",
      filters: (query) {
        PostgrestFilterBuilder<PostgrestList> filtered = query.eq(
          "group_id",
          groupId,
        );
        if (before != null) {
          final String timestamp = before.createdAt.toUtc().toIso8601String();
          filtered = filtered.or(
            "created_at.lt.\"$timestamp\","
            "and(created_at.eq.\"$timestamp\",id.lt.${before.id})",
          );
        }
        return filtered
            .order("created_at", ascending: false)
            .order("id", ascending: false)
            .limit(_imageMessagesPageSize + 1);
      },
    );
    final bool hasMore = rows.length > _imageMessagesPageSize;
    final List<Map<String, dynamic>> pageRows = rows
        .take(_imageMessagesPageSize)
        .toList();
    final List<String> senderIds = pageRows
        .map((row) => row["sender_id"] as String)
        .toSet()
        .toList();
    final Map<String, Map<String, dynamic>> profilesById = await _profilesById(
      senderIds,
      withPhoto: true,
    );

    return GroupImageMessagesPage(
      messages: pageRows.reversed
          .map(
            (row) => _imageMessageFromRow(
              row,
              profileRow: profilesById[row["sender_id"]],
            ),
          )
          .toList(),
      hasMore: hasMore,
    );
  }

  Future<GroupImageMessageEntity> sendImageMessage({
    required String userId,
    required String groupId,
    required String imageBase64,
  }) async {
    final Map<String, dynamic> row = await _supabaseService.requireClient
        .from("group_image_messages")
        .insert({
          "group_id": groupId,
          "sender_id": userId,
          "image_base64": imageBase64,
        })
        .select("id, group_id, sender_id, image_base64, created_at")
        .single()
        .timeout(_remoteCallTimeout);
    _logger.logResponse("insert public.group_image_messages", row);
    final Map<String, Map<String, dynamic>> profilesById = await _profilesById([
      userId,
    ], withPhoto: true);

    return _imageMessageFromRow(row, profileRow: profilesById[userId]);
  }

  /// Ends [userId]'s own membership. Deleting a `group_members` row that is
  /// already gone is a no-op, so this is safe to send again.
  Future<void> leaveGroup({
    required String groupId,
    required String userId,
  }) async {
    await _supabaseService.requireClient
        .from("group_members")
        .delete()
        .eq("group_id", groupId)
        .eq("user_id", userId)
        .timeout(_remoteCallTimeout);
  }

  Future<void> removeMember({
    required String groupId,
    required String memberId,
  }) async {
    await _supabaseService.requireClient
        .from("group_members")
        .delete()
        .eq("group_id", groupId)
        .eq("user_id", memberId)
        .timeout(_remoteCallTimeout);
  }

  Future<void> transferLeadership({
    required String groupId,
    required String nextLeaderId,
  }) async {
    const String operation = "rpc public.transfer_group_ownership";
    final Map<String, dynamic> payload = {
      "target_group_id": groupId,
      "next_owner_id": nextLeaderId,
    };
    _logger.logRequest(operation, payload);
    final dynamic response = await _supabaseService.requireClient
        .rpc("transfer_group_ownership", params: payload)
        .timeout(_remoteCallTimeout);
    _logger.logResponse(operation, response);
  }

  Future<void> resetGroupProgress(String groupId) async {
    const String operation = "rpc public.reset_group_progress";
    _logger.logRequest(operation, {"target_group_id": groupId});
    final dynamic response = await _supabaseService.requireClient
        .rpc("reset_group_progress", params: {"target_group_id": groupId})
        .timeout(_remoteCallTimeout);
    _logger.logResponse(operation, response);
  }

  Future<List<GroupInvitationEntity>> fetchPendingInvitations() async {
    final dynamic response = await _supabaseService.requireClient
        .rpc("pending_group_invitations")
        .timeout(_remoteCallTimeout);
    _logger.logResponse("rpc public.pending_group_invitations", response);
    final List<dynamic> rows = response as List<dynamic>? ?? const [];
    return rows
        .map(
          (row) => GroupInvitationEntity.fromMap(
            Map<String, dynamic>.from(row as Map),
          ),
        )
        .toList();
  }

  Future<List<SentGroupInvitationEntity>> fetchSentInvitations(
    String userId,
  ) async {
    final List<Map<String, dynamic>> invitationRows = await _selectRows(
      table: "group_invitations",
      columns: "id, group_id, invitee_id, created_at",
      filters: (query) => query
          .eq("inviter_id", userId)
          .eq("status", "pending")
          .order("created_at", ascending: false),
    );
    if (invitationRows.isEmpty) {
      return const [];
    }

    final List<String> groupIds = invitationRows
        .map((row) => row["group_id"] as String)
        .toSet()
        .toList();
    final List<String> inviteeIds = invitationRows
        .map((row) => row["invitee_id"] as String)
        .toSet()
        .toList();

    final List<Map<String, dynamic>> groupRows = await _selectRows(
      table: "groups",
      columns: "id, name, theme",
      filters: (query) => query.inFilter("id", groupIds),
    );
    final Map<String, Map<String, dynamic>> groupsById = {
      for (final Map<String, dynamic> row in groupRows)
        row["id"] as String: row,
    };
    final Map<String, Map<String, dynamic>> profilesById = await _profilesById(
      inviteeIds,
    );

    return invitationRows.map((row) {
      final String groupId = row["group_id"] as String;
      final String inviteeId = row["invitee_id"] as String;
      final Map<String, dynamic>? groupRow = groupsById[groupId];
      final Map<String, dynamic>? profileRow = profilesById[inviteeId];

      return SentGroupInvitationEntity(
        id: row["id"] as String,
        groupId: groupId,
        groupName: groupRow?["name"] as String? ?? "Grupo",
        theme: GroupThemeType.byName(groupRow?["theme"] as String?),
        inviteeId: inviteeId,
        inviteeName: profileDisplayName(profileRow, fallback: "Amigo"),
        inviteeColorValue:
            (profileRow?["accent_color_value"] as num?)?.toInt() ??
            GroupAvatarColors.byIndex(inviteeId.hashCode.abs()),
        createdAt: DateTime.tryParse(row["created_at"] as String? ?? ""),
      );
    }).toList();
  }

  /// Accepts the invitation. The answer says whether the user is in the group
  /// or is now waiting for its leader: only an invitation from the leader
  /// joins straight away.
  ///
  /// Backends in the field disagree on the RPC's parameter name, and an older
  /// version of it fails on an ambiguous column, so this tries both names and
  /// then accepts through the tables directly.
  Future<GroupJoinResponse> acceptInvitation(String invitationId) async {
    dynamic response;
    try {
      response = await _supabaseService.requireClient
          .rpc(
            "accept_group_invitation",
            params: {"invitation_id": invitationId},
          )
          .timeout(_remoteCallTimeout);
    } catch (error) {
      if (_isRecoverableAcceptInvitationRpcError(error)) {
        return _acceptInvitationDirectly(invitationId);
      }
      if (!_isRpcSignatureError(error)) {
        rethrow;
      }
      try {
        response = await _supabaseService.requireClient
            .rpc(
              "accept_group_invitation",
              params: {"target_invitation_id": invitationId},
            )
            .timeout(_remoteCallTimeout);
      } catch (fallbackError) {
        if (_isRecoverableAcceptInvitationRpcError(fallbackError)) {
          return _acceptInvitationDirectly(invitationId);
        }
        rethrow;
      }
    }
    _logger.logResponse("rpc public.accept_group_invitation", response);
    return _joinResponseFrom(response) ??
        await _acceptInvitationDirectly(invitationId);
  }

  Future<void> declineInvitation(String invitationId) async {
    await _supabaseService.requireClient
        .rpc(
          "decline_group_invitation",
          params: {"invitation_id": invitationId},
        )
        .timeout(_remoteCallTimeout);
  }

  /// Asks to join the group behind [inviteCode]. The link never joins on its
  /// own: unless the user is already a member, the answer is a request the
  /// group's leader has to approve.
  Future<GroupJoinResponse> joinGroupByInviteCode(String inviteCode) async {
    final String code = inviteCode.trim().toUpperCase();
    if (code.isEmpty) {
      throw ArgumentError("Invite code must not be empty.");
    }
    dynamic response;
    try {
      response = await _supabaseService.requireClient
          .rpc("join_group_by_invite_code", params: {"lookup_code": code})
          .timeout(_remoteCallTimeout);
    } catch (error) {
      if (!_isRpcSignatureError(error)) {
        rethrow;
      }
      response = await _supabaseService.requireClient
          .rpc("join_group_by_invite_code", params: {"invite_code": code})
          .timeout(_remoteCallTimeout);
    }
    _logger.logResponse("rpc public.join_group_by_invite_code", response);
    final GroupJoinResponse? joined = _joinResponseFrom(response);
    if (joined == null) {
      throw StateError("join_group_by_invite_code returned no group row.");
    }
    return joined;
  }

  /// The people waiting for the group's leader to let them in. Only the
  /// leader is served this list.
  Future<List<GroupJoinRequestEntity>> fetchJoinRequests(String groupId) async {
    final dynamic response = await _supabaseService.requireClient
        .rpc("group_join_requests", params: {"target_group_id": groupId})
        .timeout(_remoteCallTimeout);
    _logger.logResponse("rpc public.group_join_requests", response);
    final List<dynamic> rows = response as List<dynamic>? ?? const [];
    return rows
        .map(
          (row) => GroupJoinRequestEntity.fromMap(
            Map<String, dynamic>.from(row as Map),
          ),
        )
        .toList();
  }

  Future<void> answerJoinRequest({
    required String requestId,
    required bool approve,
  }) async {
    final String function = approve
        ? "approve_group_join_request"
        : "decline_group_join_request";
    final dynamic response = await _supabaseService.requireClient
        .rpc(function, params: {"request_id": requestId})
        .timeout(_remoteCallTimeout);
    _logger.logResponse("rpc public.$function", response);
  }

  Future<GroupJoinResponse> _acceptInvitationDirectly(
    String invitationId,
  ) async {
    final String? userId = _supabaseService.currentUserId;
    if (userId == null) {
      throw StateError("User must be signed in to accept a group invitation.");
    }

    final dynamic invitationResponse = await _supabaseService.requireClient
        .from("group_invitations")
        .select("id, group_id, invitee_id, status")
        .eq("id", invitationId)
        .eq("invitee_id", userId)
        .maybeSingle()
        .timeout(_remoteCallTimeout);
    _logger.logResponse("select public.group_invitations", invitationResponse);
    if (invitationResponse == null) {
      throw StateError("Group invitation was not found for current user.");
    }
    final Map<String, dynamic> invitationRow = Map<String, dynamic>.from(
      invitationResponse as Map,
    );
    final String groupId = invitationRow["group_id"] as String;
    final String status = invitationRow["status"] as String? ?? "";
    if (status != "pending" && status != "accepted") {
      throw StateError("Group invitation is not pending.");
    }

    if (status == "pending") {
      try {
        await _supabaseService.requireClient
            .from("group_members")
            .insert({
              "group_id": groupId,
              "user_id": userId,
              "role": "member",
              "joined_at": DateTime.now().toUtc().toIso8601String(),
            })
            .timeout(_remoteCallTimeout);
      } catch (error) {
        if (!_isUniqueViolation(error)) {
          rethrow;
        }
      }
      await _supabaseService.requireClient
          .from("group_invitations")
          .update({"status": "accepted"})
          .eq("id", invitationId)
          .eq("invitee_id", userId)
          .timeout(_remoteCallTimeout);
    }

    // This path only runs against a backend that predates join requests, so
    // the insert above is the whole story.
    return (groupId: groupId, groupName: "", pendingApproval: false);
  }

  String? _groupIdFromRpcResponse(dynamic response) {
    final Map<String, dynamic>? row = _firstRpcRow(response);
    final Object? rawId = row?["id"] ?? row?["group_id"];
    final String? id = rawId?.toString();
    return id == null || id.isEmpty ? null : id;
  }

  /// A backend that predates join requests answers without
  /// `pending_approval`, which reads as the join it performed.
  GroupJoinResponse? _joinResponseFrom(dynamic response) {
    final String? groupId = _groupIdFromRpcResponse(response);
    if (groupId == null) {
      return null;
    }
    final Map<String, dynamic>? row = _firstRpcRow(response);
    return (
      groupId: groupId,
      groupName: row?["name"] as String? ?? "",
      pendingApproval: row?["pending_approval"] as bool? ?? false,
    );
  }

  Map<String, dynamic>? _firstRpcRow(dynamic response) {
    if (response == null) {
      return null;
    }
    if (response is List) {
      if (response.isEmpty) {
        return null;
      }
      final Object? first = response.first;
      return first is Map ? Map<String, dynamic>.from(first) : null;
    }
    if (response is Map) {
      return Map<String, dynamic>.from(response);
    }
    return null;
  }

  bool _isRpcSignatureError(Object error) {
    final String description = describeBackendError(error);
    return description.contains("PGRST202") ||
        description.contains("42883") ||
        description.contains("function") && description.contains("not found");
  }

  bool _isRecoverableAcceptInvitationRpcError(Object error) {
    final String description = describeBackendError(error);
    return description.contains("42702") || description.contains("ambiguous");
  }

  bool _isUniqueViolation(Object error) {
    final String description = describeBackendError(error);
    return description.contains("23505") ||
        description.contains("duplicate key");
  }

  /// Creates the group with [userId] as its owner. Invited friends are not
  /// members yet: they get a pending invitation and only appear once they
  /// accept, so the new group starts with the owner only.
  Future<GroupEntity> createGroup({
    required String userId,
    required String name,
    required GroupThemeType theme,
    required List<FriendOption> invitedFriends,
    String description = "",
    GroupActivityDraft? activity,
  }) async {
    const String operation = "rpc public.create_group_with_members";
    final Map<String, dynamic> createGroupPayload = {
      "group_name": name,
      "group_theme": theme.name,
      "invited_friend_ids": invitedFriends.map((friend) => friend.id).toList(),
      "group_description": description,
      "activity_kind": activity?.kindName,
      "activity_payload": activity == null
          ? null
          : {
              ...activity.toPayload(),
              "local_date": DateTime.now().toIso8601String().substring(0, 10),
            },
    };
    _logger.logRequest(operation, createGroupPayload);
    final dynamic response = await _supabaseService.requireClient
        .rpc("create_group_with_members", params: createGroupPayload)
        .timeout(_remoteCallTimeout);
    _logger.logResponse(operation, response);
    final List<dynamic> rows = response as List<dynamic>;
    if (rows.isEmpty) {
      throw StateError("create_group_with_members returned no group row.");
    }
    final Map<String, dynamic> groupRow = Map<String, dynamic>.from(
      rows.first as Map,
    );
    final String groupId = groupRow["id"] as String;
    final Map<String, Map<String, dynamic>> profilesById = await _profilesById([
      userId,
    ], withPhoto: true);
    final DateTime now = DateTime.now().toUtc();
    final List<GroupMemberEntity> members = [
      _memberFromRows(
        memberRow: {
          "user_id": userId,
          "role": "owner",
          "joined_at": now.toIso8601String(),
        },
        profileRow: profilesById[userId],
        scoresByUser: const {},
      ),
    ];

    return GroupEntity(
      id: groupId,
      name: name,
      theme: theme,
      members: members,
      description: groupRow["description"] as String? ?? description,
      ownerId: userId,
      createdAt: DateTime.tryParse(groupRow["created_at"] as String? ?? ""),
      inviteCode: groupRow["invite_code"] as String? ?? "",
      privacy: groupRow["privacy"] as String? ?? "inviteOnly",
      createdActivityId: groupRow["activity_id"] as String?,
      colorValue: activity?.colorValue,
    );
  }

  /// Saves the group's settings. The answer carries no members, so those (and
  /// anything else it leaves out) are taken from [fallbackGroup].
  Future<GroupEntity> updateGroup({
    required String groupId,
    required String name,
    required String description,
    required Map<String, dynamic> activityPayload,
    required GroupEntity fallbackGroup,
  }) async {
    const String operation = "rpc public.update_group_with_activity";
    final Map<String, dynamic> payload = {
      "target_group_id": groupId,
      "group_name": name,
      "group_description": description,
      "activity_payload": activityPayload,
    };
    _logger.logRequest(operation, payload);
    final dynamic response = await _supabaseService.requireClient
        .rpc("update_group_with_activity", params: payload)
        .timeout(_remoteCallTimeout);
    _logger.logResponse(operation, response);

    final List<dynamic> rows = response as List<dynamic>;
    if (rows.isEmpty) {
      throw StateError("update_group_with_activity returned no group row.");
    }
    final Map<String, dynamic> row = Map<String, dynamic>.from(
      rows.first as Map,
    );

    return GroupEntity(
      id: row["id"] as String? ?? fallbackGroup.id,
      name: row["name"] as String? ?? name,
      theme: GroupThemeType.byName(row["theme"] as String?),
      members: fallbackGroup.members,
      colorValue:
          (activityPayload["color_value"] as num?)?.toInt() ??
          fallbackGroup.colorValue,
      description: row["description"] as String? ?? description,
      ownerId: row["owner_id"] as String? ?? fallbackGroup.ownerId,
      createdAt:
          DateTime.tryParse(row["created_at"] as String? ?? "") ??
          fallbackGroup.createdAt,
      inviteCode: row["invite_code"] as String? ?? fallbackGroup.inviteCode,
      privacy: row["privacy"] as String? ?? fallbackGroup.privacy,
      createdActivityId:
          row["activity_id"] as String? ?? fallbackGroup.createdActivityId,
    );
  }

  Future<List<Map<String, dynamic>>> _selectRows({
    required String table,
    required String columns,
    required PostgrestTransformBuilder<PostgrestList> Function(
      PostgrestFilterBuilder<PostgrestList> query,
    )
    filters,
  }) async {
    final PostgrestList response = await filters(
      _supabaseService.requireClient.from(table).select(columns),
    ).timeout(_remoteCallTimeout);
    _logger.logResponse("select public.$table", response);
    return (response as List<dynamic>)
        .map((row) => Map<String, dynamic>.from(row as Map))
        .toList();
  }

  /// [withPhoto] stays off wherever the avatar is not rendered: the photo is an
  /// inline base64 blob and dominates the payload size.
  Future<Map<String, Map<String, dynamic>>> _profilesById(
    List<String> ids, {
    bool withPhoto = false,
  }) async {
    if (ids.isEmpty) {
      return const {};
    }
    final List<Map<String, dynamic>> profileRows = await _selectRows(
      table: "profiles",
      columns: withPhoto
          ? "id, nick_name, user_name, accent_color_value, "
                "avatar_icon_index, profile_photo_base64"
          : "id, nick_name, user_name, accent_color_value, avatar_icon_index",
      filters: (query) => query.inFilter("id", ids),
    );
    return {
      for (final Map<String, dynamic> row in profileRows)
        row["id"] as String: row,
    };
  }

  GroupMemberEntity _memberFromRows({
    required Map<String, dynamic> memberRow,
    required Map<String, dynamic>? profileRow,
    required Map<String, _PeriodScores> scoresByUser,
  }) {
    final String userId = memberRow["user_id"] as String;
    final _PeriodScores scores =
        scoresByUser[userId] ??
        const _PeriodScores(today: 0, week: 0, month: 0);

    return GroupMemberEntity(
      id: userId,
      name: profileDisplayName(profileRow, fallback: "User"),
      avatarColorValue:
          (profileRow?["accent_color_value"] as num?)?.toInt() ??
          GroupAvatarColors.byIndex(userId.hashCode.abs()),
      avatar: profileRow?["profile_photo_base64"] as String? ?? "",
      avatarIconIndex: (profileRow?["avatar_icon_index"] as num?)?.toInt(),
      todaySeconds: scores.today,
      weekSeconds: scores.week,
      monthSeconds: scores.month,
      totalSeconds: scores.total,
      role: memberRow["role"] as String? ?? "member",
      joinedAt: DateTime.tryParse(memberRow["joined_at"] as String? ?? ""),
    );
  }

  GroupImageMessageEntity _imageMessageFromRow(
    Map<String, dynamic> row, {
    required Map<String, dynamic>? profileRow,
  }) {
    final String senderId = row["sender_id"] as String;
    return GroupImageMessageEntity(
      id: row["id"] as String,
      groupId: row["group_id"] as String,
      senderId: senderId,
      imageBase64: row["image_base64"] as String? ?? "",
      createdAt:
          DateTime.tryParse(row["created_at"] as String? ?? "") ??
          DateTime.now(),
      senderName: profileDisplayName(profileRow, fallback: "Membro"),
      senderAvatar: profileRow?["profile_photo_base64"] as String? ?? "",
      senderAvatarIconIndex: (profileRow?["avatar_icon_index"] as num?)
          ?.toInt(),
      senderAvatarColorValue:
          (profileRow?["accent_color_value"] as num?)?.toInt() ??
          GroupAvatarColors.byIndex(senderId.hashCode.abs()),
    );
  }

  int _intValue(Object? value) => value is num ? value.toInt() : 0;

  DateTime _weekStart() {
    final DateTime today = DateTime.now().dateOnly.toUtc();
    return today.subtract(Duration(days: today.weekday - 1));
  }

  DateTime _monthStart() {
    final DateTime now = DateTime.now();
    return DateTime(now.year, now.month).toUtc();
  }
}

class _PeriodScores {
  const _PeriodScores({
    required this.today,
    required this.week,
    required this.month,
    this.total = 0,
  });

  final int today;
  final int week;
  final int month;
  final int total;
}
