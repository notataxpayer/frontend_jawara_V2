import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pbl_jawara_test/config/api_config.dart';

class AuthService {

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.authLogin),
        headers: ApiConfig.headers,
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': data,
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Login gagal',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  Future<Map<String, dynamic>> register(
      String name, String email, String password) async {
    try {
      // Pastikan semua field tidak kosong
      if (name.trim().isEmpty || email.trim().isEmpty || password.trim().isEmpty) {
        return {
          'success': false,
          'message': 'Semua field harus diisi',
        };
      }

      final requestBody = {
        'nama': name.trim(),
        'email': email.trim().toLowerCase(),
        'password': password.trim(),
      };

      print('===== REGISTER DEBUG =====');
      print('URL: ${ApiConfig.authRegister}');
      print('Headers: ${ApiConfig.headers}');
      print('Request Body: ${jsonEncode(requestBody)}');
      print('========================');

      final response = await http.post(
        Uri.parse(ApiConfig.authRegister),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      print('Response Status: ${response.statusCode}');
      print('Response Headers: ${response.headers}');
      print('Response Body: ${response.body}');
      print('========================');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data,
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? data['error'] ?? 'Registrasi gagal',
        };
      }
    } catch (e) {
      print('Register Exception: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  // Get current user profile
  Future<Map<String, dynamic>> getProfile(String token) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.authProfile),
        headers: ApiConfig.headersWithAuth(token),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': data,
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal mengambil profil',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }
}
