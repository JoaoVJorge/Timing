import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";
import "package:timing/app/app_constants.dart";
import "package:timing/core/services/deep_links/invite_code.dart";

void main() {
  group("codeIn", () {
    test("a code typed or pasted alone is kept as it is", () {
      expect(InviteCodeKind.friend.codeIn(" a1b2c3 "), "a1b2c3");
      expect(InviteCodeKind.friend.codeIn("@A1B2C3D4E5"), "@A1B2C3D4E5");
      expect(InviteCodeKind.group.codeIn("H0123456789"), "H0123456789");
    });

    test("an app link gives the code it carries", () {
      expect(
        InviteCodeKind.friend.codeIn(AppConstants.friendLink("a1b2c3d4e5")),
        "A1B2C3D4E5",
      );
      expect(
        InviteCodeKind.group.codeIn(AppConstants.groupLink("h0123456789")),
        "H0123456789",
      );
    });

    test("a whole shared message gives the code in its link", () {
      const String friendMessage =
          "Me adicione no Timing com meu código:\nA1B2C3D4E5\n\n"
          "Abrir no app: com.moonstone.timing://add-friend?code=A1B2C3D4E5";
      const String groupMessage =
          "Entre no meu grupo Estudos 2026 no Timing com o código:\n"
          "H0123456789\n\n"
          "Abrir no app: com.moonstone.timing://join-group?code=H0123456789";

      expect(InviteCodeKind.friend.codeIn(friendMessage), "A1B2C3D4E5");
      expect(InviteCodeKind.group.codeIn(groupMessage), "H0123456789");
    });

    test("messages shared by older versions still give their code", () {
      expect(
        InviteCodeKind.friend.codeIn(
          "Me adicione no Timing com meu código: a1b2c3d4e5",
        ),
        "A1B2C3D4E5",
      );
      expect(
        InviteCodeKind.group.codeIn(
          "Entre no meu grupo Leitura no Timing: "
          "com.moonstone.timing://join-group?code=H0123456789.\n"
          "Se o link não abrir, use o código H0123456789 no app.",
        ),
        "H0123456789",
      );
      expect(
        InviteCodeKind.group.codeIn(
          "Rejoignez mon groupe Lecture sur Timing : use le code H0123456789.",
        ),
        "H0123456789",
      );
    });

    test("the other invite's link or code is not taken for this one", () {
      const String groupMessage =
          "Entre no meu grupo no Timing com o código:\nH0123456789\n\n"
          "Abrir no app: com.moonstone.timing://join-group?code=H0123456789";

      expect(InviteCodeKind.friend.codeIn(groupMessage), groupMessage.trim());
      expect(
        InviteCodeKind.group.codeIn("Meu código de amigo: A1B2C3D4E5"),
        "Meu código de amigo: A1B2C3D4E5",
      );
    });
  });

  test("the field formatter turns a pasted message into its code", () {
    const InviteCodeInputFormatter formatter = InviteCodeInputFormatter(
      InviteCodeKind.group,
    );
    final TextEditingValue pasted = formatter.formatEditUpdate(
      TextEditingValue.empty,
      const TextEditingValue(
        text:
            "Entre no meu grupo no Timing com o código:\nH0123456789\n\n"
            "Abrir no app: com.moonstone.timing://join-group?code=H0123456789",
      ),
    );
    expect(pasted.text, "H0123456789");
    expect(pasted.selection, const TextSelection.collapsed(offset: 11));

    const TextEditingValue typed = TextEditingValue(
      text: "H01",
      selection: TextSelection.collapsed(offset: 3),
    );
    expect(formatter.formatEditUpdate(TextEditingValue.empty, typed), typed);
  });
}
