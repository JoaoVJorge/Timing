import "package:dartz/dartz.dart";
import "package:flutter/foundation.dart";
import "package:help_out/core/domain/entities/friend_option.dart";
import "package:help_out/core/domain/entities/group_entity.dart";
import "package:help_out/core/domain/entities/group_image_message_entity.dart";
import "package:help_out/core/domain/entities/group_member_entity.dart";
import "package:help_out/core/domain/enums/group_theme_type.dart";
import "package:help_out/core/domain/errors/app_error.dart";
import "package:help_out/core/services/supabase/supabase_service.dart";
import "package:help_out/theme/group_colors.dart";

class GroupsDataSource {
  GroupsDataSource({required this._supabaseService});

  final SupabaseService _supabaseService;

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
        columns: "id, name, theme, owner_id, created_at, invite_code, privacy",
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
      final List<Map<String, dynamic>> activityRows = memberIds.isEmpty
          ? []
          : await _selectRows(
              table: "activity_entries",
              columns:
                  "user_id, category, occurred_at, seconds, pages, completed_tasks",
              filters: (query) => query
                  .inFilter("user_id", memberIds)
                  .gte("occurred_at", _monthStart().toIso8601String()),
            );

      final Map<String, List<Map<String, dynamic>>> membersByGroup = {};
      for (final Map<String, dynamic> row in memberRows) {
        final String groupId = row["group_id"] as String;
        membersByGroup.putIfAbsent(groupId, () => []).add(row);
      }

      // One pass per theme, shared by every group that uses it.
      final Map<GroupThemeType, Map<String, _PeriodScores>> scoresByTheme = {};

      return Right(
        groupRows.map((row) {
          final GroupThemeType theme = GroupThemeType.byName(
            row["theme"] as String?,
          );
          final Map<String, _PeriodScores> scoresByUser = scoresByTheme
              .putIfAbsent(
                theme,
                () => _scoresByUser(theme: theme, activityRows: activityRows),
              );
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

  Future<Either<AppError, GroupEntity>> createGroup({
    required String name,
    required GroupThemeType theme,
    required List<FriendOption> invitedFriends,
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
      };
      _logSqlStep(operation, createGroupPayload);
      final dynamic response = await _supabaseService.requireClient.rpc(
        "create_group_with_members",
        params: createGroupPayload,
      );
      final List<dynamic> rows = response as List<dynamic>;
      if (rows.isEmpty) {
        throw StateError("create_group_with_members returned no group row.");
      }
      final Map<String, dynamic> groupRow = Map<String, dynamic>.from(
        rows.first as Map,
      );
      final String groupId = groupRow["id"] as String;
      operation = "select public.profiles for group members";
      final Map<String, Map<String, dynamic>> profilesById =
          await _profilesById([
            userId,
            ...invitedFriends.map((item) => item.id),
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
          theme: theme,
        ),
        for (int index = 0; index < invitedFriends.length; index++)
          GroupMemberEntity(
            id: invitedFriends[index].id,
            name: invitedFriends[index].name,
            avatarColorValue: GroupAvatarColors.byIndex(index),
            todaySeconds: 0,
            weekSeconds: 0,
            monthSeconds: 0,
          ),
      ];

      return Right(
        GroupEntity(
          id: groupId,
          name: name,
          theme: theme,
          members: members,
          ownerId: userId,
          createdAt: DateTime.tryParse(groupRow["created_at"] as String? ?? ""),
          inviteCode: groupRow["invite_code"] as String? ?? "",
          privacy: groupRow["privacy"] as String? ?? "inviteOnly",
        ),
      );
    } catch (error, stackTrace) {
      _logSqlError(operation, error, stackTrace);
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

  int _scoreValue(Map<String, dynamic> row, GroupThemeType theme) =>
      switch (theme.unit) {
        GroupMetricUnit.hours => (row["seconds"] as num?)?.toInt() ?? 0,
        GroupMetricUnit.pages => (row["pages"] as num?)?.toInt() ?? 0,
        GroupMetricUnit.days => (row["completed_tasks"] as num?)?.toInt() ?? 0,
      };

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

  void _logSqlStep(String operation, Object payload) {
    debugPrint("[HelpOut][Supabase][$operation] payload: $payload");
  }

  void _logSqlError(String operation, Object error, StackTrace stackTrace) {
    debugPrint(
      "[HelpOut][Supabase][$operation] failed: "
      "${SqlOperationAppError.describe(error)}",
    );
    debugPrint("[HelpOut][Supabase][$operation] stack: $stackTrace");
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
