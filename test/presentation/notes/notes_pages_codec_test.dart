import "package:flutter_test/flutter_test.dart";
import "package:help_out/presentation/notes/notes_pages_codec.dart";

void main() {
  group("NotesPagesCodec", () {
    test("opens an empty note as one page", () {
      expect(NotesPagesCodec.decode(""), <String>[""]);
    });

    test("keeps existing single-page notes compatible", () {
      expect(NotesPagesCodec.decode("Old note"), <String>["Old note"]);
    });

    test("round-trips multiple pages", () {
      final List<String> pages = <String>["First", "", "Third"];

      expect(NotesPagesCodec.decode(NotesPagesCodec.encode(pages)), pages);
    });
  });
}
