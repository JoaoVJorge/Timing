enum LocalStorageKeys {
  appConfig(hasSensitiveData: false, isUserScoped: true),
  subjects(hasSensitiveData: false, isUserScoped: true),
  dailyTasks(hasSensitiveData: false, isUserScoped: true),
  lastActivity(hasSensitiveData: false, isUserScoped: true),
  dailyProgress(hasSensitiveData: false, isUserScoped: true),
  scheduleEntries(hasSensitiveData: false, isUserScoped: true),
  accessToken(hasSensitiveData: true, isUserScoped: false),
  refreshToken(hasSensitiveData: true, isUserScoped: false);

  const LocalStorageKeys({
    required this.hasSensitiveData,
    required this.isUserScoped,
  });

  final bool hasSensitiveData;
  final bool isUserScoped;
}
