import "package:flutter/material.dart";
import "package:get/get.dart";
import "package:help_out/app/app_controller.dart";

class ConfigController extends GetxController {
  ConfigController({required this._appController});

  final AppController _appController;

  RxBool get isDarkMode => _appController.isDarkMode;
  Rx<Color> get accentColor => _appController.accentColor;

  void onToggleDarkMode(bool value) => _appController.setDarkMode(value);
  void onTapAccentColor(Color color) => _appController.setAccentColor(color);
}
