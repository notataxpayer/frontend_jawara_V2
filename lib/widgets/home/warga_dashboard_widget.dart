import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pbl_jawara_test/services/warga_service.dart';
import 'package:pbl_jawara_test/services/transaksi_service.dart';
import 'package:pbl_jawara_test/utils/user_storage.dart';

class WargaDashboardWidget extends StatefulWidget {
  const WargaDashboardWidget({super.key});

  @override
  State<WargaDashboardWidget> createState() => _WargaDashboardWidgetState();
}

class _WargaDashboardWidgetState extends State<WargaDashboardWidget> {
  bool _isLoading = true;
  Map<String, dynamic>? _wargaData;
  List<Map<String, dynamic>> _recentTransactions = [];
  int _totalTransactions = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final token = await UserStorage.getToken();
      if (token == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Get warga profile
      final wargaService = WargaService();
      final wargaResult = await wargaService.getMyWargaProfile(token);
      
      if (wargaResult['success'] == true && wargaResult['data'] != null) {
        _wargaData = wargaResult['data'];
      }

      // Get recent transactions
      final transaksiService = TransaksiService(token: token);
      final transaksiResult = await transaksiService.getMyTransactions();
      
      if (transaksiResult['success'] == true && transaksiResult['data'] != null) {
        final responseData = transaksiResult['data'];
        List allTransactions = [];
        
        if (responseData is Map && responseData['data'] is List) {
          allTransactions = responseData['data'] as List;
        } else if (responseData is List) {
          allTransactions = responseData;
        }
        
        _totalTransactions = allTransactions.length;
        // Get last 3 transactions
        _recentTransactions = allTransactions.take(3).map((e) => e as Map<String, dynamic>).toList();
      }
    } catch (e) {
      print('Error loading warga dashboard data: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _formatCurrency(dynamic value) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    
    if (value is int) {
      return formatter.format(value);
    } else if (value is String) {
      return formatter.format(int.tryParse(value) ?? 0);
    }
    return 'Rp 0';
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '-';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy', 'id_ID').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Profil Warga Card
        if (_wargaData != null) _buildProfileCard(),
        
        const SizedBox(height: 20),
        
        // Quick Access Menu
        _buildQuickAccessMenu(),
        
        const SizedBox(height: 20),
        
        // Recent Transactions
        if (_recentTransactions.isNotEmpty) _buildRecentTransactions(),
      ],
    );
  }

  Widget _buildProfileCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF00B894), Color(0xFF00D2A0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 35,
                    color: Color(0xFF00B894),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Profil Warga',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _wargaData?['namaWarga']?.toString() ?? 'N/A',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: Colors.white30),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.credit_card, 'NIK', _wargaData?['nik']?.toString() ?? '-'),
            const SizedBox(height: 8),
            _buildInfoRow(
              _wargaData?['jenisKelamin']?.toString() == 'Laki-laki' 
                ? Icons.male 
                : Icons.female,
              'Jenis Kelamin',
              _wargaData?['jenisKelamin']?.toString() ?? '-'
            ),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.home, 'Status Domisili', _wargaData?['statusDomisili']?.toString() ?? '-'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.white70),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAccessMenu() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Menu Cepat',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMenuCard(
                icon: Icons.shopping_bag,
                title: 'Marketplace',
                color: const Color(0xFF00B894),
                onTap: () => context.go('/marketplace'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMenuCard(
                icon: Icons.receipt_long,
                title: 'Transaksi',
                subtitle: '$_totalTransactions transaksi',
                color: const Color(0xFF6C5CE7),
                onTap: () => context.go('/histori-transaksi'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    String? subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
                textAlign: TextAlign.center,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentTransactions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Transaksi Terbaru',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () => context.go('/histori-transaksi'),
              child: const Text('Lihat Semua'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ..._recentTransactions.map((transaksi) {
          final marketplace = transaksi['marketPlace'];
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF00B894).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.shopping_cart,
                  color: Color(0xFF00B894),
                  size: 20,
                ),
              ),
              title: Text(
                marketplace?['namaProduk'] ?? 'Item',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                _formatDate(transaksi['created_at']),
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              trailing: Text(
                _formatCurrency(transaksi['total_harga']),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00B894),
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }
}
