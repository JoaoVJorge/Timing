import "package:flutter/material.dart";
import "package:get/get.dart";
import "package:help_out/app/app_controller.dart";

class EditProfileController extends GetxController {
  EditProfileController({required this._appController});

  final AppController _appController;

  late final TextEditingController nameController = TextEditingController(text: _appController.userName.value);
  late final TextEditingController nickNameController = TextEditingController(text: _appController.nickName.value);

  Rx<Color> get accentColor => _appController.accentColor;
  RxInt get avatarIconIndex => _appController.avatarIconIndex;

  void onNameChanged(String value) => _appController.setUserName(value.trim());

  void onNickNameChanged(String value) => _appController.setNickName(value.trim());

  void onSelectAccentColor(Color color) => _appController.setAccentColor(color);

  void onSelectAvatarIcon(int index) => _appController.setAvatarIconIndex(index);

  @override
  void onClose() {
    nameController.dispose();
    nickNameController.dispose();
    super.onClose();
  }
}
