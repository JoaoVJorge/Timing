typedef AppLanguage = ({String code, String label});

class AppLanguages {
  const AppLanguages._();

  static const List<AppLanguage> values = [
    (code: "en", label: "English"),
    (code: "pt", label: "Português"),
    (code: "es", label: "Español"),
  ];

  static AppLanguage byCode(String code) => values.firstWhere((language) => language.code == code, orElse: () => values.first);
}
