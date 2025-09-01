import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const _storage = FlutterSecureStorage();

  static const _keyToken = 'accessToken';
  static const _keyRefreshToken = 'refreshToken';

  static Future<void> setToken({
    required String token,
    required String refreshToken,
  }) async {
    await _storage.write(key: _keyToken, value: token);
    await _storage.write(key: _keyRefreshToken, value: refreshToken);
  }

  static Future<Map<String, String>> getToken() async {
    String? token = await _storage.read(key: _keyToken);
    String? refreshToken = await _storage.read(key: _keyRefreshToken);

    return {
      'token': token ?? '',
      'refreshToken': refreshToken ?? '',
    };
  }

  static Future<void> clear() async {
    await _storage.deleteAll();
  }
}
