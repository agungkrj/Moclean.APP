// main.dart yang sudah dimodifikasi untuk mendukung Login Admin + Navigasi

import 'package:flutter/material.dart';
import 'package:moclienapp/fiturr/aktivitas.dart';
import 'package:moclienapp/fiturr/riwayat_pesanan_page.dart';
import 'package:moclienapp/mitra/BerandaMitra.dart';
import 'package:moclienapp/mitra/order_teknis_page.dart';
import 'package:moclienapp/mitra/profile_mitra.dart';
import 'package:moclienapp/screens/pilih_role_page.dart';
import 'package:moclienapp/screens/splash_page.dart';
import 'package:moclienapp/fiturr/beranda_page.dart';
import 'package:moclienapp/fiturr/profil_page.dart';
import 'package:moclienapp/mitra/regis_mitra.dart';

// Import halaman login admin
import 'package:moclienapp/admin/login_admin.dart';
import 'package:moclienapp/admin/beranda_admin.dart';

// Firebase
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Locale
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Init Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await initializeDateFormatting('id_ID', null);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MoClean App',

      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: const Color(0xFF5B7FDB),
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // Splash sebagai halaman pertama
      home: SplashScreen(),

      routes: {
        '/beranda': (context) => const BerandaPage(),
        '/riwayat': (context) => const RiwayatPesananPage(),
        '/order_teknisi': (context) => const OrderTeknisiPage(),
        '/profil': (context) => const ProfilPage(),
        '/registrasi_mitra': (context) => const RegistrasiMitraPage(),
        '/Aktifitas': (context) => const AktifitasScreen(),
        '/profilmitra': (context) => const ProfileMitraPage(),
         '/berandamitra': (context) => const BerandaMitra(),
         '/pilihrole': (context) => const PilihRolePage(),
        

        // Admin
        '/login_admin': (context) => const LoginAdminPage(),
        '/admin_dashboard': (context) => const AdminDashboardPage(),
      },
    );
  }
}
