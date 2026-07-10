import "package:flutter/material.dart";
import "package:help_out/core/domain/entities/subject_entity.dart";
import "package:help_out/core/domain/enums/time_category_type.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/shared/widgets/app_icon.dart";
import "package:help_out/theme/subject_icons.dart";

class SubjectIconBadge extends StatelessWidget {
  const SubjectIconBadge({
    required this.subject,
    this.width = 44,
    this.height = 44,
    this.iconSize = 22,
    this.borderRadius = 14,
    super.key,
  });

  final SubjectEntity subject;
  final double width;
  final double height;
  final double iconSize;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final Color color = Color(subject.colorValue);
    final String iconName = subject.iconName.isEmpty
        ? _fallbackIconName(subject.category)
        : subject.iconName;
    final IconData? icon = SubjectIcons.byName(iconName);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Center(
        child: icon == null
            ? AppIcon(
                iconName,
                size: iconSize,
                color: context.colorTokens.white,
              )
            : Icon(icon, size: iconSize, color: context.colorTokens.white),
      ),
    );
  }

  String _fallbackIconName(TimeCategoryType category) => switch (category) {
    TimeCategoryType.studying => "school",
    TimeCategoryType.reading => "book",
    TimeCategoryType.exercises => "fitness",
    TimeCategoryType.hobbies => "music",
  };
}
