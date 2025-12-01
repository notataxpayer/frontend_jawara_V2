import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pbl_jawara_test/utils/user_storage.dart';
import 'package:pbl_jawara_test/widgets/menu_popup.dart';

class BottomNavbarWidget extends StatefulWidget {
  const BottomNavbarWidget({super.key, required int currentIndex});

  @override
  State<BottomNavbarWidget> createState() => _BottomNavbarWidgetState();
}

class _BottomNavbarWidgetState extends State<BottomNavbarWidget> {
  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/marketplace') || location.startsWith('/kelola-marketplace')) return 1;
    if (location.startsWith('/menu-popup')) return 2;
    if (location.startsWith('/user-management')) return 3;
    return 0;
  }

  void _onItemTapped(int index) async {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        // Navigate to marketplace - check user role
        final userData = await UserStorage.getUserData();
        final userRole = userData?['role']?.toString();
        final isAdmin = userRole == 'adminSistem' || 
                       userRole == 'ketuaRT' || 
                       userRole == 'ketuaRW';
        
        if (context.mounted) {
          context.go(isAdmin ? '/kelola-marketplace' : '/marketplace');
        }
        break;
      case 2:
        showMenuPopUp(context); // ✅ ganti ini
        break;
      case 3:
        // pengguna
        context.go('/user-management');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = [
      {'icon': Icons.home_rounded, 'label': 'Home'},
      {'icon': Icons.shopping_bag_outlined, 'label': 'Marketplace'},
      {'icon': Icons.apps_rounded, 'label': 'Menu'},
      {'icon': Icons.people_alt_rounded, 'label': 'Pengguna'},
    ];

    return BottomNavigationBar(
      currentIndex: _calculateSelectedIndex(context),
      onTap: _onItemTapped,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.teal,
      unselectedItemColor: Colors.grey,
      items: items
          .map(
            (e) => BottomNavigationBarItem(
              icon: Icon(e['icon'] as IconData),
              label: e['label'] as String,
            ),
          )
          .toList(),
    );
  }
}
