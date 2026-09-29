/// Name shown for a profile row: the nickname when set, otherwise the user
/// name, otherwise [fallback].
String profileDisplayName(
  Map<String, dynamic>? row, {
  required String fallback,
}) {
  final String nickName = (row?["nick_name"] as String? ?? "").trim();
  if (nickName.isNotEmpty) {
    return nickName;
  }
  final String userName = (row?["user_name"] as String? ?? "").trim();
  return userName.isNotEmpty ? userName : fallback;
}
