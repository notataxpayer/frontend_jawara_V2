import 'package:pbl_jawara_test/models/warga.dart';

class WargaService {
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
