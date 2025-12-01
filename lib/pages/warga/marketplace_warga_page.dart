import 'package:flutter/material.dart';
import 'package:pbl_jawara_test/services/marketplace_service.dart';
import 'package:pbl_jawara_test/utils/user_storage.dart';

class MarketplaceWargaPage extends StatefulWidget {
  const MarketplaceWargaPage({super.key});

  @override
  State<MarketplaceWargaPage> createState() => _MarketplaceWargaPageState();
}

class _MarketplaceWargaPageState extends State<MarketplaceWargaPage> {
  MarketplaceService? _marketplaceService;
  List<Map<String, dynamic>> _itemList = [];
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
      _marketplaceService = MarketplaceService(token: _token);
      final result = await _marketplaceService!.getAllItems();

      if (mounted) {
        setState(() {
          if (result['success'] == true && result['data'] != null) {
            final responseData = result['data'];
            if (responseData is Map && responseData['data'] is List) {
              _itemList = List<Map<String, dynamic>>.from(responseData['data']);
            } else if (responseData is List) {
              _itemList = List<Map<String, dynamic>>.from(responseData);
            } else {
              _itemList = [];
            }
          } else {
            _itemList = [];
          }
          _isLoading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _itemList = [];
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Marketplace',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF6A1B9A),
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
                    'Memuat data marketplace...',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            )
          : _itemList.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_bag_outlined,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Belum ada item tersedia',
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
                    itemCount: _itemList.length,
                    itemBuilder: (context, index) {
                      return _buildItemCard(_itemList[index]);
                    },
                  ),
                ),
    );
  }

  Widget _buildItemCard(Map<String, dynamic> data) {
    final namaProduk = data['namaProduk']?.toString() ?? 'N/A';
    final harga = data['harga']?.toString() ?? '0';
    final deskripsi = data['deskripsi']?.toString() ?? '';
    final gambar = data['gambar']?.toString();

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (gambar != null && gambar.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                gambar,
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
          
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  namaProduk,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Rp ${_formatPrice(harga)}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  deskripsi,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatPrice(String price) {
    try {
      final number = int.parse(price);
      return number.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]}.',
      );
    } catch (e) {
      return price;
    }
  }
}
