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
import 'package:pbl_jawara_test/pages/warga_rumah/keluarga/keluarga_page.dart';
import 'package:pbl_jawara_test/pages/warga_rumah/keluarga/keluarga_detail_page.dart';
import 'package:pbl_jawara_test/pages/warga_rumah/keluarga/keluarga_form_page.dart';

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
    // ====== Keluarga Management ======
    GoRoute(
      path: '/keluarga',
      name: 'keluarga',
      builder: (context, state) => const KeluargaPage(),
    ),
    GoRoute(
      path: '/keluarga/add',
      name: 'keluarga-add',
      builder: (context, state) => const KeluargaFormPage(),
    ),
    GoRoute(
      path: '/keluarga/edit/:id',
      name: 'keluarga-edit',
      builder: (context, state) {
        final keluargaId = state.pathParameters['id']!;
        return KeluargaFormPage(keluargaId: keluargaId);
      },
    ),
    GoRoute(
      path: '/keluarga/detail/:id',
      name: 'keluarga-detail',
      builder: (context, state) {
        final keluargaId = state.pathParameters['id']!;
        return KeluargaDetailPage(keluargaId: keluargaId);
      }
    ),
  ],
);


