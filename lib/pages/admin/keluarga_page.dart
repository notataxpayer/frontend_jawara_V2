import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pbl_jawara_test/services/keluarga_service.dart';
import 'package:pbl_jawara_test/utils/user_storage.dart';

class KeluargaPage extends StatefulWidget {
  const KeluargaPage({super.key});

  @override
  State<KeluargaPage> createState() => _KeluargaPageState();
}

class _KeluargaPageState extends State<KeluargaPage> {
  final _keluargaService = KeluargaService();
  List<dynamic> _keluargaList = [];
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
      final result = await _keluargaService.getAllKeluarga(_token!);
      
      print('Keluarga result: $result');
      
      if (mounted) {
        setState(() {
          if (result['success'] == true && result['data'] != null) {
            final responseData = result['data'];
            // Backend returns: {success: true, message: "...", data: [...]}
            // So we need to get the 'data' field from responseData
            if (responseData is Map && responseData['data'] is List) {
              _keluargaList = List<Map<String, dynamic>>.from(responseData['data']);
            } else if (responseData is List) {
              _keluargaList = List<Map<String, dynamic>>.from(responseData);
            } else {
              _keluargaList = [];
            }
          } else {
            _keluargaList = [];
          }
          _isLoading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _keluargaList = [];
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
        content: const Text('Apakah Anda yakin ingin menghapus keluarga ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true && _token != null) {
      final result = await _keluargaService.deleteKeluarga(_token!, id);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Keluarga dihapus'),
            backgroundColor: result['success'] == true ? Colors.green : Colors.red,
          ),
        );

        if (result['success'] == true) {
          _loadData();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Kelola Keluarga',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF00BFA5),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _keluargaList.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.family_restroom,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Belum ada data keluarga',
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
                    itemCount: _keluargaList.length,
                    itemBuilder: (context, index) {
                      final keluarga = _keluargaList[index];
                      return _buildKeluargaCard(keluarga);
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await context.push('/kelola-keluarga/tambah');
          if (result == true) {
            _loadData();
          }
        },
        backgroundColor: const Color(0xFF00BFA5),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Tambah Keluarga',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildKeluargaCard(Map<String, dynamic> data) {
    final namaKeluarga = data['namaKeluarga']?.toString() ?? 'N/A';
    // Backend uses 'jumlahanggota' (lowercase)
    final jumlahAnggota = (data['jumlahanggota'] ?? data['jumlahAnggota'])?.toString() ?? '0';
    final rumahId = data['rumahId']?.toString() ?? 'N/A';
    final kepalaKeluargaId = data['kepala_Keluarga_Id']?.toString() ?? 'N/A';
    final id = data['id'];

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
                    namaKeluarga,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                PopupMenuButton(
                  icon: const Icon(Icons.more_vert),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: const [
                          Icon(Icons.edit, size: 20),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: const [
                          Icon(Icons.delete, size: 20, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Hapus', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'edit') {
                      context.push('/kelola-keluarga/edit/$id', extra: data);
                    } else if (value == 'delete') {
                      _handleDelete(id);
                    }
                  },
                ),
              ],
            ),
            const Divider(height: 24),
            _buildInfoRow('Jumlah Anggota', '$jumlahAnggota orang'),
            const SizedBox(height: 8),
            if (rumahId != 'N/A')
              _buildInfoRow('Rumah ID', rumahId)
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
                        'Rumah belum ditambahkan',
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
            const SizedBox(height: 8),
            _buildInfoRow('Kepala Keluarga ID', kepalaKeluargaId),
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
