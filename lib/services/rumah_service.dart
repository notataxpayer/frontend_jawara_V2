import 'package:pbl_jawara_test/models/rumah.dart';

class RumahService {
  static final List<Rumah> _rumahList = [
    const Rumah(
      id: 'R001',
      alamat: 'Jl. Merdeka No. 12, RT 01/RW 02',
      statusKepemilikan: 'milik_sendiri',
      keluargaId: 'K001',
      jumlahPenghuni: 4,
    ),
    const Rumah(
      id: 'R002',
      alamat: 'Jl. Sudirman No. 45, RT 02/RW 02',
      statusKepemilikan: 'kontrak',
      keluargaId: 'K002',
      jumlahPenghuni: 3,
    ),
    const Rumah(
      id: 'R003',
      alamat: 'Jl. Ahmad Yani No. 78, RT 03/RW 02',
      statusKepemilikan: 'milik_sendiri',
      keluargaId: 'K003',
      jumlahPenghuni: 5,
    ),
  ];

  Future<List<Rumah>> getAllRumah() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _rumahList;
  }

  Future<List<Rumah>> searchRumah(String query) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (query.isEmpty) return _rumahList;
    return _rumahList
        .where(
            (rumah) => rumah.alamat.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  Future<List<Rumah>> getRumahByKeluargaId(String keluargaId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _rumahList.where((rumah) => rumah.keluargaId == keluargaId).toList();
  }

  Future<Rumah?> getRumahById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return _rumahList.firstWhere((rumah) => rumah.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>> addRumah(Rumah rumah) async {
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      _rumahList.add(rumah);
      return {
        'success': true,
        'message': 'Rumah berhasil ditambahkan',
        'data': rumah,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal menambahkan rumah: $e',
        'data': null,
      };
    }
  }

  Future<Map<String, dynamic>> updateRumah(String id, Rumah rumah) async {
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      final index = _rumahList.indexWhere((r) => r.id == id);
      if (index == -1) {
        return {
          'success': false,
          'message': 'Rumah tidak ditemukan',
          'data': null,
        };
      }

      _rumahList[index] = rumah;
      return {
        'success': true,
        'message': 'Rumah berhasil diperbarui',
        'data': rumah,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal memperbarui rumah: $e',
        'data': null,
      };
    }
  }

  Future<Map<String, dynamic>> deleteRumah(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      final index = _rumahList.indexWhere((r) => r.id == id);
      if (index == -1) {
        return {
          'success': false,
          'message': 'Rumah tidak ditemukan',
          'data': null,
        };
      }

      _rumahList.removeAt(index);
      return {
        'success': true,
        'message': 'Rumah berhasil dihapus',
        'data': null,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal menghapus rumah: $e',
        'data': null,
      };
    }
  }

  List<String> getStatusKepemilikanOptions() => ['milik_sendiri', 'kontrak'];
}
