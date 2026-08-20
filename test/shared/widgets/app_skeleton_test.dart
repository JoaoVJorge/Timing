import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:timing/presentation/friends/widgets/friends_loading_skeleton.dart";
import "package:timing/shared/widgets/app_skeleton.dart";
import "package:timing/theme/theme.dart";

/// Renders [child] in a bounded page (like the real Scaffold body) and advances
/// a few frames. [AppSkeleton] loops forever, so `pumpAndSettle` is avoided.
Future<void> _pumpSkeleton(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppThemes.build(seed: Colors.blue, brightness: Brightness.light),
      home: Scaffold(body: Padding(padding: const EdgeInsets.all(16), child: child)),
    ),
  );
  await tester.pump(const Duration(milliseconds: 300));
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  group("AppSkeleton", () {
    testWidgets("renders shimmering placeholders without errors", (
      tester,
    ) async {
      await _pumpSkeleton(
        tester,
        const AppSkeleton(
          child: Column(
            children: [
              AppSkeletonBox(height: 18, width: 128),
              SizedBox(height: 8),
              AppSkeletonCircle(size: 42),
            ],
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.byType(AppSkeletonBox), findsOneWidget);
      expect(find.byType(AppSkeletonCircle), findsOneWidget);
    });

    testWidgets("friends skeleton now shimmers like the others", (
      tester,
    ) async {
      await _pumpSkeleton(tester, const FriendsLoadingSkeleton());

      expect(tester.takeException(), isNull);
      // The unified shimmer wrapper is present around the friends placeholder.
      expect(find.byType(AppSkeleton), findsOneWidget);
      expect(find.byType(AppSkeletonBox), findsWidgets);
      expect(find.byType(AppSkeletonCircle), findsWidgets);
    });
  });
}
