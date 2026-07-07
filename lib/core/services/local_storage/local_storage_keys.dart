enum LocalStorageKeys {
  appConfig(hasSensitiveData: false),
  subjects(hasSensitiveData: false),
  dailyTasks(hasSensitiveData: false),
  lastActivity(hasSensitiveData: false),
  scheduleEntries(hasSensitiveData: false),
  accessToken(hasSensitiveData: true),
  refreshToken(hasSensitiveData: true);

  const LocalStorageKeys({required this.hasSensitiveData});

  final bool hasSensitiveData;
}
