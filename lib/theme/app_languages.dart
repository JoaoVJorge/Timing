typedef AppLanguage = ({String code, String label, String flag});

class AppLanguages {
  const AppLanguages._();

  static const List<AppLanguage> values = [
    (code: "en", label: "English", flag: "\u{1F1FA}\u{1F1F8}"),
    (code: "pt", label: "Portugu\u{00EA}s", flag: "\u{1F1E7}\u{1F1F7}"),
    (code: "es", label: "Espa\u{00F1}ol", flag: "\u{1F1EA}\u{1F1F8}"),
    (code: "fr", label: "Fran\u{00E7}ais", flag: "\u{1F1EB}\u{1F1F7}"),
    (code: "de", label: "Deutsch", flag: "\u{1F1E9}\u{1F1EA}"),
    (
      code: "ar",
      label: "\u{0627}\u{0644}\u{0639}\u{0631}\u{0628}\u{064A}\u{0629}",
      flag: "\u{1F1F8}\u{1F1E6}",
    ),
  ];

  static AppLanguage byCode(String code) => values.firstWhere(
    (language) => language.code == code,
    orElse: () => values.first,
  );
}
