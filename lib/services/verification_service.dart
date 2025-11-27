import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pbl_jawara_test/config/api_config.dart';

class VerificationService {
  
  /// Get all verification requests (pending, approved, rejected)
  Future<Map<String, dynamic>> getAllVerifications(String token) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.verificationAll),
        headers: ApiConfig.headersWithAuth(token),
      );

      print('Get All Verifications Status: ${response.statusCode}');
      print('Get All Verifications Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data['data'] ?? [],
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal mengambil data verifikasi',
        };
      }
    } catch (e) {
      print('Get All Verifications Error: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }
  
  /// Get all pending verification requests
  Future<Map<String, dynamic>> getPendingVerifications(String token) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.verificationPending),
        headers: ApiConfig.headersWithAuth(token),
      );

      print('Get Pending Verifications Status: ${response.statusCode}');
      print('Get Pending Verifications Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data['data'] ?? [],
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal mengambil data verifikasi',
        };
      }
    } catch (e) {
      print('Get Pending Verifications Error: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  /// Approve verification request
  Future<Map<String, dynamic>> approveVerification(String token, int id) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.verificationWargaApprove}/$id'),
        headers: ApiConfig.headersWithAuth(token),
      );

      print('Approve Verification Status: ${response.statusCode}');
      print('Approve Verification Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'message': data['message'] ?? 'Verifikasi berhasil disetujui',
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal menyetujui verifikasi',
        };
      }
    } catch (e) {
      print('Approve Verification Error: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  /// Reject verification request
  Future<Map<String, dynamic>> rejectVerification(String token, int id) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.verificationWargaReject}/$id'),
        headers: ApiConfig.headersWithAuth(token),
      );

      print('Reject Verification Status: ${response.statusCode}');
      print('Reject Verification Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'message': data['message'] ?? 'Verifikasi berhasil ditolak',
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal menolak verifikasi',
        };
      }
    } catch (e) {
      print('Reject Verification Error: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }
}
