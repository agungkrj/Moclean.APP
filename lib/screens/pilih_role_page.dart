import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:moclienapp/admin/login_admin.dart';
import 'package:moclienapp/mitra/login_mitra.dart';
import 'package:moclienapp/screens/login_page.dart';
import 'package:moclienapp/screens/home_page.dart';

class PilihRolePage extends StatelessWidget {
  const PilihRolePage({super.key});

  Future<void> _clearSessionAndNavigate(BuildContext context, Widget page) async {
    try {
      await FirebaseAuth.instance.signOut();
      print("✅ Firebase Auth logged out");

      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      print("✅ SharedPreferences cleared");

      await Future.delayed(const Duration(milliseconds: 300));

      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => page),
        );
      }
    } catch (e) {
      print("❌ Error clearing session: $e");
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => page),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3C6EEF),
      body: SafeArea(
        child: Column(
          children: [
            // Header dengan Back Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => HomePage()),
                      );
                    },
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Pilih Role",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // Konten Utama
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                // ✅ FIX: SingleChildScrollView mencegah overflow
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Icon
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: const Color(0xFF3C6EEF).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person_search_rounded,
                          color: Color(0xFF3C6EEF),
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 24),

                      const Text(
                        "Masuk Sebagai",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 8),

                      const Text(
                        "Pilih peran untuk melanjutkan ke halaman login",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF666666),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Card Pengguna
                      _buildRoleCard(
                        icon: Icons.person_rounded,
                        title: "Pengguna",
                        subtitle: "Akses layanan sebagai pengguna",
                        color: const Color(0xFF3C6EEF),
                        context: context,
                        onTap: () => _clearSessionAndNavigate(context, const LoginPage()),
                      ),
                      const SizedBox(height: 16),

                      // Card Mitra
                      _buildRoleCard(
                        icon: Icons.business_center_rounded,
                        title: "Mitra",
                        subtitle: "Masuk sebagai mitra atau penyedia jasa",
                        color: const Color(0xFF4CAF50),
                        context: context,
                        onTap: () => _clearSessionAndNavigate(context, const LoginMitraPage()),
                      ),
                      const SizedBox(height: 16),

                      // Card Admin
                      _buildRoleCard(
                        icon: Icons.admin_panel_settings_rounded,
                        title: "Admin",
                        subtitle: "Akses dashboard administrasi",
                        color: const Color(0xFFF44336),
                        context: context,
                        onTap: () => _clearSessionAndNavigate(context, const LoginAdminPage()),
                      ),

                      const SizedBox(height: 32),

                      // Footer Text
                      const Text(
                        "Pilih sesuai dengan peran Anda",
                        style: TextStyle(
                          color: Color(0xFF888888),
                          fontSize: 13,
                        ),
                      ),

                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required BuildContext context,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey.shade200,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon Container
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),

            // Text Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF666666),
                    ),
                  ),
                ],
              ),
            ),

            // Arrow Icon
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_forward_rounded,
                color: color,
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}