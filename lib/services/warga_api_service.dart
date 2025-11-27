import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pbl_jawara_test/config/api_config.dart';

class WargaApiService {
  final String? token;

  WargaApiService({this.token});

  Map<String, String> get _headers =>
      token != null ? ApiConfig.headersWithAuth(token!) : ApiConfig.headers;

  // Get all warga
  Future<Map<String, dynamic>> getAllWarga() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.warga),
        headers: _headers,
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
          'message': data['message'] ?? 'Gagal mengambil data warga',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  // Get warga by NIK
  Future<Map<String, dynamic>> getWargaByNik(String nik) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.warga}/$nik'),
        headers: _headers,
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
          'message': data['message'] ?? 'Gagal mengambil data warga',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  // Self register warga
  Future<Map<String, dynamic>> selfRegisterWarga(
      Map<String, dynamic> wargaData) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.wargaSelfRegister),
        headers: _headers,
        body: jsonEncode(wargaData),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return {
          'success': true,
          'data': data,
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal mendaftar warga',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  // Create warga (admin only)
  Future<Map<String, dynamic>> createWarga(
      Map<String, dynamic> wargaData) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.warga),
        headers: _headers,
        body: jsonEncode(wargaData),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return {
          'success': true,
          'data': data,
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal membuat data warga',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  // Update warga
  Future<Map<String, dynamic>> updateWarga(
      String nik, Map<String, dynamic> wargaData) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.warga}/$nik'),
        headers: _headers,
        body: jsonEncode(wargaData),
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
          'message': data['message'] ?? 'Gagal mengupdate data warga',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  // Delete warga (admin only)
  Future<Map<String, dynamic>> deleteWarga(String nik) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.warga}/$nik'),
        headers: _headers,
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
          'message': data['message'] ?? 'Gagal menghapus data warga',
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
