import "dart:convert";

import "package:equatable/equatable.dart";
import "package:help_out/theme/accent_presets.dart";

class AppConfigEntity extends Equatable {
  const AppConfigEntity({
    required this.isDarkMode,
    required this.userName,
    required this.nickName,
    required this.email,
    required this.phoneNumber,
    required this.birthDate,
    required this.profilePhotoBase64,
    required this.accentColorValue,
    required this.avatarIconIndex,
    required this.notificationsEnabled,
    required this.languageCode,
    required this.friendCode,
    required this.focusLockStudyingEnabled,
    required this.focusLockExercisesEnabled,
    required this.focusLockReadingEnabled,
    required this.focusLockHobbiesEnabled,
  });

  factory AppConfigEntity.fallback() => const AppConfigEntity(
    isDarkMode: false,
    userName: "",
    nickName: "",
    email: null,
    phoneNumber: null,
    birthDate: null,
    profilePhotoBase64: null,
    accentColorValue: AppAccentPresets.defaultAccentValue,
    avatarIconIndex: 0,
    notificationsEnabled: true,
    languageCode: null,
    friendCode: "",
    focusLockStudyingEnabled: false,
    focusLockExercisesEnabled: false,
    focusLockReadingEnabled: false,
    focusLockHobbiesEnabled: false,
  );

  factory AppConfigEntity.fromJson(String source) =>
      AppConfigEntity.fromMap(jsonDecode(source) as Map<String, dynamic>);

  factory AppConfigEntity.fromMap(Map<String, dynamic> map) => AppConfigEntity(
    isDarkMode: map["isDarkMode"] as bool,
    userName: map["userName"] as String,
    nickName: map["nickName"] as String? ?? "",
    email: map["email"] as String?,
    phoneNumber: map["phoneNumber"] as String?,
    birthDate: map["birthDate"] as String?,
    profilePhotoBase64: map["profilePhotoBase64"] as String?,
    accentColorValue: map["accentColorValue"] as int,
    avatarIconIndex: map["avatarIconIndex"] as int? ?? 0,
    notificationsEnabled: map["notificationsEnabled"] as bool? ?? true,
    languageCode: map["languageCode"] as String?,
    friendCode: map["friendCode"] as String? ?? "",
    focusLockStudyingEnabled: map["focusLockStudyingEnabled"] as bool? ?? false,
    focusLockExercisesEnabled:
        map["focusLockExercisesEnabled"] as bool? ?? false,
    focusLockReadingEnabled: map["focusLockReadingEnabled"] as bool? ?? false,
    focusLockHobbiesEnabled: map["focusLockHobbiesEnabled"] as bool? ?? false,
  );

  final bool isDarkMode;
  final String userName;
  final String nickName;
  final String? email;
  final String? phoneNumber;

  /// ISO-8601 date (yyyy-MM-dd), null until the user completes the credentials step.
  final String? birthDate;
  final String? profilePhotoBase64;
  final int accentColorValue;
  final int avatarIconIndex;
  final bool notificationsEnabled;
  final String? languageCode;
  final String friendCode;
  final bool focusLockStudyingEnabled;
  final bool focusLockExercisesEnabled;
  final bool focusLockReadingEnabled;
  final bool focusLockHobbiesEnabled;

  Map<String, dynamic> toMap() => {
    "isDarkMode": isDarkMode,
    "userName": userName,
    "nickName": nickName,
    "email": email,
    "phoneNumber": phoneNumber,
    "birthDate": birthDate,
    "profilePhotoBase64": profilePhotoBase64,
    "accentColorValue": accentColorValue,
    "avatarIconIndex": avatarIconIndex,
    "notificationsEnabled": notificationsEnabled,
    "languageCode": languageCode,
    "friendCode": friendCode,
    "focusLockStudyingEnabled": focusLockStudyingEnabled,
    "focusLockExercisesEnabled": focusLockExercisesEnabled,
    "focusLockReadingEnabled": focusLockReadingEnabled,
    "focusLockHobbiesEnabled": focusLockHobbiesEnabled,
  };

  String toJson() => jsonEncode(toMap());

  AppConfigEntity copyWith({
    bool? isDarkMode,
    String? userName,
    String? nickName,
    Object? email = _unset,
    Object? phoneNumber = _unset,
    Object? birthDate = _unset,
    Object? profilePhotoBase64 = _unset,
    int? accentColorValue,
    int? avatarIconIndex,
    bool? notificationsEnabled,
    Object? languageCode = _unset,
    String? friendCode,
    bool? focusLockStudyingEnabled,
    bool? focusLockExercisesEnabled,
    bool? focusLockReadingEnabled,
    bool? focusLockHobbiesEnabled,
  }) => AppConfigEntity(
    isDarkMode: isDarkMode ?? this.isDarkMode,
    userName: userName ?? this.userName,
    nickName: nickName ?? this.nickName,
    email: email == _unset ? this.email : email as String?,
    phoneNumber: phoneNumber == _unset
        ? this.phoneNumber
        : phoneNumber as String?,
    birthDate: birthDate == _unset ? this.birthDate : birthDate as String?,
    profilePhotoBase64: profilePhotoBase64 == _unset
        ? this.profilePhotoBase64
        : profilePhotoBase64 as String?,
    accentColorValue: accentColorValue ?? this.accentColorValue,
    avatarIconIndex: avatarIconIndex ?? this.avatarIconIndex,
    notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    languageCode: languageCode == _unset
        ? this.languageCode
        : languageCode as String?,
    friendCode: friendCode ?? this.friendCode,
    focusLockStudyingEnabled:
        focusLockStudyingEnabled ?? this.focusLockStudyingEnabled,
    focusLockExercisesEnabled:
        focusLockExercisesEnabled ?? this.focusLockExercisesEnabled,
    focusLockReadingEnabled:
        focusLockReadingEnabled ?? this.focusLockReadingEnabled,
    focusLockHobbiesEnabled:
        focusLockHobbiesEnabled ?? this.focusLockHobbiesEnabled,
  );

  @override
  List<Object?> get props => [
    isDarkMode,
    userName,
    nickName,
    email,
    phoneNumber,
    birthDate,
    profilePhotoBase64,
    accentColorValue,
    avatarIconIndex,
    notificationsEnabled,
    languageCode,
    friendCode,
    focusLockStudyingEnabled,
    focusLockExercisesEnabled,
    focusLockReadingEnabled,
    focusLockHobbiesEnabled,
  ];
}

const Object _unset = Object();
