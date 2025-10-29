import 'dart:async'; // <— penting untuk TimeoutException
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'session.dart';


class Api {
  // Emulator Android → akses localhost PC
  static const base = 'http://10.0.2.2/AplikasiAbsen/api/public';

  static Future<Map<String, dynamic>> post(String path, Map data, {bool auth = false}) async {
    final uri = Uri.parse('$base$path');
    final headers = <String, String>{'Content-Type': 'application/json'};

    if (auth) {
      final t = await Session.token();
      if (t != null && t.isNotEmpty) headers['Authorization'] = 'Bearer $t';
    }

    try {
      final res = await http
          .post(uri, headers: headers, body: jsonEncode(data))
          .timeout(const Duration(seconds: 20));
      return _handleResponse(uri, res);
    } on SocketException {
      return {'error': 'Tidak dapat terhubung ke server', 'status': 0, 'url': uri.toString()};
    } on HttpException {
      return {'error': 'Terjadi kesalahan HTTP', 'status': 0, 'url': uri.toString()};
    } on FormatException {
      return {'error': 'Format respons server tidak valid', 'status': 0, 'url': uri.toString()};
    } on TimeoutException {
      return {'error': 'Koneksi ke server timeout', 'status': 0, 'url': uri.toString()};
    }
  }

  static Future<Map<String, dynamic>> get(String path, {bool auth = false}) async {
    final uri = Uri.parse('$base$path');
    final headers = <String, String>{'Content-Type': 'application/json'};

    if (auth) {
      final t = await Session.token();
      if (t != null && t.isNotEmpty) headers['Authorization'] = 'Bearer $t';
    }

    try {
      final res = await http.get(uri, headers: headers).timeout(const Duration(seconds: 20));
      return _handleResponse(uri, res);
    } on SocketException {
      return {'error': 'Tidak dapat terhubung ke server', 'status': 0, 'url': uri.toString()};
    } on HttpException {
      return {'error': 'Terjadi kesalahan HTTP', 'status': 0, 'url': uri.toString()};
    } on FormatException {
      return {'error': 'Format respons server tidak valid', 'status': 0, 'url': uri.toString()};
    } on TimeoutException {
      return {'error': 'Koneksi ke server timeout', 'status': 0, 'url': uri.toString()};
    }
  }

  static Map<String, dynamic> _handleResponse(Uri uri, http.Response res) {
    final ct = (res.headers['content-type'] ?? '').toLowerCase();

    if (!ct.contains('application/json')) {
      return {
        'error': 'Non-JSON response from server',
        'status': res.statusCode,
        'body': res.body.length > 300 ? res.body.substring(0, 300) : res.body,
        'url': uri.toString(),
      };
    }

    try {
      final parsed = jsonDecode(res.body) as Map<String, dynamic>;
      parsed['status'] = res.statusCode;

      if (res.statusCode == 401) {
        parsed['error'] ??= 'Unauthorized — token tidak valid / sesi habis';
      } else if (res.statusCode == 404) {
        parsed['error'] ??= 'Endpoint tidak ditemukan (404)';
      } else if (res.statusCode >= 500) {
        parsed['error'] ??= 'Kesalahan server (>=500)';
      }

      return parsed;
    } catch (_) {
      return {
        'error': 'Invalid JSON from server',
        'status': res.statusCode,
        'body': res.body.length > 300 ? res.body.substring(0, 300) : res.body,
        'url': uri.toString(),
      };
    }
  }
}
