import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:moclienapp/mitra/BerandaMitra.dart';
import 'package:moclienapp/mitra/regis_mitra.dart';
import 'package:moclienapp/screens/pilih_role_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginMitraPage extends StatefulWidget {
  const LoginMitraPage({super.key});

  @override
  State<LoginMitraPage> createState() => _LoginMitraPageState();
}

class _LoginMitraPageState extends State<LoginMitraPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadRememberMe();
    _checkLoginStatus();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _checkLoginStatus() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        final mitraDoc = await _firestore.collection('mitra').doc(currentUser.uid).get();
        if (mitraDoc.exists) {
          final status = mitraDoc.data()?['status'] ?? 'pending';
          if (status == 'approved' && mounted) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const BerandaMitra()));
          } else {
            await _auth.signOut();
          }
          return;
        }
        await _auth.signOut();
      }
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  Future<void> _loadRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _rememberMe = prefs.getBool('mitra_rememberMe') ?? false;
      if (_rememberMe) {
        _emailController.text = prefs.getString('mitra_email') ?? '';
      }
    });
  }

  Future<void> _saveRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      await prefs.setBool('mitra_rememberMe', true);
      await prefs.setString('mitra_email', _emailController.text);
    } else {
      await prefs.remove('mitra_rememberMe');
      await prefs.remove('mitra_email');
    }
  }

  void _showErrorPopup(String title, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(color: Colors.red.shade50, shape: BoxShape.circle),
                child: Icon(Icons.error_outline_rounded, color: Colors.red.shade600, size: 50),
              ),
              const SizedBox(height: 20),
              Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Text(message, textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade600,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Tutup', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSuccessPopup(String title, String message, VoidCallback onConfirm) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(color: Colors.green.shade50, shape: BoxShape.circle),
                child: Icon(Icons.check_circle_rounded, color: Colors.green.shade600, size: 50),
              ),
              const SizedBox(height: 20),
              Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Text(message, textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    onConfirm();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Lanjutkan', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showWarningPopup(String title, String message, Color color, IconData icon) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 50),
              ),
              const SizedBox(height: 20),
              Text(title, textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
              const SizedBox(height: 12),
              Text(message, textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () async {
                    await _auth.signOut();
                    Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Mengerti', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showErrorPopup('Data Tidak Lengkap', 'Harap isi email dan password terlebih dahulu');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      final mitraDoc = await _firestore.collection('mitra').doc(userCredential.user!.uid).get();

      if (!mitraDoc.exists) {
        await _auth.signOut();
        setState(() => _isLoading = false);
        _showErrorPopup('Akun Tidak Ditemukan', 'Akun ini bukan akun mitra. Silakan daftar sebagai mitra terlebih dahulu.');
        return;
      }

      final status = mitraDoc.data()?['status'] ?? 'pending';
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_id', userCredential.user!.uid);
      await prefs.setString('user_role', 'mitra');
      await _saveRememberMe();

      setState(() => _isLoading = false);

      if (status == 'pending') {
        _showWarningPopup('Menunggu Persetujuan', 'Akun mitra Anda sedang dalam proses verifikasi. Mohon tunggu konfirmasi dari tim kami.', Colors.orange.shade600, Icons.schedule_rounded);
      } else if (status == 'rejected') {
        _showWarningPopup('Akun Ditolak', 'Maaf, akun mitra Anda tidak dapat disetujui. Silakan hubungi customer service untuk informasi lebih lanjut.', Colors.red.shade600, Icons.cancel_rounded);
      } else if (status == 'approved') {
        _showSuccessPopup('Login Berhasil!', 'Selamat datang kembali di MoClean Mitra', () {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const BerandaMitra()));
        });
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _isLoading = false);
      String title = 'Login Gagal';
      String message = 'Terjadi kesalahan saat login';

      switch (e.code) {
        case 'user-not-found':
          title = 'Email Tidak Terdaftar';
          message = 'Email yang Anda masukkan tidak terdaftar sebagai mitra.';
          break;
        case 'wrong-password':
          title = 'Password Salah';
          message = 'Password yang Anda masukkan salah.';
          break;
        case 'invalid-email':
          title = 'Email Tidak Valid';
          message = 'Format email tidak valid.';
          break;
        case 'invalid-credential':
          title = 'Kredensial Tidak Valid';
          message = 'Email atau password salah.';
          break;
        case 'user-disabled':
          title = 'Akun Dinonaktifkan';
          message = 'Akun Anda telah dinonaktifkan.';
          break;
        case 'too-many-requests':
          title = 'Terlalu Banyak Percobaan';
          message = 'Terlalu banyak percobaan login. Coba lagi nanti.';
          break;
        case 'network-request-failed':
          title = 'Koneksi Bermasalah';
          message = 'Periksa koneksi internet Anda.';
          break;
        default:
          message = e.message ?? 'Terjadi kesalahan';
      }
      _showErrorPopup(title, message);
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorPopup('Terjadi Kesalahan', e.toString());
    }
  }

  Future<void> _forgotPassword() async {
    final emailCtrl = TextEditingController();
    bool loading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(color: const Color(0xFF5B7FDB).withOpacity(0.1), shape: BoxShape.circle),
                  child: const Icon(Icons.lock_reset_rounded, color: Color(0xFF5B7FDB), size: 35),
                ),
                const SizedBox(height: 20),
                const Text('Lupa Password?', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text('Masukkan email mitra yang terdaftar', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                const SizedBox(height: 24),
                TextField(
                  controller: emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  enabled: !loading,
                  decoration: InputDecoration(
                    hintText: 'Masukkan email mitra',
                    prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF5B7FDB)),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF5B7FDB), width: 2)),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: loading ? null : () => Navigator.pop(ctx),
                        child: Text('Batal', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: loading ? Colors.grey : const Color(0xFF5B7FDB))),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: loading ? null : () async {
                          final email = emailCtrl.text.trim();
                          if (email.isEmpty) {
                            Navigator.pop(ctx);
                            _showErrorPopup('Email Kosong', 'Silakan masukkan email Anda');
                            return;
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
                            Navigator.pop(ctx);
                            _showErrorPopup('Format Email Salah', 'Format email tidak valid');
                            return;
                          }
                          setDlgState(() => loading = true);
                          try {
                            debugPrint('Mencari email: $email');
                            await _auth.sendPasswordResetEmail(email: email);
                            setDlgState(() => loading = false);
                            Navigator.pop(ctx);
                            _showSuccessPopup('Email Berhasil Dikirim!', 'Link reset password telah dikirim ke:\n$email\n\nCek inbox atau spam folder', () {});
                          } on FirebaseAuthException catch (e) {
                            setDlgState(() => loading = false);
                            Navigator.pop(ctx);
                            String title = 'Gagal Mengirim';
                            String msg = 'Terjadi kesalahan';
                            switch (e.code) {
                              case 'user-not-found':
                                title = 'Email Tidak Terdaftar';
                                msg = 'Email tidak terdaftar di Firebase Authentication';
                                break;
                              case 'invalid-email':
                                title = 'Format Email Salah';
                                msg = 'Format email tidak valid';
                                break;
                              case 'too-many-requests':
                                title = 'Terlalu Banyak Permintaan';
                                msg = 'Tunggu beberapa menit lalu coba lagi';
                                break;
                              default:
                                msg = e.message ?? 'Unknown error';
                            }
                            _showErrorPopup(title, msg);
                          } catch (e) {
                            setDlgState(() => loading = false);
                            Navigator.pop(ctx);
                            _showErrorPopup('Terjadi Kesalahan', e.toString());
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5B7FDB),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: loading
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text('Kirim Link', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.3,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [const Color(0xFF5B7FDB).withOpacity(0.1), const Color(0xFF4A6FD4).withOpacity(0.05)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              Expanded(child: Container(color: Colors.white)),
            ],
          ),
          SingleChildScrollView(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    const Column(
                      children: [
                        SizedBox(height: 12),
                        Text('Login Mitra', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        Text('Masuk ke akun mitra Anda', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 48),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 5))],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Email', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              hintText: 'Masukkan email Anda',
                              prefixIcon: const Icon(Icons.email_outlined),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text('Password', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              hintText: 'Masukkan password',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: _forgotPassword,
                              child: const Text('Lupa Password?', style: TextStyle(color: Color(0xFF5B7FDB), fontWeight: FontWeight.w600)),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _login,
                              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF5B7FDB), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                              child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Masuk', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () async {
                        await _auth.signOut();
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.remove('user_id');
                        await prefs.remove('user_role');
                        if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const PilihRolePage()));
                      },
                      child: const Text('Keluar', style: TextStyle(color: Color(0xFF5B7FDB), fontSize: 16, fontWeight: FontWeight.w700)),
                    ),
                    const SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Belum punya akun mitra? '),
                        GestureDetector(
                          onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const RegistrasiMitraPage())),
                          child: const Text('Daftar Sekarang', style: TextStyle(color: Color(0xFF5B7FDB), fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}