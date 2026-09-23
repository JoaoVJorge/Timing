import "dart:math";

import "package:flutter_test/flutter_test.dart";
import "package:timing/core/utils/id_generator.dart";

class _BoundCheckingRandom implements Random {
  final List<int> requestedBounds = <int>[];

  @override
  int nextInt(int max) {
    requestedBounds.add(max);
    return max - 1;
  }

  @override
  bool nextBool() => false;

  @override
  double nextDouble() => 0;
}

void main() {
  group("generateEntityId", () {
    test("produces unique ids even in a tight loop", () {
      final EntityIdGenerator generator = EntityIdGenerator(
        random: Random(2468),
        timestampMicros: () => 123456789,
      );
      final ids = <String>{};
      for (int i = 0; i < 100000; i++) {
        ids.add(generator.generate());
      }

      expect(ids.length, 100000);
    });

    test("contains only characters safe for the in (...) filter", () {
      final RegExp safe = RegExp(r"^[0-9a-z-]+$");
      final EntityIdGenerator generator = EntityIdGenerator(
        random: Random(1357),
        timestampMicros: () => 123456789,
      );

      for (int i = 0; i < 1000; i++) {
        final String id = generator.generate();
        expect(safe.hasMatch(id), isTrue);
        expect(id.split("-").last.length, 14);
      }
    });

    test("keeps ids roughly time-ordered by their timestamp prefix", () {
      final EntityIdGenerator generator = EntityIdGenerator(
        random: Random(9753),
        timestampMicros: () => 123456789,
      );
      final String first = generator.generate();
      final int firstTimestamp = int.parse(first.split("-").first);

      expect(firstTimestamp, 123456789);
    });

    test("requests only dart2js-safe 16-bit random words", () {
      final _BoundCheckingRandom random = _BoundCheckingRandom();
      final EntityIdGenerator generator = EntityIdGenerator(
        random: random,
        timestampMicros: () => 123456789,
      );

      generator.generate();

      expect(random.requestedBounds, [0x10000, 0x10000, 0x10000, 0x10000]);
    });
  });

  group("generateUuidV4", () {
    test("matches RFC 4122 version 4 syntax", () {
      final RegExp uuidV4 = RegExp(
        r"^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$",
      );

      for (int i = 0; i < 1000; i++) {
        expect(uuidV4.hasMatch(generateUuidV4()), isTrue);
      }
    });

    test("produces unique ids even in a tight loop", () {
      final ids = <String>{};
      for (int i = 0; i < 10000; i++) {
        ids.add(generateUuidV4());
      }

      expect(ids.length, 10000);
    });
  });
}
