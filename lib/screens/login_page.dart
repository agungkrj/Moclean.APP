import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moclienapp/fiturr/beranda_page.dart';
import 'package:moclienapp/screens/regis_page.dart';
import 'package:moclienapp/screens/pilih_role_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3C6EEF),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ===== JUDUL =====
                Text(
                  "Selamat Datang",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Masukkan HP kamu akan dipakai untuk proses verifikasi dan masuk ke akun MoClean",
                  style: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 25),

                // ===== KOTAK PUTIH =====
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ---- NOMOR TELEPON ----
                      Text(
                        "Nomor Telepon",
                        style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(13),
                        ],
                        decoration: InputDecoration(
                          prefixIcon:
                              const Icon(Icons.phone_android, color: Colors.red),
                          hintText: "+62 8xxxxxxxxxx",
                          hintStyle: GoogleFonts.poppins(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF4F4F4),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      // ---- KATA SANDI ----
                      Text(
                        "Kata Sandi",
                        style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscureText,
                        decoration: InputDecoration(
                          prefixIcon:
                              const Icon(Icons.lock_outline, color: Colors.blue),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureText
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureText = !_obscureText;
                              });
                            },
                          ),
                          hintText: "Masukkan kata sandi",
                          hintStyle: GoogleFonts.poppins(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF4F4F4),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          child: Text(
                            "Lupa Password",
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF3C6EEF),
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // ---- TOMBOL MASUK ----
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const BerandaPage(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3C6EEF),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            "Masuk",
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Expanded(child: Divider(color: Colors.black26)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              "atau",
                              style: GoogleFonts.poppins(
                                color: Colors.black54,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const Expanded(child: Divider(color: Colors.black26)),
                        ],
                      ),

                      const SizedBox(height: 10),

                      Center(
                        child: TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const RegisterPage()),
                            );
                          },
                          child: Text(
                            "Tidak punya akun? Daftar",
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF3C6EEF),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: TextButton(
                          onPressed: () {},
                          child: Text(
                            "Ada kendala atau lupa nomor?",
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF3C6EEF),
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // 🔹 TOMBOL KELUAR DI TENGAH
                      Center(
                        child: TextButton.icon(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const PilihRolePage(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.logout,
                              color: Colors.redAccent, size: 20),
                          label: Text(
                            "Keluar",
                            style: GoogleFonts.poppins(
                              color: Colors.redAccent,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: Text(
                    "Saya menyetujui Ketentuan layanan & Kebijakan Privasi MoClean",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: Colors.white.withOpacity(0.9),
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
    );
  }
}
