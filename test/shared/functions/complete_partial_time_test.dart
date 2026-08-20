import "package:flutter_test/flutter_test.dart";
import "package:timing/shared/functions/format_schedule_time.dart";

void main() {
  group("completePartialTime", () {
    test("fills a bare hour to HH:00", () {
      expect(completePartialTime("10"), "10:00");
      expect(completePartialTime("9"), "09:00");
      expect(completePartialTime("0"), "00:00");
    });

    test("keeps an already complete time", () {
      expect(completePartialTime("10:30"), "10:30");
      expect(completePartialTime("08:05"), "08:05");
    });

    test("fills a single minute digit as tens", () {
      expect(completePartialTime("10:3"), "10:30");
      expect(completePartialTime("7:4"), "07:40");
    });

    test("completes a dangling colon", () {
      expect(completePartialTime("10:"), "10:00");
    });

    test("clamps 24:xx to 24:00 and out-of-range minutes", () {
      expect(completePartialTime("24:30"), "24:00");
    });

    test("returns null for empty input", () {
      expect(completePartialTime(""), isNull);
      expect(completePartialTime("   "), isNull);
    });
  });
}
