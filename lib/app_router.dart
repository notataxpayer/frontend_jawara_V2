import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pbl_jawara_test/pages/auth/login_page.dart';
import 'package:pbl_jawara_test/pages/auth/register_page.dart';
import 'package:pbl_jawara_test/pages/home_dashboard_page.dart';
import 'package:pbl_jawara_test/pages/user_management/user_management_page.dart';
import 'package:pbl_jawara_test/pages/user_management/add_user_page.dart';
import 'package:pbl_jawara_test/pages/user_management/edit_user_page.dart';
import 'package:pbl_jawara_test/pages/user_management/user_detail_page.dart';
import 'package:pbl_jawara_test/pages/warga_rumah/data_warga_rumah_page.dart';
import 'package:pbl_jawara_test/pages/warga_rumah/warga/warga_page.dart';
import 'package:pbl_jawara_test/pages/warga_rumah/warga/warga_detail_page.dart';
import 'package:pbl_jawara_test/pages/warga_rumah/warga/warga_form_page.dart';
import 'package:pbl_jawara_test/pages/warga_rumah/rumah/rumah_page.dart';
import 'package:pbl_jawara_test/pages/warga_rumah/rumah/rumah_detail_page.dart';
import 'package:pbl_jawara_test/pages/warga_rumah/rumah/rumah_form_page.dart';
import 'package:pbl_jawara_test/pages/admin/keluarga_page.dart';
import 'package:pbl_jawara_test/pages/admin/keluarga_form_page.dart';
import 'package:pbl_jawara_test/pages/admin/rumah_admin_page.dart';
import 'package:pbl_jawara_test/pages/admin/rumah_admin_form_page.dart';
import 'package:pbl_jawara_test/pages/admin/marketplace_admin_page.dart';
import 'package:pbl_jawara_test/pages/admin/marketplace_form_page.dart';
import 'package:pbl_jawara_test/pages/warga/marketplace_warga_page.dart';
import 'package:pbl_jawara_test/pages/transaksi/histori_transaksi_page.dart';
import 'package:pbl_jawara_test/pages/warga/warga_self_register_page.dart';
import 'package:pbl_jawara_test/pages/admin/verification_warga_page.dart';
import 'package:pbl_jawara_test/utils/user_storage.dart';

import 'screen/pemasukan/menu_pemasukan.dart';
import 'screen/pemasukan/kategori_iuran.dart';
import 'screen/pemasukan/detail_kategori_iuran.dart';
import 'screen/pemasukan/tagih_iuran_page.dart';
import 'screen/pemasukan/daftar_tagihan.dart';
import 'screen/pemasukan/detail_tagihan.dart';
import 'screen/pemasukan/daftar_pemasukan.dart';
import 'screen/pemasukan/detail_pemasukan.dart';

final appRouter = GoRouter(
  initialLocation: '/login',
  routes: <GoRoute>[
    // ====== Autentikasi ======
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/register',
      name: 'register',
      builder: (context, state) => const RegisterPage(),
    ),
    // ====== Home Dashboard ======
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => const HomeDashboardPage(),
    ),
    // ====== Warga Self Register ======
    GoRoute(
      path: '/warga-self-register',
      name: 'warga-self-register',
      builder: (context, state) => const _WargaSelfRegisterWrapper(),
    ),
    // ====== Verifikasi Data Warga (Admin Only) ======
    GoRoute(
      path: '/verification-warga',
      name: 'verification-warga',
      builder: (context, state) => const VerificationWargaPage(),
    ),
    // ====== Manajemen Pengguna ======
    GoRoute(
      path: '/user-management',
      name: 'user-management',
      builder: (context, state) => const UserManagementPage(),
    ),
    GoRoute(
      path: '/user-management/add',
      name: 'user-management-add',
      builder: (context, state) => const AddUserPage(),
    ),
    GoRoute(
      path: '/user-management/edit/:id',
      name: 'user-management-edit',
      builder: (context, state) {
        final userId = state.pathParameters['id']!;
        return EditUserPage(userId: userId);
      },
    ),
    GoRoute(
      path: '/user-management/detail/:id',
      name: 'user-management-detail',
      builder: (context, state) {
        final userId = state.pathParameters['id']!;
        return UserDetailPage(userId: userId);
      },
    ),
    // ====== Popup Menu ======
    GoRoute(
      path: '/menu-popup',
      name: 'menu-popup',
      builder: (context, state) => Scaffold(
        backgroundColor: Colors.black.withOpacity(0.5),
        body: Center(),
      ),
    ),
    // ====== Menu Pemasukan ======
    GoRoute(
      path: '/menu-pemasukan',
      name: 'menu-pemasukan',
      builder: (context, state) => const MenuPemasukan(),
    ),
    GoRoute(
      path: '/kategori-iuran',
      name: 'kategori-iuran',
      builder: (context, state) => const KategoriIuran(),
    ),
    GoRoute(
      path: '/detail-kategori',
      name: 'detail-kategori',
      builder: (context, state) {
        final data = state.extra as Map<String, String>;
        return DetailKategoriIuran(kategoriData: data);
      },
    ),
    GoRoute(
      path: '/tagih-iuran',
      name: 'tagih-iuran',
      builder: (context, state) => const TagihIuranPage(),
    ),
    GoRoute(
      path: '/daftar-tagihan',
      name: 'daftar-tagihan',
      builder: (context, state) => const DaftarTagihan(),
    ),
    GoRoute(
      path: '/daftar-pemasukan',
      name: 'daftar-pemasukan',
      builder: (context, state) => const DaftarPemasukan(),
    ),
    GoRoute(
      path: '/detail-pemasukan',
      name: 'detail-pemasukan',
      builder: (context, state) {
        final data = state.extra as Map<String, String>;
        return DetailPemasukan(pemasukanData: data);
      },
    ),
    GoRoute(
      path: '/detail-tagihan',
      name: 'detail-tagihan',
      builder: (context, state) {
        final data = state.extra as Map<String, String>;
        return DetailTagihan(kategoriData: data);
      },
    ),
    
    // ====== Data Warga & Rumah Hub ======
    GoRoute(
      path: '/data-warga-rumah',
      name: 'data-warga-rumah',
      builder: (context, state) => const DataWargaRumahPage(),
    ),
    // ====== Warga Management ======
    GoRoute(
      path: '/warga',
      name: 'warga',
      builder: (context, state) => const WargaPage(),
    ),
    GoRoute(
      path: '/warga/add',
      name: 'warga-add',
      builder: (context, state) => const WargaFormPage(),
    ),
    GoRoute(
      path: '/warga/edit/:id',
      name: 'warga-edit',
      builder: (context, state) {
        final wargaId = state.pathParameters['id']!;
        return WargaFormPage(wargaId: wargaId);
      },
    ),
    GoRoute(
      path: '/warga/detail/:id',
      name: 'warga-detail',
      builder: (context, state) {
        final wargaId = state.pathParameters['id']!;
        return WargaDetailPage(wargaId: wargaId);
      },
    ),
    // ====== Rumah Management ======
    GoRoute(
      path: '/rumah',
      name: 'rumah',
      builder: (context, state) => const RumahPage(),
    ),
    GoRoute(
      path: '/rumah/add',
      name: 'rumah-add',
      builder: (context, state) => const RumahFormPage(),
    ),
    GoRoute(
      path: '/rumah/edit/:id',
      name: 'rumah-edit',
      builder: (context, state) {
        final rumahId = state.pathParameters['id']!;
        return RumahFormPage(rumahId: rumahId);
      },
    ),
    GoRoute(
      path: '/rumah/detail/:id',
      name: 'rumah-detail',
      builder: (context, state) {
        final rumahId = state.pathParameters['id']!;
        return RumahDetailPage(rumahId: rumahId);
      },
    ),
    // ====== Keluarga Management (Admin Only) ======
    GoRoute(
      path: '/kelola-keluarga',
      name: 'kelola-keluarga',
      builder: (context, state) => const _KeluargaPageWrapper(),
    ),
    GoRoute(
      path: '/kelola-keluarga/tambah',
      name: 'kelola-keluarga-tambah',
      builder: (context, state) => const _KeluargaFormWrapper(),
    ),
    GoRoute(
      path: '/kelola-keluarga/edit/:id',
      name: 'kelola-keluarga-edit',
      builder: (context, state) {
        final keluargaData = state.extra as Map<String, dynamic>?;
        return _KeluargaFormWrapper(
          keluargaData: keluargaData,
          isEdit: true,
        );
      },
    ),
    // ====== Rumah Management (Admin Only) ======
    GoRoute(
      path: '/kelola-rumah',
      name: 'kelola-rumah',
      builder: (context, state) => const _RumahAdminPageWrapper(),
    ),
    GoRoute(
      path: '/kelola-rumah/tambah',
      name: 'kelola-rumah-tambah',
      builder: (context, state) => const _RumahAdminFormWrapper(),
    ),
    GoRoute(
      path: '/kelola-rumah/edit/:id',
      name: 'kelola-rumah-edit',
      builder: (context, state) {
        final rumahData = state.extra as Map<String, dynamic>?;
        return _RumahAdminFormWrapper(
          rumahData: rumahData,
          isEdit: true,
        );
      },
    ),
    
    // Marketplace routes
    GoRoute(
      path: '/marketplace',
      name: 'marketplace',
      builder: (context, state) => const _MarketplaceWargaPageWrapper(),
    ),
    GoRoute(
      path: '/kelola-marketplace',
      name: 'kelola-marketplace',
      builder: (context, state) => const _MarketplaceAdminPageWrapper(),
    ),
    GoRoute(
      path: '/kelola-marketplace/tambah',
      name: 'kelola-marketplace-tambah',
      builder: (context, state) => const _MarketplaceFormWrapper(),
    ),
    GoRoute(
      path: '/kelola-marketplace/edit/:id',
      name: 'kelola-marketplace-edit',
      builder: (context, state) {
        final itemData = state.extra as Map<String, dynamic>?;
        return _MarketplaceFormWrapper(
          itemData: itemData,
          isEdit: true,
        );
      },
    ),
    
    // Transaksi routes
    GoRoute(
      path: '/histori-transaksi',
      name: 'histori-transaksi',
      builder: (context, state) => const HistoriTransaksiPage(),
    ),
  ],
);

// Wrapper widget for WargaSelfRegisterPage
class _WargaSelfRegisterWrapper extends StatelessWidget {
  const _WargaSelfRegisterWrapper();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: UserStorage.getToken(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        final token = snapshot.data ?? '';
        return WargaSelfRegisterPage(token: token);
      },
    );
  }
}

// Wrapper widget for KeluargaPage
class _KeluargaPageWrapper extends StatelessWidget {
  const _KeluargaPageWrapper();

  @override
  Widget build(BuildContext context) {
    return const KeluargaPage();
  }
}

// Wrapper widget for KeluargaFormPage
class _KeluargaFormWrapper extends StatelessWidget {
  final Map<String, dynamic>? keluargaData;
  final bool isEdit;

  const _KeluargaFormWrapper({
    this.keluargaData,
    this.isEdit = false,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: UserStorage.getToken(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        final token = snapshot.data ?? '';
        return KeluargaFormPage(
          token: token,
          keluargaData: keluargaData,
          isEdit: isEdit,
        );
      },
    );
  }
}

// Wrapper widget for RumahAdminPage
class _RumahAdminPageWrapper extends StatelessWidget {
  const _RumahAdminPageWrapper();

  @override
  Widget build(BuildContext context) {
    return const RumahAdminPage();
  }
}

// Wrapper widget for RumahAdminFormPage
class _RumahAdminFormWrapper extends StatelessWidget {
  final Map<String, dynamic>? rumahData;
  final bool isEdit;

  const _RumahAdminFormWrapper({
    this.rumahData,
    this.isEdit = false,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: UserStorage.getToken(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        final token = snapshot.data ?? '';
        return RumahAdminFormPage(
          token: token,
          rumahData: rumahData,
          isEdit: isEdit,
        );
      },
    );
  }
}

// Wrapper widget for MarketplaceWargaPage
class _MarketplaceWargaPageWrapper extends StatelessWidget {
  const _MarketplaceWargaPageWrapper();

  @override
  Widget build(BuildContext context) {
    return const MarketplaceWargaPage();
  }
}

// Wrapper widget for MarketplaceAdminPage
class _MarketplaceAdminPageWrapper extends StatelessWidget {
  const _MarketplaceAdminPageWrapper();

  @override
  Widget build(BuildContext context) {
    return const MarketplaceAdminPage();
  }
}

// Wrapper widget for MarketplaceFormPage
class _MarketplaceFormWrapper extends StatelessWidget {
  final Map<String, dynamic>? itemData;
  final bool isEdit;

  const _MarketplaceFormWrapper({
    this.itemData,
    this.isEdit = false,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: UserStorage.getToken(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        final token = snapshot.data ?? '';
        return MarketplaceFormPage(
          token: token,
          itemData: itemData,
          isEdit: isEdit,
        );
      },
    );
  }
}


