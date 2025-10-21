import 'dart:async';
import 'package:flutter/material.dart';
import 'package:moclienapp/screens/home_page.dart'; // nanti ganti dengan halaman utama kamu

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Setelah 3 detik pindah ke halaman utama
    Timer(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF3C6EEF), // warna biru seperti di gambar
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Spacer(),
            // logo di tengah
            Center(
              child: Image.asset(
                'assets/logo.png', // ganti sesuai nama file logomu
                width: 200,
                height: 200,
              ),
            ),
            Spacer(),
            // teks "From GOTO"
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Column(
                children: [
                  Text(
                    "From",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "GOTO",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
