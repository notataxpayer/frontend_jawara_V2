import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pbl_jawara_test/config/api_config.dart';

class RumahApiService {
  final String? token;

  RumahApiService({this.token});

  Map<String, String> get _headers =>
      token != null ? ApiConfig.headersWithAuth(token!) : ApiConfig.headers;

  // Get all rumah
  Future<Map<String, dynamic>> getAllRumah() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.rumah),
        headers: _headers,
      );

      print('GET Rumah response status: ${response.statusCode}');
      print('GET Rumah response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data,
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal mengambil data rumah',
        };
      }
    } catch (e) {
      print('Kesalahan saat mengambil semua rumah: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  // Get rumah by ID
  Future<Map<String, dynamic>> getRumahById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.rumah}/$id'),
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
          'message': data['message'] ?? 'Gagal mengambil data rumah',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  // Create rumah (admin only)
  Future<Map<String, dynamic>> createRumah(
      Map<String, dynamic> rumahData) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.rumah),
        headers: _headers,
        body: jsonEncode(rumahData),
      );

      print('POST Rumah response status: ${response.statusCode}');
      print('POST Rumah response body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {
          'success': true,
          'data': data,
          'message': data['message'] ?? 'Rumah berhasil dibuat',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal membuat data rumah',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  // Update rumah (admin only)
  Future<Map<String, dynamic>> updateRumah(
      String id, Map<String, dynamic> rumahData) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.rumah}/$id'),
        headers: _headers,
        body: jsonEncode(rumahData),
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
          'message': data['message'] ?? 'Gagal mengupdate data rumah',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  // Delete rumah (admin only)
  Future<Map<String, dynamic>> deleteRumah(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.rumah}/$id'),
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
          'message': data['message'] ?? 'Gagal menghapus data rumah',
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
