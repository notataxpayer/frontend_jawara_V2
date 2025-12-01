import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pbl_jawara_test/config/api_config.dart';
import 'package:pbl_jawara_test/models/warga.dart';
import 'package:pbl_jawara_test/utils/user_storage.dart';

class WargaService {
  
  /// Self-register warga profile with KTP verification
  /// Returns response with success status and message
  Future<Map<String, dynamic>> selfRegister({
    required String token,
    required String nik,
    required String namaWarga,
    required String jenisKelamin,
    required String statusDomisili,
    required String statusHidup,
    required XFile fotoKtp,
    Uint8List? fotoKtpBytes,
    int? keluargaId,
  }) async {
    try {
      // Validasi NIK 16 digit
      if (nik.length != 16) {
        return {
          'success': false,
          'message': 'NIK harus 16 digit',
        };
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiConfig.wargaSelfRegister),
      );

      // Add headers
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      // Add fields
      request.fields['nik'] = nik;
      request.fields['namaWarga'] = namaWarga;
      request.fields['jenisKelamin'] = jenisKelamin;
      request.fields['statusDomisili'] = statusDomisili;
      request.fields['statusHidup'] = statusHidup;
      
      if (keluargaId != null) {
        request.fields['keluargaId'] = keluargaId.toString();
      }

      // Add file - gunakan bytes jika tersedia (untuk web)
      if (fotoKtpBytes != null) {
        request.files.add(http.MultipartFile.fromBytes(
          'foto_ktp',
          fotoKtpBytes,
          filename: fotoKtp.name,
          contentType: MediaType('image', 'jpeg'),
        ));
      } else {
        // Fallback untuk platform lain
        final bytes = await fotoKtp.readAsBytes();
        request.files.add(http.MultipartFile.fromBytes(
          'foto_ktp',
          bytes,
          filename: fotoKtp.name,
          contentType: MediaType('image', 'jpeg'),
        ));
      }

      print('===== SELF REGISTER WARGA DEBUG =====');
      print('URL: ${ApiConfig.wargaSelfRegister}');
      print('Fields: ${request.fields}');
      print('File: ${fotoKtp.name}');
      print('====================================');

      // Send request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print('====================================');

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {
          'success': true,
          'data': data,
          'message': data['message'] ?? 'Berhasil mendaftarkan data warga',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? data['error'] ?? 'Gagal mendaftarkan data warga',
        };
      }
    } catch (e) {
      print('Self Register Warga Exception: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  /// Get all warga from API (requires authentication)
  Future<Map<String, dynamic>> getAllWargaFromApi(String token) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.warga),
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

  /// Get current user's warga profile (if exists)
  Future<Map<String, dynamic>> getMyWargaProfile(String token) async {
    try {
      // Ambil userId dari storage dulu
      final userData = await UserStorage.getUserData();
      int? loggedInUserId;
      
      if (userData != null) {
        try {
          loggedInUserId = userData['id'] is int 
            ? userData['id'] 
            : int.tryParse(userData['id'].toString());
          print('Logged in userId from storage: $loggedInUserId');
        } catch (e) {
          print('Kesalahan parsing data pengguna: $e');
        }
      }

      // Coba dari auth profile dulu
      final profileResponse = await http.get(
        Uri.parse(ApiConfig.authProfile),
        headers: ApiConfig.headersWithAuth(token),
      );

      print('Get My Warga Profile Status: ${profileResponse.statusCode}');
      print('Get My Warga Profile Body: ${profileResponse.body}');

      if (profileResponse.statusCode == 200) {
        final profileData = jsonDecode(profileResponse.body);
        final warga = profileData['warga'];
        
        // Jika ada data warga dari profile, return
        if (warga != null) {
          return {
            'success': true,
            'hasProfile': true,
            'data': warga,
            'status': warga['status'] ?? 'approved',
          };
        }
        
        // Update userId dari profile jika ada
        if (profileData['id'] != null && loggedInUserId == null) {
          loggedInUserId = profileData['id'] is int 
            ? profileData['id'] 
            : int.tryParse(profileData['id'].toString());
        }
      }

      // Jika tidak ada userId, return tidak ada profile
      if (loggedInUserId == null) {
        print('KESALAHAN: Tidak dapat mengambil userId yang login');
        return {
          'success': true,
          'hasProfile': false,
          'data': null,
        };
      }

      // Jika tidak ada dari profile, coba ambil semua warga dan filter by userId
      final wargaResponse = await http.get(
        Uri.parse(ApiConfig.warga),
        headers: ApiConfig.headersWithAuth(token),
      );

      print('Get All Warga Status: ${wargaResponse.statusCode}');
      print('Get All Warga Body: ${wargaResponse.body}');

      if (wargaResponse.statusCode == 200) {
        final wargaData = jsonDecode(wargaResponse.body);
        final wargaList = wargaData['data'] as List? ?? [];
        
        print('Looking for userId: $loggedInUserId');
        print('Warga list count: ${wargaList.length}');
        
        // Cari warga dengan userId yang sama
        Map<String, dynamic>? myWarga;
        
        for (var warga in wargaList) {
          final wargaMap = warga as Map<String, dynamic>;
          final wargaUserId = wargaMap['userId'];
          
          print('Checking warga: NIK=${wargaMap['nik']}, userId=$wargaUserId, status=${wargaMap['status']}');
          
          // Compare userId (convert both to int for comparison)
          if (wargaUserId != null) {
            final wargaUserIdInt = wargaUserId is int ? wargaUserId : int.tryParse(wargaUserId.toString());
            
            if (wargaUserIdInt == loggedInUserId) {
              myWarga = wargaMap;
              print('Found matching warga!');
              break;
            }
          }
        }
        
        if (myWarga != null) {
          print('Found my warga: $myWarga');
          return {
            'success': true,
            'hasProfile': true,
            'data': myWarga,
            'status': myWarga['status'] ?? 'pending',
          };
        } else {
          print('No warga found for userId: $loggedInUserId');
        }
      }

      // Tidak ada data warga
      return {
        'success': true,
        'hasProfile': false,
        'data': null,
      };
    } catch (e) {
      print('Get My Warga Profile Error: $e');
      return {
        'success': false,
        'hasProfile': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  /// Get warga by NIK from API (requires authentication)
  Future<Map<String, dynamic>> getWargaByNikFromApi(String token, String nik) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.warga}/$nik'),
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

  /// Update warga data (requires authentication)
  /// Nama changes will go through verification process
  Future<Map<String, dynamic>> updateWargaApi({
    required String token,
    required String nik,
    String? namaWarga,
    String? jenisKelamin,
    String? statusDomisili,
    String? statusHidup,
    int? keluargaId,
  }) async {
    try {
      final Map<String, dynamic> requestBody = {};
      
      if (namaWarga != null) requestBody['namaWarga'] = namaWarga;
      if (jenisKelamin != null) requestBody['jenisKelamin'] = jenisKelamin;
      if (statusDomisili != null) requestBody['statusDomisili'] = statusDomisili;
      if (statusHidup != null) requestBody['statusHidup'] = statusHidup;
      if (keluargaId != null) requestBody['keluargaId'] = keluargaId;

      final response = await http.put(
        Uri.parse('${ApiConfig.warga}/$nik'),
        headers: ApiConfig.headersWithAuth(token),
        body: jsonEncode(requestBody),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': data,
          'message': data['message'] ?? 'Berhasil mengupdate data warga',
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

  /// Delete warga from API (admin only)
  Future<Map<String, dynamic>> deleteWargaApi(String token, String nik) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.warga}/$nik'),
        headers: ApiConfig.headersWithAuth(token),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Berhasil menghapus data warga',
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

  // ===== MOCK DATA METHODS (existing) =====

  static final List<Warga> _wargaList = [
    const Warga(
      id: 'W001',
      namaWarga: 'Budi Santoso',
      nik: '3201010101990001',
      namaKeluarga: 'Keluarga Santoso',
      jenisKelamin: 'Laki-laki',
      statusDomisili: 'tetap',
      statusHidup: 'hidup',
      keluargaId: 'K001',
    ),
    const Warga(
      id: 'W002',
      namaWarga: 'Siti Nurhaliza',
      nik: '3201010505980005',
      namaKeluarga: 'Keluarga Santoso',
      jenisKelamin: 'Perempuan',
      statusDomisili: 'tetap',
      statusHidup: 'hidup',
      keluargaId: 'K001',
    ),
    const Warga(
      id: 'W003',
      namaWarga: 'Ahmad Wijaya',
      nik: '3201010202010002',
      namaKeluarga: 'Keluarga Wijaya',
      jenisKelamin: 'Laki-laki',
      statusDomisili: 'kontrak',
      statusHidup: 'hidup',
      keluargaId: 'K002',
    ),
    const Warga(
      id: 'W004',
      namaWarga: 'Nur Azizah',
      nik: '3201010303990003',
      namaKeluarga: 'Keluarga Wijaya',
      jenisKelamin: 'Perempuan',
      statusDomisili: 'kontrak',
      statusHidup: 'hidup',
      keluargaId: 'K002',
    ),
    const Warga(
      id: 'W005',
      namaWarga: 'Hendra Kusuma',
      nik: '3201010404000004',
      namaKeluarga: 'Keluarga Kusuma',
      jenisKelamin: 'Laki-laki',
      statusDomisili: 'pindah',
      statusHidup: 'meninggal',
      keluargaId: 'K003',
    ),
  ];

  Future<List<Warga>> getAllWarga() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _wargaList;
  }

  Future<List<Warga>> searchWarga(String query) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (query.isEmpty) return _wargaList;
    return _wargaList
        .where((warga) =>
            warga.namaWarga.toLowerCase().contains(query.toLowerCase()) ||
            warga.nik.contains(query) ||
            warga.namaKeluarga.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  Future<List<Warga>> getWargaByKeluargaId(String keluargaId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _wargaList.where((warga) => warga.keluargaId == keluargaId).toList();
  }

  Future<Warga?> getWargaById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return _wargaList.firstWhere((warga) => warga.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>> addWarga(Warga warga) async {
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      // Check if NIK already exists
      final exists = _wargaList.any((w) => w.nik == warga.nik);
      if (exists) {
        return {
          'success': false,
          'message': 'NIK sudah terdaftar',
          'data': null,
        };
      }

      _wargaList.add(warga);
      return {
        'success': true,
        'message': 'Warga berhasil ditambahkan',
        'data': warga,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal menambahkan warga: $e',
        'data': null,
      };
    }
  }

  Future<Map<String, dynamic>> updateWarga(String id, Warga warga) async {
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      final index = _wargaList.indexWhere((w) => w.id == id);
      if (index == -1) {
        return {
          'success': false,
          'message': 'Warga tidak ditemukan',
          'data': null,
        };
      }

      _wargaList[index] = warga;
      return {
        'success': true,
        'message': 'Warga berhasil diperbarui',
        'data': warga,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal memperbarui warga: $e',
        'data': null,
      };
    }
  }

  Future<Map<String, dynamic>> deleteWarga(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      final index = _wargaList.indexWhere((w) => w.id == id);
      if (index == -1) {
        return {
          'success': false,
          'message': 'Warga tidak ditemukan',
          'data': null,
        };
      }

      _wargaList.removeAt(index);
      return {
        'success': true,
        'message': 'Warga berhasil dihapus',
        'data': null,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal menghapus warga: $e',
        'data': null,
      };
    }
  }

  List<String> getJenisKelaminOptions() => ['Laki-laki', 'Perempuan'];

  List<String> getStatusDomisiliOptions() => ['tetap', 'kontrak', 'pindah'];

  List<String> getStatusHidupOptions() => ['hidup', 'meninggal'];
}
