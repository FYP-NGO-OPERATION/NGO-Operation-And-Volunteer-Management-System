import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage();
  
  static const _options = AndroidOptions(
    encryptedSharedPreferences: true,
  );

  static const _iosOptions = IOSOptions(
    accessibility: KeychainAccessibility.first_unlock,
  );

  static Future<void> writeString(String key, String value) async {
    await _storage.write(
      key: key,
      value: value,
      aOptions: _options,
      iOptions: _iosOptions,
    );
  }

  static Future<String?> readString(String key) async {
    return await _storage.read(
      key: key,
      aOptions: _options,
      iOptions: _iosOptions,
    );
  }

  static Future<void> delete(String key) async {
    await _storage.delete(
      key: key,
      aOptions: _options,
      iOptions: _iosOptions,
    );
  }

  static Future<void> writeBool(String key, bool value) async {
    await writeString(key, value.toString());
  }

  static Future<bool> readBool(String key, {bool defaultValue = false}) async {
    final str = await readString(key);
    if (str == null) return defaultValue;
    return str.toLowerCase() == 'true';
  }

  static Future<void> deleteAll() async {
    await _storage.deleteAll(
      aOptions: _options,
      iOptions: _iosOptions,
    );
  }
}
