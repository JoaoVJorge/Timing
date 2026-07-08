/// Normalises a user-entered name for display: trims, collapses inner spaces
/// and capitalises the first letter of each word ("joao" -> "Joao", "JOAO" ->
/// "Joao"). Accents are left untouched.
String capitalizeName(String value) {
  final String trimmed = value.trim();
  if (trimmed.isEmpty) {
    return trimmed;
  }

  return trimmed
      .split(RegExp(r"\s+"))
      .map(
        (word) =>
            "${word[0].toUpperCase()}${word.substring(1).toLowerCase()}",
      )
      .join(" ");
}
