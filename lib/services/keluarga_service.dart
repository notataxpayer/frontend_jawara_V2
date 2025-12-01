import 'package:pbl_jawara_test/models/keluarga.dart';
import 'package:pbl_jawara_test/services/keluarga_api_service.dart';

class KeluargaService {
  static final List<Keluarga> _keluargaList = [
    const Keluarga(
      id: 'K001',
      namaKeluarga: 'Keluarga Santoso',
      kepaluargaWargaId: 'W001',
      rumahId: 'R001',
      jumlahAnggota: 4,
    ),
    const Keluarga(
      id: 'K002',
      namaKeluarga: 'Keluarga Wijaya',
      kepaluargaWargaId: 'W003',
      rumahId: 'R002',
      jumlahAnggota: 3,
    ),
    const Keluarga(
      id: 'K003',
      namaKeluarga: 'Keluarga Kusuma',
      kepaluargaWargaId: 'W005',
      rumahId: 'R003',
      jumlahAnggota: 5,
    ),
  ];

  // Use API service for actual API calls
  Future<Map<String, dynamic>> getAllKeluarga(String token) async {
    final apiService = KeluargaApiService(token: token);
    return await apiService.getAllKeluarga();
  }

  Future<Map<String, dynamic>> getKeluargaById(String token, int id) async {
    final apiService = KeluargaApiService(token: token);
    return await apiService.getKeluargaById(id.toString());
  }

  Future<Map<String, dynamic>> createKeluarga(
      String token, Map<String, dynamic> keluargaData) async {
    final apiService = KeluargaApiService(token: token);
    return await apiService.createKeluarga(keluargaData);
  }

  Future<Map<String, dynamic>> updateKeluarga(
      String token, int id, Map<String, dynamic> keluargaData) async {
    final apiService = KeluargaApiService(token: token);
    return await apiService.updateKeluarga(id.toString(), keluargaData);
  }

  Future<Map<String, dynamic>> deleteKeluarga(String token, int id) async {
    final apiService = KeluargaApiService(token: token);
    return await apiService.deleteKeluarga(id.toString());
  }

  // Legacy methods for local data (kept for backward compatibility)
  Future<List<Keluarga>> getAllKeluargaLocal() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _keluargaList;
  }

  Future<List<Keluarga>> searchKeluarga(String query) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (query.isEmpty) return _keluargaList;
    return _keluargaList
        .where((keluarga) =>
            keluarga.namaKeluarga.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  Future<Keluarga?> getKeluargaByIdLocal(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return _keluargaList.firstWhere((keluarga) => keluarga.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<Keluarga?> getKeluargaByRumahId(String rumahId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return _keluargaList
          .firstWhere((keluarga) => keluarga.rumahId == rumahId);
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>> addKeluarga(Keluarga keluarga) async {
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      _keluargaList.add(keluarga);
      return {
        'success': true,
        'message': 'Keluarga berhasil ditambahkan',
        'data': keluarga,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal menambahkan keluarga: $e',
        'data': null,
      };
    }
  }

  Future<Map<String, dynamic>> updateKeluargaLocal(
      String id, Keluarga keluarga) async {
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      final index = _keluargaList.indexWhere((k) => k.id == id);
      if (index == -1) {
        return {
          'success': false,
          'message': 'Keluarga tidak ditemukan',
          'data': null,
        };
      }

      _keluargaList[index] = keluarga;
      return {
        'success': true,
        'message': 'Keluarga berhasil diperbarui',
        'data': keluarga,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal memperbarui keluarga: $e',
        'data': null,
      };
    }
  }

  Future<Map<String, dynamic>> deleteKeluargaLocal(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      final index = _keluargaList.indexWhere((k) => k.id == id);
      if (index == -1) {
        return {
          'success': false,
          'message': 'Keluarga tidak ditemukan',
          'data': null,
        };
      }

      _keluargaList.removeAt(index);
      return {
        'success': true,
        'message': 'Keluarga berhasil dihapus',
        'data': null,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal menghapus keluarga: $e',
        'data': null,
      };
    }
  }
}
