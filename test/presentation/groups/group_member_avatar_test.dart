import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:timing/presentation/groups/widgets/group_member_avatar.dart";
import "package:timing/theme/avatar_presets.dart";
import "package:timing/theme/theme.dart";

void main() {
  Widget app(Widget child) => MaterialApp(
    theme: AppThemes.build(seed: Colors.blue, brightness: Brightness.light),
    home: Scaffold(body: child),
  );

  testWidgets("uses the selected avatar preset when there is no photo", (
    tester,
  ) async {
    await tester.pumpWidget(
      app(
        const GroupMemberAvatar(
          name: "User",
          colorValue: 0xFF123456,
          avatarIconIndex: 3,
        ),
      ),
    );

    expect(find.byIcon(AppAvatarPresets.byIndex(3)), findsOneWidget);
  });

  testWidgets("uses initials when a legacy payload has no avatar index", (
    tester,
  ) async {
    await tester.pumpWidget(
      app(const GroupMemberAvatar(name: "Ana Souza", colorValue: 0xFF123456)),
    );

    expect(find.text("AS"), findsOneWidget);
  });

  testWidgets("a profile photo takes precedence over the avatar preset", (
    tester,
  ) async {
    const String onePixelPng =
        "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk"
        "/x8AAusB9Wl2nWQAAAAASUVORK5CYII=";

    await tester.pumpWidget(
      app(
        const GroupMemberAvatar(
          key: ValueKey("member-avatar"),
          name: "User",
          colorValue: 0xFF123456,
          avatar: onePixelPng,
          avatarIconIndex: 3,
        ),
      ),
    );

    final Finder containerFinder = find.descendant(
      of: find.byKey(const ValueKey("member-avatar")),
      matching: find.byType(Container),
    );
    final Container container = tester.widget<Container>(containerFinder.first);
    final BoxDecoration decoration = container.decoration! as BoxDecoration;

    expect(decoration.image, isNotNull);
    expect(find.byIcon(AppAvatarPresets.byIndex(3)), findsNothing);
  });
}
