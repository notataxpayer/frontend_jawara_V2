import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pbl_jawara_test/services/verification_service.dart';
import 'package:pbl_jawara_test/utils/user_storage.dart';

class VerificationWargaPage extends StatefulWidget {
  const VerificationWargaPage({super.key});

  @override
  State<VerificationWargaPage> createState() => _VerificationWargaPageState();
}

class _VerificationWargaPageState extends State<VerificationWargaPage> {
  final _verificationService = VerificationService();
  List<dynamic> _allVerifications = [];
  List<dynamic> _filteredVerifications = [];
  bool _isLoading = true;
  String? _token;
  String _selectedFilter = 'all'; // all, pending, approved, rejected

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
      final result = await _verificationService.getAllVerifications(_token!);
      
      print('===== VERIFICATION DATA DEBUG =====');
      print('Result success: ${result['success']}');
      print('Result data type: ${result['data'].runtimeType}');
      if (result['data'] is List) {
        print('Data count: ${(result['data'] as List).length}');
        if ((result['data'] as List).isNotEmpty) {
          print('First item: ${(result['data'] as List).first}');
          print('Status values: ${(result['data'] as List).map((e) => e['status']).toList()}');
        }
      }
      print('====================================');
      
      if (mounted) {
        setState(() {
          if (result['success'] == true && result['data'] != null) {
            _allVerifications = result['data'] is List ? result['data'] : [];
            _applyFilter();
          } else {
            _allVerifications = [];
            _filteredVerifications = [];
          }
          _isLoading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _allVerifications = [];
          _filteredVerifications = [];
          _isLoading = false;
        });
      }
    }
  }

  void _applyFilter() {
    setState(() {
      if (_selectedFilter == 'all') {
        _filteredVerifications = _allVerifications;
      } else {
        _filteredVerifications = _allVerifications.where((item) {
          final status = item['status']?.toString().toLowerCase() ?? '';
          
          switch (_selectedFilter) {
            case 'pending':
              return status == 'pending';
            case 'approved':
              // Handle both 'approved' and 'accepted' dari backend
              return status == 'approved' || status == 'accepted';
            case 'rejected':
              return status == 'rejected';
            default:
              return true;
          }
        }).toList();
      }
      
      print('Filter applied: $_selectedFilter');
      print('Total all: ${_allVerifications.length}');
      print('Filtered: ${_filteredVerifications.length}');
    });
  }

  void _changeFilter(String filter) {
    setState(() {
      _selectedFilter = filter;
      _applyFilter();
    });
  }

  Future<void> _handleApprove(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: const Text('Apakah Anda yakin ingin menyetujui verifikasi ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Setujui'),
          ),
        ],
      ),
    );

    if (confirm == true && _token != null) {
      final result = await _verificationService.approveVerification(_token!, id);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Verifikasi disetujui'),
            backgroundColor: result['success'] == true ? Colors.green : Colors.red,
          ),
        );

        if (result['success'] == true) {
          _loadData(); // Reload data
        }
      }
    }
  }

  Future<void> _handleReject(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: const Text('Apakah Anda yakin ingin menolak verifikasi ini?'),
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
            child: const Text('Tolak'),
          ),
        ],
      ),
    );

    if (confirm == true && _token != null) {
      final result = await _verificationService.rejectVerification(_token!, id);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Verifikasi ditolak'),
            backgroundColor: result['success'] == true ? Colors.orange : Colors.red,
          ),
        );

        if (result['success'] == true) {
          _loadData(); // Reload data
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Verifikasi Data Warga',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF00BFA5),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Filter Tabs
          Container(
            color: Colors.white,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  _buildFilterChip('Semua', 'all'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Pending', 'pending'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Disetujui', 'approved'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Ditolak', 'rejected'),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          
          // Content
          Expanded(
            child: _isLoading
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text(
                          'Memuat data warga yang perlu diverifikasi...',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : _filteredVerifications.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inbox_outlined,
                              size: 80,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Tidak ada data verifikasi',
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
                          itemCount: _filteredVerifications.length,
                          itemBuilder: (context, index) {
                            final verification = _filteredVerifications[index];
                            return _buildVerificationCard(verification);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          _changeFilter(value);
        }
      },
      backgroundColor: Colors.grey[200],
      selectedColor: const Color(0xFF00BFA5),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      checkmarkColor: Colors.white,
    );
  }

  Widget _buildVerificationCard(Map<String, dynamic> data) {
    // Extract extra_data if exists (might be string JSON or already a Map)
    Map<String, dynamic>? extraData;
    
    if (data['extra_data'] != null) {
      if (data['extra_data'] is String) {
        try {
          extraData = jsonDecode(data['extra_data']) as Map<String, dynamic>;
        } catch (e) {
          print('Error parsing extra_data: $e');
        }
      } else if (data['extra_data'] is Map) {
        extraData = data['extra_data'] as Map<String, dynamic>;
      }
    }
    
    final status = data['status']?.toString() ?? 'pending';
    
    // Warna berdasarkan status
    Color statusColor;
    Color cardBorderColor;
    Color cardBackgroundColor;
    
    if (status == 'approved' || status == 'accepted') {
      statusColor = Colors.green;
      cardBorderColor = Colors.green;
      cardBackgroundColor = Colors.green.shade50;
    } else if (status == 'rejected') {
      statusColor = Colors.red;
      cardBorderColor = Colors.red;
      cardBackgroundColor = Colors.red.shade50;
    } else {
      // pending
      statusColor = Colors.orange;
      cardBorderColor = Colors.orange;
      cardBackgroundColor = Colors.white;
    }

    // Get data from extra_data or fallback to main data
    final nik = data['nik_baru']?.toString() ?? data['nik']?.toString() ?? 'N/A';
    final namaWarga = data['namaWarga_baru']?.toString() ?? data['namaWarga']?.toString() ?? 'N/A';
    final jenisKelamin = extraData?['jenisKelamin']?.toString() ?? data['jenisKelamin']?.toString() ?? 'N/A';
    final statusDomisili = extraData?['statusDomisili']?.toString() ?? data['statusDomisili']?.toString() ?? 'N/A';
    final statusHidup = extraData?['statusHidup']?.toString() ?? data['statusHidup']?.toString() ?? 'N/A';
    final userId = data['user_id']?.toString() ?? data['userId']?.toString() ?? 'N/A';
    final fotoKtp = extraData?['foto_ktp']?.toString() ?? data['foto_ktp']?.toString();

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      color: cardBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: cardBorderColor,
          width: 2,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border(
            left: BorderSide(
              color: cardBorderColor,
              width: 6,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header dengan status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      namaWarga,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: statusColor),
                    ),
                    child: Text(
                      status.toUpperCase(),
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
                const Divider(height: 24),
              
              // Data warga
              _buildInfoRow('Nama Warga', namaWarga),
              const SizedBox(height: 8),
              _buildInfoRow('NIK', nik),
              const SizedBox(height: 8),
              _buildInfoRow('Jenis Kelamin', jenisKelamin),
              const SizedBox(height: 8),
              _buildInfoRow('Status Domisili', statusDomisili),
              const SizedBox(height: 8),
              _buildInfoRow('Status Hidup', statusHidup),
              const SizedBox(height: 8),
                _buildInfoRow('User ID', userId),
              
              // Foto KTP
              if (fotoKtp != null) ...[
                const SizedBox(height: 16),
                const Text(
                  'Foto KTP:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    fotoKtp,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 200,
                        color: Colors.grey[200],
                        child: const Center(
                          child: Icon(Icons.error_outline, size: 48),
                        ),
                      );
                    },
                  ),
                ),
              ],
              
              // Action buttons (hanya tampil jika status pending)
              if (status == 'pending') ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _handleReject(data['id']),
                        icon: const Icon(Icons.close),
                        label: const Text('Tolak'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _handleApprove(data['id']),
                        icon: const Icon(Icons.check),
                        label: const Text('Setujui'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
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
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
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
