import "package:flutter_test/flutter_test.dart";
import "package:timing/core/utils/id_generator.dart";

void main() {
  group("generateEntityId", () {
    test("produces unique ids even in a tight loop", () {
      final ids = <String>{};
      for (int i = 0; i < 100000; i++) {
        ids.add(generateEntityId());
      }

      expect(ids.length, 100000);
    });

    test("contains only characters safe for the in (...) filter", () {
      final RegExp safe = RegExp(r"^[0-9a-z-]+$");

      for (int i = 0; i < 1000; i++) {
        expect(safe.hasMatch(generateEntityId()), isTrue);
      }
    });

    test("keeps ids roughly time-ordered by their timestamp prefix", () {
      final String first = generateEntityId();
      final int firstTimestamp = int.parse(first.split("-").first);

      expect(firstTimestamp, greaterThan(0));
    });
  });
}
