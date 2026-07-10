import "package:flutter/material.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";

class GroupMemberAvatar extends StatelessWidget {
  const GroupMemberAvatar({
    required this.name,
    required this.colorValue,
    this.size = 40,
    super.key,
  });

  final String name;
  final int colorValue;
  final double size;

  @override
  Widget build(BuildContext context) {
    final Color color = Color(colorValue);
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: context.isDarkMode ? 0.28 : 0.18),
        shape: BoxShape.circle,
      ),
      child: Text(
        _initials(name),
        maxLines: 1,
        overflow: TextOverflow.clip,
        style: context.textStyles.bodySmall.copyWith(
          color: color,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  static String _initials(String name) {
    final List<String> words = name
        .trim()
        .split(RegExp(r"\s+"))
        .where((word) => word.isNotEmpty)
        .toList();
    if (words.isEmpty) {
      return "?";
    }
    final String first = words.first.characters.first.toUpperCase();
    if (words.length == 1) {
      return first;
    }
    return "$first${words.last.characters.first.toUpperCase()}";
  }
}
