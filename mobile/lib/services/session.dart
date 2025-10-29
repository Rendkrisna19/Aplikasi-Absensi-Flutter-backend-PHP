import 'package:shared_preferences/shared_preferences.dart';

class Session {
  static const _kToken = 'token';
  static const _kRole  = 'role';

  static Future<void> saveToken(String token, String role) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_kToken, token);
    await p.setString(_kRole, role);
  }

  static Future<String?> token() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_kToken);
  }

  static Future<void> clear() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_kToken);
    await p.remove(_kRole);
  }
}
