enum LocalStorageKeys {
  appConfig(hasSensitiveData: false),
  subjects(hasSensitiveData: false),
  scheduleEntries(hasSensitiveData: false),
  accessToken(hasSensitiveData: true),
  refreshToken(hasSensitiveData: true);

  const LocalStorageKeys({required this.hasSensitiveData});

  final bool hasSensitiveData;
}
