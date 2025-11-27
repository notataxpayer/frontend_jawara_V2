import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pbl_jawara_test/config/api_config.dart';

class MarketplaceApiService {
  final String? token;

  MarketplaceApiService({this.token});

  Map<String, String> get _headers =>
      token != null ? ApiConfig.headersWithAuth(token!) : ApiConfig.headers;

  // Get all marketplace items
  Future<Map<String, dynamic>> getAllMarketplace() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.marketplace),
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
          'message': data['message'] ?? 'Gagal mengambil data marketplace',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  // Get marketplace item by ID
  Future<Map<String, dynamic>> getMarketplaceById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.marketplace}/$id'),
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
          'message': data['message'] ?? 'Gagal mengambil data marketplace',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  // Create marketplace item
  Future<Map<String, dynamic>> createMarketplace(
      Map<String, dynamic> marketplaceData) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.marketplace),
        headers: _headers,
        body: jsonEncode(marketplaceData),
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
          'message': data['message'] ?? 'Gagal membuat data marketplace',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  // Update marketplace item
  Future<Map<String, dynamic>> updateMarketplace(
      String id, Map<String, dynamic> marketplaceData) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.marketplace}/$id'),
        headers: _headers,
        body: jsonEncode(marketplaceData),
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
          'message': data['message'] ?? 'Gagal mengupdate data marketplace',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  // Delete marketplace item
  Future<Map<String, dynamic>> deleteMarketplace(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.marketplace}/$id'),
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
          'message': data['message'] ?? 'Gagal menghapus data marketplace',
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
