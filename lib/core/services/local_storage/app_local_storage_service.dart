import "package:flutter_secure_storage/flutter_secure_storage.dart";
import "package:help_out/core/services/local_storage/local_storage_keys.dart";
import "package:help_out/core/services/supabase/supabase_service.dart";
import "package:shared_preferences/shared_preferences.dart";

class AppLocalStorageService {
  AppLocalStorageService({
    required this.localStorage,
    required this.secureStorage,
    required this.supabaseService,
  });

  final SharedPreferences localStorage;
  final FlutterSecureStorage secureStorage;
  final SupabaseService supabaseService;

  Future<void> clearStorage() async {
    await Future.wait([localStorage.clear(), secureStorage.deleteAll()]);
  }

  Future<void> write<T>(LocalStorageKeys key, T value) async {
    final String storageKey = _storageKey(key);
    if (key.hasSensitiveData) {
      await secureStorage.write(key: storageKey, value: value.toString());
      return;
    }

    switch (value) {
      case final String data:
        await _writeLocalValue(storageKey, data);
      case final int data:
        await _writeLocalValue(storageKey, data);
      case final double data:
        await _writeLocalValue(storageKey, data);
      case final bool data:
        await _writeLocalValue(storageKey, data);
      case final List<String> data:
        await _writeLocalValue(storageKey, data);
      default:
        await _writeLocalValue(storageKey, value.toString());
    }
  }

  Future<T?> read<T>(LocalStorageKeys key) async {
    final String storageKey = _storageKey(key);
    if (key.hasSensitiveData) {
      return await secureStorage.read(key: storageKey) as T?;
    }

    final Object? value = localStorage.get(storageKey);
    if (value != null ||
        !key.isUserScoped ||
        !supabaseService.hasSignedInUser) {
      return value as T?;
    }

    final Object? legacyValue = localStorage.get(key.name);
    if (legacyValue == null) {
      return null;
    }

    await _writeLocalValue(storageKey, legacyValue);
    await localStorage.remove(key.name);
    return legacyValue as T?;
  }

  Future<void> delete(LocalStorageKeys key) async {
    final String storageKey = _storageKey(key);
    if (key.hasSensitiveData) {
      await secureStorage.delete(key: storageKey);
      return;
    }

    await localStorage.remove(storageKey);
  }

  String _storageKey(LocalStorageKeys key) {
    if (!key.isUserScoped) {
      return key.name;
    }

    final String ownerId = supabaseService.currentUserId ?? "guest";
    return "user.$ownerId.${key.name}";
  }

  Future<void> _writeLocalValue(String storageKey, Object value) async {
    switch (value) {
      case final String data:
        await localStorage.setString(storageKey, data);
      case final int data:
        await localStorage.setInt(storageKey, data);
      case final double data:
        await localStorage.setDouble(storageKey, data);
      case final bool data:
        await localStorage.setBool(storageKey, data);
      case final List<String> data:
        await localStorage.setStringList(storageKey, data);
      default:
        await localStorage.setString(storageKey, value.toString());
    }
  }
}
