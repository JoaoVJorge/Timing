import "dart:convert";

import "package:equatable/equatable.dart";

class AppConfigEntity extends Equatable {
  const AppConfigEntity({
    required this.isDarkMode,
    required this.userName,
    required this.nickName,
    required this.accentColorValue,
    required this.avatarIconIndex,
  });

  factory AppConfigEntity.fallback() => const AppConfigEntity(
    isDarkMode: false,
    userName: "",
    nickName: "",
    accentColorValue: 0xFFFFC107,
    avatarIconIndex: 0,
  );

  factory AppConfigEntity.fromJson(String source) => AppConfigEntity.fromMap(jsonDecode(source) as Map<String, dynamic>);

  factory AppConfigEntity.fromMap(Map<String, dynamic> map) => AppConfigEntity(
    isDarkMode: map["isDarkMode"] as bool,
    userName: map["userName"] as String,
    nickName: map["nickName"] as String? ?? "",
    accentColorValue: map["accentColorValue"] as int,
    avatarIconIndex: map["avatarIconIndex"] as int? ?? 0,
  );

  final bool isDarkMode;
  final String userName;
  final String nickName;
  final int accentColorValue;
  final int avatarIconIndex;

  Map<String, dynamic> toMap() => {
    "isDarkMode": isDarkMode,
    "userName": userName,
    "nickName": nickName,
    "accentColorValue": accentColorValue,
    "avatarIconIndex": avatarIconIndex,
  };

  String toJson() => jsonEncode(toMap());

  AppConfigEntity copyWith({
    bool? isDarkMode,
    String? userName,
    String? nickName,
    int? accentColorValue,
    int? avatarIconIndex,
  }) => AppConfigEntity(
    isDarkMode: isDarkMode ?? this.isDarkMode,
    userName: userName ?? this.userName,
    nickName: nickName ?? this.nickName,
    accentColorValue: accentColorValue ?? this.accentColorValue,
    avatarIconIndex: avatarIconIndex ?? this.avatarIconIndex,
  );

  @override
  List<Object?> get props => [isDarkMode, userName, nickName, accentColorValue, avatarIconIndex];
}
