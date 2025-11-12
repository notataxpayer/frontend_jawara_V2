import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/pemasukan_filter.dart';

class DaftarPemasukan extends StatelessWidget {
  const DaftarPemasukan({super.key});

  final List<Map<String, String>> _pemasukanData = const [
    {"no": "1", "nama": "Iuran Warga", "jenis": "Iuran", "tanggal": "15 Okt 2025", "nominal": "Rp 500.000"},
    {"no": "2", "nama": "Sumbangan Acara", "jenis": "Sumbangan", "tanggal": "14 Okt 2025", "nominal": "Rp 750.000"},
    {"no": "3", "nama": "Sewa Lapangan", "jenis": "Sewa Aset", "tanggal": "12 Okt 2025", "nominal": "Rp 300.000"},
  ];

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Filter Pemasukan"),
          content: const PemasukanFilter(),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
            ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text("Cari")),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        title: const Text("Daftar Pemasukan", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(icon: const Icon(Icons.filter_list), onPressed: () => _showFilterDialog(context)),
          IconButton(icon: const Icon(Icons.add), onPressed: () => context.push('/tambah-pemasukan')),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: DataTable2(
          columnSpacing: 12,
          horizontalMargin: 12,
          headingRowColor: MaterialStateProperty.all(colorScheme.primary.withOpacity(0.1)),
          columns: const [
            DataColumn2(label: Text('No')),
            DataColumn2(label: Text('Nama')),
            DataColumn2(label: Text('Nominal'), numeric: true),
          ],
          rows: _pemasukanData.map((item) {
            return DataRow2(
              onTap: () => context.push('/detail-pemasukan-all', extra: item),
              cells: [
                DataCell(Text(item['no']!)),
                DataCell(Text(item['nama']!)),
                DataCell(Text(item['nominal']!, style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.bold))),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
