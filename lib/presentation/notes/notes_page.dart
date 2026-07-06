import "package:flutter/material.dart";
import "package:get/get.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/presentation/notes/notes_controller.dart";
import "package:help_out/shared/widgets/app_scaffold.dart";
import "package:help_out/shared/widgets/app_top_bar.dart";
import "package:help_out/shared/widgets/floating_primary_button.dart";

class NotesPage extends StatelessWidget {
  const NotesPage({super.key});

  static const double _lineSpacing = 28;
  static const double _marginX = 32;

  @override
  Widget build(BuildContext context) {
    final NotesController controller = Get.find();
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color marginColor = Colors.redAccent.withValues(
      alpha: isDarkMode ? 0.45 : 0.55,
    );

    return AppScaffold(
      backgroundColor: context.colorTokens.scaffold,
      topBar: AppTopBar(
        title: "${context.l10n.notesLabel} - ${controller.subject.name}",
        showBackButton: true,
        onBack: controller.onTapSave,
      ),
      bottomBar: FloatingPrimaryButton(
        label: context.l10n.saveNotesButton,
        onTap: controller.onTapSave,
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
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: context.colorTokens.surfaceShadow,
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Stack(
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
                        top: 20,
                        bottom: 16,
                      ),
                      child: TextField(
                        controller: controller.notesController,
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
          ],
        ),
      ),
    );
  }
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
