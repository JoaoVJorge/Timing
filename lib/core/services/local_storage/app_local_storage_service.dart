import "dart:convert";

import "package:cryptography/cryptography.dart";
import "package:flutter_secure_storage/flutter_secure_storage.dart";
import "package:timing/core/services/local_storage/local_storage_keys.dart";
import "package:timing/core/services/supabase/supabase_service.dart";
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
  static const String _encryptedPrefix = "enc.v1:";
  static const String _encryptionKeyName = "timing.local-data-key.v1";
  final Cipher _cipher = AesGcm.with256bits();
  SecretKey? _cachedEncryptionKey;

  Future<void> write<T>(LocalStorageKeys key, T value) async {
    final String storageKey = _storageKey(key);
    if (key.hasSensitiveData) {
      await secureStorage.write(key: storageKey, value: value.toString());
      return;
    }

    if (key.encryptAtRest) {
      await _writeLocalValue(storageKey, await _encrypt(value.toString()));
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
    if (key.encryptAtRest && value is String) {
      if (value.startsWith(_encryptedPrefix)) {
        return await _decrypt(value) as T?;
      }

      // Transparently migrates caches created by older builds. The plaintext
      // is replaced only after it has been read successfully.
      await _writeLocalValue(storageKey, await _encrypt(value));
      return value as T?;
    }
    if (value != null ||
        !key.isUserScoped ||
        !supabaseService.hasSignedInUser) {
      return _castValue<T>(value);
    }

    final Object? legacyValue = localStorage.get(key.name);
    if (legacyValue == null) {
      return null;
    }

    await _writeLocalValue(
      storageKey,
      key.encryptAtRest ? await _encrypt(legacyValue.toString()) : legacyValue,
    );
    await localStorage.remove(key.name);
    return _castValue<T>(legacyValue);
  }

  // Some shared_preferences backends decode stored string lists as
  // List<Object?> instead of List<String>, which fails a direct cast
  // even though every element is actually a String.
  T? _castValue<T>(Object? value) {
    if (value is List && value is! List<String>) {
      return value.map((element) => element.toString()).toList() as T?;
    }
    return value as T?;
  }

  Future<void> delete(LocalStorageKeys key) async {
    final String storageKey = _storageKey(key);
    if (key.hasSensitiveData) {
      await secureStorage.delete(key: storageKey);
      return;
    }

    await localStorage.remove(storageKey);
  }

  Future<void> deleteCurrentUserData() async {
    await Future.wait(
      LocalStorageKeys.values
          .where((key) => key.isUserScoped)
          .map((key) => delete(key)),
    );
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

  Future<String> _encrypt(String clearText) async {
    final SecretBox box = await _cipher.encrypt(
      utf8.encode(clearText),
      secretKey: await _encryptionKey(),
    );
    final Map<String, String> envelope = {
      "nonce": base64Encode(box.nonce),
      "cipherText": base64Encode(box.cipherText),
      "mac": base64Encode(box.mac.bytes),
    };
    return "$_encryptedPrefix${base64Encode(utf8.encode(jsonEncode(envelope)))}";
  }

  Future<String> _decrypt(String encoded) async {
    final String payload = encoded.substring(_encryptedPrefix.length);
    final Map<String, dynamic> envelope =
        jsonDecode(utf8.decode(base64Decode(payload))) as Map<String, dynamic>;
    final SecretBox box = SecretBox(
      base64Decode(envelope["cipherText"] as String),
      nonce: base64Decode(envelope["nonce"] as String),
      mac: Mac(base64Decode(envelope["mac"] as String)),
    );
    final List<int> clearBytes = await _cipher.decrypt(
      box,
      secretKey: await _encryptionKey(),
    );
    return utf8.decode(clearBytes);
  }

  Future<SecretKey> _encryptionKey() async {
    final SecretKey? cached = _cachedEncryptionKey;
    if (cached != null) return cached;

    final String? stored = await secureStorage.read(key: _encryptionKeyName);
    if (stored != null) {
      return _cachedEncryptionKey = SecretKey(base64Decode(stored));
    }

    final SecretKey generated = await _cipher.newSecretKey();
    final List<int> bytes = await generated.extractBytes();
    await secureStorage.write(
      key: _encryptionKeyName,
      value: base64Encode(bytes),
    );
    return _cachedEncryptionKey = SecretKey(bytes);
  }
}
