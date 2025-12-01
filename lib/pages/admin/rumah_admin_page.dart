import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pbl_jawara_test/services/rumah_api_service.dart';
import 'package:pbl_jawara_test/utils/user_storage.dart';

class RumahAdminPage extends StatefulWidget {
  const RumahAdminPage({super.key});

  @override
  State<RumahAdminPage> createState() => _RumahAdminPageState();
}

class _RumahAdminPageState extends State<RumahAdminPage> {
  RumahApiService? _rumahService;
  List<Map<String, dynamic>> _rumahList = [];
  bool _isLoading = true;
  String? _token;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    _token = await UserStorage.getToken();
    if (_token != null) {
      _rumahService = RumahApiService(token: _token);
      final result = await _rumahService!.getAllRumah();

      if (mounted) {
        setState(() {
          if (result['success'] == true && result['data'] != null) {
            final data = result['data'];
            if (data is Map && data['data'] is List) {
              _rumahList = List<Map<String, dynamic>>.from(data['data']);
            } else if (data is List) {
              _rumahList = List<Map<String, dynamic>>.from(data);
            } else {
              _rumahList = [];
            }
          } else {
            _rumahList = [];
          }
          _isLoading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _rumahList = [];
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleDelete(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: const Text('Apakah Anda yakin ingin menghapus rumah ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true && _token != null) {
      final result = await _rumahService!.deleteRumah(id.toString());

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result['message'] ??
                (result['success']
                    ? 'Rumah berhasil dihapus'
                    : 'Gagal menghapus rumah'),
          ),
          backgroundColor: result['success'] ? Colors.green : Colors.red,
        ),
      );

      if (result['success']) {
        _loadData();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Kelola Rumah',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF00BFA5),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Memuat data rumah...',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            )
          : _rumahList.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.home,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Belum ada data rumah',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _rumahList.length,
                    itemBuilder: (context, index) {
                      final rumah = _rumahList[index];
                      return _buildRumahCard(rumah);
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await context.push('/kelola-rumah/tambah');
          if (result == true) {
            _loadData();
          }
        },
        backgroundColor: const Color(0xFF00BFA5),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Tambah Rumah',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildRumahCard(Map<String, dynamic> data) {
    final alamat = data['alamat']?.toString() ?? 'N/A';
    final statusKepemilikan = data['statusKepemilikan']?.toString() ?? 'N/A';
    // Backend uses 'jumlahpenghuni' (lowercase)
    final jumlahPenghuni = (data['jumlahpenghuni'] ?? data['jumlahPenghuni'])?.toString() ?? '0';
    final keluargaId = data['keluargaId'];
    final id = data['id'];
    final blok = data['blok']?.toString() ?? '';
    final nomorRumah = data['nomorRumah']?.toString() ?? '';

    // Determine if keluargaId is assigned
    final hasKeluarga = keluargaId != null;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    blok.isNotEmpty && nomorRumah.isNotEmpty 
                        ? 'Blok $blok No. $nomorRumah'
                        : alamat,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                PopupMenuButton(
                  icon: const Icon(Icons.more_vert),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 20),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 20, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Hapus', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'edit') {
                      context.push('/kelola-rumah/edit/$id', extra: data);
                    } else if (value == 'delete') {
                      _handleDelete(id);
                    }
                  },
                ),
              ],
            ),
            const Divider(height: 24),
            _buildInfoRow('Alamat', alamat),
            const SizedBox(height: 8),
            _buildInfoRow('Status Kepemilikan', statusKepemilikan),
            const SizedBox(height: 8),
            _buildInfoRow('Jumlah Penghuni', '$jumlahPenghuni orang'),
            const SizedBox(height: 8),
            if (hasKeluarga)
              _buildInfoRow('Keluarga ID', keluargaId.toString())
            else
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  border: Border.all(color: Colors.orange.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber, 
                        color: Colors.orange.shade700, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Keluarga ID belum di-assign',
                        style: TextStyle(
                          color: Colors.orange.shade900,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140,
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ),
        const Text(': ', style: TextStyle(fontSize: 14)),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}
