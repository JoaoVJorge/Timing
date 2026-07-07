import "dart:convert";

import "package:equatable/equatable.dart";

class AppConfigEntity extends Equatable {
  const AppConfigEntity({
    required this.isDarkMode,
    required this.userName,
    required this.nickName,
    required this.email,
    required this.phoneNumber,
    required this.birthDate,
    required this.accentColorValue,
    required this.avatarIconIndex,
    required this.notificationsEnabled,
    required this.languageCode,
  });

  factory AppConfigEntity.fallback() => const AppConfigEntity(
    isDarkMode: false,
    userName: "",
    nickName: "",
    email: null,
    phoneNumber: null,
    birthDate: null,
    accentColorValue: 0xFFFFC107,
    avatarIconIndex: 0,
    notificationsEnabled: true,
    languageCode: "en",
  );

  factory AppConfigEntity.fromJson(String source) => AppConfigEntity.fromMap(jsonDecode(source) as Map<String, dynamic>);

  factory AppConfigEntity.fromMap(Map<String, dynamic> map) => AppConfigEntity(
    isDarkMode: map["isDarkMode"] as bool,
    userName: map["userName"] as String,
    nickName: map["nickName"] as String? ?? "",
    email: map["email"] as String?,
    phoneNumber: map["phoneNumber"] as String?,
    birthDate: map["birthDate"] as String?,
    accentColorValue: map["accentColorValue"] as int,
    avatarIconIndex: map["avatarIconIndex"] as int? ?? 0,
    notificationsEnabled: map["notificationsEnabled"] as bool? ?? true,
    languageCode: map["languageCode"] as String? ?? "en",
  );

  final bool isDarkMode;
  final String userName;
  final String nickName;
  final String? email;
  final String? phoneNumber;

  /// ISO-8601 date (yyyy-MM-dd), null until the user completes the credentials step.
  final String? birthDate;
  final int accentColorValue;
  final int avatarIconIndex;
  final bool notificationsEnabled;
  final String languageCode;

  Map<String, dynamic> toMap() => {
    "isDarkMode": isDarkMode,
    "userName": userName,
    "nickName": nickName,
    "email": email,
    "phoneNumber": phoneNumber,
    "birthDate": birthDate,
    "accentColorValue": accentColorValue,
    "avatarIconIndex": avatarIconIndex,
    "notificationsEnabled": notificationsEnabled,
    "languageCode": languageCode,
  };

  String toJson() => jsonEncode(toMap());

  AppConfigEntity copyWith({
    bool? isDarkMode,
    String? userName,
    String? nickName,
    int? accentColorValue,
    int? avatarIconIndex,
    bool? notificationsEnabled,
    String? languageCode,
  }) => AppConfigEntity(
    isDarkMode: isDarkMode ?? this.isDarkMode,
    userName: userName ?? this.userName,
    nickName: nickName ?? this.nickName,
    email: email,
    phoneNumber: phoneNumber,
    birthDate: birthDate,
    accentColorValue: accentColorValue ?? this.accentColorValue,
    avatarIconIndex: avatarIconIndex ?? this.avatarIconIndex,
    notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    languageCode: languageCode ?? this.languageCode,
  );

  @override
  List<Object?> get props => [
    isDarkMode,
    userName,
    nickName,
    email,
    phoneNumber,
    birthDate,
    accentColorValue,
    avatarIconIndex,
    notificationsEnabled,
    languageCode,
  ];
}
