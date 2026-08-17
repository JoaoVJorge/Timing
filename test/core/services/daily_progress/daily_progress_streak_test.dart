import "dart:convert";

import "package:flutter_test/flutter_test.dart";
import "package:timing/core/services/daily_progress/daily_progress_service.dart";
import "package:timing/core/services/local_storage/app_local_storage_service.dart";
import "package:timing/core/services/local_storage/local_storage_keys.dart";

class _FakeStorage implements AppLocalStorageService {
  _FakeStorage(this._json);

  final String? _json;

  @override
  Future<T?> read<T>(LocalStorageKeys key) async => _json as T?;

  @override
  Future<void> write<T>(LocalStorageKeys key, T value) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

/// Builds the persisted daily-progress JSON from a list of focus seconds where
/// index 0 is today, index 1 is yesterday, and so on.
String _json(List<int> focusSecondsByDaysAgo) {
  final DateTime now = DateTime.now();
  final DateTime today = DateTime(now.year, now.month, now.day);
  final Map<String, dynamic> map = {};
  for (int i = 0; i < focusSecondsByDaysAgo.length; i++) {
    final int seconds = focusSecondsByDaysAgo[i];
    if (seconds <= 0) {
      continue;
    }
    final DateTime date = today.subtract(Duration(days: i));
    map[DailyProgressService.dateKey(date)] = {
      "focusSeconds": seconds,
      "sessions": 1,
      "pages": 0,
    };
  }
  return jsonEncode(map);
}

Future<DailyProgressService> _loaded(List<int> focusSecondsByDaysAgo) async {
  final service = DailyProgressService(
    localStorageService: _FakeStorage(_json(focusSecondsByDaysAgo)),
  );
  await service.load();
  return service;
}

void main() {
  group("DailyProgressService.currentStreak", () {
    test("counts consecutive days including today", () async {
      final service = await _loaded([1800, 1800, 1800]);

      expect(service.currentStreak.value, 3);
    });

    test("stays alive when today has no focus time yet", () async {
      final service = await _loaded([0, 1800, 1800]);

      expect(service.currentStreak.value, 2);
    });

    test("breaks on the first day without focus", () async {
      final service = await _loaded([1800, 0, 1800]);

      expect(service.currentStreak.value, 1);
    });

    test("is zero when there is no recent activity", () async {
      final service = await _loaded([0, 0]);

      expect(service.currentStreak.value, 0);
    });
  });
}
