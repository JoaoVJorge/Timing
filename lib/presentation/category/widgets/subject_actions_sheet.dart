import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:help_out/app/app_navigator.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/shared/widgets/app_nav_row.dart";
import "package:help_out/theme/app_spacing.dart";

enum SubjectAction { notes, edit, delete }

/// Discoverable counterpart to the swipe gestures on a subject tile.
Future<SubjectAction?> showSubjectActionsSheet({
  required String subjectName,
  required bool hasNotes,
}) => appNavigator.modalBottomSheet<SubjectAction>(
  child: _SubjectActionsSheet(subjectName: subjectName, hasNotes: hasNotes),
);

class _SubjectActionsSheet extends StatelessWidget {
  const _SubjectActionsSheet({
    required this.subjectName,
    required this.hasNotes,
  });

  final String subjectName;
  final bool hasNotes;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(
      AppSpacing.page,
      AppSpacing.betweenRelated,
      AppSpacing.page,
      AppSpacing.betweenSections,
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: context.colorTokens.borderUnfocused,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ),
        const Gap(AppSpacing.betweenRelated),
        Text(
          subjectName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.textStyles.sectionTitle,
        ),
        const Gap(AppSpacing.betweenRelated),
        AppNavRowGroup(
          rows: [
            if (hasNotes)
              AppNavRow(
                icon: Icons.sticky_note_2_rounded,
                title: context.l10n.notesLabel,
                onTap: () =>
                    appNavigator.back<SubjectAction>(result: SubjectAction.notes),
              ),
            AppNavRow(
              icon: Icons.edit_rounded,
              title: context.l10n.editButton,
              onTap: () =>
                  appNavigator.back<SubjectAction>(result: SubjectAction.edit),
            ),
            AppNavRow(
              icon: Icons.delete_outline_rounded,
              iconColor: context.colorTokens.error,
              title: context.l10n.deleteButton,
              onTap: () =>
                  appNavigator.back<SubjectAction>(result: SubjectAction.delete),
            ),
          ],
        ),
      ],
    ),
  );
}
