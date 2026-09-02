import "package:flutter/widgets.dart";

/// Keeps every visited tab mounted (like [IndexedStack]) so switching never
/// rebuilds a page or loses its scroll position, and cross-fades the incoming
/// tab over a short window.
///
/// Tabs are built lazily: a slot's subtree is only created the first time it is
/// shown, so app start still only pays for the first tab.
class FadeIndexedStack extends StatefulWidget {
  const FadeIndexedStack({
    required this.index,
    required this.itemCount,
    required this.itemBuilder,
    this.duration = const Duration(milliseconds: 150),
    super.key,
  });

  final int index;
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final Duration duration;

  @override
  State<FadeIndexedStack> createState() => _FadeIndexedStackState();
}

class _FadeIndexedStackState extends State<FadeIndexedStack>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fade = AnimationController(
    vsync: this,
    duration: widget.duration,
    value: 1,
  );
  late final Animation<double> _fadeReversed = ReverseAnimation(_fade);
  late int _previousIndex = widget.index;
  late final List<Widget?> _built = List<Widget?>.filled(
    widget.itemCount,
    null,
  );

  @override
  void didUpdateWidget(FadeIndexedStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.index != widget.index) {
      _previousIndex = oldWidget.index;
      _fade.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _fade.dispose();
    super.dispose();
  }

  bool _isVisible(int slot) =>
      slot == widget.index || (slot == _previousIndex && _fade.isAnimating);

  Animation<double> _opacityFor(int slot) {
    if (slot == widget.index) {
      return _fade;
    }
    if (slot == _previousIndex) {
      return _fadeReversed;
    }
    return kAlwaysCompleteAnimation;
  }

  @override
  Widget build(BuildContext context) {
    _built[widget.index] ??= widget.itemBuilder(context, widget.index);

    return AnimatedBuilder(
      animation: _fade,
      builder: (context, _) => Stack(
        fit: StackFit.expand,
        children: [
          for (int slot = 0; slot < widget.itemCount; slot++)
            KeyedSubtree(
              key: ValueKey<int>(slot),
              child: _built[slot] == null
                  ? const SizedBox.shrink()
                  : Offstage(
                      offstage: !_isVisible(slot),
                      child: TickerMode(
                        enabled: _isVisible(slot),
                        child: IgnorePointer(
                          ignoring: slot != widget.index,
                          child: ExcludeSemantics(
                            excluding: slot != widget.index,
                            child: FadeTransition(
                              opacity: _opacityFor(slot),
                              child: RepaintBoundary(child: _built[slot]),
                            ),
                          ),
                        ),
                      ),
                    ),
            ),
        ],
      ),
    );
  }
}
