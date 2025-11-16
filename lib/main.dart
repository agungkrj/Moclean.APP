import 'package:flutter/material.dart';
import 'package:moclienapp/fiturr/riwayat_pesanan_page.dart';
import 'package:moclienapp/mitra/order_teknis_page.dart';
import 'package:moclienapp/screens/splash_page.dart';
import 'package:moclienapp/fiturr/beranda_page.dart';
//import 'package:moclienapp/fiturr/aktivitas_page.dart';
import 'package:moclienapp/fiturr/profil_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MoClean App',
      // halaman pertama kali muncul
      home: SplashScreen(),

      // daftar rute navigasi
      routes: {
        '/beranda': (context) => const BerandaPage(),
        '/riwayat': (context) => const RiwayatPesananPage(),
        '/order_teknisi': (context) => const OrderTeknisiPage(),
        //'/aktivitas': (context) => const AktivitasPage(),
        '/profil': (context) => const ProfilPage(),
      },
    );
  }
}
