import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  static SharedPreferences? _prefs;

  static const String _keyToken = 'jwt_access_token';
  static const String _keyUserRole = 'user_role';
  static const String _keyUserEmail = 'user_email';
  static const String _keyUserFullName = 'user_full_name';
  static const String _keyUserUid = 'user_uid';
  static const String _keyIsLoggedIn = 'is_logged_in';

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  static Future<void> saveAuthSession({
    required String token,
    required Map<String, dynamic> userData,
  }) async {
    await init();

    await _secureStorage.write(key: _keyToken, value: token);

    final role = userData['role']?.toString().toLowerCase().trim() ?? '';
    final email = userData['email']?.toString().trim() ?? '';
    final fullName =
        userData['fullName']?.toString().trim() ??
        userData['full_name']?.toString().trim() ??
        '';
    final uid = userData['uid']?.toString() ?? userData['id']?.toString() ?? '';

    await _prefs?.setString(_keyUserRole, role);
    await _prefs?.setString(_keyUserEmail, email);
    await _prefs?.setString(_keyUserFullName, fullName);
    await _prefs?.setString(_keyUserUid, uid);
    await _prefs?.setBool(_keyIsLoggedIn, true);
  }

  static Future<String?> getToken() async {
    try {
      return await _secureStorage.read(key: _keyToken);
    } catch (_) {
      return null;
    }
  }

  static String? getUserRole() {
    return _prefs?.getString(_keyUserRole);
  }

  static Map<String, String> getUserProfile() {
    return {
      'role': _prefs?.getString(_keyUserRole) ?? '',
      'email': _prefs?.getString(_keyUserEmail) ?? '',
      'fullName': _prefs?.getString(_keyUserFullName) ?? '',
      'uid': _prefs?.getString(_keyUserUid) ?? '',
    };
  }

  static Future<bool> hasValidSession() async {
    final token = await getToken();
    final role = getUserRole();
    return token != null &&
        token.isNotEmpty &&
        role != null &&
        role.isNotEmpty &&
        role != 'unknown';
  }

  static Future<void> clearSession() async {
    await init();
    try {
      await _secureStorage.delete(key: _keyToken);
    } catch (_) {}

    await _prefs?.remove(_keyUserRole);
    await _prefs?.remove(_keyUserEmail);
    await _prefs?.remove(_keyUserFullName);
    await _prefs?.remove(_keyUserUid);
    await _prefs?.setBool(_keyIsLoggedIn, false);
  }
}
