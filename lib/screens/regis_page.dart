import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
//import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:moclienapp/screens/login_page.dart';
import 'package:moclienapp/screens/pilih_lokasi_page.dart';
//import 'package:moclienapp/screens/pilih_role_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3C6EEF),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Registrasi",
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF3C6EEF),
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Buat akun untuk menggunakan layanan aplikasi MoClean",
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 25),

                  // Nama
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: "Nama Pengguna",
                      labelStyle: GoogleFonts.poppins(fontSize: 13),
                      filled: true,
                      fillColor: const Color(0xFFF1F1F1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(Icons.person_outline),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Kata Sandi
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Kata Sandi",
                      labelStyle: GoogleFonts.poppins(fontSize: 13),
                      filled: true,
                      fillColor: const Color(0xFFF1F1F1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: const Icon(Icons.visibility_off_outlined),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Nomor Telepon
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: "Nomor Telepon",
                      labelStyle: GoogleFonts.poppins(fontSize: 13),
                      filled: true,
                      fillColor: const Color(0xFFF1F1F1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(Icons.phone_android_outlined),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Alamat (buka peta)
                  GestureDetector(
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PilihLokasiPage(),
                        ),
                      );
                      if (result != null) {
                        setState(() {
                          _alamatController.text = result.toString();
                        });
                      }
                    },
                    child: AbsorbPointer(
                      child: TextField(
                        controller: _alamatController,
                        decoration: InputDecoration(
                          labelText: "Alamat",
                          labelStyle: GoogleFonts.poppins(fontSize: 13),
                          hintText: "Pilih lokasi di peta",
                          filled: true,
                          fillColor: const Color(0xFFF1F1F1),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: const Icon(Icons.location_on_outlined),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // Tombol Lanjut
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LoginPage(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3C6EEF),
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        "Lanjut",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                  Center(
                    child: Text(
                      "Saya menyetujui Ketentuan layanan & Kebijakan Privasi MoClean",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: Colors.black54,
                        fontSize: 11,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
