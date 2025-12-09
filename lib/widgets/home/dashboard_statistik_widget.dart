import 'package:flutter/material.dart';
import 'package:pbl_jawara_test/services/warga_service.dart';
import 'package:pbl_jawara_test/services/rumah_api_service.dart';
import 'package:pbl_jawara_test/services/keluarga_api_service.dart';
import 'package:pbl_jawara_test/services/marketplace_service.dart';
import 'package:pbl_jawara_test/utils/user_storage.dart';

class DashboardStatistikWidget extends StatefulWidget {
  const DashboardStatistikWidget({super.key});

  @override
  State<DashboardStatistikWidget> createState() => _DashboardStatistikWidgetState();
}

class _DashboardStatistikWidgetState extends State<DashboardStatistikWidget> {
  bool _isLoading = true;
  bool _isAdmin = false;
  int _jumlahWarga = 0;
  int _jumlahRumah = 0;
  int _jumlahKeluarga = 0;
  int _jumlahMarketplace = 0;

  @override
  void initState() {
    super.initState();
    _loadStatistik();
  }

  Future<void> _loadStatistik() async {
    try {
      final userData = await UserStorage.getUserData();
      final userRole = userData?['role']?.toString();
      final token = await UserStorage.getToken();
      
      // Cek apakah admin
      _isAdmin = userRole == 'adminSistem' || 
                 userRole == 'ketuaRT' || 
                 userRole == 'ketuaRW';
      
      if (!_isAdmin || token == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Load semua data statistik
      final wargaService = WargaService();
      final rumahService = RumahApiService(token: token);
      final keluargaService = KeluargaApiService(token: token);
      final marketplaceService = MarketplaceService(token: token);

      final results = await Future.wait([
        wargaService.getAllWargaFromApi(token),
        rumahService.getAllRumah(),
        keluargaService.getAllKeluarga(),
        marketplaceService.getAllItems(),
      ]);

      if (mounted) {
        setState(() {
          // Parse warga
          if (results[0]['success'] == true && results[0]['data'] != null) {
            final responseData = results[0]['data'];
            if (responseData is Map && responseData['data'] is List) {
              _jumlahWarga = (responseData['data'] as List).length;
            } else if (responseData is List) {
              _jumlahWarga = responseData.length;
            }
          }
          
          // Parse rumah
          if (results[1]['success'] == true && results[1]['data'] != null) {
            final responseData = results[1]['data'];
            if (responseData is Map && responseData['data'] is List) {
              _jumlahRumah = (responseData['data'] as List).length;
            } else if (responseData is List) {
              _jumlahRumah = responseData.length;
            }
          }
          
          // Parse keluarga
          if (results[2]['success'] == true && results[2]['data'] != null) {
            final responseData = results[2]['data'];
            if (responseData is Map && responseData['data'] is List) {
              _jumlahKeluarga = (responseData['data'] as List).length;
            } else if (responseData is List) {
              _jumlahKeluarga = responseData.length;
            }
          }
          
          // Parse marketplace
          if (results[3]['success'] == true && results[3]['data'] != null) {
            final responseData = results[3]['data'];
            if (responseData is Map && responseData['data'] is List) {
              _jumlahMarketplace = (responseData['data'] as List).length;
            } else if (responseData is List) {
              _jumlahMarketplace = responseData.length;
            }
          }
          
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      print('Error loading statistik: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Jika bukan admin, jangan tampilkan statistik
    if (!_isAdmin) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 8)],
      ),
      padding: const EdgeInsets.only(top: 24, bottom: 24, left: 16, right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Dashboard Statistik",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _isLoading
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(),
                  ),
                )
              : Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _buildStatCard(
                      icon: Icons.people_alt_outlined,
                      label: 'Total Warga',
                      value: _jumlahWarga.toString(),
                      color: Colors.blue,
                    ),
                    _buildStatCard(
                      icon: Icons.home_outlined,
                      label: 'Total Rumah',
                      value: _jumlahRumah.toString(),
                      color: Colors.orange,
                    ),
                    _buildStatCard(
                      icon: Icons.family_restroom,
                      label: 'Total Keluarga',
                      value: _jumlahKeluarga.toString(),
                      color: Colors.teal,
                    ),
                    _buildStatCard(
                      icon: Icons.shopping_bag_outlined,
                      label: 'Item Marketplace',
                      value: _jumlahMarketplace.toString(),
                      color: Colors.purple,
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const Spacer(),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
