import "dart:async";

import "package:flutter/widgets.dart";
import "package:get/get.dart";
import "package:supabase_flutter/supabase_flutter.dart";
import "package:timing/core/services/local_storage/app_local_storage_service.dart";
import "package:timing/core/services/local_storage/local_storage_keys.dart";
import "package:timing/core/services/supabase/supabase_service.dart";
import "package:timing/core/services/sync/pending_sync_store.dart";
import "package:url_launcher/url_launcher.dart";

/// OAuth credentials stay in the backend. A failed Calendar request must never
/// undo a successful Timing save; it is retried through the existing outbox.
class GoogleCalendarService extends GetxService with WidgetsBindingObserver {
  GoogleCalendarService({
    required SupabaseService supabaseService,
    required AppLocalStorageService localStorageService,
    required PendingSyncStore pendingSyncStore,
    Future<Map<String, dynamic>> Function(String action)? invoke,
    Future<bool> Function(Uri url)? launch,
  }) : _supabase = supabaseService,
       _storage = localStorageService,
       _pending = pendingSyncStore,
       _invokeOverride = invoke,
       _launchOverride = launch;

  final SupabaseService _supabase;
  final AppLocalStorageService _storage;
  final PendingSyncStore _pending;
  final Future<Map<String, dynamic>> Function(String)? _invokeOverride;
  final Future<bool> Function(Uri)? _launchOverride;
  final RxBool connected = false.obs;
  final RxBool busy = false.obs;
  final RxBool connecting = false.obs;
  final RxBool needsReconnect = false.obs;
  final RxBool pending = false.obs;
  final RxString timeZone = "".obs;
  final RxString errorCode = "".obs;
  String? _owner;
  Future<void>? _syncInProgress;
  bool _syncRequested = false;

  Future<void> initialize() async {
    WidgetsBinding.instance.addObserver(this);
    _owner = _supabase.currentUserId;
    connected.value =
        await _storage.read<bool>(LocalStorageKeys.googleCalendarEnabled) ??
        false;
    pending.value = _pending.contains(PendingSyncDataset.googleCalendar);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) unawaited(refresh());
  }

  Future<Map<String, dynamic>> _call(String action) async {
    if (_invokeOverride != null) return _invokeOverride(action);
    final response = await _supabase.requireClient.functions
        .invoke("google-calendar", body: {"action": action})
        .timeout(const Duration(seconds: 60));
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<void> refresh() async {
    final user = _supabase.currentUserId;
    if (user != _owner) {
      _owner = user;
      connected.value = false;
      needsReconnect.value = false;
      pending.value = false;
      errorCode.value = "";
      timeZone.value = "";
      connecting.value = false;
    }
    if (user == null || !_supabase.isConfigured || busy.value) return;
    try {
      final result = await _call("status");
      if (user != _supabase.currentUserId) return;
      await _applyStatus(result);
      connecting.value = false;
      if (connected.value) await sync();
    } catch (_) {
      // Keep the last known connection while offline. Errors from explicit
      // connect/sync actions are shown in the Calendar row.
    }
  }

  Future<void> connect() async {
    if (busy.value) return;
    busy.value = true;
    errorCode.value = "";
    try {
      final result = await _call("connect");
      final url = Uri.parse(result["url"] as String);
      if (url.scheme != "https" || url.host != "accounts.google.com") {
        throw StateError("Invalid Google authorization URL");
      }
      connecting.value = true;
      final launched =
          await (_launchOverride?.call(url) ??
              launchUrl(url, mode: LaunchMode.externalApplication));
      if (!launched) throw StateError("Browser unavailable");
    } catch (error) {
      connecting.value = false;
      errorCode.value = _errorCode(error, "connect_failed");
    } finally {
      busy.value = false;
    }
  }

  Future<void> disconnect() async {
    if (busy.value) return;
    busy.value = true;
    try {
      await _applyStatus(await _call("disconnect"));
      needsReconnect.value = false;
      connecting.value = false;
      errorCode.value = "";
    } catch (_) {
      errorCode.value = "disconnect_failed";
    } finally {
      busy.value = false;
    }
  }

  Future<void> _applyStatus(Map<String, dynamic> result) async {
    connected.value = result["connected"] == true;
    timeZone.value = result["timeZone"] as String? ?? "";
    await _storage.write(
      LocalStorageKeys.googleCalendarEnabled,
      connected.value,
    );
    if (!connected.value) {
      await _pending.clear(PendingSyncDataset.googleCalendar);
      pending.value = false;
    }
  }

  Future<void> sync() {
    if (!connected.value ||
        _supabase.currentUserId == null ||
        _owner != _supabase.currentUserId) {
      return Future.value();
    }
    if (_syncInProgress != null) {
      _syncRequested = true;
      return _syncInProgress!;
    }
    return _syncInProgress = _drainSync().whenComplete(
      () => _syncInProgress = null,
    );
  }

  Future<void> _drainSync() async {
    do {
      _syncRequested = false;
      await _sync();
    } while (_syncRequested &&
        connected.value &&
        _owner == _supabase.currentUserId);
  }

  Future<void> _sync() async {
    final user = _supabase.currentUserId;
    pending.value = true;
    await _pending.markPending(PendingSyncDataset.googleCalendar);
    // Calendar reads the backend schedule. Wait until offline Timing changes
    // have reached it before reconciling events, including removed entries.
    if (_pending.contains(PendingSyncDataset.schedule)) return;
    try {
      final result = await _call("sync");
      if (user != _supabase.currentUserId) return;
      await _applyStatus(result);
      await _pending.clear(PendingSyncDataset.googleCalendar);
      pending.value = false;
      needsReconnect.value = false;
      errorCode.value = "";
    } catch (error) {
      if (user != _supabase.currentUserId) return;
      // FunctionException.toString includes only our sanitized error code.
      final text = error.toString();
      needsReconnect.value =
          text.contains("reconnect_required") ||
          text.contains("permission_required");
      errorCode.value = _errorCode(error, "sync_failed");
    }
  }

  static String _errorCode(Object error, String fallback) =>
      error is FunctionException && error.status == 404
      ? "function_unavailable"
      : fallback;

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }
}
