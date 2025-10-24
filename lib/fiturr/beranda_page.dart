import 'package:flutter/material.dart';
import 'package:moclienapp/fiturr/detail_page.dart';
import 'navbar.dart';

class BerandaPage extends StatefulWidget {
  const BerandaPage({super.key});

  @override
  State<BerandaPage> createState() => _BerandaPageState();
}

class _BerandaPageState extends State<BerandaPage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔵 HEADER
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 25,
                ),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF4169E1), Color(0xFF1E3A8A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Judul & avatar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "MoClean",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              "Halo, Park Jisung",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Center(
                            child: Text(
                              "PJ",
                              style: TextStyle(
                                color: Color(0xFF4169E1),
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // PROMO CARD dengan ilustrasi
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF5B9BF3),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          // Ilustrasi orang kiri
                          Container(
                            width: 60,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                            ),
                            child: Stack(
                              children: [
                                // Kepala
                                Positioned(
                                  top: 0,
                                  left: 15,
                                  child: Container(
                                    width: 30,
                                    height: 30,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFFFDBCC),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                                // Rambut
                                Positioned(
                                  top: 0,
                                  left: 10,
                                  child: Container(
                                    width: 40,
                                    height: 20,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF1A1A1A),
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(20),
                                        topRight: Radius.circular(20),
                                      ),
                                    ),
                                  ),
                                ),
                                // Badan (baju merah/orange)
                                Positioned(
                                  top: 28,
                                  left: 10,
                                  child: Container(
                                    width: 40,
                                    height: 52,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFF5733),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                                // HP di tangan
                                Positioned(
                                  top: 40,
                                  left: 18,
                                  child: Container(
                                    width: 15,
                                    height: 25,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1A5FB4),
                                      borderRadius: BorderRadius.circular(3),
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Teks promo
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    "Promo Untuk Kamu",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    "Cuci mobil 3 kali,\nbonus 1 kali cuci gratis\nmenanti!",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Ilustrasi orang kanan
                          Container(
                            width: 60,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                            ),
                            child: Stack(
                              children: [
                                // Kepala
                                Positioned(
                                  top: 0,
                                  left: 15,
                                  child: Container(
                                    width: 30,
                                    height: 30,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFFFDBCC),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                                // Rambut
                                Positioned(
                                  top: 0,
                                  left: 10,
                                  child: Container(
                                    width: 40,
                                    height: 20,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF1A1A1A),
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(20),
                                        topRight: Radius.circular(20),
                                      ),
                                    ),
                                  ),
                                ),
                                // Badan (baju biru)
                                Positioned(
                                  top: 28,
                                  left: 10,
                                  child: Container(
                                    width: 40,
                                    height: 52,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1E3A8A),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // 🧽 PILIH LAYANAN MU
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "Pilih Layanan Mu",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 15),

              // HORIZONTAL SCROLLABLE LAYANAN
             SizedBox(
              height: 210, // tambahkan ruang agar muat tinggi 193
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  layananCard(Icons.local_car_wash, "Cuci Eksterior"),
                  const SizedBox(width: 15),
                  layananCard(Icons.directions_car, "Cuci Interior"),
                  const SizedBox(width: 15),
                  layananCard(Icons.car_repair, "Cuci Komplit"),
                ],
              ),
            ),

              const SizedBox(height: 20),

              // 🚗 REKOMENDASI
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "Rekomendasi",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 15),
              rekomendasiCard(),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Navbar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

  // CARD LAYANAN - SESUAI GAMBAR (bulat penuh biru dengan icon putih)
  // 🔹 LAYANAN CARD (fix overflow)
   // 🔹 LAYANAN CARD (modifikasi ukuran & warna)
  Widget layananCard(IconData icon, String title) {
  return GestureDetector(
    onTap: () {
      // Aksi jika seluruh card diklik (bukan tombol)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Kamu memilih $title'),
          duration: const Duration(seconds: 1),
        ),
      );
    },
    child: Container(
      width: 113,
      height: 193,
      margin: const EdgeInsets.only(bottom: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFDCE0F3),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(height: 5),
            Container(
              width: 96,
              height: 92,
              decoration: const BoxDecoration(
                color: Color(0xFF4169E1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 45, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () {
                // Aksi tombol Details
                Navigator.push(
                  context,
                  MaterialPageRoute(
                     builder: (_) => DetailPage(
                      title: title,
                      imagePath: 'assets/eksterio.png',),
                  ),
                );
              },
              child: Container(
                height: 28,
                width: 75,
                decoration: BoxDecoration(
                  color: const Color(0xFF4169E1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text(
                    "Details",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 5),
          ],
        ),
      ),
    ),
  );
}



  // CARD REKOMENDASI - Gambar bulat kecil di pojok atas
  Widget rekomendasiCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Card utama (warna DCE0F3)
          Container(
            margin: const EdgeInsets.only(top: 25, left: 35),
            padding: const EdgeInsets.only(
              left: 60,
              right: 16,
              top: 10,
              bottom: 10,
            ),
            width: 229, // ukuran lebar card sesuai permintaan
            height: 108, // tinggi card sesuai permintaan
            decoration: BoxDecoration(
              color: const Color(0xFFDCE0F3), // ubah warna background
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 6,
                  spreadRadius: 1,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Shiney Carwash",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: const [
                    Icon(Icons.location_on, size: 13, color: Colors.grey),
                    SizedBox(width: 3),
                    Text(
                      "3 Km",
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: const [
                    Text(
                      "Rating",
                      style: TextStyle(fontSize: 11, color: Colors.black54),
                    ),
                    SizedBox(width: 5),
                    Icon(Icons.star, color: Colors.black, size: 13),
                    Icon(Icons.star, color: Colors.black, size: 13),
                    Icon(Icons.star, color: Colors.black, size: 13),
                    Icon(Icons.star, color: Colors.black, size: 13),
                  ],
                ),
              ],
            ),
          ),

          // Gambar bulat di kiri atas card
          Positioned(
            top: 5,
            left: 0,
            child: Container(
              width: 65,
              height: 65,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 6,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.network(
                  'https://i.imgur.com/T9gC5eL.png',
                  width: 65,
                  height: 65,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 65,
                      height: 65,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE53935),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.directions_car,
                        size: 30,
                        color: Colors.white,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
