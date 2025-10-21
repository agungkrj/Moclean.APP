import 'package:flutter/material.dart';
import 'package:moclienapp/screens/splash_page.dart'; // panggil halaman lain

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Contoh Aplikasi',
      home: SplashScreen(), // ini menentukan tampilan awal
    );
  }
}
