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
