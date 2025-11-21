import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pbl_jawara_test/models/rumah.dart';
import 'package:pbl_jawara_test/services/rumah_service.dart';

class RumahDetailPage extends StatefulWidget {
  final String rumahId;

  const RumahDetailPage({
    Key? key,
    required this.rumahId,
  }) : super(key: key);

  @override
  State<RumahDetailPage> createState() => _RumahDetailPageState();
}

class _RumahDetailPageState extends State<RumahDetailPage> {
  final RumahService _rumahService = RumahService();
  late Future<Rumah?> _rumahFuture;

  @override
  void initState() {
    super.initState();
    _rumahFuture = _rumahService.getRumahById(widget.rumahId);
  }

  void _showDeleteConfirmation(Rumah rumah) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Rumah'),
        content:
            Text('Apakah Anda yakin ingin menghapus rumah di ${rumah.alamat}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final result = await _rumahService.deleteRumah(rumah.id);

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

  String _getStatusDisplay(String status) {
    return status == 'kontrak' ? 'Kontrak' : 'Milik Sendiri';
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
          'Detail Rumah',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<Rumah?>(
        future: _rumahFuture,
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

          final rumah = snapshot.data!;

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
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color:
                                    const Color(0xFF00BFA5).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.home,
                                color: Color(0xFF00BFA5),
                                size: 48,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Center(
                            child: Text(
                              rumah.alamat,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 16,
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
                                color: rumah.statusKepemilikan == 'kontrak'
                                    ? Colors.orange.withOpacity(0.15)
                                    : Colors.green.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _getStatusDisplay(rumah.statusKepemilikan),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: rumah.statusKepemilikan == 'kontrak'
                                      ? Colors.orange
                                      : Colors.green,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          _buildDetailField('ID Rumah', rumah.id),
                          _buildDetailField('Alamat', rumah.alamat),
                          _buildDetailField(
                            'Status Kepemilikan',
                            _getStatusDisplay(rumah.statusKepemilikan),
                          ),
                          _buildDetailField(
                            'Jumlah Penghuni',
                            rumah.jumlahPenghuni.toString(),
                          ),
                          if (rumah.keluargaId != null)
                            _buildDetailField('ID Keluarga', rumah.keluargaId!),
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
                              context.push('/rumah/edit/${rumah.id}'),
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
                          onPressed: () => _showDeleteConfirmation(rumah),
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
