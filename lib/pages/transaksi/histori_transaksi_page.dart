import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pbl_jawara_test/services/transaksi_service.dart';
import 'package:pbl_jawara_test/utils/user_storage.dart';

class HistoriTransaksiPage extends StatefulWidget {
  const HistoriTransaksiPage({super.key});

  @override
  State<HistoriTransaksiPage> createState() => _HistoriTransaksiPageState();
}

class _HistoriTransaksiPageState extends State<HistoriTransaksiPage> {
  TransaksiService? _transaksiService;
  List<Map<String, dynamic>> _transaksiList = [];
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
      _transaksiService = TransaksiService(token: _token);
      final result = await _transaksiService!.getMyTransactions();

      if (mounted) {
        setState(() {
          if (result['success'] == true && result['data'] != null) {
            final responseData = result['data'];
            if (responseData is Map && responseData['data'] is List) {
              _transaksiList = List<Map<String, dynamic>>.from(responseData['data']);
            } else if (responseData is List) {
              _transaksiList = List<Map<String, dynamic>>.from(responseData);
            } else {
              _transaksiList = [];
            }
          } else {
            _transaksiList = [];
          }
          _isLoading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _transaksiList = [];
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
      return DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String? status) {
    switch (status?.toLowerCase()) {
      case 'completed':
        return 'Selesai';
      case 'pending':
        return 'Pending';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return status ?? 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Histori Transaksi',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF00B894),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _transaksiList.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.receipt_long,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Belum ada transaksi',
                        style: TextStyle(
                          fontSize: 18,
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
                    itemCount: _transaksiList.length,
                    itemBuilder: (context, index) {
                      final transaksi = _transaksiList[index];
                      final marketplace = transaksi['marketPlace'];
                      final user = transaksi['user'];
                      
                      // Format tanggal untuk judul
                      String tanggalText = '';
                      try {
                        final createdAtStr = transaksi['created_at']?.toString() ?? '';
                        if (createdAtStr.isNotEmpty) {
                          final createdAt = DateTime.parse(createdAtStr);
                          tanggalText = DateFormat('dd/MM/yyyy').format(createdAt);
                        } else {
                          tanggalText = DateFormat('dd/MM/yyyy').format(DateTime.now());
                        }
                      } catch (e) {
                        print('Error parsing date: $e');
                        tanggalText = DateFormat('dd/MM/yyyy').format(DateTime.now());
                      }
                      
                      final namaBarang = marketplace?['namaProduk']?.toString() ?? 'Produk';
                      final judulTransaksi = 'Transaksi $namaBarang - $tanggalText';
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            _showTransactionDetail(transaksi);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header with status
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        judulTransaksi,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(transaksi['status']),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        _getStatusText(transaksi['status']),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(height: 24),
                                
                                // Marketplace item info
                                if (marketplace != null) ...[
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.shopping_bag,
                                        size: 20,
                                        color: Color(0xFF00B894),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          marketplace['namaProduk'] ?? '-',
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                ],
                                
                                // Quantity and price
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.shopping_cart,
                                      size: 18,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Jumlah: ${transaksi['jumlah'] ?? 0}',
                                      style: TextStyle(
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.attach_money,
                                      size: 18,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Harga Satuan: ${_formatCurrency(transaksi['harga_satuan'])}',
                                      style: TextStyle(
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                
                                // Total price
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF00B894).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Total Harga',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                      Text(
                                        _formatCurrency(transaksi['total_harga']),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Color(0xFF00B894),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                
                                // Date
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.access_time,
                                      size: 16,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _formatDate(transaksi['created_at']),
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  void _showTransactionDetail(Map<String, dynamic> transaksi) {
    final marketplace = transaksi['marketPlace'];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Detail Transaksi #${transaksi['id']}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Status', _getStatusText(transaksi['status'])),
              const Divider(),
              
              if (marketplace != null) ...[
                const Text(
                  'Informasi Produk',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 8),
                _buildDetailRow('Nama Produk', marketplace['namaProduk'] ?? '-'),
                _buildDetailRow('Penjual', marketplace['gambar'] ?? '-'),
                const Divider(),
              ],
              
              const Text(
                'Informasi Pembelian',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 8),
              _buildDetailRow('Jumlah', '${transaksi['jumlah']} pcs'),
              _buildDetailRow('Harga Satuan', _formatCurrency(transaksi['harga_satuan'])),
              _buildDetailRow('Total Harga', _formatCurrency(transaksi['total_harga'])),
              const Divider(),
              
              _buildDetailRow('Tanggal Transaksi', _formatDate(transaksi['created_at'])),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
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
          const Text(': '),
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
      ),
    );
  }
}
