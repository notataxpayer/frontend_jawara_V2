import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pbl_jawara_test/utils/user_storage.dart';

class KegiatanPage extends StatefulWidget {
  const KegiatanPage({super.key});

  @override
  State<KegiatanPage> createState() => _KegiatanPageState();
}

class _KegiatanPageState extends State<KegiatanPage> {
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _checkUserRole();
  }

  Future<void> _checkUserRole() async {
    final role = await UserStorage.getUserRole();
    setState(() {
      _isAdmin = role == 'admin' || role == 'super_admin' || role == 'adminSistem';
    });
  }

  @override
  Widget build(BuildContext context) {
    // Dummy data kegiatan
    final kegiatanList = [
      {
        'judul': 'Muncak Bromo',
        'tanggal': '29 November 2025',
        'deskripsi': 'Kegiatan pendakian bersama ke Gunung Bromo untuk mempererat tali silaturahmi antar warga.',
        'gambar': 'https://images.unsplash.com/photo-1588668214407-6ea9a6d8c272?ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&q=80&w=871',
        'lokasi': 'Gunung Bromo, Jawa Timur',
        'peserta': '45 warga',
      },
      {
        'judul': 'Touring Warga',
        'tanggal': '29 Desember 2025',
        'deskripsi': 'Touring bersama menggunakan sepeda motor menuju pantai selatan untuk refreshing.',
        'gambar': 'https://images.unsplash.com/photo-1551632811-561732d1e306?auto=format&fit=crop&w=800&q=80',
        'lokasi': 'Pantai Parangtritis',
        'peserta': '32 warga',
      },
      {
        'judul': 'Kerja Bakti Lingkungan',
        'tanggal': '20 Desember 2025',
        'deskripsi': 'Gotong royong membersihkan lingkungan RT dan penanaman pohon.',
        'gambar': 'https://images.unsplash.com/photo-1559827260-dc66d52bef19?auto=format&fit=crop&w=800&q=80',
        'lokasi': 'Lingkungan RT 05',
        'peserta': '68 warga',
      },
      {
        'judul': 'Lomba 17 Agustus',
        'tanggal': '17 Agustus 2025',
        'deskripsi': 'Perayaan HUT RI dengan berbagai lomba tradisional untuk seluruh warga.',
        'gambar': 'https://images.unsplash.com/photo-1511895426328-dc8714191300?auto=format&fit=crop&w=800&q=80',
        'lokasi': 'Lapangan RT',
        'peserta': '120 warga',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
        title: const Text(
          'Kegiatan Warga',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF00B894),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: kegiatanList.length,
        itemBuilder: (context, index) {
          final kegiatan = kegiatanList[index];
          return _buildKegiatanCard(context, kegiatan);
        },
      ),
      floatingActionButton: _isAdmin
          ? FloatingActionButton(
              onPressed: () => _showAddKegiatanDialog(context),
              backgroundColor: const Color(0xFF00B894),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  void _showAddKegiatanDialog(BuildContext context) {
    final judulController = TextEditingController();
    final tanggalController = TextEditingController();
    final lokasiController = TextEditingController();
    final pesertaController = TextEditingController();
    final deskripsiController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Kegiatan Warga'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: judulController,
                decoration: const InputDecoration(
                  labelText: 'Judul Kegiatan',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: tanggalController,
                decoration: const InputDecoration(
                  labelText: 'Tanggal',
                  hintText: 'Contoh: 29 November 2025',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: lokasiController,
                decoration: const InputDecoration(
                  labelText: 'Lokasi',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: pesertaController,
                decoration: const InputDecoration(
                  labelText: 'Jumlah Peserta',
                  hintText: 'Contoh: 45 warga',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: deskripsiController,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              // Dummy action - tidak disimpan ke backend
              if (judulController.text.isNotEmpty) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Kegiatan "${judulController.text}" berhasil ditambahkan (dummy)'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00B894),
              foregroundColor: Colors.white,
            ),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  Widget _buildKegiatanCard(BuildContext context, Map<String, String> kegiatan) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image dengan overlay
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(
                  kegiatan['gambar']!,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image_not_supported, size: 64),
                    );
                  },
                ),
              ),
              // Gradient overlay
              Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
              ),
              // Title on image
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Text(
                  kegiatan['judul']!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Text(
                      kegiatan['tanggal']!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        kegiatan['lokasi']!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.people, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Text(
                      kegiatan['peserta']!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 8),
                Text(
                  kegiatan['deskripsi']!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[800],
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Detail kegiatan
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Detail ${kegiatan['judul']}')),
                      );
                    },
                    icon: const Icon(Icons.info_outline),
                    label: const Text('Lihat Detail'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00B894),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
