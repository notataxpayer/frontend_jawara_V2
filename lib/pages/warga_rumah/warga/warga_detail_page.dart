import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pbl_jawara_test/models/warga.dart';
import 'package:pbl_jawara_test/services/warga_service.dart';

class WargaDetailPage extends StatefulWidget {
  final String wargaId;

  const WargaDetailPage({
    Key? key,
    required this.wargaId,
  }) : super(key: key);

  @override
  State<WargaDetailPage> createState() => _WargaDetailPageState();
}

class _WargaDetailPageState extends State<WargaDetailPage> {
  final WargaService _wargaService = WargaService();
  late Future<Warga?> _wargaFuture;

  @override
  void initState() {
    super.initState();
    _wargaFuture = _wargaService.getWargaById(widget.wargaId);
  }

  void _showDeleteConfirmation(Warga warga) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Warga'),
        content: Text('Apakah Anda yakin ingin menghapus ${warga.namaWarga}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final result = await _wargaService.deleteWarga(warga.id);

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(result['message']),
                    backgroundColor:
                        result['success'] ? Colors.green : Colors.red,
                  ),
                );

                if (result['success']) {
                  context.pop();
                }
              }
            },
            child: const Text(
              'Hapus',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusLabel(String status) {
    return status == 'hidup' ? 'Hidup' : 'Meninggal';
  }

  String _displayStatusDomisili(String status) {
    switch (status) {
      case 'tetap':
        return 'Tetap';
      case 'kontrak':
        return 'Kontrak';
      case 'pindah':
        return 'Pindah';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF00BFA5),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Detail Warga',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<Warga?>(
        future: _wargaFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Color(0xFF00BFA5),
                ),
              ),
            );
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: Text('Error: ${snapshot.error ?? 'Data tidak ditemukan'}'),
            );
          }

          final warga = snapshot.data!;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: CircleAvatar(
                              radius: 40,
                              backgroundColor: const Color(0xFF00BFA5),
                              child: Text(
                                warga.avatarInitial,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 32,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Center(
                            child: Text(
                              warga.namaWarga,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF171d1b),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: warga.statusHidup == 'hidup'
                                    ? Colors.green.withOpacity(0.15)
                                    : Colors.grey.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _getStatusLabel(warga.statusHidup),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: warga.statusHidup == 'hidup'
                                      ? Colors.green
                                      : Colors.grey,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          _buildDetailField('Nomor ID', warga.id),
                          _buildDetailField('Nama Warga', warga.namaWarga),
                          _buildDetailField('NIK', warga.nik),
                          _buildDetailField(
                              'Nama Keluarga', warga.namaKeluarga),
                          _buildDetailField(
                              'Jenis Kelamin', warga.jenisKelamin),
                          _buildDetailField(
                            'Status Domisili',
                            _displayStatusDomisili(warga.statusDomisili),
                          ),
                          _buildDetailField(
                            'Status Hidup',
                            _getStatusLabel(warga.statusHidup),
                          ),
                          if (warga.keluargaId != null)
                            _buildDetailField('ID Keluarga', warga.keluargaId!),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () =>
                              context.push('/warga/edit/${warga.id}'),
                          icon: const Icon(Icons.edit, color: Colors.white),
                          label: const Text(
                            'Edit',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD4AF37),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _showDeleteConfirmation(warga),
                          icon: const Icon(Icons.delete, color: Colors.white),
                          label: const Text(
                            'Hapus',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF171d1b),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 1,
            color: Colors.grey[200],
          ),
        ],
      ),
    );
  }
}
