import "package:flutter/material.dart";
import "package:help_out/core/domain/entities/subject_entity.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/shared/functions/format_name.dart";
import "package:help_out/shared/widgets/bounce_tap.dart";

class TopThemeTile extends StatelessWidget {
  const TopThemeTile({
    required this.rank,
    required this.subject,
    this.onTap,
    super.key,
  });

  final int rank;
  final SubjectEntity subject;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Widget tile = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: context.colorTokens.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.colorTokens.borderUnfocused),
      ),
      child: _content(context),
    );

    if (onTap == null) {
      return tile;
    }
    return BounceTap(
      onTap: onTap!,
      pressedScale: 0.98,
      behavior: HitTestBehavior.opaque,
      child: tile,
    );
  }

  Widget _content(BuildContext context) => Row(
      children: [
        Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Color(subject.colorValue).withValues(alpha: 0.18),
            shape: BoxShape.circle,
          ),
          child: Text(
            "#$rank",
            style: context.textStyles.bodyTiny.copyWith(
              color: Color(subject.colorValue),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            capitalizeName(subject.name),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textStyles.bodyLarge,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          context.l10n.metricPagesValue(subject.currentPages),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.textStyles.bodySmall.copyWith(
            color: context.colorTokens.textHint,
          ),
        ),
      ],
    );
}
