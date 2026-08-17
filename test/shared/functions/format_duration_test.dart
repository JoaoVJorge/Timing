import "package:flutter_test/flutter_test.dart";
import "package:timing/shared/functions/format_duration.dart";

void main() {
  test("formatDurationLong omits zero minutes after whole hours", () {
    expect(formatDurationLong(const Duration(hours: 1)), "1h");
    expect(formatDurationLong(const Duration(hours: 2)), "2h");
    expect(
      formatDurationLong(const Duration(hours: 1, minutes: 15)),
      "1h 15 min",
    );
    expect(formatDurationLong(const Duration(minutes: 45)), "45 min");
  });
}
