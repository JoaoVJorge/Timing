import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:timing/core/domain/entities/group_member_entity.dart";
import "package:timing/core/domain/enums/group_theme_type.dart";
import "package:timing/l10n/app_localizations.dart";
import "package:timing/presentation/groups/widgets/group_member_avatar.dart";
import "package:timing/presentation/groups/widgets/leaderboard_tile.dart";
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

  /// The fill of the avatar circle, read from what is actually rendered.
  BoxDecoration circleOf(WidgetTester tester, Finder avatar) {
    final Finder container = find.descendant(
      of: avatar,
      matching: find.byType(Container),
    );
    return tester.widget<Container>(container.first).decoration!
        as BoxDecoration;
  }

  testWidgets("without a photo the circle is see-through by default", (
    tester,
  ) async {
    await tester.pumpWidget(
      app(
        const GroupMemberAvatar(
          key: ValueKey("member-avatar"),
          name: "Ana Souza",
          colorValue: 0xFF123456,
        ),
      ),
    );

    final BoxDecoration decoration = circleOf(
      tester,
      find.byKey(const ValueKey("member-avatar")),
    );
    expect(decoration.color!.a, lessThan(1));
  });

  testWidgets("without a photo the circle can be a solid color", (
    tester,
  ) async {
    await tester.pumpWidget(
      app(
        const GroupMemberAvatar(
          key: ValueKey("member-avatar"),
          name: "Ana Souza",
          colorValue: 0xFF123456,
          useSolidFallbackBackground: true,
        ),
      ),
    );

    final BoxDecoration decoration = circleOf(
      tester,
      find.byKey(const ValueKey("member-avatar")),
    );
    expect(decoration.color, const Color(0xFF123456));
    expect(find.text("AS"), findsOneWidget);
  });

  testWidgets("the ranking shows members without a photo on a solid circle", (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppThemes.build(seed: Colors.blue, brightness: Brightness.light),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: const Scaffold(
          body: LeaderboardTile(
            rank: 4,
            member: GroupMemberEntity(
              id: "member-1",
              name: "Ana Souza",
              avatarColorValue: 0xFF123456,
              todaySeconds: 0,
              weekSeconds: 0,
              monthSeconds: 0,
            ),
            theme: GroupThemeType.studying,
            value: 120,
            isCurrentUser: false,
            isFirst: false,
            isLast: false,
            isTied: false,
          ),
        ),
      ),
    );

    final BoxDecoration decoration = circleOf(
      tester,
      find.byType(GroupMemberAvatar),
    );
    expect(decoration.color, const Color(0xFF123456));
  });
}
