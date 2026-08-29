/// Keeps the expensive main-tab data in memory and records only the changes
/// that make a cached tab stale.
class MainTabRefreshService {
  bool _homeNeedsRefresh = false;
  bool _progressNeedsRefresh = false;

  void markGroupsChanged() => _homeNeedsRefresh = true;

  void markHomeDataChanged() => _progressNeedsRefresh = true;

  bool consumeHomeRefresh() {
    final bool needsRefresh = _homeNeedsRefresh;
    _homeNeedsRefresh = false;
    return needsRefresh;
  }

  bool consumeProgressRefresh() {
    final bool needsRefresh = _progressNeedsRefresh;
    _progressNeedsRefresh = false;
    return needsRefresh;
  }
}
