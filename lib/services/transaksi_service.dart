import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pbl_jawara_test/config/api_config.dart';

class TransaksiService {
  final String? token;

  TransaksiService({this.token});

  Map<String, String> get _headers =>
      token != null ? ApiConfig.headersWithAuth(token!) : ApiConfig.headers;

  /// Purchase marketplace item
  /// POST /api/transaksi/marketplace/{id}/beli
  /// Body: { "jumlah": number }
  Future<Map<String, dynamic>> purchaseItem({
    required int marketplaceId,
    required int jumlah,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.apiUrl}/transaksi/marketplace/$marketplaceId/beli'),
        headers: _headers,
        body: jsonEncode({'jumlah': jumlah}),
      );

      print('Purchase Item response status: ${response.statusCode}');
      print('Purchase Item response body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {
          'success': true,
          'data': data,
          'message': data['message'] ?? 'Pembelian berhasil',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? data['error'] ?? 'Gagal melakukan pembelian',
        };
      }
    } catch (e) {
      print('Error purchasing item: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  /// Get current user's transaction history
  /// GET /api/transaksi/my-transactions
  Future<Map<String, dynamic>> getMyTransactions() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.apiUrl}/transaksi/my-transactions'),
        headers: _headers,
      );

      print('Get My Transactions response status: ${response.statusCode}');
      print('Get My Transactions response body: ${response.body}');

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
          'message': data['message'] ?? 'Gagal mengambil data transaksi',
        };
      }
    } catch (e) {
      print('Error getting my transactions: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  /// Get all transactions (Admin only)
  /// GET /api/transaksi/all
  Future<Map<String, dynamic>> getAllTransactions() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.apiUrl}/transaksi/all'),
        headers: _headers,
      );

      print('Get All Transactions response status: ${response.statusCode}');
      print('Get All Transactions response body: ${response.body}');

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
          'message': data['message'] ?? 'Gagal mengambil semua transaksi',
        };
      }
    } catch (e) {
      print('Error getting all transactions: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  /// Get transaction by ID
  /// GET /api/transaksi/{id}
  Future<Map<String, dynamic>> getTransactionById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.apiUrl}/transaksi/$id'),
        headers: _headers,
      );

      print('Get Transaction by ID response status: ${response.statusCode}');
      print('Get Transaction by ID response body: ${response.body}');

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
          'message': data['message'] ?? 'Gagal mengambil data transaksi',
        };
      }
    } catch (e) {
      print('Error getting transaction by id: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }
}
