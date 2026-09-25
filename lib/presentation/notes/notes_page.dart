import "dart:math" as math;

import "package:flutter/material.dart";
import "package:flutter_quill/flutter_quill.dart";
import "package:get/get.dart";
import "package:timing/core/utils/extensions/context_extensions.dart";
import "package:timing/presentation/notes/notes_controller.dart";
import "package:timing/shared/widgets/app_scaffold.dart";
import "package:timing/shared/widgets/app_top_bar.dart";
import "package:timing/theme/subject_colors.dart";

class NotesPage extends StatelessWidget {
  const NotesPage({super.key});

  static const double _lineSpacing = 28;
  static const double _marginX = 32;
  static const double _belowToolbarReservedHeight = 8 + 60 + 16;
  static const double _toolbarKeyboardGap = 8;

  @override
  Widget build(BuildContext context) {
    final NotesController controller = Get.find();
    final Color marginColor = context.colorTokens.primary;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          return;
        }
        controller.onBack();
      },
      child: AppScaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: context.colorTokens.scaffold,
        topBar: AppTopBar(
          title: "${context.l10n.notesLabel}\n${controller.subject.name}",
          titleMaxLines: 3,
          showBackButton: true,
          onBack: () => controller.onBack(),
          trailing: IconButton(
            onPressed: controller.toggleFormattingToolbar,
            tooltip: context.l10n.editButton,
            color: context.colorTokens.primary,
            iconSize: 30,
            icon: const Icon(Icons.edit_outlined),
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Builder(
                builder: (context) {
                  return Padding(
                    padding: EdgeInsets.zero,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                              bottom: math.max(
                                0.0,
                                MediaQuery.viewInsetsOf(context).bottom -
                                    _belowToolbarReservedHeight +
                                    _toolbarKeyboardGap,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Container(
                                    clipBehavior: Clip.antiAlias,
                                    decoration: BoxDecoration(
                                      color: context.colorTokens.surface,
                                      borderRadius: BorderRadius.circular(28),
                                      border: Border.all(
                                        color: context.colorTokens.divider
                                            .withValues(alpha: 0.75),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color:
                                              context.colorTokens.surfaceShadow,
                                          blurRadius: 24,
                                          offset: const Offset(0, 10),
                                        ),
                                      ],
                                    ),
                                    child: Obx(
                                      () => PageView.builder(
                                        controller: controller.pageController,
                                        itemCount: controller.pageCount,
                                        onPageChanged: controller.onPageChanged,
                                        itemBuilder: (context, index) => Stack(
                                          children: [
                                            Positioned.fill(
                                              child: CustomPaint(
                                                painter: _MarginLinePainter(
                                                  color: marginColor,
                                                  marginX: _marginX,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                left: _marginX + 16,
                                                right: 20,
                                                top: 28,
                                                bottom: 20,
                                              ),
                                              child: QuillEditor.basic(
                                                controller: controller
                                                    .notesControllers[index],
                                                focusNode: controller
                                                    .focusNodes[index],
                                                config: QuillEditorConfig(
                                                  expands: true,
                                                  showCursor: true,
                                                  paintCursorAboveText: true,
                                                  onTapOutsideEnabled: false,
                                                  textSelectionThemeData:
                                                      TextSelectionThemeData(
                                                        cursorColor: context
                                                            .colorTokens
                                                            .primary,
                                                        selectionColor: context
                                                            .colorTokens
                                                            .primaryVeryLight,
                                                        selectionHandleColor:
                                                            context
                                                                .colorTokens
                                                                .primary,
                                                      ),
                                                  padding: EdgeInsets.zero,
                                                  placeholder:
                                                      context.l10n.notesHint,
                                                  customStyles: DefaultStyles(
                                                    paragraph:
                                                        DefaultTextBlockStyle(
                                                          TextStyle(
                                                            fontSize: 16,
                                                            height:
                                                                _lineSpacing /
                                                                16,
                                                            color: context
                                                                .colorTokens
                                                                .textBody,
                                                          ),
                                                          HorizontalSpacing
                                                              .zero,
                                                          VerticalSpacing.zero,
                                                          VerticalSpacing.zero,
                                                          null,
                                                        ),
                                                    placeHolder:
                                                        DefaultTextBlockStyle(
                                                          TextStyle(
                                                            fontSize: 16,
                                                            height:
                                                                _lineSpacing /
                                                                16,
                                                            color: context
                                                                .colorTokens
                                                                .textHint,
                                                          ),
                                                          HorizontalSpacing
                                                              .zero,
                                                          VerticalSpacing.zero,
                                                          VerticalSpacing.zero,
                                                          null,
                                                        ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Obx(() {
                                  final bool isToolbarVisible = controller
                                      .isFormattingToolbarVisible
                                      .value;
                                  return AnimatedSize(
                                    duration: const Duration(milliseconds: 200),
                                    curve: Curves.easeOut,
                                    alignment: Alignment.bottomCenter,
                                    child: AnimatedOpacity(
                                      duration: const Duration(
                                        milliseconds: 150,
                                      ),
                                      opacity: isToolbarVisible ? 1 : 0,
                                      child: isToolbarVisible
                                          ? Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const SizedBox(height: 12),
                                                _NotesFormattingToolbar(
                                                  notesController: controller,
                                                  controller: controller
                                                      .activeNotesController,
                                                ),
                                              ],
                                            )
                                          : const SizedBox(
                                              width: double.infinity,
                                            ),
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Obx(
                          () => _PageControls(
                            currentPage: controller.currentPageIndex.value + 1,
                            pageCount: controller.pageCount,
                            onPrevious: controller.previousPage,
                            onNext: controller.nextPage,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotesFormattingToolbar extends StatelessWidget {
  const _NotesFormattingToolbar({
    required this.notesController,
    required this.controller,
  });

  final NotesController notesController;
  final QuillController controller;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    child: Container(
      key: const ValueKey("notes-formatting-toolbar"),
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: context.colorTokens.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.colorTokens.borderUnfocused.withValues(alpha: 0.55),
        ),
      ),
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          final FlutterQuillLocalizations localizations =
              FlutterQuillLocalizations.of(context)!;

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _FormattingButton(
                formatKey: "bold",
                icon: Icons.format_bold_rounded,
                tooltip: localizations.bold,
                isActive: notesController.isFormattingActive(Attribute.bold),
                onPressed: () =>
                    notesController.toggleFormatting(Attribute.bold),
              ),
              _FormattingButton(
                formatKey: "italic",
                icon: Icons.format_italic_rounded,
                tooltip: localizations.italic,
                isActive: notesController.isFormattingActive(Attribute.italic),
                onPressed: () =>
                    notesController.toggleFormatting(Attribute.italic),
              ),
              _FormattingButton(
                formatKey: "underline",
                icon: Icons.format_underline_rounded,
                tooltip: localizations.underline,
                isActive: notesController.isFormattingActive(
                  Attribute.underline,
                ),
                onPressed: () =>
                    notesController.toggleFormatting(Attribute.underline),
              ),
              _FormattingButton(
                formatKey: "strike",
                icon: Icons.format_strikethrough_rounded,
                tooltip: localizations.strikeThrough,
                isActive: notesController.isFormattingActive(
                  Attribute.strikeThrough,
                ),
                onPressed: () =>
                    notesController.toggleFormatting(Attribute.strikeThrough),
              ),
              _FormattingButton(
                formatKey: "marker",
                icon: Icons.format_color_fill_rounded,
                tooltip: context.l10n.highlightTextTooltip,
                isActive: notesController.isHighlightActive,
                activeColor: notesController.activeHighlightColor,
                onPressed: () =>
                    _showHighlightColorSheet(context, notesController),
              ),
            ],
          );
        },
      ),
    ),
  );
}

class _FormattingButton extends StatelessWidget {
  const _FormattingButton({
    required this.formatKey,
    required this.icon,
    required this.tooltip,
    required this.isActive,
    required this.onPressed,
    this.activeColor,
  });

  final IconData icon;
  final String formatKey;
  final String tooltip;
  final bool isActive;
  final VoidCallback onPressed;
  final Color? activeColor;

  @override
  Widget build(BuildContext context) {
    final Color? overrideColor = activeColor;
    final Color backgroundColor = isActive
        ? (overrideColor?.withValues(alpha: 0.25) ??
              context.colorTokens.primaryVeryLight)
        : context.colorTokens.transparent;
    final Color iconColor = isActive
        ? (overrideColor ?? context.colorTokens.primary)
        : context.colorTokens.textBody;

    return Tooltip(
      message: tooltip,
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          key: ValueKey<String>("notes-format-$formatKey"),
          onTap: onPressed,
          borderRadius: BorderRadius.circular(14),
          child: SizedBox(
            width: 40,
            height: 40,
            child: Center(child: Icon(icon, size: 24, color: iconColor)),
          ),
        ),
      ),
    );
  }
}

Future<void> _showHighlightColorSheet(
  BuildContext context,
  NotesController notesController,
) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  backgroundColor: context.colorTokens.surface,
  clipBehavior: Clip.antiAlias,
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
  ),
  builder: (context) => _HighlightColorSheet(notesController: notesController),
);

class _HighlightColorSheet extends StatelessWidget {
  const _HighlightColorSheet({required this.notesController});

  final NotesController notesController;

  static const List<Color> _colors = SubjectColors.veryLightValues;

  @override
  Widget build(BuildContext context) => SafeArea(
    child: SizedBox(
      width: double.infinity,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          12,
          20,
          20 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52,
              height: 4,
              decoration: BoxDecoration(
                color: context.colorTokens.borderUnfocused,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: [
                _HighlightColorSwatch(
                  color: null,
                  isSelected: notesController.activeHighlightColor == null,
                  semanticLabel: context.l10n.removeHighlightTooltip,
                  onTap: () {
                    notesController.setHighlightColor(null);
                    Navigator.of(context).pop();
                  },
                ),
                for (final Color color in _colors)
                  _HighlightColorSwatch(
                    color: color,
                    isSelected: notesController.activeHighlightColor == color,
                    semanticLabel: context.l10n.highlightTextTooltip,
                    onTap: () {
                      notesController.setHighlightColor(color);
                      Navigator.of(context).pop();
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

class _HighlightColorSwatch extends StatelessWidget {
  const _HighlightColorSwatch({
    required this.color,
    required this.isSelected,
    required this.semanticLabel,
    required this.onTap,
  });

  final Color? color;
  final bool isSelected;
  final String semanticLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: semanticLabel,
    child: InkWell(
      key: ValueKey<String>(
        "notes-highlight-${color == null ? 'none' : _hexKey(color!)}",
      ),
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: color ?? context.colorTokens.white,
          shape: BoxShape.circle,
          border: color == null
              ? null
              : Border.all(
                  color: isSelected
                      ? context.colorTokens.primary
                      : context.colorTokens.transparent,
                  width: isSelected ? 2.5 : 1,
                ),
          boxShadow: [
            BoxShadow(
              color: context.colorTokens.black.withValues(alpha: 0.15),
              blurRadius: 6,
              offset: const Offset(1, 1),
            ),
          ],
        ),
        child: color == null
            ? Icon(
                Icons.format_color_reset_rounded,
                size: 20,
                color: context.colorTokens.black.withValues(alpha: 0.65),
              )
            : null,
      ),
    ),
  );

  static String _hexKey(Color color) =>
      (color.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, "0");
}

class _PageControls extends StatelessWidget {
  const _PageControls({
    required this.currentPage,
    required this.pageCount,
    required this.onPrevious,
    required this.onNext,
  });

  final int currentPage;
  final int pageCount;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) => Container(
    key: const ValueKey("notes-page-controls"),
    height: 60,
    padding: const EdgeInsets.symmetric(horizontal: 8),
    decoration: BoxDecoration(
      color: context.colorTokens.scaffold.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(999),
      border: Border.all(
        color: context.colorTokens.divider.withValues(alpha: 0.65),
      ),
    ),
    child: Row(
      children: [
        _NavigationButton(
          icon: Icons.chevron_left_rounded,
          tooltip: MaterialLocalizations.of(context).previousPageTooltip,
          onTap: currentPage > 1 ? onPrevious : null,
        ),
        Expanded(
          child: Semantics(
            label: context.l10n.notesPageCounter(currentPage, pageCount),
            child: Text(
              "$currentPage / $pageCount",
              textAlign: TextAlign.center,
              style: context.textStyles.bodyLarge.copyWith(
                color: context.colorTokens.textBody,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        _NavigationButton(
          icon: Icons.chevron_right_rounded,
          tooltip: MaterialLocalizations.of(context).nextPageTooltip,
          onTap: onNext,
        ),
      ],
    ),
  );
}

class _NavigationButton extends StatelessWidget {
  const _NavigationButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => IconButton(
    onPressed: onTap,
    tooltip: tooltip,
    visualDensity: VisualDensity.compact,
    color: context.colorTokens.primary,
    disabledColor: context.colorTokens.textHint.withValues(alpha: 0.45),
    icon: Icon(icon),
  );
}

class _MarginLinePainter extends CustomPainter {
  const _MarginLinePainter({required this.color, required this.marginX});

  final Color color;
  final double marginX;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint marginPaint = Paint()
      ..color = color
      ..strokeWidth = 1.5;
    canvas.drawLine(
      Offset(marginX, 0),
      Offset(marginX, size.height),
      marginPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _MarginLinePainter oldDelegate) =>
      oldDelegate.color != color;
}
