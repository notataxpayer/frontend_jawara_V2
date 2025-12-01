import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pbl_jawara_test/services/keluarga_service.dart';
import 'package:pbl_jawara_test/services/rumah_api_service.dart';
import 'package:pbl_jawara_test/services/warga_service.dart';
import 'package:pbl_jawara_test/utils/user_storage.dart';

class KeluargaPage extends StatefulWidget {
  const KeluargaPage({super.key});

  @override
  State<KeluargaPage> createState() => _KeluargaPageState();
}

class _KeluargaPageState extends State<KeluargaPage> {
  final _keluargaService = KeluargaService();
  final _wargaService = WargaService();
  List<dynamic> _keluargaList = [];
  List<Map<String, dynamic>> _rumahList = [];
  List<Map<String, dynamic>> _wargaList = [];
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
      // Load keluarga
      final result = await _keluargaService.getAllKeluarga(_token!);
      
      print('Keluarga result: $result');
      
      // Load rumah for alamat display
      final rumahService = RumahApiService(token: _token);
      final rumahResult = await rumahService.getAllRumah();
      
      // Load warga for kepala keluarga name
      final wargaResult = await _wargaService.getAllWargaFromApi(_token!);
      
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
            
            // Debug: print raw keluarga data
            print('Loaded keluarga list:');
            for (var kel in _keluargaList) {
              print('  - ${kel['namaKeluarga']}: ALL FIELDS = $kel');
            }
          } else {
            _keluargaList = [];
          }
          
          // Parse rumah data
          if (rumahResult['success'] == true && rumahResult['data'] != null) {
            final rumahData = rumahResult['data'];
            if (rumahData is Map && rumahData['data'] is List) {
              _rumahList = List<Map<String, dynamic>>.from(rumahData['data']);
            } else if (rumahData is List) {
              _rumahList = List<Map<String, dynamic>>.from(rumahData);
            }
          }
          
          // Parse warga data
          if (wargaResult['success'] == true && wargaResult['data'] != null) {
            final wargaData = wargaResult['data'];
            if (wargaData is Map && wargaData['data'] is List) {
              _wargaList = List<Map<String, dynamic>>.from(wargaData['data']);
            } else if (wargaData is List) {
              _wargaList = List<Map<String, dynamic>>.from(wargaData);
            }
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
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Memuat data keluarga...',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            )
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
    final rumahId = data['rumahId'];
    final id = data['id'];
    
    // Find rumah alamat from rumahId
    String? rumahAlamat;
    if (rumahId != null) {
      final rumah = _rumahList.firstWhere(
        (r) => r['id'] == rumahId,
        orElse: () => {},
      );
      rumahAlamat = rumah['alamat']?.toString();
    }
    
    // Get kepala keluarga - now returned as object
    String kepalaKeluargaNama = 'N/A';
    String? kepalaKeluargaNik;
    bool isKepalaKeluargaMissing = true;
    
    // Check if kepala_keluarga is returned as object (with underscore!)
    if (data['kepala_keluarga'] != null && data['kepala_keluarga'] is Map) {
      final kepalaKeluarga = data['kepala_keluarga'] as Map<String, dynamic>;
      kepalaKeluargaNama = kepalaKeluarga['namaWarga']?.toString() ?? 'N/A';
      kepalaKeluargaNik = kepalaKeluarga['nik']?.toString();
      isKepalaKeluargaMissing = false;
      print('Kepala keluarga from object: $kepalaKeluargaNama (NIK: $kepalaKeluargaNik)');
    } 
    // Fallback: check old field name kepala_Keluarga_Id or kepala_keluarga_id
    else if (data['kepala_Keluarga_Id'] != null || data['kepala_keluarga_id'] != null) {
      final kepalaKeluargaId = (data['kepala_Keluarga_Id'] ?? data['kepala_keluarga_id'])?.toString();
      if (kepalaKeluargaId != null && kepalaKeluargaId.isNotEmpty && kepalaKeluargaId != 'null') {
        print('Looking for kepala keluarga NIK: $kepalaKeluargaId');
        final warga = _wargaList.firstWhere(
          (w) => w['nik']?.toString() == kepalaKeluargaId,
          orElse: () => {},
        );
        print('Found warga: ${warga['namaWarga']} with NIK: ${warga['nik']}');
        kepalaKeluargaNama = warga['namaWarga']?.toString() ?? 'NIK: $kepalaKeluargaId';
        kepalaKeluargaNik = kepalaKeluargaId;
        isKepalaKeluargaMissing = false;
      }
    } else {
      print('Kepala keluarga not found in response');
    }

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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        namaKeluarga,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: [
                          if (rumahAlamat == null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade100,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.orange.shade300),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.home_outlined, size: 12, color: Colors.orange.shade700),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Rumah belum diisi',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.orange.shade900,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (isKepalaKeluargaMissing)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.red.shade100,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.red.shade300),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.person_outline, size: 12, color: Colors.red.shade700),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Kepala keluarga belum diisi',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.red.shade900,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
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
            if (rumahAlamat != null)
              _buildInfoRow('Alamat Rumah', rumahAlamat),
            const SizedBox(height: 8),
            if (!isKepalaKeluargaMissing)
              _buildInfoRow('Kepala Keluarga', kepalaKeluargaNama),
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
