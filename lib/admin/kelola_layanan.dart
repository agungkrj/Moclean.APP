import 'package:flutter/material.dart';
import 'package:moclienapp/admin/beranda_admin.dart';
import 'package:moclienapp/admin/kelola_langganan_page.dart';
import 'admin_bottom_navbar.dart'; // Import navbar admin

class KelolaLayananPage extends StatefulWidget {
  const KelolaLayananPage({Key? key}) : super(key: key);

  @override
  State<KelolaLayananPage> createState() => _KelolaLayananPageState();
}

class _KelolaLayananPageState extends State<KelolaLayananPage> {
  int _selectedIndex = 1; // Index 1 untuk Mitra

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
         Navigator.push(context, MaterialPageRoute(builder: (context) => AdminDashboardPage()));
        break;
      case 1:
        // Sudah di halaman mitra/layanan
        break;
      case 2:
         Navigator.push(context, MaterialPageRoute(builder: (context) => KelolaLanggananPage()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Kelola layanan',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Cuci Interior
          _buildServiceCard(
            title: 'Cuci Interior',
            hargaSekarang: 'Rp. 135.000,00',
            ubahHargaHint: 'masukkan harga',
          ),

          const SizedBox(height: 16),

          // Cuci Eksterior
          _buildServiceCard(
            title: 'Cuci Eksterior',
            hargaSekarang: 'Rp. 80.000,00',
            ubahHargaHint: 'masukkan harga',
          ),

          const SizedBox(height: 16),

          // Cuci Komplit
          _buildServiceCard(
            title: 'Cuci Komplit',
            hargaSekarang: 'Rp. 80.000,00',
            ubahHargaHint: 'masukkan harga',
          ),

          const SizedBox(height: 80),
        ],
      ),
      bottomNavigationBar: AdminBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

  Widget _buildServiceCard({
    required String title,
    required String hargaSekarang,
    required String ubahHargaHint,
  }) {
    final TextEditingController hargaController = TextEditingController();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8EBFF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 12),

          // Harga Sekarang
          const Text(
            'Harga Sekarang',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            hargaSekarang,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 12),

          // Ubah Harga
          const Text(
            'Ubah Harga',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),

          // Input & Button Row
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: hargaController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: ubahHargaHint,
                    hintStyle: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF9E9E9E),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFEEEEEE)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: Color(0xFF5669FF),
                        width: 1.5,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  if (hargaController.text.isNotEmpty) {
                    _showSuccessDialog(title, hargaController.text);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Masukkan harga terlebih dahulu'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5669FF),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  minimumSize: const Size(60, 40),
                ),
                child: const Text(
                  'Atur',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String layanan, String hargaBaru) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFFE8EBFF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Color(0xFF5669FF),
                  size: 48,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Berhasil!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Harga $layanan berhasil diubah menjadi Rp. $hargaBaru',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Refresh data atau update state
                  setState(() {});
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5669FF),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  'OK',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}