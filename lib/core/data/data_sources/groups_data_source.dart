import "dart:async";

import "package:dartz/dartz.dart";
import "package:timing/core/domain/entities/friend_option.dart";
import "package:timing/core/domain/entities/group_activity_draft.dart";
import "package:timing/core/domain/entities/group_activity_progress_entity.dart";
import "package:timing/core/domain/entities/group_entity.dart";
import "package:timing/core/domain/entities/group_image_message_entity.dart";
import "package:timing/core/domain/entities/group_invite_option_entity.dart";
import "package:timing/core/domain/entities/group_invitation_entity.dart";
import "package:timing/core/domain/entities/group_member_entity.dart";
import "package:timing/core/domain/entities/sent_group_invitation_entity.dart";
import "package:timing/core/domain/enums/group_theme_type.dart";
import "package:timing/core/domain/errors/app_error.dart";
import "package:timing/core/services/log/app_logger_service.dart";
import "package:timing/core/services/supabase/supabase_service.dart";
import "package:timing/theme/group_colors.dart";

class GroupsDataSource {
  GroupsDataSource({required this._supabaseService, required this._logger});

  final SupabaseService _supabaseService;
  final AppLoggerService _logger;
  static const Duration _activityScoresTimeout = Duration(seconds: 8);

  Future<Either<AppError, List<GroupEntity>>> getGroups() async {
    try {
      final String? userId = _supabaseService.currentUserId;
      if (userId == null) {
        return const Right([]);
      }

      final List<Map<String, dynamic>> currentMemberships = await _selectRows(
        table: "group_members",
        columns: "group_id",
        filters: (query) => query.eq("user_id", userId),
      );
      final List<String> groupIds = currentMemberships
          .map((row) => row["group_id"] as String)
          .toList();
      if (groupIds.isEmpty) {
        return const Right([]);
      }

      final List<Map<String, dynamic>> groupRows = await _selectRows(
        table: "groups",
        columns:
            "id, name, theme, description, owner_id, created_at, "
            "invite_code, privacy",
        filters: (query) => query.inFilter("id", groupIds),
      );
      final List<Map<String, dynamic>> memberRows = await _selectRows(
        table: "group_members",
        columns: "group_id, user_id, role, joined_at",
        filters: (query) => query.inFilter("group_id", groupIds),
      );
      final List<String> memberIds = memberRows
          .map((row) => row["user_id"] as String)
          .toSet()
          .toList();
      final Map<String, Map<String, dynamic>> profilesById =
          await _profilesById(memberIds, withPhoto: true);
      final Map<GroupThemeType, Map<String, _PeriodScores>> scoresByTheme =
          await _leaderboardScoresForMembers(memberIds);

      final Map<String, List<Map<String, dynamic>>> membersByGroup = {};
      for (final Map<String, dynamic> row in memberRows) {
        final String groupId = row["group_id"] as String;
        membersByGroup.putIfAbsent(groupId, () => []).add(row);
      }

      return Right(
        groupRows.map((row) {
          final GroupThemeType theme = GroupThemeType.byName(
            row["theme"] as String?,
          );
          final Map<String, _PeriodScores> scoresByUser =
              scoresByTheme[theme] ?? const {};
          final String groupId = row["id"] as String;
          final List<GroupMemberEntity> members =
              membersByGroup[groupId]
                  ?.map(
                    (memberRow) => _memberFromRows(
                      memberRow: memberRow,
                      profileRow: profilesById[memberRow["user_id"]],
                      scoresByUser: scoresByUser,
                      theme: theme,
                    ),
                  )
                  .toList() ??
              [];

          return GroupEntity(
            id: groupId,
            name: row["name"] as String? ?? "",
            theme: theme,
            members: members,
            description: row["description"] as String? ?? "",
            ownerId: row["owner_id"] as String? ?? "",
            createdAt: DateTime.tryParse(row["created_at"] as String? ?? ""),
            inviteCode: row["invite_code"] as String? ?? "",
            privacy: row["privacy"] as String? ?? "inviteOnly",
          );
        }).toList(),
      );
    } catch (error, stackTrace) {
      return Left(GenericAppError(error: error, stackTrace: stackTrace));
    }
  }

  Future<Either<AppError, List<GroupActivityProgressEntity>>>
  getGroupActivityProgress(String groupId, {String? localDate}) async {
    try {
      final dynamic response = await _supabaseService.requireClient.rpc(
        "group_activity_progress",
        params: {"target_group_id": groupId, "local_date": localDate},
      );
      _logger.logResponse("rpc public.group_activity_progress", response);
      final List<dynamic> rows = response as List<dynamic>? ?? const [];
      return Right(
        rows
            .map(
              (row) => GroupActivityProgressEntity.fromMap(
                Map<String, dynamic>.from(row as Map),
              ),
            )
            .toList(),
      );
    } catch (error, stackTrace) {
      _logger.logError(
        "Failed to load group_activity_progress",
        error: error,
        stackTrace: stackTrace,
      );
      return Left(GenericAppError(error: error, stackTrace: stackTrace));
    }
  }

  Future<List<Map<String, dynamic>>> _activityRowsForMembers(
    List<String> memberIds,
  ) async {
    if (memberIds.isEmpty) {
      return const [];
    }

    try {
      return await _selectRows(
        table: "activity_entries",
        columns:
            "user_id, category, occurred_at, seconds, pages, completed_tasks",
        filters: (query) => query
            .inFilter("user_id", memberIds)
            .gte("occurred_at", _monthStart().toIso8601String()),
      ).timeout(_activityScoresTimeout);
    } on TimeoutException catch (error, stackTrace) {
      _logger.logError(
        "Timed out loading group leaderboard scores",
        error: error,
        stackTrace: stackTrace,
      );
      return const [];
    }
  }

  Future<Map<GroupThemeType, Map<String, _PeriodScores>>>
  _leaderboardScoresForMembers(List<String> memberIds) async {
    if (memberIds.isEmpty) {
      return const {};
    }

    try {
      final List<List<Map<String, dynamic>>> rowsByPeriod = await Future.wait([
        _aggregatedActivityScores(memberIds, _todayStart()),
        _aggregatedActivityScores(memberIds, _weekStart()),
        _aggregatedActivityScores(memberIds, _monthStart()),
      ]);
      return _scoresByThemeFromAggregates(
        todayRows: rowsByPeriod[0],
        weekRows: rowsByPeriod[1],
        monthRows: rowsByPeriod[2],
      );
    } catch (error, stackTrace) {
      _logger.logError(
        "Failed to load aggregated group leaderboard scores",
        error: error,
        stackTrace: stackTrace,
      );
      final List<Map<String, dynamic>> activityRows =
          await _activityRowsForMembers(memberIds);
      return {
        for (final GroupThemeType theme in GroupThemeType.values)
          theme: _scoresByUser(theme: theme, activityRows: activityRows),
      };
    }
  }

  Future<List<Map<String, dynamic>>> _aggregatedActivityScores(
    List<String> memberIds,
    DateTime periodStart,
  ) async {
    return await _selectRows(
      table: "activity_entries",
      columns:
          "user_id, category, total_seconds:seconds.sum(), "
          "total_pages:pages.sum(), "
          "total_completed_tasks:completed_tasks.sum()",
      filters: (query) => query
          .inFilter("user_id", memberIds)
          .gte("occurred_at", periodStart.toIso8601String()),
    ).timeout(_activityScoresTimeout);
  }

  Future<Either<AppError, List<FriendOption>>> getInvitableFriends() async {
    try {
      final String? userId = _supabaseService.currentUserId;
      if (userId == null) {
        return const Right([]);
      }

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
      final Map<String, Map<String, dynamic>> profilesById =
          await _profilesById(friendIds);

      return Right(
        friendIds
            .map(
              (id) => (
                id: id,
                name: _displayName(profilesById[id], fallback: "Friend"),
              ),
            )
            .toList(),
      );
    } catch (error, stackTrace) {
      return Left(GenericAppError(error: error, stackTrace: stackTrace));
    }
  }

  Future<Either<AppError, List<GroupInviteOptionEntity>>> getGroupInviteOptions(
    String groupId,
  ) async {
    try {
      final dynamic response = await _supabaseService.requireClient.rpc(
        "group_invite_options",
        params: {"target_group_id": groupId},
      );
      _logger.logResponse("rpc public.group_invite_options", response);
      final List<dynamic> rows = response as List<dynamic>? ?? const [];
      return Right(
        rows
            .map(
              (row) => GroupInviteOptionEntity.fromMap(
                Map<String, dynamic>.from(row as Map),
              ),
            )
            .toList(),
      );
    } catch (error, stackTrace) {
      return Left(GenericAppError(error: error, stackTrace: stackTrace));
    }
  }

  Future<Either<AppError, void>> inviteFriendToGroup({
    required String groupId,
    required String friendId,
  }) async {
    try {
      await _supabaseService.requireClient.rpc(
        "invite_friend_to_group",
        params: {"target_group_id": groupId, "target_friend_id": friendId},
      );
      return const Right(null);
    } catch (error, stackTrace) {
      return Left(GenericAppError(error: error, stackTrace: stackTrace));
    }
  }

  Future<Either<AppError, void>> cancelGroupInvitation({
    required String groupId,
    required String friendId,
  }) async {
    try {
      await _supabaseService.requireClient.rpc(
        "cancel_group_invitation",
        params: {"target_group_id": groupId, "target_friend_id": friendId},
      );
      return const Right(null);
    } catch (error, stackTrace) {
      return Left(GenericAppError(error: error, stackTrace: stackTrace));
    }
  }

  Future<Either<AppError, List<GroupImageMessageEntity>>> getImageMessages(
    String groupId,
  ) async {
    try {
      final String? userId = _supabaseService.currentUserId;
      if (userId == null) {
        return const Right([]);
      }

      final List<Map<String, dynamic>> rows = await _selectRows(
        table: "group_image_messages",
        columns: "id, group_id, sender_id, image_base64, created_at",
        filters: (query) =>
            query.eq("group_id", groupId).order("created_at", ascending: true),
      );
      final List<String> senderIds = rows
          .map((row) => row["sender_id"] as String)
          .toSet()
          .toList();
      final Map<String, Map<String, dynamic>> profilesById =
          await _profilesById(senderIds, withPhoto: true);

      return Right(
        rows
            .map(
              (row) => _imageMessageFromRow(
                row,
                profileRow: profilesById[row["sender_id"]],
              ),
            )
            .toList(),
      );
    } catch (error, stackTrace) {
      return Left(GenericAppError(error: error, stackTrace: stackTrace));
    }
  }

  Future<Either<AppError, GroupImageMessageEntity>> sendImageMessage({
    required String groupId,
    required String imageBase64,
  }) async {
    try {
      final String? userId = _supabaseService.currentUserId;
      if (userId == null) {
        return Left(
          GenericAppError(
            error: StateError("User must be signed in to send images."),
            stackTrace: StackTrace.current,
          ),
        );
      }

      final Map<String, dynamic> row = await _supabaseService.requireClient
          .from("group_image_messages")
          .insert({
            "group_id": groupId,
            "sender_id": userId,
            "image_base64": imageBase64,
          })
          .select("id, group_id, sender_id, image_base64, created_at")
          .single();
      _logger.logResponse("insert public.group_image_messages", row);
      final Map<String, Map<String, dynamic>> profilesById =
          await _profilesById([userId], withPhoto: true);

      return Right(_imageMessageFromRow(row, profileRow: profilesById[userId]));
    } catch (error, stackTrace) {
      return Left(GenericAppError(error: error, stackTrace: stackTrace));
    }
  }

  Future<Either<AppError, void>> leaveGroup(String groupId) async {
    try {
      final String? userId = _supabaseService.currentUserId;
      if (userId == null) {
        return Left(
          GenericAppError(
            error: StateError("User must be signed in to leave a group."),
            stackTrace: StackTrace.current,
          ),
        );
      }

      await _supabaseService.requireClient
          .from("group_members")
          .delete()
          .eq("group_id", groupId)
          .eq("user_id", userId);
      return const Right(null);
    } catch (error, stackTrace) {
      return Left(GenericAppError(error: error, stackTrace: stackTrace));
    }
  }

  Future<Either<AppError, List<GroupInvitationEntity>>>
  getPendingInvitations() async {
    try {
      final String? userId = _supabaseService.currentUserId;
      if (userId == null) {
        return const Right([]);
      }
      final dynamic response = await _supabaseService.requireClient.rpc(
        "pending_group_invitations",
      );
      _logger.logResponse("rpc public.pending_group_invitations", response);
      final List<dynamic> rows = response as List<dynamic>? ?? const [];
      return Right(
        rows
            .map(
              (row) => GroupInvitationEntity.fromMap(
                Map<String, dynamic>.from(row as Map),
              ),
            )
            .toList(),
      );
    } catch (error, stackTrace) {
      return Left(GenericAppError(error: error, stackTrace: stackTrace));
    }
  }

  Future<Either<AppError, List<SentGroupInvitationEntity>>>
  getSentInvitations() async {
    try {
      final String? userId = _supabaseService.currentUserId;
      if (userId == null) {
        return const Right([]);
      }

      final List<Map<String, dynamic>> invitationRows = await _selectRows(
        table: "group_invitations",
        columns: "id, group_id, invitee_id, created_at",
        filters: (query) => query
            .eq("inviter_id", userId)
            .eq("status", "pending")
            .order("created_at", ascending: false),
      );
      if (invitationRows.isEmpty) {
        return const Right([]);
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
      final Map<String, Map<String, dynamic>> profilesById =
          await _profilesById(inviteeIds);

      return Right(
        invitationRows.map((row) {
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
            inviteeName: _displayName(profileRow, fallback: "Amigo"),
            inviteeColorValue:
                (profileRow?["accent_color_value"] as num?)?.toInt() ??
                GroupAvatarColors.byIndex(inviteeId.hashCode.abs()),
            createdAt: DateTime.tryParse(row["created_at"] as String? ?? ""),
          );
        }).toList(),
      );
    } catch (error, stackTrace) {
      return Left(GenericAppError(error: error, stackTrace: stackTrace));
    }
  }

  Future<Either<AppError, GroupEntity>> acceptInvitation(
    String invitationId,
  ) async {
    String operation = "rpc public.accept_group_invitation";
    try {
      dynamic response;
      try {
        response = await _supabaseService.requireClient.rpc(
          "accept_group_invitation",
          params: {"invitation_id": invitationId},
        );
      } catch (error) {
        if (_isRecoverableAcceptInvitationRpcError(error)) {
          return await _acceptInvitationDirectly(invitationId);
        }
        if (!_isRpcSignatureError(error)) {
          rethrow;
        }
        try {
          response = await _supabaseService.requireClient.rpc(
            "accept_group_invitation",
            params: {"target_invitation_id": invitationId},
          );
        } catch (fallbackError) {
          if (_isRecoverableAcceptInvitationRpcError(fallbackError)) {
            return await _acceptInvitationDirectly(invitationId);
          }
          rethrow;
        }
      }
      _logger.logResponse(operation, response);
      final String? groupId = _groupIdFromRpcResponse(response);
      if (groupId != null) {
        return await _groupByIdAfterMembershipChange(groupId);
      }
      return await _acceptInvitationDirectly(invitationId);
    } catch (error, stackTrace) {
      _logger.logError(
        "Supabase $operation failed",
        error: SqlOperationAppError.describe(error),
        stackTrace: stackTrace,
      );
      return Left(GenericAppError(error: error, stackTrace: stackTrace));
    }
  }

  Future<Either<AppError, void>> declineInvitation(String invitationId) async {
    try {
      await _supabaseService.requireClient.rpc(
        "decline_group_invitation",
        params: {"invitation_id": invitationId},
      );
      return const Right(null);
    } catch (error, stackTrace) {
      return Left(GenericAppError(error: error, stackTrace: stackTrace));
    }
  }

  Future<Either<AppError, GroupEntity>> joinGroupByInviteCode(
    String inviteCode,
  ) async {
    String operation = "rpc public.join_group_by_invite_code";
    try {
      final String code = inviteCode.trim().toUpperCase();
      if (code.isEmpty) {
        throw ArgumentError("Invite code must not be empty.");
      }
      dynamic response;
      try {
        response = await _supabaseService.requireClient.rpc(
          "join_group_by_invite_code",
          params: {"lookup_code": code},
        );
      } catch (error) {
        if (!_isRpcSignatureError(error)) {
          rethrow;
        }
        response = await _supabaseService.requireClient.rpc(
          "join_group_by_invite_code",
          params: {"invite_code": code},
        );
      }
      _logger.logResponse(operation, response);
      final String? groupId = _groupIdFromRpcResponse(response);
      if (groupId == null) {
        throw StateError("join_group_by_invite_code returned no group row.");
      }
      return await _groupByIdAfterMembershipChange(groupId);
    } catch (error, stackTrace) {
      _logger.logError(
        "Supabase $operation failed",
        error: SqlOperationAppError.describe(error),
        stackTrace: stackTrace,
      );
      return Left(GenericAppError(error: error, stackTrace: stackTrace));
    }
  }

  Future<Either<AppError, GroupEntity>> _acceptInvitationDirectly(
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
        .maybeSingle();
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
        await _supabaseService.requireClient.from("group_members").insert({
          "group_id": groupId,
          "user_id": userId,
          "role": "member",
          "joined_at": DateTime.now().toUtc().toIso8601String(),
        });
      } catch (error) {
        if (!_isUniqueViolation(error)) {
          rethrow;
        }
      }
      await _supabaseService.requireClient
          .from("group_invitations")
          .update({"status": "accepted"})
          .eq("id", invitationId)
          .eq("invitee_id", userId);
    }

    return await _groupByIdAfterMembershipChange(groupId);
  }

  Future<Either<AppError, GroupEntity>> _groupByIdAfterMembershipChange(
    String groupId,
  ) async {
    final Either<AppError, List<GroupEntity>> groupsResult = await getGroups();
    return groupsResult.fold(Left.new, (groups) {
      for (final GroupEntity item in groups) {
        if (item.id == groupId) {
          return Right(item);
        }
      }
      throw StateError("Joined group was not returned by getGroups.");
    });
  }

  String? _groupIdFromRpcResponse(dynamic response) {
    final Map<String, dynamic>? row = _firstRpcRow(response);
    final Object? rawId = row?["id"] ?? row?["group_id"];
    final String? id = rawId?.toString();
    return id == null || id.isEmpty ? null : id;
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
    final String description = SqlOperationAppError.describe(error);
    return description.contains("PGRST202") ||
        description.contains("42883") ||
        description.contains("function") && description.contains("not found");
  }

  bool _isRecoverableAcceptInvitationRpcError(Object error) {
    final String description = SqlOperationAppError.describe(error);
    return description.contains("42702") || description.contains("ambiguous");
  }

  bool _isUniqueViolation(Object error) {
    final String description = SqlOperationAppError.describe(error);
    return description.contains("23505") ||
        description.contains("duplicate key");
  }

  Future<Either<AppError, GroupEntity>> createGroup({
    required String name,
    required GroupThemeType theme,
    required List<FriendOption> invitedFriends,
    String description = "",
    GroupActivityDraft? activity,
  }) async {
    String operation = "checking signed-in user";
    try {
      final String? userId = _supabaseService.currentUserId;
      if (userId == null) {
        return Left(
          GenericAppError(
            error: StateError("User must be signed in to create a group."),
            stackTrace: StackTrace.current,
          ),
        );
      }

      operation = "rpc public.create_group_with_members";
      final Map<String, dynamic> createGroupPayload = {
        "group_name": name,
        "group_theme": theme.name,
        "invited_friend_ids": invitedFriends
            .map((friend) => friend.id)
            .toList(),
        "group_description": description,
        "activity_kind": activity?.kindName,
        "activity_payload": activity?.toPayload(),
      };
      _logger.logRequest(operation, createGroupPayload);
      final dynamic response = await _supabaseService.requireClient.rpc(
        "create_group_with_members",
        params: createGroupPayload,
      );
      _logger.logResponse(operation, response);
      final List<dynamic> rows = response as List<dynamic>;
      if (rows.isEmpty) {
        throw StateError("create_group_with_members returned no group row.");
      }
      final Map<String, dynamic> groupRow = Map<String, dynamic>.from(
        rows.first as Map,
      );
      final String groupId = groupRow["id"] as String;
      operation = "select public.profiles for group owner";
      final Map<String, Map<String, dynamic>> profilesById =
          await _profilesById([userId], withPhoto: true);
      final DateTime now = DateTime.now().toUtc();
      // Invited friends are not members yet: they get a pending invitation and
      // only appear once they accept. The new group starts with the owner only.
      final List<GroupMemberEntity> members = [
        _memberFromRows(
          memberRow: {
            "user_id": userId,
            "role": "owner",
            "joined_at": now.toIso8601String(),
          },
          profileRow: profilesById[userId],
          scoresByUser: const {},
          theme: theme,
        ),
      ];

      return Right(
        GroupEntity(
          id: groupId,
          name: name,
          theme: theme,
          members: members,
          description: groupRow["description"] as String? ?? description,
          ownerId: userId,
          createdAt: DateTime.tryParse(groupRow["created_at"] as String? ?? ""),
          inviteCode: groupRow["invite_code"] as String? ?? "",
          privacy: groupRow["privacy"] as String? ?? "inviteOnly",
        ),
      );
    } catch (error, stackTrace) {
      _logger.logError(
        "Supabase $operation failed",
        error: SqlOperationAppError.describe(error),
        stackTrace: stackTrace,
      );
      return Left(
        SqlOperationAppError(
          operation: operation,
          error: error,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  Future<List<Map<String, dynamic>>> _selectRows({
    required String table,
    required String columns,
    required dynamic Function(dynamic query) filters,
  }) async {
    final dynamic response = await filters(
      _supabaseService.requireClient.from(table).select(columns),
    );
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
          ? "id, nick_name, user_name, accent_color_value, profile_photo_base64"
          : "id, nick_name, user_name, accent_color_value",
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
    required GroupThemeType theme,
  }) {
    final String userId = memberRow["user_id"] as String;
    final _PeriodScores scores =
        scoresByUser[userId] ??
        const _PeriodScores(today: 0, week: 0, month: 0);

    return GroupMemberEntity(
      id: userId,
      name: _displayName(profileRow, fallback: "User"),
      avatarColorValue:
          (profileRow?["accent_color_value"] as num?)?.toInt() ??
          GroupAvatarColors.byIndex(userId.hashCode.abs()),
      avatar: profileRow?["profile_photo_base64"] as String? ?? "",
      todaySeconds: scores.today,
      weekSeconds: scores.week,
      monthSeconds: scores.month,
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
      senderName: _displayName(profileRow, fallback: "Membro"),
      senderAvatar: profileRow?["profile_photo_base64"] as String? ?? "",
      senderAvatarColorValue:
          (profileRow?["accent_color_value"] as num?)?.toInt() ??
          GroupAvatarColors.byIndex(senderId.hashCode.abs()),
    );
  }

  /// Walks the activity rows once and parses each timestamp once, instead of
  /// re-scanning the whole list for every member of every group.
  Map<String, _PeriodScores> _scoresByUser({
    required GroupThemeType theme,
    required List<Map<String, dynamic>> activityRows,
  }) {
    final DateTime todayStart = _todayStart();
    final DateTime weekStart = _weekStart();
    final DateTime monthStart = _monthStart();
    final Map<String, _PeriodScores> scores = {};

    for (final Map<String, dynamic> row in activityRows) {
      if (row["category"] != theme.name) {
        continue;
      }
      final DateTime? occurredAt = DateTime.tryParse(
        row["occurred_at"] as String? ?? "",
      )?.toUtc();
      if (occurredAt == null || occurredAt.isBefore(monthStart)) {
        continue;
      }

      final String userId = row["user_id"] as String;
      final _PeriodScores current =
          scores[userId] ?? const _PeriodScores(today: 0, week: 0, month: 0);
      final int value = _scoreValue(row, theme);
      scores[userId] = _PeriodScores(
        today: !occurredAt.isBefore(todayStart)
            ? current.today + value
            : current.today,
        week: !occurredAt.isBefore(weekStart)
            ? current.week + value
            : current.week,
        month: current.month + value,
      );
    }

    return scores;
  }

  Map<GroupThemeType, Map<String, _PeriodScores>> _scoresByThemeFromAggregates({
    required List<Map<String, dynamic>> todayRows,
    required List<Map<String, dynamic>> weekRows,
    required List<Map<String, dynamic>> monthRows,
  }) {
    final Map<GroupThemeType, Map<String, _PeriodScores>> scoresByTheme = {
      for (final GroupThemeType theme in GroupThemeType.values)
        theme: <String, _PeriodScores>{},
    };

    void merge(
      List<Map<String, dynamic>> rows, {
      required int Function(_PeriodScores current, int value) today,
      required int Function(_PeriodScores current, int value) week,
      required int Function(_PeriodScores current, int value) month,
    }) {
      for (final Map<String, dynamic> row in rows) {
        final String? userId = row["user_id"] as String?;
        if (userId == null) {
          continue;
        }
        final GroupThemeType? theme = _themeByName(row["category"] as String?);
        if (theme == null) {
          continue;
        }
        final int value = _aggregateScoreValue(row, theme);
        final Map<String, _PeriodScores> scoresByUser = scoresByTheme[theme] ??=
            <String, _PeriodScores>{};
        final _PeriodScores current =
            scoresByUser[userId] ??
            const _PeriodScores(today: 0, week: 0, month: 0);
        scoresByUser[userId] = _PeriodScores(
          today: today(current, value),
          week: week(current, value),
          month: month(current, value),
        );
      }
    }

    merge(
      todayRows,
      today: (_, value) => value,
      week: (current, _) => current.week,
      month: (current, _) => current.month,
    );
    merge(
      weekRows,
      today: (current, _) => current.today,
      week: (_, value) => value,
      month: (current, _) => current.month,
    );
    merge(
      monthRows,
      today: (current, _) => current.today,
      week: (current, _) => current.week,
      month: (_, value) => value,
    );

    return scoresByTheme;
  }

  int _scoreValue(Map<String, dynamic> row, GroupThemeType theme) =>
      switch (theme.unit) {
        GroupMetricUnit.hours => (row["seconds"] as num?)?.toInt() ?? 0,
        GroupMetricUnit.pages => (row["pages"] as num?)?.toInt() ?? 0,
        GroupMetricUnit.days => (row["completed_tasks"] as num?)?.toInt() ?? 0,
      };

  int _aggregateScoreValue(Map<String, dynamic> row, GroupThemeType theme) =>
      switch (theme.unit) {
        GroupMetricUnit.hours => _intValue(row["total_seconds"]),
        GroupMetricUnit.pages => _intValue(row["total_pages"]),
        GroupMetricUnit.days => _intValue(row["total_completed_tasks"]),
      };

  int _intValue(Object? value) => value is num ? value.toInt() : 0;

  GroupThemeType? _themeByName(String? name) {
    for (final GroupThemeType value in GroupThemeType.values) {
      if (value.name == name) {
        return value;
      }
    }
    return null;
  }

  String _displayName(Map<String, dynamic>? row, {required String fallback}) {
    if (row == null) {
      return fallback;
    }
    final String nickName = row["nick_name"] as String? ?? "";
    if (nickName.trim().isNotEmpty) {
      return nickName.trim();
    }
    final String userName = row["user_name"] as String? ?? "";
    if (userName.trim().isNotEmpty) {
      return userName.trim();
    }
    return fallback;
  }

  DateTime _todayStart() {
    final DateTime now = DateTime.now().toUtc();
    return DateTime.utc(now.year, now.month, now.day);
  }

  DateTime _weekStart() {
    final DateTime today = _todayStart();
    return today.subtract(Duration(days: today.weekday - 1));
  }

  DateTime _monthStart() {
    final DateTime now = DateTime.now().toUtc();
    return DateTime.utc(now.year, now.month);
  }
}

class _PeriodScores {
  const _PeriodScores({
    required this.today,
    required this.week,
    required this.month,
  });

  final int today;
  final int week;
  final int month;
}
