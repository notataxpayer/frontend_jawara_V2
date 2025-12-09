import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pbl_jawara_test/services/warga_service.dart';
import 'package:pbl_jawara_test/services/marketplace_service.dart';
import 'package:pbl_jawara_test/utils/user_storage.dart';

class LogAktivitasSection extends StatefulWidget {
  const LogAktivitasSection({super.key});

  @override
  State<LogAktivitasSection> createState() => _LogAktivitasSectionState();
}

class _LogAktivitasSectionState extends State<LogAktivitasSection> {

  bool _isLoading = true;
  bool _isAdmin = false;
  String? _latestUserName;
  String? _latestMarketplaceName;
  DateTime? _latestMarketplaceCreatedAt;
  DateTime? _latestUserCreatedAt;

  @override
  void initState() {
    super.initState();
    _loadLatestActivities();
  }

  Future<void> _loadLatestActivities() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Check if user is admin
      final userData = await UserStorage.getUserData();
      final role = userData?['role'] as String?;
      _isAdmin = role == 'admin' || role == 'super_admin' || role == 'adminSistem';
      
      print('User role: $role');
      print('Is admin: $_isAdmin');

      final token = await UserStorage.getToken();
      if (token == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Fetch latest marketplace item (for all roles)
      final marketplaceService = MarketplaceService(token: token);
      final marketplaceResult = await marketplaceService.getAllItems();
      
      if (marketplaceResult['success'] == true && marketplaceResult['data'] != null) {
        final responseData = marketplaceResult['data'];
        List items = [];
        
        if (responseData is Map && responseData['data'] is List) {
          items = responseData['data'] as List;
        } else if (responseData is List) {
          items = responseData;
        }
        
        if (items.isNotEmpty) {
          // Sort by created_at descending and get the latest
          items.sort((a, b) {
            final aDate = DateTime.tryParse(a['created_at'] ?? '') ?? DateTime(1970);
            final bDate = DateTime.tryParse(b['created_at'] ?? '') ?? DateTime(1970);
            return bDate.compareTo(aDate);
          });
          _latestMarketplaceName = items.first['namaProduk'] ?? 'Item Baru';
          _latestMarketplaceCreatedAt = DateTime.tryParse(items.first['created_at'] ?? '');
        }
      }

      // Fetch latest user (admin only)
      if (_isAdmin) {
        final wargaService = WargaService();
        final wargaResult = await wargaService.getAllWargaFromApi(token);
        
        if (wargaResult['success'] == true && wargaResult['data'] != null) {
          final responseData = wargaResult['data'];
          List users = [];
          
          if (responseData is Map && responseData['data'] is List) {
            users = responseData['data'] as List;
          } else if (responseData is List) {
            users = responseData;
          }
          
          if (users.isNotEmpty) {
            // Sort by created_at descending and get the latest
            users.sort((a, b) {
              final aDate = DateTime.tryParse(a['created_at'] ?? '') ?? DateTime(1970);
              final bDate = DateTime.tryParse(b['created_at'] ?? '') ?? DateTime(1970);
              return bDate.compareTo(aDate);
            });
            _latestUserName = users.first['namaWarga'] ?? 'User Baru';
            _latestUserCreatedAt = DateTime.tryParse(users.first['created_at'] ?? '');
            
            print('Latest user: $_latestUserName');
            print('Latest user created at: $_latestUserCreatedAt');
          }
        }
      }
    } catch (e) {
      print('Error loading latest activities: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Build logs based on fetched data
    final logs = <Map<String, dynamic>>[];
    final now = DateTime.now();
    
    if (_isAdmin && _latestUserName != null) {
      // Check if user was added within last 24 hours
      String userText;
      if (_latestUserCreatedAt != null) {
        final difference = now.difference(_latestUserCreatedAt!);
        if (difference.inHours < 24) {
          userText = 'User $_latestUserName baru saja ditambahkan';
        } else {
          userText = 'User yang terakhir kali ditambahkan: $_latestUserName';
        }
      } else {
        userText = 'User $_latestUserName berhasil ditambahkan';
      }
      
      logs.add({
        'icon': FontAwesomeIcons.userGroup,
        'text': userText,
      });
    }
    
    if (_latestMarketplaceName != null) {
      // Check if item was added within last 24 hours
      String marketplaceText;
      if (_latestMarketplaceCreatedAt != null) {
        final difference = now.difference(_latestMarketplaceCreatedAt!);
        if (difference.inHours < 24) {
          marketplaceText = 'Barang "$_latestMarketplaceName" baru saja ditambahkan';
        } else {
          marketplaceText = 'Barang yang terakhir kali ditambahkan: "$_latestMarketplaceName"';
        }
      } else {
        marketplaceText = 'Barang "$_latestMarketplaceName" baru ditambahkan';
      }
      
      logs.add({
        'icon': FontAwesomeIcons.cartShopping,
        'text': marketplaceText,
      });
    }

    const cardColor = Color(0xFF00B894); // warna hijau toska

    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (logs.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Log Aktivitas', style: theme.textTheme.titleLarge),
            Text(
              'Detail',
              style: theme.textTheme.bodyMedium!.copyWith(
                color: cardColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // List log
        Column(
          children: logs.map((log) {
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              height: 65, // ✅ tinggi seragam untuk semua item
              child: Row(
                children: [
                  // Kotak ikon
                  Container(
                    width: 65,
                    height: double.infinity, // ✅ biar sejajar penuh
                    decoration: const BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        bottomLeft: Radius.circular(12),
                      ),
                    ),
                    child: Center(
                      child: FaIcon(
                        log['icon'] as IconData,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),

                  const SizedBox(width: 6), // ✅ jarak antar kotak
                  // Kotak teks
                  Expanded(
                    child: Container(
                      height: double.infinity, // ✅ tinggi sama
                      decoration: const BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        log['text'] as String,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
