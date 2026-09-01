import "dart:convert";

import "package:flutter_quill/flutter_quill.dart";

/// Encodes one notebook page as a Quill Delta while still accepting the plain
/// text stored by app versions that predate rich-text notes.
class NotesRichTextCodec {
  const NotesRichTextCodec._();

  static const String _prefix = "\u001dquill-v1:";

  static Document decode(String value) {
    if (value.startsWith(_prefix)) {
      try {
        final Object? decoded = jsonDecode(value.substring(_prefix.length));
        if (decoded is List<dynamic>) {
          return Document.fromJson(decoded);
        }
      } on Object catch (_) {
        // Preserve malformed or partial values as visible plain text instead
        // of making the user's note disappear.
      }
    }

    final String plainText = value.endsWith("\n") ? value : "$value\n";
    return Document.fromJson(<Map<String, dynamic>>[
      <String, dynamic>{"insert": plainText},
    ]);
  }

  static String encode(Document document) =>
      "$_prefix${jsonEncode(document.toDelta().toJson())}";

  static bool isEmpty(Document document) =>
      document.toPlainText().trim().isEmpty;
}
