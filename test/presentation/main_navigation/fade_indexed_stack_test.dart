import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:timing/presentation/main_navigation/fade_indexed_stack.dart";

/// Counts its own builds so a test can tell "kept mounted" from "rebuilt".
class _Tab extends StatefulWidget {
  const _Tab(this.label);

  final String label;

  @override
  State<_Tab> createState() => _TabState();
}

class _TabState extends State<_Tab> {
  int builds = 0;

  @override
  Widget build(BuildContext context) {
    builds++;
    return Text("${widget.label}:$builds", textDirection: TextDirection.ltr);
  }
}

void main() {
  Widget host({
    required int index,
    required List<String> labels,
    required Set<int> builtSlots,
  }) => MaterialApp(
    home: FadeIndexedStack(
      index: index,
      itemCount: labels.length,
      itemBuilder: (context, slot) {
        builtSlots.add(slot);
        return _Tab(labels[slot]);
      },
    ),
  );

  testWidgets("only the visible tab is built; others activate lazily", (
    tester,
  ) async {
    final Set<int> built = {};
    await tester.pumpWidget(
      host(index: 0, labels: const ["a", "b", "c"], builtSlots: built),
    );

    expect(built, {0});
    expect(find.text("a:1"), findsOneWidget);
    expect(find.textContaining("b:", skipOffstage: false), findsNothing);

    await tester.pumpWidget(
      host(index: 1, labels: const ["a", "b", "c"], builtSlots: built),
    );
    await tester.pumpAndSettle();

    expect(built, {0, 1});
    expect(find.text("b:1"), findsOneWidget);
    // "c" was never shown, so it was never built.
    expect(find.textContaining("c:", skipOffstage: false), findsNothing);
  });

  testWidgets("switching away and back keeps the tab mounted, not rebuilt", (
    tester,
  ) async {
    final Set<int> built = {};
    await tester.pumpWidget(
      host(index: 0, labels: const ["a", "b"], builtSlots: built),
    );
    final _TabState tabA = tester.state(find.byType(_Tab));
    expect(tabA.builds, 1);

    await tester.pumpWidget(
      host(index: 1, labels: const ["a", "b"], builtSlots: built),
    );
    await tester.pumpAndSettle();
    await tester.pumpWidget(
      host(index: 0, labels: const ["a", "b"], builtSlots: built),
    );
    await tester.pumpAndSettle();

    // Same State instance, same build count: tab A was never torn down, so its
    // scroll offset / local state would have survived the round trip.
    expect(identical(tabA, tester.state(find.byType(_Tab))), isTrue);
    expect(tabA.builds, 1);
    expect(built, {0, 1});
  });

  testWidgets("both tabs are on screen during the cross-fade, one after it", (
    tester,
  ) async {
    final Set<int> built = {};
    await tester.pumpWidget(
      host(index: 0, labels: const ["a", "b"], builtSlots: built),
    );

    await tester.pumpWidget(
      host(index: 1, labels: const ["a", "b"], builtSlots: built),
    );
    await tester.pump(const Duration(milliseconds: 75)); // mid cross-fade

    expect(find.text("a:1"), findsOneWidget);
    expect(find.text("b:1"), findsOneWidget);

    await tester.pumpAndSettle();

    expect(find.text("a:1"), findsNothing); // now offstage
    expect(find.text("a:1", skipOffstage: false), findsOneWidget);
    expect(find.text("b:1"), findsOneWidget);
  });

  testWidgets("only the incoming tab receives taps during the cross-fade", (
    tester,
  ) async {
    int firstTabTaps = 0;
    int secondTabTaps = 0;

    Widget tappableHost(int index) => MaterialApp(
      home: FadeIndexedStack(
        index: index,
        itemCount: 2,
        itemBuilder: (context, slot) => GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            if (slot == 0) {
              firstTabTaps++;
            } else {
              secondTabTaps++;
            }
          },
          child: SizedBox.expand(child: Text("tab $slot")),
        ),
      ),
    );

    // Switching from the higher slot to the lower one leaves the outgoing tab
    // later in Stack paint order, which used to let it intercept this tap.
    await tester.pumpWidget(tappableHost(1));
    await tester.pumpWidget(tappableHost(0));
    await tester.pump(const Duration(milliseconds: 75));
    await tester.tapAt(tester.getCenter(find.byType(FadeIndexedStack)));

    expect(firstTabTaps, 1);
    expect(secondTabTaps, 0);
  });
}
