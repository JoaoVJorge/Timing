import "dart:async";

import "package:dartz/dartz.dart";
import "package:timing/core/domain/entities/friend_option.dart";
import "package:timing/core/domain/entities/group_activity_draft.dart";
import "package:timing/core/domain/entities/group_activity_progress_entity.dart";
import "package:timing/core/domain/entities/group_entity.dart";
import "package:timing/core/domain/entities/group_image_message_entity.dart";
import "package:timing/core/domain/entities/group_image_messages_page.dart";
import "package:timing/core/domain/entities/group_invite_option_entity.dart";
import "package:timing/core/domain/entities/group_invitation_entity.dart";
import "package:timing/core/domain/entities/group_member_entity.dart";
import "package:timing/core/domain/entities/sent_group_invitation_entity.dart";
import "package:timing/core/domain/enums/group_theme_type.dart";
import "package:timing/core/domain/errors/app_error.dart";
import "package:timing/core/services/log/app_logger_service.dart";
import "package:timing/core/services/supabase/supabase_service.dart";
import "package:timing/theme/group_colors.dart";
import "package:supabase_flutter/supabase_flutter.dart"
    show PostgrestFilterBuilder, PostgrestList, PostgrestTransformBuilder;

class GroupsDataSource {
  GroupsDataSource({required this._supabaseService, required this._logger});

  final SupabaseService _supabaseService;
  final AppLoggerService _logger;
  static const Duration _activityScoresTimeout = Duration(seconds: 8);
  static const int _imageMessagesPageSize = 50;

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
      final Map<String, Map<String, _PeriodScores>> scoresByGroup =
          await _leaderboardScoresForGroups(groupIds);

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

  Future<Map<String, Map<String, _PeriodScores>>> _leaderboardScoresForGroups(
    List<String> groupIds,
  ) async {
    if (groupIds.isEmpty) {
      return const {};
    }

    try {
      final dynamic response = await _supabaseService.requireClient
          .rpc(
            "group_leaderboard_scores",
            params: {
              "target_group_ids": groupIds,
              "today_start": _todayStart().toIso8601String(),
              "week_start": _weekStart().toIso8601String(),
              "month_start": _monthStart().toIso8601String(),
            },
          )
          .timeout(_activityScoresTimeout);
      _logger.logResponse("rpc public.group_leaderboard_scores", response);
      final List<dynamic> rows = response as List<dynamic>? ?? const [];
      final Map<String, Map<String, _PeriodScores>> scoresByGroup = {};
      for (final dynamic value in rows) {
        final Map<String, dynamic> row = Map<String, dynamic>.from(
          value as Map,
        );
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
    } on TimeoutException catch (error, stackTrace) {
      _logger.logError(
        "Timed out loading group leaderboard scores",
        error: error,
        stackTrace: stackTrace,
      );
      // The leaderboard is supplementary data. Groups and their members must
      // still be usable if score aggregation is temporarily unavailable.
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
          await _profilesById(friendIds, withPhoto: true);

      return Right(
        friendIds.map((id) {
          final Map<String, dynamic>? profile = profilesById[id];
          return (
            id: id,
            name: _displayName(profile, fallback: "Friend"),
            colorValue:
                (profile?["accent_color_value"] as num?)?.toInt() ??
                GroupAvatarColors.byIndex(id.hashCode.abs()),
            avatarIconIndex: (profile?["avatar_icon_index"] as num?)?.toInt(),
            profilePhotoBase64:
                profile?["profile_photo_base64"] as String? ?? "",
          );
        }).toList(),
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
      final dynamic response = await _supabaseService.requireClient.rpc(
        "invite_friend_to_group",
        params: {"target_group_id": groupId, "target_friend_id": friendId},
      );
      _logger.logResponse("rpc public.invite_friend_to_group", response);
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
      final dynamic response = await _supabaseService.requireClient.rpc(
        "cancel_group_invitation",
        params: {"target_group_id": groupId, "target_friend_id": friendId},
      );
      _logger.logResponse("rpc public.cancel_group_invitation", response);
      return const Right(null);
    } catch (error, stackTrace) {
      return Left(GenericAppError(error: error, stackTrace: stackTrace));
    }
  }

  Future<Either<AppError, GroupImageMessagesPage>> getImageMessages(
    String groupId, {
    GroupImageMessageEntity? before,
  }) async {
    try {
      final String? userId = _supabaseService.currentUserId;
      if (userId == null) {
        return const Right(
          GroupImageMessagesPage(messages: [], hasMore: false),
        );
      }

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
      final Map<String, Map<String, dynamic>> profilesById =
          await _profilesById(senderIds, withPhoto: true);

      return Right(
        GroupImageMessagesPage(
          messages: pageRows.reversed
              .map(
                (row) => _imageMessageFromRow(
                  row,
                  profileRow: profilesById[row["sender_id"]],
                ),
              )
              .toList(),
          hasMore: hasMore,
        ),
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

  Future<Either<AppError, void>> removeMember({
    required String groupId,
    required String memberId,
  }) async {
    try {
      await _supabaseService.requireClient
          .from("group_members")
          .delete()
          .eq("group_id", groupId)
          .eq("user_id", memberId);
      return const Right(null);
    } catch (error, stackTrace) {
      return Left(GenericAppError(error: error, stackTrace: stackTrace));
    }
  }

  Future<Either<AppError, void>> transferLeadership({
    required String groupId,
    required String nextLeaderId,
  }) async {
    const String operation = "rpc public.transfer_group_ownership";
    try {
      final Map<String, dynamic> payload = {
        "target_group_id": groupId,
        "next_owner_id": nextLeaderId,
      };
      _logger.logRequest(operation, payload);
      final dynamic response = await _supabaseService.requireClient.rpc(
        "transfer_group_ownership",
        params: payload,
      );
      _logger.logResponse(operation, response);
      return const Right(null);
    } catch (error, stackTrace) {
      _logger.logError(
        "Failed to transfer group ownership",
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

  Future<Either<AppError, void>> resetGroupProgress(String groupId) async {
    const String operation = "rpc public.reset_group_progress";
    try {
      _logger.logRequest(operation, {"target_group_id": groupId});
      final dynamic response = await _supabaseService.requireClient.rpc(
        "reset_group_progress",
        params: {"target_group_id": groupId},
      );
      _logger.logResponse(operation, response);
      return const Right(null);
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
          createdActivityId: groupRow["activity_id"] as String?,
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

  Future<Either<AppError, GroupEntity>> updateGroup({
    required GroupEntity group,
    required String name,
    required String description,
    required Map<String, dynamic> activityPayload,
  }) async {
    const String operation = "rpc public.update_group_with_activity";
    try {
      final Map<String, dynamic> payload = {
        "target_group_id": group.id,
        "group_name": name,
        "group_description": description,
        "activity_payload": activityPayload,
      };
      _logger.logRequest(operation, payload);
      final dynamic response = await _supabaseService.requireClient.rpc(
        "update_group_with_activity",
        params: payload,
      );
      _logger.logResponse(operation, response);

      final List<dynamic> rows = response as List<dynamic>;
      if (rows.isEmpty) {
        throw StateError("update_group_with_activity returned no group row.");
      }
      final Map<String, dynamic> row = Map<String, dynamic>.from(
        rows.first as Map,
      );

      return Right(
        GroupEntity(
          id: row["id"] as String? ?? group.id,
          name: row["name"] as String? ?? name,
          theme: GroupThemeType.byName(row["theme"] as String?),
          members: group.members,
          description: row["description"] as String? ?? description,
          ownerId: row["owner_id"] as String? ?? group.ownerId,
          createdAt:
              DateTime.tryParse(row["created_at"] as String? ?? "") ??
              group.createdAt,
          inviteCode: row["invite_code"] as String? ?? group.inviteCode,
          privacy: row["privacy"] as String? ?? group.privacy,
          createdActivityId:
              row["activity_id"] as String? ?? group.createdActivityId,
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
    required PostgrestTransformBuilder<PostgrestList> Function(
      PostgrestFilterBuilder<PostgrestList> query,
    )
    filters,
  }) async {
    final PostgrestList response = await filters(
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
      name: _displayName(profileRow, fallback: "User"),
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
      senderName: _displayName(profileRow, fallback: "Membro"),
      senderAvatar: profileRow?["profile_photo_base64"] as String? ?? "",
      senderAvatarIconIndex: (profileRow?["avatar_icon_index"] as num?)
          ?.toInt(),
      senderAvatarColorValue:
          (profileRow?["accent_color_value"] as num?)?.toInt() ??
          GroupAvatarColors.byIndex(senderId.hashCode.abs()),
    );
  }

  int _intValue(Object? value) => value is num ? value.toInt() : 0;

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
    final DateTime now = DateTime.now();
    return DateTime(now.year, now.month, now.day).toUtc();
  }

  DateTime _weekStart() {
    final DateTime today = _todayStart();
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
