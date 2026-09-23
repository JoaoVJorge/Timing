import "dart:async";
import "dart:convert";

import "package:dartz/dartz.dart";
import "package:timing/core/domain/entities/friend_entity.dart";
import "package:timing/core/domain/entities/friend_presence_entity.dart";
import "package:timing/core/domain/entities/friend_suggestion_entity.dart";
import "package:timing/core/domain/entities/friends_social_entity.dart";
import "package:timing/core/domain/errors/app_error.dart";
import "package:timing/core/services/local_storage/app_local_storage_service.dart";
import "package:timing/core/services/local_storage/local_storage_keys.dart";
import "package:timing/core/services/log/app_logger_service.dart";
import "package:timing/core/services/supabase/supabase_service.dart";
import "package:timing/core/services/sync/pending_sync_store.dart";
import "package:timing/theme/group_colors.dart";

class FriendsDataSource {
  FriendsDataSource({
    required this._supabaseService,
    required this._logger,
    required this._localStorageService,
    required this._pendingSyncStore,
  });

  final SupabaseService _supabaseService;
  final AppLoggerService _logger;
  final AppLocalStorageService _localStorageService;
  final PendingSyncStore _pendingSyncStore;
  static const Duration _offlineFallbackTimeout = Duration(seconds: 8);
  // Every other remote call below must fail fast on a "connected but no real
  // internet" network so its try/catch can queue the write for retry or
  // surface the offline notice, instead of hanging on the platform's own
  // (much longer) socket timeout.
  static const Duration _remoteCallTimeout = Duration(seconds: 10);

  Future<Either<AppError, List<FriendPresenceEntity>>> getPresences(
    List<String> friendIds,
  ) async {
    if (friendIds.isEmpty) {
      return const Right([]);
    }
    try {
      final List<Map<String, dynamic>> rows = await _selectRows(
        table: "profile_presence_status",
        columns: "id, is_online, last_seen_at",
        filters: (query) => query.inFilter("id", friendIds),
      );
      return Right(
        rows
            .map(
              (row) => FriendPresenceEntity(
                id: row["id"] as String,
                isOnline: row["is_online"] as bool? ?? false,
                lastSeenAt: DateTime.tryParse(
                  row["last_seen_at"] as String? ?? "",
                ),
              ),
            )
            .toList(),
      );
    } catch (error, stackTrace) {
      return Left(GenericAppError(error: error, stackTrace: stackTrace));
    }
  }

  /// Like [GroupsDataSource.getGroups], this is remote-authoritative shared
  /// state: try the backend first (unchanged from before), only falling back
  /// to the last cached snapshot if that fails, with an inner timeout so an
  /// offline device sees it quickly instead of after a long OS timeout.
  Future<Either<AppError, FriendsSocialEntity>> getSocial() async {
    final String? userId = _supabaseService.currentUserId;
    if (userId == null) {
      return const Right(FriendsSocialEntity.empty());
    }

    try {
      final FriendsSocialEntity social = await _fetchRemoteSocial(
        userId,
      ).timeout(_offlineFallbackTimeout);
      await _cacheSocial(social);
      return Right(social);
    } catch (error, stackTrace) {
      final FriendsSocialEntity? cached = await _readCachedSocial();
      if (cached != null) {
        return Right(cached);
      }
      return Left(GenericAppError(error: error, stackTrace: stackTrace));
    }
  }

  Future<FriendsSocialEntity> _fetchRemoteSocial(String userId) async {
    final Map<String, dynamic>? profileRow = await _supabaseService
        .requireClient
        .from("profiles")
        .select("friend_code")
        .eq("id", userId)
        .maybeSingle();
    _logger.logResponse("select public.profiles (friend_code)", profileRow);
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
    final Map<String, Map<String, dynamic>> profilesById = await _profilesById(
      profileIds.toList(),
    );

    return FriendsSocialEntity(
      inviteCode:
          profileRow?["friend_code"] as String? ??
          userId.substring(0, 8).toUpperCase(),
      requests: incomingRows.map((row) {
        final String requesterId = row["requester_id"] as String;
        return _friendFromRow(
          userId: requesterId,
          friendshipId: row["id"] as String,
          profileRow: profilesById[requesterId],
        );
      }).toList(),
      sentRequests: outgoingRows.map((row) {
        final String addresseeId = row["addressee_id"] as String;
        return _friendFromRow(
          userId: addresseeId,
          friendshipId: row["id"] as String,
          profileRow: profilesById[addresseeId],
        );
      }).toList(),
      friends: friendRows.map((row) {
        final String friendId = row["requester_id"] == userId
            ? row["addressee_id"] as String
            : row["requester_id"] as String;
        return _friendFromRow(
          userId: friendId,
          friendshipId: row["id"] as String,
          profileRow: profilesById[friendId],
        );
      }).toList(),
    );
  }

  Future<Either<AppError, void>> sendFriendRequest(String addresseeId) async {
    final String? userId = _supabaseService.currentUserId;
    if (userId == null) {
      return _signedOut("send a friend request");
    }
    try {
      await _sendFriendRequestRemote(userId, addresseeId);
      return const Right(null);
    } catch (error, stackTrace) {
      _logger.logError(
        "Failed to send friend request, queueing for retry",
        error: error,
        stackTrace: stackTrace,
      );
      await _enqueueFriendAction({
        "type": "sendFriendRequest",
        "addresseeId": addresseeId,
      });
      return const Right(null);
    }
  }

  Future<void> _sendFriendRequestRemote(
    String userId,
    String addresseeId,
  ) async {
    await _supabaseService.requireClient
        .from("friendships")
        .insert({
          "requester_id": userId,
          "addressee_id": addresseeId,
          "status": "pending",
        })
        .timeout(_remoteCallTimeout);
  }

  Future<Either<AppError, void>> acceptRequest(String friendshipId) async {
    FriendsSocialEntity acceptInCache(FriendsSocialEntity social) {
      final FriendEntity? match = _findByFriendshipId(
        social.requests,
        friendshipId,
      );
      if (match == null) {
        return social;
      }
      return FriendsSocialEntity(
        inviteCode: social.inviteCode,
        requests: social.requests
            .where((item) => item.friendshipId != friendshipId)
            .toList(),
        sentRequests: social.sentRequests,
        friends: [
          ...social.friends.where((item) => item.id != match.id),
          match,
        ],
      );
    }

    try {
      await _acceptRequestRemote(friendshipId);
      await _updateCachedSocial(acceptInCache);
      return const Right(null);
    } catch (error, stackTrace) {
      _logger.logError(
        "Failed to accept friend request, queueing for retry",
        error: error,
        stackTrace: stackTrace,
      );
      await _updateCachedSocial(acceptInCache);
      await _enqueueFriendAction({
        "type": "acceptRequest",
        "friendshipId": friendshipId,
      });
      return const Right(null);
    }
  }

  Future<void> _acceptRequestRemote(String friendshipId) async {
    await _supabaseService.requireClient
        .from("friendships")
        .update({"status": "accepted"})
        .eq("id", friendshipId)
        .timeout(_remoteCallTimeout);
  }

  Future<Either<AppError, void>> declineRequest(String friendshipId) async {
    FriendsSocialEntity declineInCache(FriendsSocialEntity social) =>
        FriendsSocialEntity(
          inviteCode: social.inviteCode,
          requests: social.requests
              .where((item) => item.friendshipId != friendshipId)
              .toList(),
          sentRequests: social.sentRequests,
          friends: social.friends,
        );

    try {
      await _declineRequestRemote(friendshipId);
      await _updateCachedSocial(declineInCache);
      return const Right(null);
    } catch (error, stackTrace) {
      _logger.logError(
        "Failed to decline friend request, queueing for retry",
        error: error,
        stackTrace: stackTrace,
      );
      await _updateCachedSocial(declineInCache);
      await _enqueueFriendAction({
        "type": "declineRequest",
        "friendshipId": friendshipId,
      });
      return const Right(null);
    }
  }

  Future<void> _declineRequestRemote(String friendshipId) async {
    await _supabaseService.requireClient
        .from("friendships")
        .delete()
        .eq("id", friendshipId)
        .timeout(_remoteCallTimeout);
  }

  Future<Either<AppError, void>> cancelSentRequest({
    required String addresseeId,
    String friendshipId = "",
  }) async {
    final String? userId = _supabaseService.currentUserId;
    if (friendshipId.isEmpty && userId == null) {
      return _signedOut("cancel a friend request");
    }
    FriendsSocialEntity cancelInCache(FriendsSocialEntity social) =>
        FriendsSocialEntity(
          inviteCode: social.inviteCode,
          requests: social.requests,
          sentRequests: social.sentRequests
              .where(
                (item) =>
                    item.friendshipId != friendshipId &&
                    item.id != addresseeId,
              )
              .toList(),
          friends: social.friends,
        );
    try {
      await _cancelSentRequestRemote(
        userId: userId,
        addresseeId: addresseeId,
        friendshipId: friendshipId,
      );
      await _updateCachedSocial(cancelInCache);
      return const Right(null);
    } catch (error, stackTrace) {
      _logger.logError(
        "Failed to cancel friend request, queueing for retry",
        error: error,
        stackTrace: stackTrace,
      );
      await _updateCachedSocial(cancelInCache);
      await _enqueueFriendAction({
        "type": "cancelSentRequest",
        "addresseeId": addresseeId,
        "friendshipId": friendshipId,
      });
      return const Right(null);
    }
  }

  Future<void> _cancelSentRequestRemote({
    required String? userId,
    required String addresseeId,
    required String friendshipId,
  }) async {
    if (friendshipId.isNotEmpty) {
      await _supabaseService.requireClient
          .from("friendships")
          .delete()
          .eq("id", friendshipId)
          .timeout(_remoteCallTimeout);
      return;
    }
    await _supabaseService.requireClient
        .from("friendships")
        .delete()
        .eq("requester_id", userId!)
        .eq("addressee_id", addresseeId)
        .eq("status", "pending")
        .timeout(_remoteCallTimeout);
  }

  Future<Either<AppError, void>> removeFriend({
    required String friendId,
    String friendshipId = "",
  }) async {
    final String? userId = _supabaseService.currentUserId;
    if (friendshipId.isEmpty && userId == null) {
      return _signedOut("remove a friend");
    }
    FriendsSocialEntity removeInCache(FriendsSocialEntity social) =>
        FriendsSocialEntity(
          inviteCode: social.inviteCode,
          requests: social.requests,
          sentRequests: social.sentRequests,
          friends: social.friends
              .where(
                (item) =>
                    item.friendshipId != friendshipId && item.id != friendId,
              )
              .toList(),
        );
    try {
      await _removeFriendRemote(
        userId: userId,
        friendId: friendId,
        friendshipId: friendshipId,
      );
      await _updateCachedSocial(removeInCache);
      return const Right(null);
    } catch (error, stackTrace) {
      _logger.logError(
        "Failed to remove friend, queueing for retry",
        error: error,
        stackTrace: stackTrace,
      );
      await _updateCachedSocial(removeInCache);
      await _enqueueFriendAction({
        "type": "removeFriend",
        "friendId": friendId,
        "friendshipId": friendshipId,
      });
      return const Right(null);
    }
  }

  Future<void> _removeFriendRemote({
    required String? userId,
    required String friendId,
    required String friendshipId,
  }) async {
    if (friendshipId.isNotEmpty) {
      await _supabaseService.requireClient
          .from("friendships")
          .delete()
          .eq("id", friendshipId)
          .timeout(_remoteCallTimeout);
      return;
    }
    await _supabaseService.requireClient
        .from("friendships")
        .delete()
        .eq("status", "accepted")
        .or(
          "and(requester_id.eq.$userId,addressee_id.eq.$friendId),"
          "and(requester_id.eq.$friendId,addressee_id.eq.$userId)",
        )
        .timeout(_remoteCallTimeout);
  }

  /// Re-attempts friend actions that failed to reach the backend earlier, in
  /// the order they were queued. Stops at the first failure so a later
  /// action (e.g. a cancel after a send) never gets applied out of order.
  Future<void> flushPendingSync() async {
    if (!_pendingSyncStore.contains(PendingSyncDataset.friends)) {
      return;
    }
    final List<Map<String, dynamic>> queue = await _readFriendActionQueue();
    if (queue.isEmpty) {
      await _pendingSyncStore.clear(PendingSyncDataset.friends);
      return;
    }

    int processed = 0;
    try {
      for (final Map<String, dynamic> action in queue) {
        await _replayFriendAction(action);
        processed++;
      }
    } catch (error, stackTrace) {
      _logger.logError(
        "Failed to flush a queued friend action",
        error: error,
        stackTrace: stackTrace,
      );
    }

    final List<Map<String, dynamic>> remaining = queue.sublist(processed);
    await _writeFriendActionQueue(remaining);
    if (remaining.isEmpty) {
      await _pendingSyncStore.clear(PendingSyncDataset.friends);
    }
  }

  Future<void> _replayFriendAction(Map<String, dynamic> action) async {
    final String? userId = _supabaseService.currentUserId;
    switch (action["type"] as String?) {
      case "sendFriendRequest":
        if (userId == null) {
          throw StateError("User must be signed in to send a friend request.");
        }
        await _sendFriendRequestRemote(
          userId,
          action["addresseeId"] as String,
        );
      case "acceptRequest":
        await _acceptRequestRemote(action["friendshipId"] as String);
      case "declineRequest":
        await _declineRequestRemote(action["friendshipId"] as String);
      case "cancelSentRequest":
        await _cancelSentRequestRemote(
          userId: userId,
          addresseeId: action["addresseeId"] as String,
          friendshipId: action["friendshipId"] as String? ?? "",
        );
      case "removeFriend":
        await _removeFriendRemote(
          userId: userId,
          friendId: action["friendId"] as String,
          friendshipId: action["friendshipId"] as String? ?? "",
        );
    }
  }

  FriendEntity? _findByFriendshipId(
    List<FriendEntity> entries,
    String friendshipId,
  ) {
    for (final FriendEntity entry in entries) {
      if (entry.friendshipId == friendshipId) {
        return entry;
      }
    }
    return null;
  }

  Future<Either<AppError, FriendSuggestionEntity?>> findByCode(
    String code,
  ) async {
    try {
      final String lookupCode = _normalizeLookupCode(code);
      if (lookupCode.isEmpty) {
        return const Right(null);
      }
      final dynamic response = await _supabaseService.requireClient
          .rpc(
            "find_profile_by_friend_code",
            params: {"lookup_code": lookupCode},
          )
          .timeout(_remoteCallTimeout);
      _logger.logResponse("rpc public.find_profile_by_friend_code", response);
      final List<dynamic> rows = response as List<dynamic>;
      if (rows.isEmpty) {
        return const Right(null);
      }
      return Right(
        _suggestionFromRow(Map<String, dynamic>.from(rows.first as Map)),
      );
    } catch (error, stackTrace) {
      return Left(GenericAppError(error: error, stackTrace: stackTrace));
    }
  }

  Left<AppError, T> _signedOut<T>(String action) => Left(
    GenericAppError(
      error: StateError("User must be signed in to $action."),
      stackTrace: StackTrace.current,
    ),
  );

  Future<List<Map<String, dynamic>>> _selectRows({
    required String table,
    String columns = "*",
    required dynamic Function(dynamic query) filters,
  }) async {
    final dynamic query = filters(
      _supabaseService.requireClient.from(table).select(columns),
    );
    final dynamic response = await query.timeout(_remoteCallTimeout);
    _logger.logResponse("select public.$table", response);
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
    return {
      for (final Map<String, dynamic> row in rows) row["id"] as String: row,
    };
  }

  FriendEntity _friendFromRow({
    required String userId,
    required String friendshipId,
    required Map<String, dynamic>? profileRow,
  }) => FriendEntity(
    id: userId,
    friendshipId: friendshipId,
    name: _displayName(profileRow),
    handle: _handleFor(userId, profileRow),
    colorValue: _colorFor(userId, profileRow),
    avatarIconIndex: (profileRow?["avatar_icon_index"] as num?)?.toInt(),
    profilePhotoBase64: (profileRow?["profile_photo_base64"] as String? ?? "")
        .trim(),
    isOnline: profileRow?["is_online"] as bool? ?? false,
    lastSeenAt: DateTime.tryParse(profileRow?["last_seen_at"] as String? ?? ""),
  );

  FriendSuggestionEntity _suggestionFromRow(Map<String, dynamic> row) {
    final String id = row["id"] as String;
    return FriendSuggestionEntity(
      id: id,
      name: _displayName(row),
      handle: _handleFor(id, row),
      colorValue: _colorFor(id, row),
      avatarIconIndex: (row["avatar_icon_index"] as num?)?.toInt(),
      profilePhotoBase64: (row["profile_photo_base64"] as String? ?? "").trim(),
    );
  }

  String _displayName(Map<String, dynamic>? row) {
    final String userName = (row?["user_name"] as String? ?? "").trim();
    if (userName.isNotEmpty) {
      return userName;
    }
    final String nickName = (row?["nick_name"] as String? ?? "").trim();
    if (nickName.isNotEmpty) {
      return nickName;
    }
    return "Timing User";
  }

  String _handleFor(String userId, Map<String, dynamic>? row) {
    final String code =
        row?["friend_code"] as String? ?? userId.substring(0, 8);
    return "@${code.toLowerCase()}";
  }

  int _colorFor(String userId, Map<String, dynamic>? row) =>
      (row?["accent_color_value"] as num?)?.toInt() ??
      GroupAvatarColors.byIndex(userId.hashCode);

  String _normalizeLookupCode(String code) =>
      _withoutDiacritics(code.trim().replaceAll("@", "").toLowerCase());

  String _withoutDiacritics(String value) {
    const Map<String, String> replacements = {
      "á": "a",
      "à": "a",
      "ã": "a",
      "â": "a",
      "ä": "a",
      "å": "a",
      "ā": "a",
      "ă": "a",
      "ą": "a",
      "ç": "c",
      "ć": "c",
      "č": "c",
      "ď": "d",
      "é": "e",
      "è": "e",
      "ê": "e",
      "ë": "e",
      "ē": "e",
      "ė": "e",
      "ę": "e",
      "í": "i",
      "ì": "i",
      "î": "i",
      "ï": "i",
      "ī": "i",
      "ł": "l",
      "ñ": "n",
      "ń": "n",
      "ó": "o",
      "ò": "o",
      "õ": "o",
      "ô": "o",
      "ö": "o",
      "ø": "o",
      "ō": "o",
      "ř": "r",
      "ś": "s",
      "š": "s",
      "ß": "ss",
      "ť": "t",
      "ú": "u",
      "ù": "u",
      "û": "u",
      "ü": "u",
      "ū": "u",
      "ý": "y",
      "ÿ": "y",
      "ž": "z",
      "ź": "z",
      "ż": "z",
    };

    final StringBuffer buffer = StringBuffer();
    for (final int codePoint in value.runes) {
      final String character = String.fromCharCode(codePoint);
      buffer.write(replacements[character] ?? character);
    }
    return buffer.toString();
  }

  Future<void> _cacheSocial(FriendsSocialEntity social) async {
    await _localStorageService.write(
      LocalStorageKeys.cachedFriendsSocial,
      jsonEncode(social.toMap()),
    );
  }

  Future<FriendsSocialEntity?> _readCachedSocial() async {
    final String? saved = await _localStorageService.read<String?>(
      LocalStorageKeys.cachedFriendsSocial,
    );
    if (saved == null) {
      return null;
    }
    try {
      return FriendsSocialEntity.fromMap(
        jsonDecode(saved) as Map<String, dynamic>,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> _updateCachedSocial(
    FriendsSocialEntity Function(FriendsSocialEntity current) transform,
  ) async {
    final FriendsSocialEntity current =
        await _readCachedSocial() ?? const FriendsSocialEntity.empty();
    await _cacheSocial(transform(current));
  }

  Future<void> _enqueueFriendAction(Map<String, dynamic> action) async {
    final List<Map<String, dynamic>> queue = await _readFriendActionQueue();
    queue.add(action);
    await _writeFriendActionQueue(queue);
    await _pendingSyncStore.markPending(PendingSyncDataset.friends);
  }

  Future<List<Map<String, dynamic>>> _readFriendActionQueue() async {
    final String? saved = await _localStorageService.read<String?>(
      LocalStorageKeys.pendingFriendActions,
    );
    if (saved == null) {
      return [];
    }
    try {
      final List<dynamic> decoded = jsonDecode(saved) as List<dynamic>;
      return decoded.map((item) => item as Map<String, dynamic>).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _writeFriendActionQueue(
    List<Map<String, dynamic>> queue,
  ) async {
    await _localStorageService.write(
      LocalStorageKeys.pendingFriendActions,
      jsonEncode(queue),
    );
  }
}
