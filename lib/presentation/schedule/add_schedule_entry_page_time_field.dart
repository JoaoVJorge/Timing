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
  });

  final String label;
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onPickTime;
  final VoidCallback? onCompleted;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _FieldLabel(text: label),
      const Gap(8),
      TextField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          _TimeInputFormatter(),
        ],
        onChanged: (value) {
          if (value.length == 5) {
            onCompleted?.call();
          }
        },
        decoration:
            AppInputDecoration.withBorder(
              tokens: context.colorTokens,
              hintText: "00:00",
            ).copyWith(
              suffixIcon: IconButton(
                onPressed: onPickTime,
                tooltip: label,
                icon: Icon(
                  Icons.schedule_rounded,
                  size: 20,
                  color: context.colorTokens.primary,
                ),
              ),
              suffixIconConstraints: const BoxConstraints(
                minWidth: 40,
                minHeight: 40,
              ),
            ),
      ),
    ],
  );
}
