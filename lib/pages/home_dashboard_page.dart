import 'package:flutter/material.dart';
import 'package:pbl_jawara_test/widgets/home/dashboard_header.dart';
import 'package:pbl_jawara_test/widgets/home/dashboard_statistik_widget.dart';
// import 'package:pbl_jawara_test/widgets/home/kegiatan_section.dart';
import 'package:pbl_jawara_test/widgets/home/log_aktivitas_section.dart';
import 'package:pbl_jawara_test/widgets/home/warga_dashboard_widget.dart';
import 'package:pbl_jawara_test/widgets/bottom_navbar_widget.dart';
import 'package:pbl_jawara_test/utils/user_storage.dart';

class HomeDashboardPage extends StatefulWidget {
  const HomeDashboardPage({super.key});

  @override
  State<HomeDashboardPage> createState() => _HomeDashboardPageState();
}

class _HomeDashboardPageState extends State<HomeDashboardPage> {
  bool _isAdmin = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkUserRole();
  }

  Future<void> _checkUserRole() async {
    final userData = await UserStorage.getUserData();
    final role = userData?['role'] as String?;
    
    setState(() {
      _isAdmin = role == 'admin' || role == 'super_admin' || role == 'adminSistem';
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: const BottomNavbarWidget(currentIndex: 0),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const DashboardHeader(),
                const SizedBox(height: 24),
                
                // Admin Dashboard
                if (_isAdmin) ...[
                  const DashboardStatistikWidget(),
                  const SizedBox(height: 24),
                  const LogAktivitasSection(),
                ],
                
                // Warga Dashboard
                if (!_isAdmin) ...[
                  const WargaDashboardWidget(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
