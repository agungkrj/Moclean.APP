import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:moclienapp/screens/login_page.dart';
import 'package:moclienapp/screens/pilih_lokasi_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> with TickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();
  bool _loading = false;
  bool _obscurePassword = true;
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));
    _slideController.forward();
    _fadeController.forward();
  }

  Future<void> registerUser() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final phone = _phoneController.text.trim();
    final alamat = _alamatController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty || phone.isEmpty) {
      _showModernDialog(icon: Icons.warning_amber_rounded, iconColor: const Color(0xFFF59E0B), gradientColors: [const Color(0xFFFEF3C7), const Color(0xFFFDE68A)], title: "Data Tidak Lengkap", message: "Semua field harus diisi kecuali alamat.\nMohon lengkapi data Anda.", buttonText: "OK", buttonColor: const Color(0xFFF59E0B));
      return;
    }
    if (password.length < 6) {
      _showModernDialog(icon: Icons.lock_outline, iconColor: const Color(0xFFF59E0B), gradientColors: [const Color(0xFFFEF3C7), const Color(0xFFFDE68A)], title: "Password Terlalu Pendek", message: "Password harus minimal 6 karakter untuk keamanan akun Anda.", buttonText: "Mengerti", buttonColor: const Color(0xFFF59E0B));
      return;
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      _showModernDialog(icon: Icons.email_outlined, iconColor: const Color(0xFFF59E0B), gradientColors: [const Color(0xFFFEF3C7), const Color(0xFFFDE68A)], title: "Email Tidak Valid", message: "Format email tidak sesuai.\nContoh: nama@email.com", buttonText: "OK", buttonColor: const Color(0xFFF59E0B));
      return;
    }

    setState(() => _loading = true);
    try {
      UserCredential userCred = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
      await FirebaseFirestore.instance.collection("users").doc(userCred.user!.uid).set({"uid": userCred.user!.uid, "nama": name, "email": email, "phone": phone, "alamat": alamat, "password": password, "role": "user", "created_at": FieldValue.serverTimestamp()});
      setState(() => _loading = false);
      _showModernDialog(icon: Icons.check_circle_rounded, iconColor: const Color(0xFF10B981), gradientColors: [const Color(0xFFD1FAE5), const Color(0xFFA7F3D0)], title: "Registrasi Berhasil!", message: "Akun Anda telah dibuat.\nSilakan login untuk melanjutkan.", buttonText: "Login Sekarang", buttonColor: const Color(0xFF10B981), isSuccess: true, onDismiss: () {Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage()));});
    } on FirebaseAuthException catch (e) {
      setState(() => _loading = false);
      String title = "Registrasi Gagal";
      String message = "Terjadi kesalahan saat mendaftar";
      switch (e.code) {
        case "weak-password": title = "Password Terlalu Lemah"; message = "Gunakan kombinasi huruf, angka, dan simbol untuk password yang lebih kuat."; break;
        case "email-already-in-use": title = "Email Sudah Terdaftar"; message = "Email ini sudah digunakan.\nSilakan gunakan email lain atau login."; break;
        case "invalid-email": title = "Email Tidak Valid"; message = "Format email tidak sesuai.\nPeriksa kembali email Anda."; break;
        default: message = e.message ?? "Terjadi kesalahan tidak terduga";
      }
      _showModernDialog(icon: Icons.error_outline_rounded, iconColor: const Color(0xFFEF4444), gradientColors: [const Color(0xFFFEE2E2), const Color(0xFFFECDCA)], title: title, message: message, buttonText: "Coba Lagi", buttonColor: const Color(0xFFEF4444));
    } catch (e) {
      setState(() => _loading = false);
      _showModernDialog(icon: Icons.warning_rounded, iconColor: const Color(0xFFEF4444), gradientColors: [const Color(0xFFFEE2E2), const Color(0xFFFECDCA)], title: "Terjadi Kesalahan", message: "Mohon maaf, terjadi kesalahan sistem.\nSilakan coba lagi nanti.", buttonText: "OK", buttonColor: const Color(0xFFEF4444));
    }
  }

  void _showModernDialog({required IconData icon, required Color iconColor, required List<Color> gradientColors, required String title, required String message, required String buttonText, required Color buttonColor, bool isSuccess = false, VoidCallback? onDismiss}) {
    showGeneralDialog(context: context, barrierDismissible: !isSuccess, barrierLabel: '', barrierColor: Colors.black54, transitionDuration: const Duration(milliseconds: 300), pageBuilder: (context, anim1, anim2) {return Container();}, transitionBuilder: (context, anim1, anim2, child) {return Transform.scale(scale: anim1.value, child: Opacity(opacity: anim1.value, child: _ModernDialogContent(icon: icon, iconColor: iconColor, gradientColors: gradientColors, title: title, message: message, buttonText: buttonText, buttonColor: buttonColor, isSuccess: isSuccess, onDismiss: onDismiss)));});
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _alamatController.dispose();
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Container(width: double.infinity, height: double.infinity, decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFFFFFFF), Color(0xFFE0EFFE), Color(0xFF3B82F6)])), child: SafeArea(child: FadeTransition(opacity: _fadeAnimation, child: SlideTransition(position: _slideAnimation, child: SingleChildScrollView(physics: const BouncingScrollPhysics(), child: Padding(padding: const EdgeInsets.all(24.0), child: Column(children: [const SizedBox(height: 20), Row(children: [Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))]), child: IconButton(icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF3B82F6)), onPressed: () => Navigator.pop(context))), const SizedBox(width: 16), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("Daftar Akun", style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold, color: const Color(0xFF1E3A8A))), Text("Buat akun baru MoClean", style: GoogleFonts.poppins(fontSize: 14, color: const Color(0xFF475569)))]))]), const SizedBox(height: 30), Container(width: double.infinity, padding: const EdgeInsets.all(28), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 40, offset: const Offset(0, 20))]), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildInputField(label: "Nama Lengkap", icon: Icons.person_outline_rounded, controller: _nameController, hint: "Masukkan nama lengkap"), const SizedBox(height: 20), _buildInputField(label: "Email", icon: Icons.email_outlined, controller: _emailController, hint: "nama@email.com", keyboardType: TextInputType.emailAddress), const SizedBox(height: 20), _buildInputField(label: "Nomor Telepon", icon: Icons.phone_android_rounded, controller: _phoneController, hint: "+62 812 3456 7890", keyboardType: TextInputType.phone, inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(13)]), const SizedBox(height: 20), _buildPasswordField(), const SizedBox(height: 20), _buildLocationField(), const SizedBox(height: 28), Container(width: double.infinity, height: 56, decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)]), borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: const Color(0xFF3B82F6).withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 10))]), child: ElevatedButton(onPressed: _loading ? null : registerUser, style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))), child: _loading ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5)) : Text("Daftar Sekarang", style: GoogleFonts.poppins(fontSize: 17, color: Colors.white, fontWeight: FontWeight.w600, letterSpacing: 0.5)))), const SizedBox(height: 24), Center(child: GestureDetector(onTap: () {Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage()));}, child: RichText(text: TextSpan(text: "Sudah punya akun? ", style: GoogleFonts.poppins(color: Colors.grey.shade600, fontSize: 15), children: [TextSpan(text: "Login", style: GoogleFonts.poppins(color: const Color(0xFF3B82F6), fontSize: 15, fontWeight: FontWeight.w600))]))))])), const SizedBox(height: 24), Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Text("Dengan mendaftar, Anda menyetujui Ketentuan Layanan\ndan Kebijakan Privasi MoClean", style: GoogleFonts.poppins(color: const Color(0xFF475569), fontSize: 12, height: 1.5), textAlign: TextAlign.center)), const SizedBox(height: 20)]))))))));
  }

  Widget _buildInputField({required String label, required IconData icon, required TextEditingController controller, required String hint, TextInputType? keyboardType, List<TextInputFormatter>? inputFormatters}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: const Color(0xFF1F2937))), const SizedBox(height: 10), Container(decoration: BoxDecoration(color: const Color(0xFFF9FAFB), borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: const Color(0xFF3B82F6).withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 4))]), child: TextField(controller: controller, keyboardType: keyboardType, inputFormatters: inputFormatters, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w500, color: const Color(0xFF1F2937)), decoration: InputDecoration(prefixIcon: Container(margin: const EdgeInsets.all(12), padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFF3B82F6).withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: const Color(0xFF3B82F6), size: 20)), hintText: hint, hintStyle: GoogleFonts.poppins(color: Colors.grey.shade400, fontSize: 15), border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18))))]);
  }

  Widget _buildPasswordField() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("Kata Sandi", style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: const Color(0xFF1F2937))), const SizedBox(height: 10), Container(decoration: BoxDecoration(color: const Color(0xFFF9FAFB), borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: const Color(0xFF3B82F6).withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 4))]), child: TextField(controller: _passwordController, obscureText: _obscurePassword, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w500, color: const Color(0xFF1F2937)), decoration: InputDecoration(prefixIcon: Container(margin: const EdgeInsets.all(12), padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFF3B82F6).withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.lock_outline_rounded, color: Color(0xFF3B82F6), size: 20)), suffixIcon: IconButton(icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: Colors.grey.shade400, size: 22), onPressed: () {setState(() {_obscurePassword = !_obscurePassword;});}), hintText: "Minimal 6 karakter", hintStyle: GoogleFonts.poppins(color: Colors.grey.shade400, fontSize: 15), border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18))))]);
  }

  Widget _buildLocationField() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Text("Alamat Lengkap", style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: const Color(0xFF1F2937))), const SizedBox(width: 6), Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(6)), child: Text("Opsional", style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.w500)))]), const SizedBox(height: 10), GestureDetector(onTap: () async {final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => const PilihLokasiPage())); if (result != null && result is Map) {setState(() {_alamatController.text = result['address'] ?? result.toString();});} else if (result != null) {setState(() {_alamatController.text = result.toString();});}}, child: Container(decoration: BoxDecoration(color: const Color(0xFFF9FAFB), borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: const Color(0xFF3B82F6).withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 4))]), child: AbsorbPointer(child: TextField(controller: _alamatController, maxLines: 3, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w500, color: const Color(0xFF1F2937)), decoration: InputDecoration(prefixIcon: Container(margin: const EdgeInsets.all(12), padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFF3B82F6).withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.location_on_outlined, color: Color(0xFF3B82F6), size: 20)), suffixIcon: Container(margin: const EdgeInsets.all(12), child: Icon(Icons.map_outlined, color: Colors.grey.shade400, size: 20)), hintText: "Tap untuk pilih lokasi di peta", hintStyle: GoogleFonts.poppins(color: Colors.grey.shade400, fontSize: 15), border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18))))))]);
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
  const _ModernDialogContent({required this.icon, required this.iconColor, required this.gradientColors, required this.title, required this.message, required this.buttonText, required this.buttonColor, this.isSuccess = false, this.onDismiss});
  @override
  State<_ModernDialogContent> createState() => _ModernDialogContentState();
}

class _ModernDialogContentState extends State<_ModernDialogContent> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _iconAnimation;
  late Animation<double> _contentAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _iconAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.5, curve: Curves.elasticOut)));
    _contentAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.3, 1.0, curve: Curves.easeOut)));
    _controller.forward();
    if (widget.isSuccess) {Future.delayed(const Duration(milliseconds: 1800), () {if (mounted) {Navigator.of(context).pop(); widget.onDismiss?.call();}});}
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(elevation: 0, backgroundColor: Colors.transparent, child: Container(constraints: const BoxConstraints(maxWidth: 340), padding: const EdgeInsets.all(28), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 30, offset: const Offset(0, 15))]), child: Column(mainAxisSize: MainAxisSize.min, children: [ScaleTransition(scale: _iconAnimation, child: Container(width: 90, height: 90, decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: widget.gradientColors), shape: BoxShape.circle, boxShadow: [BoxShadow(color: widget.iconColor.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))]), child: Icon(widget.icon, color: widget.iconColor, size: 45))), const SizedBox(height: 24), FadeTransition(opacity: _contentAnimation, child: Column(children: [Text(widget.title, style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF1F2937), height: 1.2), textAlign: TextAlign.center), const SizedBox(height: 12), Text(widget.message, style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade600, height: 1.6), textAlign: TextAlign.center), const SizedBox(height: 28), if (!widget.isSuccess) SizedBox(width: double.infinity, height: 52, child: ElevatedButton(onPressed: () {Navigator.of(context).pop(); widget.onDismiss?.call();}, style: ElevatedButton.styleFrom(backgroundColor: widget.buttonColor, elevation: 0, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))), child: Text(widget.buttonText, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)))), if (widget.isSuccess) Column(children: [const SizedBox(width: 30, height: 30, child: CircularProgressIndicator(strokeWidth: 3, valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF10B981)))), const SizedBox(height: 12), Text("Mengalihkan ke login...", style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade500))])]))])));
  }
}