class NotesPagesCodec {
  const NotesPagesCodec._();

  static const String _separator = "\u001e";

  static List<String> decode(String value) {
    if (value.isEmpty) {
      return <String>[""];
    }

    return value.split(_separator);
  }

  static String encode(Iterable<String> pages) => pages.join(_separator);
}
