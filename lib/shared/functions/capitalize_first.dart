/// Uppercases the first character of [value], leaving the rest untouched.
/// Locale-formatted month and weekday names often start lowercase (e.g. pt_BR
/// "agosto de 2026") and need this to read as a title.
String capitalizeFirst(String value) {
  if (value.isEmpty) {
    return value;
  }
  return value.replaceFirst(value[0], value[0].toUpperCase());
}
