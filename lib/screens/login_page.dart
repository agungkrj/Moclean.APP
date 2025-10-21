import 'package:flutter/material.dart';
import 'package:moclienapp/screens/regis_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3C6EEF), // warna biru khas MoClean
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
                  // Judul
                  const Text(
                    "Masukkan nomor HP",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Masukkan HP kamu akan dipakai untuk proses verifikasi dan masuk ke akun MoClean",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 25),

                  // Username field
                  TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.person_outline),
                      hintText: "Username",
                      filled: true,
                      fillColor: const Color(0xFFEAEAEA),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Password field
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.lock_outline),
                      hintText: "Password",
                      filled: true,
                      fillColor: const Color(0xFFEAEAEA),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Lupa password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: const Text(
                        "Lupa Password",
                        style: TextStyle(color: Colors.blueGrey),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Teks bantuan
                  const Center(
                    child: Text(
                      "Ada kendala atau lupa nomor?",
                      style: TextStyle(color: Colors.black54),
                    ),
                  ),
                  const SizedBox(height: 5),

                  // Garis pemisah
                  const Row(
                    children: [
                      Expanded(child: Divider(color: Colors.black26)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text("atau"),
                      ),
                      Expanded(child: Divider(color: Colors.black26)),
                    ],
                  ),
                  const SizedBox(height: 15),

                  // Tombol login
                  ElevatedButton(
                    onPressed: () {
                      // TODO: aksi login
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3C6EEF),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Masuk",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Tombol daftar
                  OutlinedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => RegisterPage()),
                      );

                    },
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: const BorderSide(color: Color(0xFF3C6EEF)),
                    ),
                    child: const Text(
                      "Tidak punya akun? Daftar",
                      style: TextStyle(
                        color: Color(0xFF3C6EEF),
                        fontSize: 15,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Bagian bawah “From GOTO”
                  const Center(
                    child: Column(
                      children: [
                        Text(
                          "From",
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          "GOTO",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Center(
                    child: Text(
                      "Saya menyetujui Ketentuan layanan & Kebijakan Privasi MoClean",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black45,
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
