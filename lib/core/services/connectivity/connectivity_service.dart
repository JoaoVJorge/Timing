import "dart:async";

import "package:connectivity_plus/connectivity_plus.dart";
import "package:dio/dio.dart";
import "package:get/get.dart";
import "package:timing/env/environment_keys.dart";

/// Reactive online/offline signal for the app.
///
/// A network link is only considered online after the configured backend's
/// health endpoint responds. Periodic checks also detect a Wi-Fi connection
/// that loses internet without changing its OS connectivity state.
class ConnectivityService {
  ConnectivityService({
    Future<List<ConnectivityResult>> Function()? checkConnectivity,
    Stream<List<ConnectivityResult>>? connectivityChanges,
    Future<bool> Function()? checkBackend,
    this._checkInterval = const Duration(seconds: 20),
  }) : _checkConnectivity =
           checkConnectivity ?? Connectivity().checkConnectivity,
       _connectivityChanges =
           connectivityChanges ?? Connectivity().onConnectivityChanged,
       _checkBackend = checkBackend ?? _probeConfiguredBackend;

  final Future<List<ConnectivityResult>> Function() _checkConnectivity;
  final Stream<List<ConnectivityResult>> _connectivityChanges;
  final Future<bool> Function() _checkBackend;
  final Duration _checkInterval;

  final RxBool isOnline = false.obs;
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  Timer? _timer;
  int _checkRevision = 0;

  Future<void> initialize() async {
    await refresh();
    _subscription = _connectivityChanges.listen((results) {
      unawaited(_check(results));
    });
    _timer = Timer.periodic(_checkInterval, (_) => unawaited(refresh()));
  }

  Future<void> refresh() async {
    final int revision = ++_checkRevision;
    try {
      final results = await _checkConnectivity();
      await _check(results, revision: revision);
    } catch (_) {
      if (revision == _checkRevision) isOnline.value = false;
    }
  }

  Future<void> _check(List<ConnectivityResult> results, {int? revision}) async {
    final int currentRevision = revision ?? ++_checkRevision;
    if (!results.any((result) => result != ConnectivityResult.none)) {
      if (currentRevision == _checkRevision) isOnline.value = false;
      return;
    }
    final bool wasOnline = isOnline.value;
    bool reachable = await _probe();
    // One slow or dropped response on a weak connection is common and must not
    // flash the offline state (banner, blocked Groups screen, suppressed sync),
    // so an online device is only declared offline after a failed re-probe.
    if (!reachable && wasOnline && currentRevision == _checkRevision) {
      reachable = await _probe();
    }
    if (currentRevision == _checkRevision) isOnline.value = reachable;
  }

  Future<bool> _probe() async {
    try {
      return await _checkBackend();
    } catch (_) {
      return false;
    }
  }

  static Future<bool> _probeConfiguredBackend() async {
    if (!EnvironmentKeys.hasSupabaseConfig) return true;
    final Uri uri = Uri.parse(
      EnvironmentKeys.supabaseUrl,
    ).resolve("/auth/v1/health");
    return probeBackend(uri);
  }

  /// Any non-redirect HTTP response proves that the server was reached.
  /// This endpoint may require authentication or be absent on a deployment;
  /// 401 and 404 must not be mistaken for a missing internet connection.
  static Future<bool> probeBackend(Uri uri) async {
    final Dio client = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 3),
        receiveTimeout: const Duration(seconds: 3),
        followRedirects: false,
        validateStatus: (_) => true,
      ),
    );
    try {
      final response = await client.getUri<dynamic>(uri);
      final int? status = response.statusCode;
      return status != null &&
          status >= 200 &&
          status < 600 &&
          status ~/ 100 != 3;
    } catch (_) {
      return false;
    } finally {
      client.close();
    }
  }

  void dispose() {
    _timer?.cancel();
    unawaited(_subscription?.cancel());
  }
}
