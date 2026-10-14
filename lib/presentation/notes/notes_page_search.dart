import "package:flutter_quill/flutter_quill.dart";
import "package:flutter_quill/quill_delta.dart";

/// Which notebook pages the page search keeps on screen.
enum NotesPageFilter { all, withText, highlighted, empty }

/// One notebook page as the page search sees it: its plain text, how long it is
/// and whether it carries highlighted passages.
class NotesPageSummary {
  const NotesPageSummary({
    required this.index,
    required this.text,
    required this.wordCount,
    required this.hasHighlight,
  });

  factory NotesPageSummary.of(int index, Document document) {
    // Line breaks are collapsed so a page always previews as a single line.
    final String text = document
        .toPlainText()
        .replaceAll(RegExp(r"\s+"), " ")
        .trim();

    return NotesPageSummary(
      index: index,
      text: text,
      wordCount: text.isEmpty ? 0 : text.split(" ").length,
      hasHighlight: document.toDelta().toList().any(
        (Operation operation) =>
            operation.attributes?.containsKey(Attribute.background.key) ??
            false,
      ),
    );
  }

  /// Characters kept before a match so it never opens the preview flush left.
  static const int _leadingContext = 16;
  static const int _previewLength = 80;

  final int index;
  final String text;
  final int wordCount;
  final bool hasHighlight;

  bool get isEmpty => text.isEmpty;

  bool matches({required NotesPageFilter filter, required String query}) =>
      _matchesFilter(filter) && _matchesQuery(query);

  /// The snippet shown under the page name, moved onto [query] so the match
  /// stays visible on a page that is longer than the row.
  String preview(String query) {
    final String normalizedQuery = query.trim().toLowerCase();
    final int matchIndex = normalizedQuery.isEmpty
        ? -1
        : text.toLowerCase().indexOf(normalizedQuery);
    final int start = matchIndex <= _leadingContext
        ? 0
        : matchIndex - _leadingContext;
    // Trimmed so a cut that lands on a space does not read as "… 15: ...".
    final String snippet = text.substring(start).trimLeft();
    final String clipped = snippet.length <= _previewLength
        ? snippet
        : "${snippet.substring(0, _previewLength).trimRight()}…";

    return start == 0 ? clipped : "…$clipped";
  }

  bool _matchesFilter(NotesPageFilter filter) => switch (filter) {
    NotesPageFilter.all => true,
    NotesPageFilter.withText => !isEmpty,
    NotesPageFilter.highlighted => hasHighlight,
    NotesPageFilter.empty => isEmpty,
  };

  bool _matchesQuery(String query) {
    final String normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) {
      return true;
    }

    return text.toLowerCase().contains(normalizedQuery);
  }
}
