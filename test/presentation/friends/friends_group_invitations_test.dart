import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:timing/core/domain/entities/group_invitation_entity.dart";
import "package:timing/core/domain/enums/group_theme_type.dart";
import "package:timing/presentation/friends/widgets/friends_group_invitations.dart";

import "../../support/pump_in_scroll_view.dart";

void main() {
  group("FriendsGroupInvitations", () {
    testWidgets("collapses to nothing when there are no invitations", (
      tester,
    ) async {
      await pumpInScrollView(
        tester,
        FriendsGroupInvitations(
          invitations: const [],
          onAccept: (_) {},
          onDecline: (_) {},
        ),
      );

      expect(find.byType(Icon), findsNothing);
    });

    testWidgets("lays out a pending invitation with accept and decline", (
      tester,
    ) async {
      GroupInvitationEntity? accepted;
      GroupInvitationEntity? declined;
      final GroupInvitationEntity invitation = GroupInvitationEntity(
        id: "inv-1",
        groupId: "grp-1",
        groupName: "Estudos de manhã",
        theme: GroupThemeType.studying,
        inviterId: "user-2",
        inviterName: "Ana",
        createdAt: DateTime(2026, 8, 11),
      );

      await pumpInScrollView(
        tester,
        FriendsGroupInvitations(
          invitations: [invitation],
          onAccept: (item) => accepted = item,
          onDecline: (item) => declined = item,
        ),
      );

      expect(find.text("Estudos de manhã"), findsOneWidget);

      await tester.tap(find.byIcon(Icons.check_rounded));
      await tester.tap(find.byIcon(Icons.close_rounded));

      expect(accepted, invitation);
      expect(declined, invitation);
    });
  });
}
