import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pbl_jawara_test/config/api_config.dart';

class VerificationWargaApiService {
  final String? token;

  VerificationWargaApiService({this.token});

  Map<String, String> get _headers =>
      token != null ? ApiConfig.headersWithAuth(token!) : ApiConfig.headers;

  // Submit verification request
  Future<Map<String, dynamic>> submitVerification(
      Map<String, dynamic> verificationData) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.verificationSubmit),
        headers: _headers,
        body: jsonEncode(verificationData),
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
          'message': data['message'] ?? 'Gagal submit verifikasi',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  // Get user's own verification requests
  Future<Map<String, dynamic>> getMyRequests() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.verificationMyRequests),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data['data'] ?? data,
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal mengambil data request',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  // Get all verification requests (admin only)
  Future<Map<String, dynamic>> getAllRequests() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.verificationAll),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data['data'] ?? data,
        };
      } else if (response.statusCode == 403) {
        return {
          'success': false,
          'message': 'Access denied',
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal mengambil data request',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  // Get pending verification requests (admin only)
  Future<Map<String, dynamic>> getPendingRequests() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.verificationPending),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data['data'] ?? data,
        };
      } else if (response.statusCode == 403) {
        return {
          'success': false,
          'message': 'Access denied',
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal mengambil data request',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  // Approve verification request (admin only)
  Future<Map<String, dynamic>> approveRequest(String id) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.verificationWarga}/approve/$id'),
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
          'message': data['message'] ?? 'Gagal approve request',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  // Reject verification request (admin only)
  Future<Map<String, dynamic>> rejectRequest(String id) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.verificationWarga}/reject/$id'),
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
          'message': data['message'] ?? 'Gagal reject request',
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
