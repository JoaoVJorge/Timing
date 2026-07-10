typedef AppLanguage = ({String code, String label, String flag});

class AppLanguages {
  const AppLanguages._();

  static const List<AppLanguage> values = [
    (code: "en", label: "English", flag: "🇺🇸"),
    (code: "pt", label: "Português", flag: "🇧🇷"),
    (code: "es", label: "Español", flag: "🇪🇸"),
  ];

  static AppLanguage byCode(String code) => values.firstWhere(
    (language) => language.code == code,
    orElse: () => values.first,
  );
}
