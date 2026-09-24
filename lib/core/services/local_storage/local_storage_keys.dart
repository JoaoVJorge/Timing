enum LocalStorageKeys {
  appConfig(hasSensitiveData: false, isUserScoped: true),
  subjects(hasSensitiveData: false, isUserScoped: true),
  dailyTasks(hasSensitiveData: false, isUserScoped: true),
  lastActivity(hasSensitiveData: false, isUserScoped: true),
  dailyProgress(hasSensitiveData: false, isUserScoped: true),
  activityHistory(hasSensitiveData: false, isUserScoped: true),
  announcedAchievementIds(hasSensitiveData: false, isUserScoped: true),
  subjectDailyHistory(hasSensitiveData: false, isUserScoped: true),
  scheduleEntries(hasSensitiveData: false, isUserScoped: true),
  pendingRemoteSyncs(hasSensitiveData: false, isUserScoped: true),
  activeTimerSession(hasSensitiveData: false, isUserScoped: true),
  activityHistoryReconciledAt(hasSensitiveData: false, isUserScoped: true),
  pendingActivityEntries(hasSensitiveData: false, isUserScoped: true),
  pendingSubjectDeletions(hasSensitiveData: false, isUserScoped: true),
  syncedSubjectIds(hasSensitiveData: false, isUserScoped: true),
  lastVerifiedOnlineAt(hasSensitiveData: false, isUserScoped: true),
  cachedGroups(hasSensitiveData: false, isUserScoped: true),
  cachedFriendsSocial(hasSensitiveData: false, isUserScoped: true),
  pendingGroupActions(hasSensitiveData: false, isUserScoped: true),
  pendingFriendActions(hasSensitiveData: false, isUserScoped: true),
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
  });

  final bool hasSensitiveData;
  final bool isUserScoped;
}
