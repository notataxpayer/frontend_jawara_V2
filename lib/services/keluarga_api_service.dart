import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pbl_jawara_test/config/api_config.dart';

class KeluargaApiService {
  final String? token;

  KeluargaApiService({this.token});

  Map<String, String> get _headers =>
      token != null ? ApiConfig.headersWithAuth(token!) : ApiConfig.headers;

  // Get all keluarga
  Future<Map<String, dynamic>> getAllKeluarga() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.keluarga),
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
          'message': data['message'] ?? 'Gagal mengambil data keluarga',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  // Get keluarga by ID
  Future<Map<String, dynamic>> getKeluargaById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.keluarga}/$id'),
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
          'message': data['message'] ?? 'Gagal mengambil data keluarga',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  // Create keluarga (admin only)
  Future<Map<String, dynamic>> createKeluarga(
      Map<String, dynamic> keluargaData) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.keluarga),
        headers: _headers,
        body: jsonEncode(keluargaData),
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
          'message': data['message'] ?? 'Gagal membuat data keluarga',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  // Update keluarga (admin only)
  Future<Map<String, dynamic>> updateKeluarga(
      String id, Map<String, dynamic> keluargaData) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.keluarga}/$id'),
        headers: _headers,
        body: jsonEncode(keluargaData),
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
          'message': data['message'] ?? 'Gagal mengupdate data keluarga',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  // Delete keluarga (admin only)
  Future<Map<String, dynamic>> deleteKeluarga(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.keluarga}/$id'),
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
          'message': data['message'] ?? 'Gagal menghapus data keluarga',
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
