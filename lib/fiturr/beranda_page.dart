import 'package:flutter/material.dart';
import 'package:moclienapp/fiturr/detail_page.dart';
import 'package:moclienapp/fiturr/detail_cuci_interior.dart';
import 'package:moclienapp/fiturr/cuci_komplit_page.dart';
import 'navbar.dart';

class BerandaPage extends StatefulWidget {
  const BerandaPage({super.key});

  @override
  State<BerandaPage> createState() => _BerandaPageState();
}

class _BerandaPageState extends State<BerandaPage> {
  int _selectedIndex = 0; // posisi tab "Riwayat"

  void _onItemTapped(int index) {
  switch (index) {
    case 0:
      break;
    case 1:
      break;
    case 2:
      Navigator.pushReplacementNamed(context, '/riwayat');
      break;
    case 3:
      Navigator.pushReplacementNamed(context, '/profil');
      break;
  }
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
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
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
                    // 🔹 Nama & Avatar
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

                   // 🎉 PROMO CARD (gradasi atas–bawah dan teks rapi)
Container(
  width: double.infinity,
  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
  decoration: BoxDecoration(
    gradient: const LinearGradient(
      colors: [Color(0xFF1E40AF), Color(0xFF5B9BF3)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter, // ⬅️ arah gradasi vertikal
    ),
    borderRadius: BorderRadius.circular(20),
  ),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      // 🧍‍♀️ Gambar kiri
      Image.asset(
        'assets/orangkiri.png',
        width: 90,
        height: 100,
        fit: BoxFit.contain,
      ),

      // 📝 Teks promo di tengah
      Expanded(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                "Promo Untuk Kamu",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Cuci mobil 3 kali,\nbonus 1 kali cuci gratis\nmenanti!",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),

      // 🧍‍♂️ Gambar kanan
      Image.asset(
        'assets/orangkanan.png',
        width: 90,
        height: 100,
        fit: BoxFit.contain,
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
                height: 210,
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

  // 🔹 LAYANAN CARD
  Widget layananCard(IconData icon, String title) {
    return GestureDetector(
      onTap: () {
        Widget nextPage;
        if (title == "Cuci Eksterior") {
          nextPage = const DetailPage();
        } else if (title == "Cuci Interior") {
          nextPage = const DetailCuciInteriorPage();
        } else {
          nextPage = const CuciKomplitPage();
        }
        Navigator.push(context, MaterialPageRoute(builder: (_) => nextPage));
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
              Container(
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
              const SizedBox(height: 5),
            ],
          ),
        ),
      ),
    );
  }

  // 🔹 REKOMENDASI CARD
  Widget rekomendasiCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 25, left: 35),
            padding: const EdgeInsets.only(left: 60, right: 16, top: 10, bottom: 10),
            width: 229,
            height: 108,
            decoration: BoxDecoration(
              color: const Color(0xFFDCE0F3),
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
                    Text("Rating", style: TextStyle(fontSize: 11, color: Colors.black54)),
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
                child: Image.asset(
                  'assets/car.png',
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
