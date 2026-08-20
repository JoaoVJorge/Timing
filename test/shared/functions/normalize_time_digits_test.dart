import "package:flutter_test/flutter_test.dart";
import "package:timing/shared/functions/format_schedule_time.dart";

void main() {
  group("normalizeTimeDigits", () {
    test("passes through fewer than two digits untouched", () {
      expect(normalizeTimeDigits(""), "");
      expect(normalizeTimeDigits("1"), "1");
    });

    test("clamps the hour to 24 and pads it", () {
      expect(normalizeTimeDigits("09"), "09");
      expect(normalizeTimeDigits("99"), "24");
    });

    test("forces 24:xx to 24:00", () {
      expect(normalizeTimeDigits("2415"), "2400");
    });

    test("caps a leading minute digit above 5 to 5", () {
      expect(normalizeTimeDigits("109"), "105");
      expect(normalizeTimeDigits("1045"), "1045");
    });

    test("clamps full minutes to 59", () {
      expect(normalizeTimeDigits("1059"), "1059");
    });
  });

  group("formatClockTime", () {
    test("pads hours and minutes to two digits", () {
      expect(formatClockTime(DateTime(2026, 8, 20, 9, 5)), "09:05");
      expect(formatClockTime(DateTime(2026, 8, 20, 14, 30)), "14:30");
    });
  });
}
