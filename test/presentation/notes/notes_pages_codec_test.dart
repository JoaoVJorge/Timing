import "package:flutter_test/flutter_test.dart";
import "package:timing/presentation/notes/notes_pages_codec.dart";

void main() {
  group("NotesPagesCodec", () {
    test("opens an empty note as one page", () {
      expect(NotesPagesCodec.decode(""), <String>[""]);
    });

    test("keeps existing single-page notes compatible", () {
      expect(NotesPagesCodec.decode("Old note"), <String>["Old note"]);
    });

    test("round-trips multiple pages with content", () {
      final List<String> pages = <String>["First", "Third"];

      expect(NotesPagesCodec.decode(NotesPagesCodec.encode(pages)), pages);
    });

    test("does not save empty or whitespace-only pages", () {
      final List<String> pages = <String>["First", "", "  \n", "Third"];

      expect(NotesPagesCodec.decode(NotesPagesCodec.encode(pages)), <String>[
        "First",
        "Third",
      ]);
    });

    test("encodes a notebook with no content as empty", () {
      expect(NotesPagesCodec.encode(<String>["", "  "]), "");
    });
  });
}
