import "package:flutter/services.dart";
import "package:timing/app/app_constants.dart";

final RegExp _appLink = RegExp(
  "${RegExp.escape(AppConstants.deepLinkScheme)}://\\S+",
  caseSensitive: false,
);
final RegExp _whitespace = RegExp(r"\s");
final RegExp _alphanumeric = RegExp("[A-Za-z0-9]+");

/// The two invites a code stands for, each with the app link that carries it
/// and the shape the backend gives it.
enum InviteCodeKind {
  /// `public.generate_friend_code`: ten hex digits.
  friend(AppConstants.addFriendLinkHost, "[0-9A-F]{10}"),

  /// `public.create_group`: an `H` followed by ten hex digits.
  group(AppConstants.joinGroupLinkHost, "H[0-9A-F]{10}");

  const InviteCodeKind(this.linkHost, this._shape);

  final String linkHost;
  final String _shape;

  /// The code [uri] carries when it is this kind's app link, otherwise null.
  String? codeInLink(Uri uri) {
    if (uri.scheme.toLowerCase() != AppConstants.deepLinkScheme ||
        uri.host.toLowerCase() != linkHost) {
      return null;
    }
    // A link copied out of a sentence can bring the punctuation after it.
    final String? code = _alphanumeric.stringMatch(
      uri.queryParameters["code"] ?? "",
    );
    return code?.toUpperCase();
  }

  /// The code in what someone pasted where this kind of code is asked for:
  /// the code itself, its app link, or the whole message it was shared in.
  /// Anything else comes back trimmed, as it was typed.
  String codeIn(String text) {
    final String trimmed = text.trim();
    for (final Match match in _appLink.allMatches(trimmed)) {
      final Uri? uri = Uri.tryParse(match[0]!);
      final String? code = uri == null ? null : codeInLink(uri);
      if (code != null) {
        return code;
      }
    }
    if (!trimmed.contains(_whitespace)) {
      return trimmed;
    }
    final String? code = RegExp(
      "\\b$_shape\\b",
      caseSensitive: false,
    ).stringMatch(trimmed);
    return code?.toUpperCase() ?? trimmed;
  }
}

/// Reduces a pasted link or shared message to the code it carries as soon as
/// it lands in the field, so pasting the whole message works.
class InviteCodeInputFormatter extends TextInputFormatter {
  const InviteCodeInputFormatter(this.kind);

  final InviteCodeKind kind;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final String code = kind.codeIn(newValue.text);
    if (code == newValue.text) {
      return newValue;
    }
    return TextEditingValue(
      text: code,
      selection: TextSelection.collapsed(offset: code.length),
    );
  }
}
