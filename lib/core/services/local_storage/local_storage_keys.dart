enum LocalStorageKeys {
  appConfig(hasSensitiveData: false, isUserScoped: true, encryptAtRest: true),
  subjects(hasSensitiveData: false, isUserScoped: true, encryptAtRest: true),
  dailyTasks(hasSensitiveData: false, isUserScoped: true, encryptAtRest: true),
  lastActivity(
    hasSensitiveData: false,
    isUserScoped: true,
    encryptAtRest: true,
  ),
  dailyProgress(
    hasSensitiveData: false,
    isUserScoped: true,
    encryptAtRest: true,
  ),
  activityHistory(
    hasSensitiveData: false,
    isUserScoped: true,
    encryptAtRest: true,
  ),
  announcedAchievementIds(
    hasSensitiveData: false,
    isUserScoped: true,
    encryptAtRest: true,
  ),
  subjectDailyHistory(
    hasSensitiveData: false,
    isUserScoped: true,
    encryptAtRest: true,
  ),
  scheduleEntries(
    hasSensitiveData: false,
    isUserScoped: true,
    encryptAtRest: true,
  ),
  pendingRemoteSyncs(
    hasSensitiveData: false,
    isUserScoped: true,
    encryptAtRest: true,
  ),
  activeTimerSession(
    hasSensitiveData: false,
    isUserScoped: true,
    encryptAtRest: true,
  ),
  activityHistoryReconciledAt(
    hasSensitiveData: false,
    isUserScoped: true,
    encryptAtRest: true,
  ),
  pendingActivityEntries(
    hasSensitiveData: false,
    isUserScoped: true,
    encryptAtRest: true,
  ),
  pendingActivityClears(
    hasSensitiveData: false,
    isUserScoped: true,
    encryptAtRest: true,
  ),
  pendingSubjectDeletions(
    hasSensitiveData: false,
    isUserScoped: true,
    encryptAtRest: true,
  ),
  syncedSubjectIds(
    hasSensitiveData: false,
    isUserScoped: true,
    encryptAtRest: true,
  ),
  lastVerifiedOnlineAt(
    hasSensitiveData: false,
    isUserScoped: true,
    encryptAtRest: true,
  ),
  cachedGroups(
    hasSensitiveData: false,
    isUserScoped: true,
    encryptAtRest: true,
  ),
  cachedFriendsSocial(
    hasSensitiveData: false,
    isUserScoped: true,
    encryptAtRest: true,
  ),
  pendingGroupActions(
    hasSensitiveData: false,
    isUserScoped: true,
    encryptAtRest: true,
  ),
  pendingFriendActions(
    hasSensitiveData: false,
    isUserScoped: true,
    encryptAtRest: true,
  ),
  isDarkMode(hasSensitiveData: false, isUserScoped: false),
  languageCode(hasSensitiveData: false, isUserScoped: false),
  focusLockStudyingEnabled(hasSensitiveData: false, isUserScoped: false),
  focusLockExercisesEnabled(hasSensitiveData: false, isUserScoped: false),
  focusLockReadingEnabled(hasSensitiveData: false, isUserScoped: false),
  focusLockHobbiesEnabled(hasSensitiveData: false, isUserScoped: false),
  cachedAccentColorValue(hasSensitiveData: false, isUserScoped: false),
  accessToken(hasSensitiveData: true, isUserScoped: false),
  refreshToken(hasSensitiveData: true, isUserScoped: false);

  const LocalStorageKeys({
    required this.hasSensitiveData,
    required this.isUserScoped,
    this.encryptAtRest = false,
  });

  final bool hasSensitiveData;
  final bool isUserScoped;
  final bool encryptAtRest;
}
