import "dart:async";

import "package:connectivity_plus/connectivity_plus.dart";
import "package:flutter_test/flutter_test.dart";
import "package:timing/core/services/connectivity/connectivity_service.dart";

void main() {
  group("ConnectivityService", () {
    test("starts online when the initial check reports a connection", () async {
      final controller = StreamController<List<ConnectivityResult>>.broadcast();
      final service = ConnectivityService(
        checkConnectivity: () async => [ConnectivityResult.wifi],
        connectivityChanges: controller.stream,
      );

      await service.initialize();

      expect(service.isOnline.value, isTrue);
      service.dispose();
      await controller.close();
    });

    test("starts offline when the initial check reports none", () async {
      final controller = StreamController<List<ConnectivityResult>>.broadcast();
      final service = ConnectivityService(
        checkConnectivity: () async => [ConnectivityResult.none],
        connectivityChanges: controller.stream,
      );

      await service.initialize();

      expect(service.isOnline.value, isFalse);
      service.dispose();
      await controller.close();
    });

    test("reacts to a later connectivity change", () async {
      final controller = StreamController<List<ConnectivityResult>>.broadcast();
      final service = ConnectivityService(
        checkConnectivity: () async => [ConnectivityResult.wifi],
        connectivityChanges: controller.stream,
      );
      await service.initialize();
      expect(service.isOnline.value, isTrue);

      controller.add([ConnectivityResult.none]);
      await Future<void>.delayed(Duration.zero);

      expect(service.isOnline.value, isFalse);

      controller.add([ConnectivityResult.mobile]);
      await Future<void>.delayed(Duration.zero);

      expect(service.isOnline.value, isTrue);

      service.dispose();
      await controller.close();
    });

    test(
      "treats Wi-Fi without backend access as offline and recovers",
      () async {
        final controller =
            StreamController<List<ConnectivityResult>>.broadcast();
        bool backendReachable = false;
        final service = ConnectivityService(
          checkConnectivity: () async => [ConnectivityResult.wifi],
          connectivityChanges: controller.stream,
          checkBackend: () async => backendReachable,
        );

        await service.initialize();
        expect(service.isOnline.value, isFalse);

        backendReachable = true;
        await service.refresh();
        expect(service.isOnline.value, isTrue);

        backendReachable = false;
        await service.refresh();
        expect(service.isOnline.value, isFalse);

        service.dispose();
        await controller.close();
      },
    );

    test("a stale 'no connectivity' refresh() does not overwrite a newer "
        "online result", () async {
      final controller = StreamController<List<ConnectivityResult>>.broadcast();

      // checkConnectivity() completes only when released manually, to
      // simulate a slow platform-channel call that started before a
      // connectivity-changed event fires.
      final slowCheckCompleter = Completer<List<ConnectivityResult>>();
      int checkConnectivityCalls = 0;

      final service = ConnectivityService(
        checkConnectivity: () {
          checkConnectivityCalls++;
          if (checkConnectivityCalls == 1) {
            return Future.value([ConnectivityResult.wifi]);
          }
          // The refresh() call under test hangs until completed below.
          return slowCheckCompleter.future;
        },
        connectivityChanges: controller.stream,
        checkBackend: () async => true,
      );

      await service.initialize();
      expect(service.isOnline.value, isTrue);

      // Start a refresh() whose _checkConnectivity() call stays pending,
      // capturing an older revision.
      final refreshFuture = service.refresh();

      // While that's still pending, a real connectivity-changed event
      // arrives and resolves fully (a newer revision), correctly
      // determining the device is online.
      controller.add([ConnectivityResult.wifi]);
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);
      expect(service.isOnline.value, isTrue);

      // The stale refresh() call finally resolves with a "no
      // connectivity" result (e.g. it captured OS state from before the
      // reconnect).
      slowCheckCompleter.complete([ConnectivityResult.none]);
      await refreshFuture;

      // The stale, older-revision result must not overwrite the newer,
      // correct "online" state.
      expect(service.isOnline.value, isTrue);

      service.dispose();
      await controller.close();
    });

    test(
      "a single failed probe does not flip an online device offline",
      () async {
        final controller =
            StreamController<List<ConnectivityResult>>.broadcast();
        final probeResults = <bool>[true, false, true];
        final service = ConnectivityService(
          checkConnectivity: () async => [ConnectivityResult.wifi],
          connectivityChanges: controller.stream,
          checkBackend: () async => probeResults.removeAt(0),
        );

        await service.initialize();
        expect(service.isOnline.value, isTrue);

        // One transient probe failure (e.g. a slow response) followed by a
        // successful re-probe must not show the offline state.
        await service.refresh();
        expect(service.isOnline.value, isTrue);

        service.dispose();
        await controller.close();
      },
    );

    test(
      "two consecutive failed probes mark an online device offline",
      () async {
        final controller =
            StreamController<List<ConnectivityResult>>.broadcast();
        final probeResults = <bool>[true, false, false];
        final service = ConnectivityService(
          checkConnectivity: () async => [ConnectivityResult.wifi],
          connectivityChanges: controller.stream,
          checkBackend: () async => probeResults.removeAt(0),
        );

        await service.initialize();
        await service.refresh();

        expect(service.isOnline.value, isFalse);

        service.dispose();
        await controller.close();
      },
    );
  });
}
