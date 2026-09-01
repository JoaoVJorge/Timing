import "package:flutter/material.dart";
import "package:flutter_quill/flutter_quill.dart";
import "package:get/get.dart";
import "package:timing/core/utils/extensions/context_extensions.dart";
import "package:timing/presentation/notes/notes_controller.dart";
import "package:timing/shared/widgets/app_scaffold.dart";
import "package:timing/shared/widgets/app_top_bar.dart";

class NotesPage extends StatelessWidget {
  const NotesPage({super.key});

  static const double _lineSpacing = 28;
  static const double _marginX = 32;

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
            onPressed: controller.addPage,
            tooltip: context.l10n.addNotesPageTooltip,
            color: context.colorTokens.primary,
            iconSize: 30,
            icon: const Icon(Icons.note_add_outlined),
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
                          child: Container(
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(
                              color: context.colorTokens.surface,
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(
                                color: context.colorTokens.divider.withValues(
                                  alpha: 0.75,
                                ),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: context.colorTokens.surfaceShadow,
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
                                        controller:
                                            controller.notesControllers[index],
                                        config: QuillEditorConfig(
                                          expands: true,
                                          showCursor: true,
                                          paintCursorAboveText: true,
                                          onTapOutsideEnabled: false,
                                          textSelectionThemeData:
                                              TextSelectionThemeData(
                                                cursorColor:
                                                    context.colorTokens.primary,
                                                selectionColor: context
                                                    .colorTokens
                                                    .primaryVeryLight,
                                                selectionHandleColor:
                                                    context.colorTokens.primary,
                                              ),
                                          padding: EdgeInsets.zero,
                                          placeholder: context.l10n.notesHint,
                                          customStyles: DefaultStyles(
                                            paragraph: DefaultTextBlockStyle(
                                              TextStyle(
                                                fontSize: 16,
                                                height: _lineSpacing / 16,
                                                color: context
                                                    .colorTokens
                                                    .textBody,
                                              ),
                                              HorizontalSpacing.zero,
                                              VerticalSpacing.zero,
                                              VerticalSpacing.zero,
                                              null,
                                            ),
                                            placeHolder: DefaultTextBlockStyle(
                                              TextStyle(
                                                fontSize: 16,
                                                height: _lineSpacing / 16,
                                                color: context
                                                    .colorTokens
                                                    .textHint,
                                              ),
                                              HorizontalSpacing.zero,
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
                        const SizedBox(height: 12),
                        Obx(
                          () => _NotesFormattingToolbar(
                            notesController: controller,
                            controller: controller.activeNotesController,
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
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: context.colorTokens.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.colorTokens.borderUnfocused.withValues(alpha: 0.55),
        ),
        boxShadow: [
          BoxShadow(
            color: context.colorTokens.surfaceShadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
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
  });

  final IconData icon;
  final String formatKey;
  final String tooltip;
  final bool isActive;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: tooltip,
    child: Material(
      color: isActive
          ? context.colorTokens.primaryVeryLight
          : context.colorTokens.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        key: ValueKey<String>("notes-format-$formatKey"),
        onTap: onPressed,
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Center(
            child: Icon(
              icon,
              size: 24,
              color: isActive
                  ? context.colorTokens.primary
                  : context.colorTokens.textBody,
            ),
          ),
        ),
      ),
    ),
  );
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
          onTap: currentPage < pageCount ? onNext : null,
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
