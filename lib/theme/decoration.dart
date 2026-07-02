import "package:flutter/material.dart";
import "package:help_out/app/app_ui_constants.dart";
import "package:help_out/theme/colors.dart";
import "package:help_out/theme/text_styles.dart";

class AppInputDecoration {
  static InputDecoration withBorder({
    required AppColorTokens tokens,
    String? labelText,
    String? hintText,
    Widget? prefixIcon,
  }) => InputDecoration(
    labelText: labelText,
    hintText: hintText,
    hintStyle: AppTextStyles(tokens).hintText,
    isDense: true,
    prefixIcon: prefixIcon == null
        ? null
        : Opacity(
            opacity: 0.5,
            child: Container(margin: const EdgeInsets.only(left: 4), alignment: Alignment.center, child: prefixIcon),
          ),
    prefixIconConstraints: const BoxConstraints(maxWidth: 40, maxHeight: 40, minHeight: 20, minWidth: 20),
    border: OutlineInputBorder(
      borderRadius: const BorderRadius.all(Radius.circular(12)),
      borderSide: BorderSide(color: tokens.borderUnfocused, width: AppUiConstants.inputFieldBorderThickness),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: const BorderRadius.all(Radius.circular(12)),
      borderSide: BorderSide(color: tokens.borderUnfocused, width: AppUiConstants.inputFieldBorderThickness),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: const BorderRadius.all(Radius.circular(12)),
      borderSide: BorderSide(color: tokens.borderFocused, width: AppUiConstants.inputFieldBorderThickness),
    ),
  );

  static InputDecoration withoutBorder({required AppColorTokens tokens, String? labelText, String? hintText}) =>
      InputDecoration(
        labelText: labelText,
        hintText: hintText,
        hintStyle: AppTextStyles(tokens).hintText,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
      );

  static TextStyle inputTextStyle(AppColorTokens tokens) => AppTextStyles(tokens).inputText;
}
