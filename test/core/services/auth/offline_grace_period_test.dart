import "package:flutter_test/flutter_test.dart";
import "package:timing/core/services/auth/offline_grace_period.dart";

void main() {
  group("OfflineGracePeriod.hasExpired", () {
    const period = OfflineGracePeriod();
    final now = DateTime.utc(2026, 9, 20);

    test("is false when never verified online (grandfather case)", () {
      expect(period.hasExpired(lastVerifiedOnlineAt: null, now: now), isFalse);
    });

    test("is false exactly at the 7-day boundary", () {
      final lastVerified = now.subtract(const Duration(days: 7));
      expect(
        period.hasExpired(lastVerifiedOnlineAt: lastVerified, now: now),
        isFalse,
      );
    });

    test("is true just past the 7-day boundary", () {
      final lastVerified = now.subtract(const Duration(days: 7, hours: 1));
      expect(
        period.hasExpired(lastVerifiedOnlineAt: lastVerified, now: now),
        isTrue,
      );
    });

    test("is false well within the window", () {
      final lastVerified = now.subtract(const Duration(days: 2));
      expect(
        period.hasExpired(lastVerifiedOnlineAt: lastVerified, now: now),
        isFalse,
      );
    });
  });
}
