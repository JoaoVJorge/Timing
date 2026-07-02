import "dart:convert";

import "package:equatable/equatable.dart";

class AppConfigEntity extends Equatable {
  const AppConfigEntity({required this.isDarkMode, required this.userName, required this.accentColorValue});

  factory AppConfigEntity.fallback() =>
      const AppConfigEntity(isDarkMode: false, userName: "", accentColorValue: 0xFFFF7A30);

  factory AppConfigEntity.fromJson(String source) => AppConfigEntity.fromMap(jsonDecode(source) as Map<String, dynamic>);

  factory AppConfigEntity.fromMap(Map<String, dynamic> map) => AppConfigEntity(
    isDarkMode: map["isDarkMode"] as bool,
    userName: map["userName"] as String,
    accentColorValue: map["accentColorValue"] as int,
  );

  final bool isDarkMode;
  final String userName;
  final int accentColorValue;

  Map<String, dynamic> toMap() => {"isDarkMode": isDarkMode, "userName": userName, "accentColorValue": accentColorValue};

  String toJson() => jsonEncode(toMap());

  AppConfigEntity copyWith({bool? isDarkMode, String? userName, int? accentColorValue}) => AppConfigEntity(
    isDarkMode: isDarkMode ?? this.isDarkMode,
    userName: userName ?? this.userName,
    accentColorValue: accentColorValue ?? this.accentColorValue,
  );

  @override
  List<Object?> get props => [isDarkMode, userName, accentColorValue];
}
