import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginAdminPage extends StatefulWidget {
  const LoginAdminPage({Key? key}) : super(key: key);

  @override
  State<LoginAdminPage> createState() => _LoginAdminPageState();
}

class _LoginAdminPageState extends State<LoginAdminPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Tunggu sebentar sebelum check, biar proses logout dari PilihRolePage selesai dulu
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _checkLoginStatus();
      }
    });
  }

  // ✅ FIXED: Auto-check khusus untuk ADMIN
  Future<void> _checkLoginStatus() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      
      if (currentUser != null) {
        print("🔍 Checking admin role for: ${currentUser.uid}");
        
        // CEK APAKAH USER INI ADALAH ADMIN
        final adminDoc = await FirebaseFirestore.instance
            .collection('admins')
            .doc(currentUser.uid)
            .get();
        
        if (adminDoc.exists) {
          print("✅ Admin confirmed, redirecting");
          if (mounted) {
            Navigator.pushReplacementNamed(context, "/admin_dashboard");
          }
          return;
        }
        
        // Jika bukan admin, logout
        print("⚠️ Not an admin account, logging out");
        await FirebaseAuth.instance.signOut();
      }
    } catch (e) {
      print("❌ Error checking admin status: $e");
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // LOGIN FIREBASE
      UserCredential credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      // CEK ROLE ADMIN DI FIRESTORE
      DocumentSnapshot snap = await FirebaseFirestore.instance
          .collection('admins')
          .doc(credential.user!.uid)
          .get();

      if (!snap.exists) {
        await FirebaseAuth.instance.signOut();
        throw Exception("Akun ini bukan admin");
      }

      // ✅ Simpan role sebagai 'admin'
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_id', credential.user!.uid);
      await prefs.setString('user_role', 'admin'); // ✅ TAMBAHKAN INI

      setState(() => _isLoading = false);

      if (mounted) {
        Navigator.pushReplacementNamed(context, "/admin_dashboard");
      }
    } catch (e) {
      setState(() => _isLoading = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: const BoxDecoration(
                      color: Color(0xFFE8EBFF),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.admin_panel_settings,
                      size: 80,
                      color: Color(0xFF5669FF),
                    ),
                  ),
                ),

                const SizedBox(height: 32),
                const Text(
                  'Admin Login',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Masuk ke Dashboard Admin MoClean',
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 40),
                const Text(
                  'Email Admin',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),

                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: inputStyle(
                    "admin@example.com",
                    Icons.email_outlined,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return 'Email harus diisi';
                    if (!value.contains('@')) return 'Format email tidak valid';
                    return null;
                  },
                ),

                const SizedBox(height: 20),
                const Text(
                  'Password',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),

                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: inputStyle(
                    "Masukkan password",
                    Icons.lock_outline,
                    suffix: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return 'Password harus diisi';
                    if (value.length < 6) return 'Minimal 6 karakter';
                    return null;
                  },
                ),

                const SizedBox(height: 32),
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5669FF),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Masuk',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 24),
                
                // ✅ FIXED: Tombol keluar dengan clear session
            // ✅ FIXED: Tombol keluar dengan clear session dan kembali ke halaman pilih role
OutlinedButton(
  onPressed: () async {
    // Sign out dari Firebase
    await FirebaseAuth.instance.signOut();
    
    // Clear SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
    await prefs.remove('user_role');
    
    if (mounted) {
      // Navigasi ke halaman pilih role
      Navigator.pushReplacementNamed(context, "/pilihrole");
    }
  },
  style: OutlinedButton.styleFrom(
    side: const BorderSide(
      color: Color(0xFF5669FF),
      width: 1.5,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    padding: const EdgeInsets.symmetric(vertical: 16),
  ),
  child: const Text(
    "Kembali ke Pilih Role",
    style: TextStyle(
      color: Color(0xFF5669FF),
      fontWeight: FontWeight.w700,
      fontSize: 16,
    ),
  ),
),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============= INPUT DECORATION REUSABLE =============
  InputDecoration inputStyle(String hint, IconData icon, {Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: const Color(0xFF757575)),
      suffixIcon: suffix,
      filled: true,
      fillColor: const Color(0xFFF8F9FF),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFEEEEEE)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF5669FF), width: 2),
      ),
    );
  }
}