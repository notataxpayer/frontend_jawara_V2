import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pbl_jawara_test/utils/user_storage.dart';

class BroadcastPage extends StatefulWidget {
  const BroadcastPage({super.key});

  @override
  State<BroadcastPage> createState() => _BroadcastPageState();
}

class _BroadcastPageState extends State<BroadcastPage> {
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
    // Dummy data broadcast
    final broadcastList = [
      {
        'judul': 'Pengumuman Iuran Bulanan',
        'tanggal': '12 Desember 2025',
        'deskripsi': 'Pengumuman pembayaran iuran bulanan RT periode Desember 2025. Pembayaran paling lambat tanggal 20 Desember 2025.',
        'gambar': 'https://images.unsplash.com/photo-1557804506-669a67965ba0?auto=format&fit=crop&w=800&q=80',
        'kategori': 'Keuangan',
        'dari': 'Bendahara RT',
      },
      {
        'judul': 'Info Jadwal Ronda',
        'tanggal': '10 Desember 2025',
        'deskripsi': 'Jadwal ronda malam untuk bulan Desember 2025. Mohon warga untuk hadir sesuai jadwal yang telah ditentukan.',
        'gambar': 'https://images.unsplash.com/photo-1504384308090-c894fdcc538d?auto=format&fit=crop&w=800&q=80',
        'kategori': 'Keamanan',
        'dari': 'Ketua RT',
      },
      {
        'judul': 'Pemadaman Listrik Terjadwal',
        'tanggal': '08 Desember 2025',
        'deskripsi': 'PLN akan melakukan pemadaman listrik terjadwal pada tanggal 15 Desember 2025 pukul 08.00-12.00 WIB untuk pemeliharaan jaringan.',
        'gambar': 'https://images.unsplash.com/photo-1473341304170-971dccb5ac1e?auto=format&fit=crop&w=800&q=80',
        'kategori': 'Informasi',
        'dari': 'PLN',
      },
      {
        'judul': 'Himbauan Kebersihan Lingkungan',
        'tanggal': '05 Desember 2025',
        'deskripsi': 'Himbauan kepada seluruh warga untuk menjaga kebersihan lingkungan dan membuang sampah pada tempatnya. Jadwal pengambilan sampah Senin, Rabu, Jumat.',
        'gambar': 'https://images.unsplash.com/photo-1532996122724-e3c354a0b15b?auto=format&fit=crop&w=800&q=80',
        'kategori': 'Lingkungan',
        'dari': 'Sekretaris RT',
      },
      {
        'judul': 'Undangan Rapat RT',
        'tanggal': '01 Desember 2025',
        'deskripsi': 'Undangan rapat RT untuk membahas program kerja tahun 2026. Rapat akan dilaksanakan pada tanggal 18 Desember 2025 pukul 19.00 WIB.',
        'gambar': 'https://images.unsplash.com/photo-1543269865-cbf427effbad?auto=format&fit=crop&w=800&q=80',
        'kategori': 'Rapat',
        'dari': 'Ketua RT',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
        title: const Text(
          'Broadcast',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF6C5CE7),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: broadcastList.length,
        itemBuilder: (context, index) {
          final broadcast = broadcastList[index];
          return _buildBroadcastCard(context, broadcast);
        },
      ),
      floatingActionButton: _isAdmin
          ? FloatingActionButton(
              onPressed: () => _showAddBroadcastDialog(context),
              backgroundColor: const Color(0xFF6C5CE7),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  void _showAddBroadcastDialog(BuildContext context) {
    final judulController = TextEditingController();
    final tanggalController = TextEditingController();
    final kategoriController = TextEditingController();
    final dariController = TextEditingController();
    final deskripsiController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Broadcast'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: judulController,
                decoration: const InputDecoration(
                  labelText: 'Judul Broadcast',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: tanggalController,
                decoration: const InputDecoration(
                  labelText: 'Tanggal',
                  hintText: 'Contoh: 12 Desember 2025',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: kategoriController,
                decoration: const InputDecoration(
                  labelText: 'Kategori',
                  hintText: 'Contoh: Keuangan, Keamanan, Informasi',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: dariController,
                decoration: const InputDecoration(
                  labelText: 'Dari',
                  hintText: 'Contoh: Ketua RT',
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
                    content: Text('Broadcast "${judulController.text}" berhasil ditambahkan (dummy)'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C5CE7),
              foregroundColor: Colors.white,
            ),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  Widget _buildBroadcastCard(BuildContext context, Map<String, String> broadcast) {
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
                  broadcast['gambar']!,
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
              // Gradient overlay dengan warna ungu
              Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      const Color(0xFF6C5CE7).withOpacity(0.8),
                    ],
                  ),
                ),
              ),
              // Title on image
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        broadcast['kategori']!,
                        style: const TextStyle(
                          color: Color(0xFF6C5CE7),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      broadcast['judul']!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
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
                      broadcast['tanggal']!,
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
                    Icon(Icons.person, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Text(
                      'Dari: ${broadcast['dari']}',
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
                  broadcast['deskripsi']!,
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
                      // TODO: Detail broadcast
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Detail ${broadcast['judul']}')),
                      );
                    },
                    icon: const Icon(Icons.announcement_outlined),
                    label: const Text('Lihat Detail'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C5CE7),
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
