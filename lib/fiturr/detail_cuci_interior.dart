import 'package:flutter/material.dart';
import 'package:moclienapp/fiturr/pesan_layanan.dart';

class DetailCuciInteriorPage extends StatelessWidget {
  const DetailCuciInteriorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔷 GAMBAR FULL LEBAR
            SizedBox(
              width: double.infinity,
              height: 190,
              child: Image.asset(
                'assets/interior.png', // ✅ ganti sesuai path kamu
                fit: BoxFit.cover,
              ),
            ),

            // 🔹 BAGIAN PUTIH (LABEL)
            Center(
              child: Transform.translate(
                offset: const Offset(0, -20),
                child: Container(
                  width: 367,
                  height: 58,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    "Cuci Interior",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 🔹 DETAIL LAYANAN
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Layanan - Cuci Interior",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    "Harga",
                    style: TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                  SizedBox(height: 2),
                  Text(
                    "Rp. 135.000",
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    "Membersihkan seluruh bagian dalam mobil (interior) menggunakan vacuum cleaner dan cairan pembersih khusus interior. Mengangkat debu, kotoran, dan noda pada karpet, jok, dashboard, dan plafon mobil agar tetap bersih dan segar.",
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // 🔹 FITUR LAYANAN
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Column(
                children: [
                  buildFeature("Vacuum Interior"),
                  buildFeature("Dashboard Cleaning"),
                  buildFeature("Carpet Wash"),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // 🔹 TOMBOL PESAN SEKARANG
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PesanLayananPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4169E1),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Pesan Sekarang",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }

  // 🔹 Widget fitur
  static Widget buildFeature(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 22),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}
