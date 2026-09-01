import "package:flutter/material.dart";
import "package:flutter_quill/flutter_quill.dart";
import "package:flutter_test/flutter_test.dart";
import "package:timing/presentation/notes/notes_rich_text_codec.dart";

void main() {
  group("NotesRichTextCodec", () {
    test("opens legacy plain-text notes", () {
      final Document document = NotesRichTextCodec.decode("Old note");

      expect(document.toPlainText(), "Old note\n");
    });

    test("round-trips inline formatting", () {
      final QuillController controller = QuillController(
        document: NotesRichTextCodec.decode("Important"),
        selection: const TextSelection(baseOffset: 0, extentOffset: 9),
      );
      addTearDown(controller.dispose);
      controller
        ..formatSelection(Attribute.bold)
        ..formatSelection(Attribute.italic)
        ..formatSelection(Attribute.underline)
        ..formatSelection(Attribute.strikeThrough);

      final String encoded = NotesRichTextCodec.encode(controller.document);
      final Document decoded = NotesRichTextCodec.decode(encoded);

      expect(decoded.toPlainText(), "Important\n");
      expect(
        decoded.toDelta().toJson(),
        controller.document.toDelta().toJson(),
      );
    });

    test("recognizes rich documents containing only whitespace as empty", () {
      final Document document = NotesRichTextCodec.decode("  \n");

      expect(NotesRichTextCodec.isEmpty(document), isTrue);
    });
  });
}
