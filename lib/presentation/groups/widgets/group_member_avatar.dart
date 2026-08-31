import "dart:convert";
import "dart:typed_data";

import "package:flutter/material.dart";
import "package:timing/core/utils/extensions/context_extensions.dart";

class GroupMemberAvatar extends StatefulWidget {
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
  State<GroupMemberAvatar> createState() => _GroupMemberAvatarState();

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

class _GroupMemberAvatarState extends State<GroupMemberAvatar> {
  Uint8List? _imageBytes;

  @override
  void initState() {
    super.initState();
    _decodeAvatar();
  }

  @override
  void didUpdateWidget(covariant GroupMemberAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.avatar != widget.avatar) {
      _decodeAvatar();
    }
  }

  void _decodeAvatar() {
    final String payload = widget.avatar.trim();
    _imageBytes = payload.isEmpty
        ? null
        : base64Decode(GroupMemberAvatar._base64Payload(payload));
  }

  @override
  Widget build(BuildContext context) {
    final Color color = Color(widget.colorValue);
    final Uint8List? imageBytes = _imageBytes;
    final int decodeWidth =
        (widget.size * MediaQuery.devicePixelRatioOf(context)).round();
    return Container(
      width: widget.size,
      height: widget.size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: context.isDarkMode ? 0.28 : 0.18),
        shape: BoxShape.circle,
        border: widget.borderColor == null
            ? null
            : Border.all(color: widget.borderColor!, width: 2),
        image: imageBytes == null
            ? null
            : DecorationImage(
                image: ResizeImage(MemoryImage(imageBytes), width: decodeWidth),
                fit: BoxFit.cover,
              ),
      ),
      child: imageBytes != null
          ? null
          : Text(
              GroupMemberAvatar._initials(widget.name),
              maxLines: 1,
              overflow: TextOverflow.clip,
              style: context.textStyles.bodySmall.copyWith(
                color: color,
                fontWeight: FontWeight.w900,
              ),
            ),
    );
  }
}
