import 'package:flutter/material.dart';
import 'package:moclienapp/screens/pilih_role_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3C6EEF), // warna biru khas MoClean
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),

                // Judul sambutan
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Selamat Datang di\nMoClean!",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
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
                    'assets/carwash.png',
                    width: 280,
                    height: 180,
                    fit: BoxFit.contain,
                  ),
                ),

                const SizedBox(height: 30),

                // Deskripsi singkat
                const Text(
                  "Solusi cuci mobil cepat, bersih, dan praktis.\n"
                  "Kami datang langsung ke lokasi kamu!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 50),

                // Tombol mulai / masuk
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PilihRolePage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 4,
                  ),
                  child: const Text(
                    "Mulai Sekarang",
                    style: TextStyle(
                      color: Color(0xFF3C6EEF),
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Footer teks
                const Text(
                  "Dengan melanjutkan, kamu menyetujui\nKetentuan Layanan & Kebijakan Privasi MoClean.",
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
