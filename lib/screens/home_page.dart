import 'package:flutter/material.dart';
import 'package:moclienapp/screens/login_page.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3C6EEF), // warna biru latar
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),

                // Teks sambutan
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Selamat datang di\nMoClean !",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Gambar ilustrasi
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Image.asset(
                    'assets/carwash.png', // ganti sesuai nama file ilustrasi kamu
                    width: 300,
                    height: 180,
                    fit: BoxFit.contain,
                  ),
                ),

                const SizedBox(height: 30),

                // Deskripsi
                const Text(
                  "Aplikasi solusi cuci mobil cepat & praktis.\n"
                  "Cukup pesan, kami datang ke lokasi kamu.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 20),

                // Garis pemisah
                const Text(
                  "***",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 18,
                    letterSpacing: 2,
                  ),
                ),

                const SizedBox(height: 25),

                // Tombol Masuk
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Masuk",
                    style: TextStyle(
                      color: Color(0xFF3C6EEF),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                // Tombol daftar
                OutlinedButton(
                  onPressed: () {
                    // TODO: arahkan ke halaman registrasi
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Belum ada akun? Daftar dulu",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Teks paling bawah
                const Text(
                  "Dengan masuk atau mendaftar, kamu menyetujui Ketentuan layanan dan Kebijakan privasi",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
