import "package:flutter/material.dart";
import "package:get/get.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/presentation/notes/notes_controller.dart";
import "package:help_out/shared/widgets/app_scaffold.dart";
import "package:help_out/shared/widgets/app_top_bar.dart";
import "package:help_out/shared/widgets/bounce_tap.dart";

class NotesPage extends StatelessWidget {
  const NotesPage({super.key});

  static const double _lineSpacing = 28;
  static const double _marginX = 32;

  @override
  Widget build(BuildContext context) {
    final NotesController controller = Get.find();
    final Color marginColor = context.colorTokens.primary;

    return AppScaffold(
      backgroundColor: context.colorTokens.scaffold,
      topBar: AppTopBar(
        title: "${context.l10n.notesLabel} - ${controller.subject.name}",
        showBackButton: true,
        onBack: controller.onTapSave,
        trailing: IconButton(
          onPressed: controller.addPage,
          tooltip: context.l10n.addNotesPageTooltip,
          color: context.colorTokens.primary,
          iconSize: 30,
          icon: const Icon(Icons.note_add_outlined),
        ),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(),
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
                    color: context.colorTokens.divider.withValues(alpha: 0.75),
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
                          child: TextField(
                            controller: controller.notesControllers[index],
                            maxLines: null,
                            expands: true,
                            textAlignVertical: TextAlignVertical.top,
                            style: TextStyle(
                              fontSize: 16,
                              height: _lineSpacing / 16,
                              color: context.colorTokens.textBody,
                            ),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: context.l10n.notesHint,
                              hintStyle: TextStyle(
                                fontSize: 16,
                                height: _lineSpacing / 16,
                                color: context.colorTokens.textHint,
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
            const SizedBox(height: 16),
            Obx(
              () => Row(
                children: [
                  Expanded(
                    child: _PageControls(
                      currentPage: controller.currentPageIndex.value + 1,
                      pageCount: controller.pageCount,
                      onPrevious: controller.previousPage,
                      onNext: controller.nextPage,
                    ),
                  ),
                  const SizedBox(width: 12),
                  _SaveButton(
                    label: context.l10n.saveNotesButton,
                    isLoading: controller.isSaving.value,
                    onTap: controller.onTapSave,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
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

class _SaveButton extends StatelessWidget {
  const _SaveButton({
    required this.label,
    required this.isLoading,
    required this.onTap,
  });

  final String label;
  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Widget content = Container(
      height: 60,
      constraints: const BoxConstraints(minWidth: 128),
      padding: const EdgeInsets.symmetric(horizontal: 22),
      decoration: BoxDecoration(
        gradient: context.colorTokens.primaryGradient,
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: context.colorTokens.surfaceShadow,
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Center(
        child: isLoading
            ? SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: context.colorTokens.primaryForeground,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.save_outlined,
                    color: context.colorTokens.primaryForeground,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    label,
                    style: context.textStyles.bodyLarge.copyWith(
                      color: context.colorTokens.primaryForeground,
                    ),
                  ),
                ],
              ),
      ),
    );

    if (isLoading) {
      return content;
    }
    return BounceTap(onTap: onTap, pressedScale: 0.96, child: content);
  }
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
