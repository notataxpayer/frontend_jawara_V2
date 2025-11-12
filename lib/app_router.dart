import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pbl_jawara_test/pages/auth/login_page.dart';
import 'package:pbl_jawara_test/pages/auth/register_page.dart';
import 'package:pbl_jawara_test/pages/home_dashboard_page.dart';

import 'screen/pemasukan/menu_pemasukan.dart';
import 'screen/pemasukan/kategori_iuran.dart';
import 'screen/pemasukan/detail_kategori_iuran.dart';
import 'screen/pemasukan/tagih_iuran_page.dart';
import 'screen/pemasukan/daftar_tagihan.dart';
import 'screen/pemasukan/detail_tagihan.dart';
import 'screen/pemasukan/daftar_pemasukan.dart';
import 'screen/pemasukan/tambah_pemasukan.dart';

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
    // ====== Popup Menu ======
    GoRoute(
      path: '/menu-popup',
      name: 'menu-popup',
      builder: (context, state) => Scaffold(
        backgroundColor: Colors.black.withOpacity(0.5),
        body: Center(),
      ),
    ),
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
      path: '/tambah-pemasukan',
      name: 'tambah-pemasukan',
      builder: (context, state) => const TambahPemasukan(),
    ),
  ],
);


