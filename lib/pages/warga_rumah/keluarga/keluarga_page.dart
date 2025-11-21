import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pbl_jawara_test/models/keluarga.dart';
import 'package:pbl_jawara_test/services/keluarga_service.dart';
import 'package:pbl_jawara_test/widgets/warga_rumah/keluarga_list_item.dart';
import 'package:pbl_jawara_test/widgets/bottom_navbar_widget.dart';

class KeluargaPage extends StatefulWidget {
  const KeluargaPage({Key? key}) : super(key: key);

  @override
  State<KeluargaPage> createState() => _KeluargaPageState();
}

class _KeluargaPageState extends State<KeluargaPage> {
  final KeluargaService _keluargaService = KeluargaService();
  late Future<List<Keluarga>> _keluargaFuture;
  final TextEditingController _searchController = TextEditingController();
  List<Keluarga> _allKeluarga = [];
  List<Keluarga> _filteredKeluarga = [];

  @override
  void initState() {
    super.initState();
    _keluargaFuture = _keluargaService.getAllKeluarga();
    _searchController.addListener(_filterKeluarga);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterKeluarga() {
    final query = _searchController.text;
    setState(() {
      if (query.isEmpty) {
        _filteredKeluarga = _allKeluarga;
      } else {
        _filteredKeluarga = _allKeluarga
            .where((keluarga) => keluarga.namaKeluarga
                .toLowerCase()
                .contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: const BottomNavbarWidget(currentIndex: 3),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00BFA5),
        elevation: 0,
        title: const Text(
          'Daftar Keluarga',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Cari nama keluarga...',
                        hintStyle: const TextStyle(color: Colors.grey),
                        prefixIcon:
                            const Icon(Icons.search, color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF00BFA5),
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () => context.push('/keluarga/add'),
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text(
                      'Tambah',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00BFA5),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<List<Keluarga>>(
                future: _keluargaFuture,
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

                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.family_restroom,
                            size: 80,
                            color: Colors.grey[300],
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
                    );
                  }

                  _allKeluarga = snapshot.data!;
                  _filteredKeluarga = _allKeluarga;

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: _filteredKeluarga.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final keluarga = _filteredKeluarga[index];
                      return KeluargaListItem(
                        keluarga: keluarga,
                        onTap: () =>
                            context.push('/keluarga/detail/${keluarga.id}'),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
