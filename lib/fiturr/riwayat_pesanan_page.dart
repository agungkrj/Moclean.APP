import 'package:flutter/material.dart';
import 'package:moclienapp/fiturr/beranda_page.dart';
import 'package:moclienapp/fiturr/navbar.dart';

class RiwayatPesananPage extends StatefulWidget {
  const RiwayatPesananPage({super.key});

  @override
  State<RiwayatPesananPage> createState() => _RiwayatPesananPageState();
}

class _RiwayatPesananPageState extends State<RiwayatPesananPage> {
  int _selectedIndex = 2; // posisi tab "Riwayat"

  void _onItemTapped(int index) {
  switch (index) {
    case 0:
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const BerandaPage()),
      );
      break;
    case 1:
      break;
    case 2:
      break;
    case 3:
      break;
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: const Color(0xff3D5AFE),
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
        ),
        title: const Text(
          'Riwayat Pesanan',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      bottomNavigationBar: Navbar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListView(
          children: [
            _buildSearchBar(),
            const SizedBox(height: 10),
            _buildRiwayatCard(
              tanggal: "Kamis, 02 Oktober 2025 10:00 WIB",
              idOrder: "011131442",
              idPelanggan: "0947242",
              jenisLayanan: "1x Cuci Mobil (Large)",
              status: "Selesai",
              statusColor: Colors.green,
              imageUrl:
                  "https://cdn.motor1.com/images/mgl/kW9Wz/s1/2021-toyota-vios-front.jpg",
            ),
            _buildRiwayatCard(
              tanggal: "Jumat, 30 Agustus 2025 15:00 WIB",
              idOrder: "09535334",
              idPelanggan: "0947242",
              jenisLayanan: "1x Cuci Mobil (Large)",
              status: "Dibatalkan",
              statusColor: Colors.redAccent,
              imageUrl:
                  "https://cdn.motor1.com/images/mgl/kW9Wz/s1/2021-toyota-vios-front.jpg",
            ),
            _buildRiwayatCard(
              tanggal: "Kamis, 14 Januari 2025 10:00 WIB",
              idOrder: "09000221",
              idPelanggan: "0947242",
              jenisLayanan: "1x Cuci Mobil (Large)",
              status: "Selesai",
              statusColor: Colors.green,
              imageUrl:
                  "https://cdn.motor1.com/images/mgl/kW9Wz/s1/2021-toyota-vios-front.jpg",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 45,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const TextField(
        decoration: InputDecoration(
          hintText: "Cari Riwayat Pesanan Berdasarkan Tanggal",
          prefixIcon: Icon(Icons.search),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildRiwayatCard({
    required String tanggal,
    required String idOrder,
    required String idPelanggan,
    required String jenisLayanan,
    required String status,
    required Color statusColor,
    required String imageUrl,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xffEAEAFF),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // header tanggal
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: Text(
              tanggal,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // isi kartu
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    imageUrl,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "ID Order: $idOrder",
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text("ID Pelanggan: $idPelanggan"),
                      Text("Jenis Layanan: $jenisLayanan"),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Text(
                            "Status Pesanan: ",
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          Text(
                            status,
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: Colors.white,
                              side: const BorderSide(color: Colors.blueAccent),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () {},
                            child: const Text(
                              "Lihat Penilaian",
                              style: TextStyle(
                                color: Colors.blueAccent,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () {},
                            child: const Text(
                              "Pesan Ulang",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
