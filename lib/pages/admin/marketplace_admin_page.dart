import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pbl_jawara_test/services/marketplace_service.dart';
import 'package:pbl_jawara_test/utils/user_storage.dart';

class MarketplaceAdminPage extends StatefulWidget {
  const MarketplaceAdminPage({super.key});

  @override
  State<MarketplaceAdminPage> createState() => _MarketplaceAdminPageState();
}

class _MarketplaceAdminPageState extends State<MarketplaceAdminPage> {
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

  Future<void> _handleDelete(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: const Text('Apakah Anda yakin ingin menghapus item ini?'),
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
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true && _token != null) {
      final result = await _marketplaceService!.deleteItem(id.toString());

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Item dihapus'),
          backgroundColor: result['success'] == true ? Colors.green : Colors.red,
        ),
      );

      if (result['success'] == true) {
        _loadData();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Kelola Marketplace',
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
                        'Belum ada item marketplace',
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await context.push('/kelola-marketplace/tambah');
          if (result == true) {
            _loadData();
          }
        },
        backgroundColor: const Color(0xFF6A1B9A),
        // icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('+', style: TextStyle(color: Colors.white),),
      ),
    );
  }

  Widget _buildItemCard(Map<String, dynamic> data) {
    final id = data['id'];
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        namaProduk,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    PopupMenuButton(
                      icon: const Icon(Icons.more_vert),
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 20),
                              SizedBox(width: 8),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 20, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Hapus', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                      onSelected: (value) async {
                        if (value == 'edit') {
                          final result = await context.push(
                            '/kelola-marketplace/edit/$id',
                            extra: data,
                          );
                          if (result == true) {
                            _loadData();
                          }
                        } else if (value == 'delete') {
                          _handleDelete(id);
                        }
                      },
                    ),
                  ],
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
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
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
