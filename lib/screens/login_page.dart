import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:moclienapp/fiturr/beranda_page.dart';
import 'package:moclienapp/screens/regis_page.dart';
import 'package:moclienapp/screens/pilih_role_page.dart';

// Firebase
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscureText = true;
  bool _loading = false;
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));

    _slideController.forward();
    _fadeController.forward();

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _checkLoginStatus();
      }
    });
  }

  Future<void> _checkLoginStatus() async {
     if (const bool.fromEnvironment('FLUTTER_TEST')) {
    return;
  }
    try {
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();

        if (userDoc.exists) {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const BerandaPage()),
            );
          }
          return;
        }

        await FirebaseAuth.instance.signOut();
      } else {
        final prefs = await SharedPreferences.getInstance();
        final userId = prefs.getString('user_id');
        final userRole = prefs.getString('user_role');

        if (userId != null && userRole == 'user') {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const BerandaPage()),
            );
          }
        }
      }
    } catch (e) {
      print("❌ Error checking login status: $e");
    }
  }

  Future<void> _login() async {
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();

    if (phone.isEmpty || password.isEmpty) {
      _showModernDialog(
        icon: Icons.error_outline,
        iconColor: const Color(0xFFF59E0B),
        gradientColors: [const Color(0xFFFEF3C7), const Color(0xFFFDE68A)],
        title: "Perhatian",
        message: "Nomor HP dan Password harus diisi",
        buttonText: "Mengerti",
        buttonColor: const Color(0xFFF59E0B),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final userQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('phone', isEqualTo: phone)
          .limit(1)
          .get();

      if (userQuery.docs.isEmpty) {
        setState(() => _loading = false);
        _showModernDialog(
          icon: Icons.person_off,
          iconColor: const Color(0xFFEF4444),
          gradientColors: [const Color(0xFFFEE2E2), const Color(0xFFFECDCA)],
          title: "Nomor Tidak Terdaftar",
          message:
              "Nomor HP ini belum terdaftar.\nSilakan daftar terlebih dahulu atau periksa kembali nomor Anda.",
          buttonText: "OK",
          buttonColor: const Color(0xFFEF4444),
        );
        return;
      }

      final userDoc = userQuery.docs.first;
      final userData = userDoc.data();
      final userEmail = userData['email'];

      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: userEmail, password: password);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_id', userCredential.user!.uid);
      await prefs.setString('user_phone', phone);
      await prefs.setString('user_nama', userData['nama'] ?? 'Pengguna');
      await prefs.setString('user_email', userEmail ?? '');
      await prefs.setString('user_role', 'user');

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .update({'last_login': FieldValue.serverTimestamp()});

      setState(() => _loading = false);

      _showModernDialog(
        icon: Icons.check_circle,
        iconColor: const Color(0xFF10B981),
        gradientColors: [const Color(0xFFD1FAE5), const Color(0xFFA7F3D0)],
        title: "Login Berhasil!",
        message: "Selamat datang kembali,\n${userData['nama'] ?? 'Pengguna'}",
        buttonText: "Lanjutkan",
        buttonColor: const Color(0xFF10B981),
        isSuccess: true,
        onDismiss: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const BerandaPage()),
          );
        },
      );
    } on FirebaseAuthException catch (e) {
      setState(() => _loading = false);

      String title = "Login Gagal";
      String message = "Terjadi kesalahan";

      switch (e.code) {
        case 'wrong-password':
        case 'invalid-credential':
          title = "Password Salah";
          message =
              "Password yang Anda masukkan salah.\nPeriksa kembali dan coba lagi.";
          break;
        case 'user-not-found':
          title = "Akun Tidak Ditemukan";
          message = "Email tidak terdaftar di sistem.";
          break;
        case 'user-disabled':
          title = "Akun Dinonaktifkan";
          message =
              "Akun Anda telah dinonaktifkan.\nHubungi customer service untuk bantuan.";
          break;
        case 'too-many-requests':
          title = "Terlalu Banyak Percobaan";
          message =
              "Akun sementara dikunci karena terlalu banyak percobaan login.\nCoba lagi dalam beberapa menit.";
          break;
        default:
          message = e.message ?? "Terjadi kesalahan tidak terduga";
      }

      _showModernDialog(
        icon: Icons.cancel,
        iconColor: const Color(0xFFEF4444),
        gradientColors: [const Color(0xFFFEE2E2), const Color(0xFFFECDCA)],
        title: title,
        message: message,
        buttonText: "Coba Lagi",
        buttonColor: const Color(0xFFEF4444),
      );
    } catch (e) {
      setState(() => _loading = false);

      _showModernDialog(
        icon: Icons.warning,
        iconColor: const Color(0xFFEF4444),
        gradientColors: [const Color(0xFFFEE2E2), const Color(0xFFFECDCA)],
        title: "Terjadi Kesalahan",
        message:
            "Mohon maaf, terjadi kesalahan sistem.\nSilakan coba lagi nanti.",
        buttonText: "OK",
        buttonColor: const Color(0xFFEF4444),
      );
    }
  }

  void _showModernDialog({
    required IconData icon,
    required Color iconColor,
    required List<Color> gradientColors,
    required String title,
    required String message,
    required String buttonText,
    required Color buttonColor,
    bool isSuccess = false,
    VoidCallback? onDismiss,
  }) {
    showGeneralDialog(
      context: context,
      barrierDismissible: !isSuccess,
      barrierLabel: '',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return Container();
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return Transform.scale(
          scale: anim1.value,
          child: Opacity(
            opacity: anim1.value,
            child: _ModernDialogContent(
              icon: icon,
              iconColor: iconColor,
              gradientColors: gradientColors,
              title: title,
              message: message,
              buttonText: buttonText,
              buttonColor: buttonColor,
              isSuccess: isSuccess,
              onDismiss: onDismiss,
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFFFFF), Color(0xFFE0EFFE), Color(0xFF3B82F6)],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),

                      // Logo
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF3B82F6).withOpacity(0.4),
                              blurRadius: 25,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.cleaning_services,
                          size: 50,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 30),

                      Text(
                        "Selamat Datang",
                        style: GoogleFonts.poppins(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1E3A8A),
                          letterSpacing: -1,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        "Masuk untuk melanjutkan",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: const Color(0xFF475569),
                          fontWeight: FontWeight.w400,
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Form Container
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 40,
                              offset: const Offset(0, 20),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Phone Input
                            Text(
                              "Nomor Telepon",
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF1F2937),
                              ),
                            ),
                            const SizedBox(height: 12),

                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFF9FAFB),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF3B82F6,
                                    ).withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: TextField(
                                key: const Key('phoneField'),
                                controller: _phoneController,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(13),
                                ],
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF1F2937),
                                ),
                                decoration: InputDecoration(
                                  prefixIcon: Container(
                                    margin: const EdgeInsets.all(12),
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFF3B82F6,
                                      ).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.phone_android,
                                      color: Color(0xFF3B82F6),
                                      size: 20,
                                    ),
                                  ),
                                  hintText: "+62 812 3456 7890",
                                  hintStyle: GoogleFonts.poppins(
                                    color: Colors.grey.shade400,
                                    fontSize: 15,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 18,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Password Input
                            Text(
                              "Kata Sandi",
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF1F2937),
                              ),
                            ),
                            const SizedBox(height: 12),

                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFF9FAFB),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF667EEA,
                                    ).withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: TextField(
                                key: const Key('passwordField'),
                                controller: _passwordController,
                                obscureText: _obscureText,
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF1F2937),
                                ),
                                decoration: InputDecoration(
                                  prefixIcon: Container(
                                    margin: const EdgeInsets.all(12),
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFF3B82F6,
                                      ).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.lock_outline,
                                      color: Color(0xFF3B82F6),
                                      size: 20,
                                    ),
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscureText
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      color: Colors.grey.shade400,
                                      size: 22,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscureText = !_obscureText;
                                      });
                                    },
                                  ),
                                  hintText: "Masukkan kata sandi",
                                  hintStyle: GoogleFonts.poppins(
                                    color: Colors.grey.shade400,
                                    fontSize: 15,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 18,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  _showModernDialog(
                                    icon: Icons.info_outline,
                                    iconColor: const Color(0xFF3B82F6),
                                    gradientColors: [
                                      const Color(0xFFDBEAFE),
                                      const Color(0xFFBFDBFE),
                                    ],
                                    title: "Informasi",
                                    message:
                                        "Fitur lupa password sedang dalam pengembangan.\n\nHubungi customer service untuk bantuan reset password.",
                                    buttonText: "Mengerti",
                                    buttonColor: const Color(0xFF3B82F6),
                                  );
                                },
                                child: Text(
                                  "Lupa Password?",
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFF3B82F6),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Login Button
                            Container(
                              width: double.infinity,
                              height: 56,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF3B82F6),
                                    Color(0xFF1D4ED8),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF3B82F6,
                                    ).withOpacity(0.4),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                key: const Key('loginButton'),
                                onPressed: _loading ? null : _login,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: _loading
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2.5,
                                        ),
                                      )
                                    : Text(
                                        "Masuk",
                                        style: GoogleFonts.poppins(
                                          fontSize: 17,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                              ),
                            ),

                            const SizedBox(height: 28),

                            // Divider
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 1,
                                    color: Colors.grey.shade200,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  child: Text(
                                    "atau",
                                    style: GoogleFonts.poppins(
                                      color: Colors.grey.shade500,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    height: 1,
                                    color: Colors.grey.shade200,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 28),

                            // Register Link
                            Center(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const RegisterPage(),
                                    ),
                                  );
                                },
                                child: RichText(
                                  text: TextSpan(
                                    text: "Belum punya akun? ",
                                    style: GoogleFonts.poppins(
                                      color: Colors.grey.shade600,
                                      fontSize: 15,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: "Daftar Sekarang",
                                        style: GoogleFonts.poppins(
                                          color: const Color(0xFF3B82F6),
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Back Button
                            Center(
                              child: TextButton.icon(
                                onPressed: () async {
                                  await FirebaseAuth.instance.signOut();
                                  final prefs =
                                      await SharedPreferences.getInstance();
                                  await prefs.clear();

                                  if (mounted) {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const PilihRolePage(),
                                      ),
                                    );
                                  }
                                },
                                icon: const Icon(
                                  Icons.arrow_back,
                                  size: 18,
                                  color: Color(0xFFEF4444),
                                ),
                                label: Text(
                                  "Kembali ke Pilih Role",
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFFEF4444),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Footer
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          "Dengan masuk, Anda menyetujui Ketentuan Layanan\ndan Kebijakan Privasi MoClean",
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF475569),
                            fontSize: 12,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ModernDialogContent extends StatefulWidget {
  final IconData icon;
  final Color iconColor;
  final List<Color> gradientColors;
  final String title;
  final String message;
  final String buttonText;
  final Color buttonColor;
  final bool isSuccess;
  final VoidCallback? onDismiss;

  const _ModernDialogContent({
    required this.icon,
    required this.iconColor,
    required this.gradientColors,
    required this.title,
    required this.message,
    required this.buttonText,
    required this.buttonColor,
    this.isSuccess = false,
    this.onDismiss,
  });

  @override
  State<_ModernDialogContent> createState() => _ModernDialogContentState();
}

class _ModernDialogContentState extends State<_ModernDialogContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _iconAnimation;
  late Animation<double> _contentAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _iconAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );

    _contentAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward();

    if (widget.isSuccess) {
      Future.delayed(const Duration(milliseconds: 1800), () {
        if (mounted) {
          Navigator.of(context).pop();
          widget.onDismiss?.call();
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 340),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon with gradient background
            ScaleTransition(
              scale: _iconAnimation,
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: widget.gradientColors,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: widget.iconColor.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(widget.icon, color: widget.iconColor, size: 45),
              ),
            ),

            const SizedBox(height: 24),

            FadeTransition(
              opacity: _contentAnimation,
              child: Column(
                children: [
                  // Title
                  Text(
                    widget.title,
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1F2937),
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 12),

                  // Message
                  Text(
                    widget.message,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      height: 1.6,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 28),

                  // Button
                  if (!widget.isSuccess)
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          widget.onDismiss?.call();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: widget.buttonColor,
                          elevation: 0,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          widget.buttonText,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                  // Auto-dismiss indicator for success
                  if (widget.isSuccess)
                    Column(
                      children: [
                        const SizedBox(
                          width: 30,
                          height: 30,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFF10B981),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "Mengalihkan...",
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.grey.shade500,
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
      )
    );
  }
}
