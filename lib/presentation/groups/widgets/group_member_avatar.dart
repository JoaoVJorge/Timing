import "dart:convert";

import "package:flutter/material.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";

class GroupMemberAvatar extends StatelessWidget {
  const GroupMemberAvatar({
    required this.name,
    required this.colorValue,
    this.avatar = "",
    this.size = 40,
    this.borderColor,
    super.key,
  });

  final String name;
  final int colorValue;
  final String avatar;
  final double size;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final Color color = Color(colorValue);
    final String imagePayload = avatar.trim();
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: context.isDarkMode ? 0.28 : 0.18),
        shape: BoxShape.circle,
        border: borderColor == null
            ? null
            : Border.all(color: borderColor!, width: 2),
        image: imagePayload.isEmpty
            ? null
            : DecorationImage(
                image: MemoryImage(base64Decode(_base64Payload(imagePayload))),
                fit: BoxFit.cover,
              ),
      ),
      child: imagePayload.isNotEmpty
          ? null
          : Text(
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

  static String _base64Payload(String value) {
    final int commaIndex = value.indexOf(",");
    if (commaIndex < 0) {
      return value;
    }
    return value.substring(commaIndex + 1);
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
