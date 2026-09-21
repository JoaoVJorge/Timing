import "dart:async";

import "package:connectivity_plus/connectivity_plus.dart";
import "package:get/get.dart";

/// Reactive online/offline signal for the app.
///
/// This reflects OS-level link reachability (Wi-Fi/cellular is connected),
/// not proven backend reachability — a device can read "online" while on a
/// Wi-Fi network with no real internet. Callers that need to know whether a
/// specific write actually reached the backend should rely on
/// [PendingSyncStore.onMarkedPending] instead; this service is meant for
/// coarse UI state and for triggering a reconnect-flush attempt.
class ConnectivityService {
  ConnectivityService({
    Future<List<ConnectivityResult>> Function()? checkConnectivity,
    Stream<List<ConnectivityResult>>? connectivityChanges,
  }) : _checkConnectivity =
           checkConnectivity ?? Connectivity().checkConnectivity,
       _connectivityChanges =
           connectivityChanges ?? Connectivity().onConnectivityChanged;

  final Future<List<ConnectivityResult>> Function() _checkConnectivity;
  final Stream<List<ConnectivityResult>> _connectivityChanges;

  final RxBool isOnline = true.obs;
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  Future<void> initialize() async {
    isOnline.value = _isOnline(await _checkConnectivity());
    _subscription = _connectivityChanges.listen((results) {
      isOnline.value = _isOnline(results);
    });
  }

  bool _isOnline(List<ConnectivityResult> results) =>
      results.any((result) => result != ConnectivityResult.none);

  void dispose() {
    unawaited(_subscription?.cancel());
  }
}
