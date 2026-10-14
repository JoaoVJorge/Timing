import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:timing/core/utils/extensions/context_extensions.dart";
import "package:timing/presentation/notes/notes_controller.dart";
import "package:timing/presentation/notes/notes_page_search.dart";
import "package:timing/shared/widgets/bounce_tap.dart";

/// Opens the notebook's page list: every page at once, filtered and searched,
/// so reaching page 14 stops being a swipe hunt.
Future<void> showNotesPagesSheet(
  BuildContext context,
  NotesController controller,
) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  backgroundColor: context.colorTokens.surface,
  clipBehavior: Clip.antiAlias,
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
  ),
  builder: (sheetContext) => _NotesPagesSheet(
    pages: controller.pageSummaries,
    currentPageIndex: controller.currentPageIndex.value,
    onSelectPage: (int index) {
      Navigator.of(sheetContext).pop();
      controller.goToPage(index);
    },
  ),
);

class _NotesPagesSheet extends StatefulWidget {
  const _NotesPagesSheet({
    required this.pages,
    required this.currentPageIndex,
    required this.onSelectPage,
  });

  final List<NotesPageSummary> pages;
  final int currentPageIndex;
  final ValueChanged<int> onSelectPage;

  @override
  State<_NotesPagesSheet> createState() => _NotesPagesSheetState();
}

class _NotesPagesSheetState extends State<_NotesPagesSheet> {
  final TextEditingController _queryController = TextEditingController();

  String _query = "";
  NotesPageFilter _filter = NotesPageFilter.all;

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  void _onQueryChanged(String query) => setState(() => _query = query);

  void _onClearQuery() {
    _queryController.clear();
    _onQueryChanged("");
  }

  void _onSelectFilter(NotesPageFilter filter) =>
      setState(() => _filter = filter);

  @override
  Widget build(BuildContext context) {
    final double keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
    final List<NotesPageSummary> pages = widget.pages
        .where(
          (NotesPageSummary page) =>
              page.matches(filter: _filter, query: _query),
        )
        .toList();

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: keyboardInset),
        child: ConstrainedBox(
          // Leaves the sheet as tall as the page list needs, up to most of what
          // the keyboard leaves of the screen.
          constraints: BoxConstraints(
            maxHeight:
                (MediaQuery.sizeOf(context).height - keyboardInset) * 0.86,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Column(
                  children: [
                    Container(
                      width: 54,
                      height: 6,
                      decoration: BoxDecoration(
                        color: context.colorTokens.borderUnfocused,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    const Gap(18),
                    Text(
                      context.l10n.notesSearchTitle,
                      textAlign: TextAlign.center,
                      style: context.textStyles.extraBold20,
                    ),
                    const Gap(16),
                    _SearchField(
                      controller: _queryController,
                      hasQuery: _query.trim().isNotEmpty,
                      onChanged: _onQueryChanged,
                      onClear: _onClearQuery,
                    ),
                  ],
                ),
              ),
              const Gap(14),
              // Full bleed, so the chips that do not fit scroll off the screen
              // edge instead of being clipped inside the sheet's padding.
              _Filters(selected: _filter, onSelect: _onSelectFilter),
              Flexible(
                child: pages.isEmpty
                    ? const _NoPagesFound()
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(12, 12, 12, 20),
                        shrinkWrap: true,
                        itemCount: pages.length,
                        separatorBuilder: (context, index) => const Gap(4),
                        itemBuilder: (context, index) {
                          final NotesPageSummary page = pages[index];

                          return _NotesPageRow(
                            page: page,
                            query: _query,
                            isCurrent: page.index == widget.currentPageIndex,
                            onTap: () => widget.onSelectPage(page.index),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.hasQuery,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final bool hasQuery;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) => Container(
    height: 52,
    padding: const EdgeInsets.symmetric(horizontal: 14),
    decoration: BoxDecoration(
      color: context.colorTokens.surfaceInnerLayer,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(
        color: context.colorTokens.borderUnfocused.withValues(alpha: 0.55),
      ),
    ),
    child: Row(
      children: [
        Icon(
          Icons.search_rounded,
          size: 22,
          color: context.colorTokens.textHint,
        ),
        const Gap(10),
        Expanded(
          child: TextField(
            key: const ValueKey("notes-pages-search-field"),
            controller: controller,
            onChanged: onChanged,
            textInputAction: TextInputAction.search,
            style: context.textStyles.inputText,
            decoration: InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.zero,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              hintText: context.l10n.notesSearchHint,
              hintStyle: context.textStyles.hintText,
            ),
          ),
        ),
        if (hasQuery)
          IconButton(
            key: const ValueKey("notes-pages-search-clear"),
            onPressed: onClear,
            tooltip: context.l10n.notesSearchClearTooltip,
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            color: context.colorTokens.textHint,
            icon: const Icon(Icons.cancel_rounded, size: 20),
          ),
      ],
    ),
  );
}

class _Filters extends StatelessWidget {
  const _Filters({required this.selected, required this.onSelect});

  final NotesPageFilter selected;
  final ValueChanged<NotesPageFilter> onSelect;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Row(
      children: [
        for (final NotesPageFilter filter in NotesPageFilter.values) ...[
          if (filter != NotesPageFilter.values.first) const Gap(8),
          _FilterChip(
            filter: filter,
            isSelected: filter == selected,
            onTap: () => onSelect(filter),
          ),
        ],
      ],
    ),
  );
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.filter,
    required this.isSelected,
    required this.onTap,
  });

  final NotesPageFilter filter;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => BounceTap(
    onTap: onTap,
    pressedScale: 0.96,
    child: AnimatedContainer(
      key: ValueKey<String>("notes-pages-filter-${filter.name}"),
      duration: const Duration(milliseconds: 180),
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isSelected
            ? context.colorTokens.primaryVeryLight
            : context.colorTokens.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isSelected
              ? context.colorTokens.primary
              : context.colorTokens.borderUnfocused,
        ),
      ),
      child: Text(
        filter.label(context),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: context.textStyles.bodySmall.copyWith(
          color: isSelected
              ? context.colorTokens.primary
              : context.colorTokens.textHint,
          fontWeight: FontWeight.w800,
        ),
      ),
    ),
  );
}

class _NotesPageRow extends StatelessWidget {
  const _NotesPageRow({
    required this.page,
    required this.query,
    required this.isCurrent,
    required this.onTap,
  });

  final NotesPageSummary page;
  final String query;
  final bool isCurrent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool hasText = !page.isEmpty;
    final Color accent = hasText
        ? context.colorTokens.primary
        : context.colorTokens.textHint;

    return BounceTap(
      onTap: onTap,
      pressedScale: 0.98,
      behavior: HitTestBehavior.opaque,
      child: Container(
        key: ValueKey<String>("notes-page-row-${page.index}"),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: isCurrent
              ? context.colorTokens.primaryVeryLight
              : context.colorTokens.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              hasText ? Icons.description_rounded : Icons.description_outlined,
              size: 24,
              color: accent,
            ),
            const Gap(12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          context.l10n.notesPageNumberLabel(page.index + 1),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.textStyles.cardTitle.copyWith(
                            color: isCurrent
                                ? context.colorTokens.primary
                                : context.colorTokens.textBody,
                          ),
                        ),
                      ),
                      if (page.hasHighlight) ...[
                        const Gap(6),
                        Icon(
                          Icons.format_color_fill_rounded,
                          size: 16,
                          color: context.colorTokens.primary,
                        ),
                      ],
                      if (hasText) ...[
                        const Gap(8),
                        Text(
                          context.l10n.notesPageWordCount(page.wordCount),
                          style: context.textStyles.bodySmall.copyWith(
                            color: context.colorTokens.textHint,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const Gap(2),
                  Text(
                    hasText
                        ? page.preview(query)
                        : context.l10n.notesEmptyPageLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textStyles.bodySmall.copyWith(
                      color: context.colorTokens.textHint,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoPagesFound extends StatelessWidget {
  const _NoPagesFound();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 28, 20, 36),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.search_off_rounded,
          size: 36,
          color: context.colorTokens.textHint,
        ),
        const Gap(12),
        Text(
          context.l10n.notesSearchNoResults,
          textAlign: TextAlign.center,
          style: context.textStyles.bodyMedium.copyWith(
            color: context.colorTokens.textHint,
          ),
        ),
      ],
    ),
  );
}

extension on NotesPageFilter {
  String label(BuildContext context) => switch (this) {
    NotesPageFilter.all => context.l10n.notesPagesFilterAll,
    NotesPageFilter.withText => context.l10n.notesPagesFilterWithText,
    NotesPageFilter.highlighted => context.l10n.notesPagesFilterHighlighted,
    NotesPageFilter.empty => context.l10n.notesPagesFilterEmpty,
  };
}
