import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:pbl_jawara_test/config/api_config.dart';

class MarketplaceService {
  final String? token;

  MarketplaceService({this.token});

  Map<String, String> get _headers =>
      token != null ? ApiConfig.headersWithAuth(token!) : ApiConfig.headers;

  // Get all marketplace items
  Future<Map<String, dynamic>> getAllItems() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.marketplace),
        headers: _headers,
      );

      print('GET Marketplace response status: ${response.statusCode}');
      print('GET Marketplace response body: ${response.body}');

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
          'message': data['message'] ?? 'Gagal mengambil data marketplace',
        };
      }
    } catch (e) {
      print('Kesalahan saat mengambil semua item: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  // Get marketplace item by ID
  Future<Map<String, dynamic>> getItemById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.marketplace}/$id'),
        headers: _headers,
      );

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
          'message': data['message'] ?? 'Gagal mengambil data item',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  // Create marketplace item (admin only) - multipart/form-data
  Future<Map<String, dynamic>> createItem({
    File? gambar,
    Uint8List? gambarBytes,
    String? gambarFilename,
    required String namaProduk,
    required int harga,
    required String deskripsi,
    int? stok,
  }) async {
    try {
      print('Creating marketplace item: $namaProduk, $harga, $deskripsi');

      var request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiConfig.marketplace),
      );

      // Add headers
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      // Add image file
      if (gambar != null) {
        // Determine MIME type from filename
        String contentType = 'image/jpeg'; // default
        final filename = gambar.path.toLowerCase();
        if (filename.endsWith('.png')) {
          contentType = 'image/png';
        } else if (filename.endsWith('.webp')) {
          contentType = 'image/webp';
        } else if (filename.endsWith('.jpg') || filename.endsWith('.jpeg')) {
          contentType = 'image/jpeg';
        }
        
        request.files.add(
          await http.MultipartFile.fromPath(
            'gambar',
            gambar.path,
            contentType: MediaType.parse(contentType),
          ),
        );
      } else if (gambarBytes != null) {
        // Determine MIME type from filename
        String contentType = 'image/jpeg'; // default
        if (gambarFilename != null) {
          if (gambarFilename.toLowerCase().endsWith('.png')) {
            contentType = 'image/png';
          } else if (gambarFilename.toLowerCase().endsWith('.webp')) {
            contentType = 'image/webp';
          } else if (gambarFilename.toLowerCase().endsWith('.jpg') || 
                     gambarFilename.toLowerCase().endsWith('.jpeg')) {
            contentType = 'image/jpeg';
          }
        }
        
        request.files.add(
          http.MultipartFile.fromBytes(
            'gambar',
            gambarBytes,
            filename: gambarFilename ?? 'image.jpg',
            contentType: MediaType.parse(contentType),
          ),
        );
      }

      // Add other fields
      request.fields['namaProduk'] = namaProduk;
      request.fields['harga'] = harga.toString();
      request.fields['deskripsi'] = deskripsi;
      if (stok != null) {
        request.fields['stok'] = stok.toString();
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('POST Marketplace response status: ${response.statusCode}');
      print('POST Marketplace response body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data,
          'message': data['message'] ?? 'Item berhasil ditambahkan',
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal menambahkan item',
        };
      }
    } catch (e) {
      print('Kesalahan saat membuat item: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  // Update marketplace item (admin only) - JSON only, no image update
  Future<Map<String, dynamic>> updateItem({
    required String id,
    File? gambar,
    Uint8List? gambarBytes,
    String? gambarFilename,
    required String namaProduk,
    required int harga,
    required String deskripsi,
    int? stok,
  }) async {
    try {
      print('Updating marketplace item ID: $id');

      // Backend expects JSON, not multipart for update
      final body = {
        'namaProduk': namaProduk,
        'harga': harga,
        'deskripsi': deskripsi,
        if (stok != null) 'stok': stok,
      };

      print('PUT Request body: ${jsonEncode(body)}');

      final response = await http.put(
        Uri.parse('${ApiConfig.marketplace}/$id'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      print('PUT Marketplace response status: ${response.statusCode}');
      print('PUT Marketplace response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final data = jsonDecode(response.body);
          return {
            'success': true,
            'data': data,
            'message': data['message'] ?? 'Item berhasil diupdate',
          };
        } catch (e) {
          // If response is not JSON, consider it success if status is 200
          return {
            'success': true,
            'message': 'Item berhasil diupdate',
          };
        }
      } else {
        try {
          final data = jsonDecode(response.body);
          return {
            'success': false,
            'message': data['message'] ?? 'Gagal mengupdate item',
          };
        } catch (e) {
          return {
            'success': false,
            'message': 'Gagal mengupdate item: ${response.body}',
          };
        }
      }
    } catch (e) {
      print('Kesalahan saat mengupdate item: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  // Delete marketplace item (admin only)
  Future<Map<String, dynamic>> deleteItem(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.marketplace}/$id'),
        headers: _headers,
      );

      print('DELETE Marketplace response status: ${response.statusCode}');
      print('DELETE Marketplace response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'message': data['message'] ?? 'Item berhasil dihapus',
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal menghapus item',
        };
      }
    } catch (e) {
      print('Kesalahan saat menghapus item: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }
}
