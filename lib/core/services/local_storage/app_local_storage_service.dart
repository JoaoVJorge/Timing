import "package:flutter_secure_storage/flutter_secure_storage.dart";
import "package:help_out/core/services/local_storage/local_storage_keys.dart";
import "package:shared_preferences/shared_preferences.dart";

class AppLocalStorageService {
  AppLocalStorageService({required this._localStorage, required this._secureStorage});

  final SharedPreferences _localStorage;
  final FlutterSecureStorage _secureStorage;

  Future<void> clearStorage() async {
    await Future.wait([_localStorage.clear(), _secureStorage.deleteAll()]);
  }

  Future<void> write<T>(LocalStorageKeys key, T value) async {
    if (key.hasSensitiveData) {
      await _secureStorage.write(key: key.name, value: value.toString());
      return;
    }

    switch (value) {
      case final String data:
        await _localStorage.setString(key.name, data);
      case final int data:
        await _localStorage.setInt(key.name, data);
      case final double data:
        await _localStorage.setDouble(key.name, data);
      case final bool data:
        await _localStorage.setBool(key.name, data);
      case final List<String> data:
        await _localStorage.setStringList(key.name, data);
      default:
        await _localStorage.setString(key.name, value.toString());
    }
  }

  Future<T?> read<T>(LocalStorageKeys key) async {
    if (key.hasSensitiveData) {
      return await _secureStorage.read(key: key.name) as T?;
    }

    return _localStorage.get(key.name) as T?;
  }

  Future<void> delete(LocalStorageKeys key) async {
    if (key.hasSensitiveData) {
      await _secureStorage.delete(key: key.name);
      return;
    }

    await _localStorage.remove(key.name);
  }
}
