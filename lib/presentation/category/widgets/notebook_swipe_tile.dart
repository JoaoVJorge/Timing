import "package:flutter/material.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";

class NotebookSwipeTile extends StatefulWidget {
  const NotebookSwipeTile({
    required this.child,
    required this.onTapNotes,
    super.key,
  });

  final Widget child;
  final VoidCallback onTapNotes;

  @override
  State<NotebookSwipeTile> createState() => _NotebookSwipeTileState();
}

class _NotebookSwipeTileState extends State<NotebookSwipeTile>
    with SingleTickerProviderStateMixin {
  static const double _revealWidth = 72;
  static const double _gap = 8;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
    upperBound: _revealWidth,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    _controller.value = (_controller.value + details.delta.dx).clamp(
      0,
      _revealWidth,
    );
  }

  void _onDragEnd(DragEndDetails details) {
    final bool shouldOpen = _controller.value > _revealWidth / 2;
    _controller.animateTo(shouldOpen ? _revealWidth : 0, curve: Curves.easeOut);
  }

  void _onTapNotes() {
    widget.onTapNotes();
    _controller.animateTo(0, curve: Curves.easeOut);
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _controller,
    builder: (context, child) => Stack(
      children: [
        Positioned.fill(
          child: Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: _onTapNotes,
              child: Container(
                width: _revealWidth - _gap,
                margin: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  gradient: context.colorTokens.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.edit_note_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          ),
        ),
        GestureDetector(
          onHorizontalDragUpdate: _onDragUpdate,
          onHorizontalDragEnd: _onDragEnd,
          child: Transform.translate(
            offset: Offset(_controller.value, 0),
            child: child,
          ),
        ),
      ],
    ),
    child: widget.child,
  );
}
