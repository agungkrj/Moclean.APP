import 'package:flutter/material.dart';
import 'package:moclienapp/admin/beranda_admin.dart';
import 'admin_bottom_navbar.dart';

class KelolaLanggananPage extends StatefulWidget {
  const KelolaLanggananPage({super.key});

  @override
  State<KelolaLanggananPage> createState() => _KelolaLanggananPageState();
}

class _KelolaLanggananPageState extends State<KelolaLanggananPage> {
  int selectedIndex = 2; // posisi tab "Langganan"

  // ================= BOTTOM NAV FUNCTION =================
  void _onItemTapped(int index) {
    if (index == selectedIndex) return;

    setState(() {
      selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.push(context, MaterialPageRoute(builder: (context) => AdminDashboardPage()));
        break;

      case 1:
         Navigator.push(context, MaterialPageRoute(builder: (context) => KelolaLanggananPage()));
        break;

      case 2:
        // tetap di halaman ini
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // ================= APP BAR =================
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back, color: Colors.black),
        ),
        title: const Text(
          "Kelola Langganan",
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      // ================= BODY =================
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            promoSection("Promo 1"),
            const SizedBox(height: 20),
            promoSection("Promo 2"),
          ],
        ),
      ),

      // ================= BOTTOM NAVBAR =================
      bottomNavigationBar: AdminBottomNavBar(
        selectedIndex: selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

  // ================= PROMO CARD (UI) =================
  Widget promoSection(String promoTitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          promoTitle,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),

        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFFE9EBFF),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildInput("Nama Promo", "masukkan nama promo"),
              const SizedBox(height: 16),

              buildInput("Harga Awal", "masukkan harga"),
              const SizedBox(height: 16),

              buildInput("Harga Promo", "masukkan harga"),
              const SizedBox(height: 16),

              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5669FF),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 26, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Atur",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  // ================= INPUT FIELD (UI) =================
  Widget buildInput(String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        TextField(
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
                color: Colors.grey, fontSize: 14),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF5669FF)),
            ),
          ),
        ),
      ],
    );
  }
}
