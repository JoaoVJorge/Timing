import "package:flutter/material.dart";

class CenteredWrapGrid extends StatelessWidget {
  const CenteredWrapGrid({
    required this.children,
    this.itemsPerRow = 4,
    this.spacing = 12,
    this.runSpacing = 12,
    super.key,
  });

  final List<Widget> children;
  final int itemsPerRow;
  final double spacing;
  final double runSpacing;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      for (int start = 0; start < children.length; start += itemsPerRow) ...[
        if (start > 0) SizedBox(height: runSpacing),
        SizedBox(
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (
                int i = start;
                i < start + itemsPerRow && i < children.length;
                i++
              ) ...[if (i > start) SizedBox(width: spacing), children[i]],
            ],
          ),
        ),
      ],
    ],
  );
}

class CenteredBalancedRows extends StatelessWidget {
  const CenteredBalancedRows({
    required this.children,
    this.spacing = 12,
    this.runSpacing = 12,
    super.key,
  });

  final List<Widget> children;
  final double spacing;
  final double runSpacing;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) {
      return const SizedBox.shrink();
    }

    final int topRowCount = (children.length + 1) ~/ 2;
    final List<Widget> topRow = children.take(topRowCount).toList();
    final List<Widget> bottomRow = children.skip(topRowCount).toList();

    return Column(
      children: [
        _CenteredRow(spacing: spacing, children: topRow),
        if (bottomRow.isNotEmpty) ...[
          SizedBox(height: runSpacing),
          _CenteredRow(spacing: spacing, children: bottomRow),
        ],
      ],
    );
  }
}

class _CenteredRow extends StatelessWidget {
  const _CenteredRow({required this.children, required this.spacing});

  final List<Widget> children;
  final double spacing;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int index = 0; index < children.length; index++) ...[
          if (index > 0) SizedBox(width: spacing),
          children[index],
        ],
      ],
    ),
  );
}
