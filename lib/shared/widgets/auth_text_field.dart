import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:help_out/shared/widgets/app_icon.dart";

/// White-on-gradient text field used throughout the phone sign-in flow.
///
/// When [readOnly] is set with an [onTap] it behaves like a tappable field
/// (e.g. opening a date picker) instead of a keyboard input.
class AuthTextField extends StatelessWidget {
  const AuthTextField({
    required this.hintText,
    this.controller,
    this.icon,
    this.materialIcon,
    this.onChanged,
    this.keyboardType,
    this.inputFormatters,
    this.readOnly = false,
    this.onTap,
    this.valueText,
    super.key,
  }) : assert(
         icon != null || materialIcon != null,
         "Provide either icon or materialIcon",
       );

  final String hintText;
  final TextEditingController? controller;
  final String? icon;
  final IconData? materialIcon;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool readOnly;
  final VoidCallback? onTap;

  /// Shown instead of the live controller text for read-only fields (e.g. a
  /// formatted date). When null and [readOnly] is true, the hint is shown.
  final String? valueText;

  @override
  Widget build(BuildContext context) {
    // When a formatted value is overlaid on top of a read-only field we must
    // hide the underlying hint, otherwise it keeps showing through behind the
    // value (e.g. the picked date sitting on top of the "birth date" hint).
    final bool hasValueOverlay = readOnly && onTap != null && valueText != null;

    final Widget field = TextField(
      controller: controller,
      onChanged: onChanged,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      readOnly: readOnly,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      decoration: InputDecoration(
        hintText: hasValueOverlay ? null : hintText,
        hintStyle: const TextStyle(color: Colors.white60),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.08),
        prefixIcon: Padding(
          padding: const EdgeInsets.all(12),
          child: icon != null
              ? AppIcon(icon!, size: 18, color: Colors.white70)
              : Icon(materialIcon, size: 20, color: Colors.white70),
        ),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 44,
          minHeight: 44,
        ),
        border: _border(0.55),
        enabledBorder: _border(0.55),
        focusedBorder: _border(1, width: 2),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );

    if (!readOnly || onTap == null) {
      return field;
    }

    // For read-only tappable fields we overlay any formatted [valueText] so the
    // field can display a value without owning a text controller.
    return GestureDetector(
      onTap: onTap,
      child: AbsorbPointer(
        child: valueText == null
            ? field
            : Stack(
                children: [
                  field,
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 58, right: 16),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          valueText!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  OutlineInputBorder _border(double alpha, {double width = 1.4}) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: Colors.white.withValues(alpha: alpha),
          width: width,
        ),
      );
}
