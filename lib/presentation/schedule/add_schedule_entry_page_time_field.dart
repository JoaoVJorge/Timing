part of "add_schedule_entry_page.dart";

class _TimeInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final String rawDigits = newValue.text.replaceAll(RegExp(r"\D"), "");
    final String digits = rawDigits.length > 4
        ? rawDigits.substring(0, 4)
        : rawDigits;
    final String normalizedDigits = normalizeTimeDigits(digits);
    final String formatted = normalizedDigits.length <= 2
        ? normalizedDigits
        : "${normalizedDigits.substring(0, 2)}:${normalizedDigits.substring(2)}";

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class _TimeTextField extends StatelessWidget {
  const _TimeTextField({
    required this.label,
    required this.controller,
    required this.focusNode,
    required this.onPickTime,
    this.onCompleted,
    this.leadingIcon = false,
  });

  final bool leadingIcon;
  final String label;
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onPickTime;
  final VoidCallback? onCompleted;

  @override
  Widget build(BuildContext context) {
    final Widget clock = IconButton(
      onPressed: onPickTime,
      tooltip: label,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 36, minHeight: 48),
      icon: Icon(
        Icons.schedule_rounded,
        size: 22,
        color: context.colorTokens.textHint,
      ),
    );
    return Row(
      children: [
        if (leadingIcon) clock,
        Expanded(
          child: Semantics(
            label: label,
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              textAlign: TextAlign.center,
              style: context.textStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w500,
              ),
              keyboardType: TextInputType.number,
              textInputAction: onCompleted == null
                  ? TextInputAction.done
                  : TextInputAction.next,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                _TimeInputFormatter(),
              ],
              onChanged: (value) {
                if (value.length == 5) onCompleted?.call();
              },
              onSubmitted: (_) => onCompleted?.call(),
              decoration: InputDecoration(
                hintText: "00:00",
                hintStyle: context.textStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ),
        if (!leadingIcon) clock,
      ],
    );
  }
}
