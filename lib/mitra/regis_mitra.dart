import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';

class RegistrasiMitraPage extends StatefulWidget {
  const RegistrasiMitraPage({super.key});

  @override
  State<RegistrasiMitraPage> createState() => _RegistrasiMitraPageState();
}

class _RegistrasiMitraPageState extends State<RegistrasiMitraPage> {
  final TextEditingController _namaLengkapController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _teleponController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _konfirmasiPasswordController = TextEditingController();
  final TextEditingController _namaUsahaController = TextEditingController();
  final TextEditingController _alamatUsahaController = TextEditingController();
  final TextEditingController _kotaController = TextEditingController();
  final TextEditingController _kodePosController = TextEditingController();

  String _selectedJenisUsaha = 'Cuci Mobil';
  
  // Untuk Mobile (Android/iOS)
  File? _ktpFile;
  File? _siupFile;
  
  // Untuk Web
  Uint8List? _ktpBytes;
  Uint8List? _siupBytes;
  String? _ktpFileName;
  String? _siupFileName;
  
  bool _showPassword = false;
  bool _showKonfirmasiPassword = false;
  bool _agreeToTerms = false;
  bool _isLoading = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final List<String> _jenisUsahaList = [
    'Cuci Mobil',
    'Bengkel Mobil',
    'Salon Mobil',
    'Service Mobil',
    'Bengkel Motor',
    'Lainnya'
  ];

  Future<void> _uploadKTP() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
      );

      if (result != null) {
        if (kIsWeb) {
          setState(() {
            _ktpBytes = result.files.single.bytes;
            _ktpFileName = result.files.single.name;
          });
        } else {
          if (result.files.single.path != null) {
            setState(() {
              _ktpFile = File(result.files.single.path!);
              _ktpFileName = result.files.single.name;
            });
          }
        }
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('File KTP berhasil dipilih: ${result.files.single.name}'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error memilih file: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _uploadSIUP() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
      );

      if (result != null) {
        if (kIsWeb) {
          setState(() {
            _siupBytes = result.files.single.bytes;
            _siupFileName = result.files.single.name;
          });
        } else {
          if (result.files.single.path != null) {
            setState(() {
              _siupFile = File(result.files.single.path!);
              _siupFileName = result.files.single.name;
            });
          }
        }
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('File SIUP berhasil dipilih: ${result.files.single.name}'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error memilih file: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _daftarMitra() async {
    // Validasi form
    if (_namaLengkapController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _teleponController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _konfirmasiPasswordController.text.isEmpty ||
        _namaUsahaController.text.isEmpty ||
        _alamatUsahaController.text.isEmpty ||
        _kotaController.text.isEmpty ||
        !_agreeToTerms) {
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Harap lengkapi semua data'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    if (_passwordController.text != _konfirmasiPasswordController.text) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password dan konfirmasi password tidak sama'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    if (_passwordController.text.length < 6) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password minimal 6 karakter'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    print('🔄 Memulai proses registrasi...');

    try {
      // 1. Buat akun Firebase Auth
      print('📝 Step 1: Membuat akun Firebase Auth...');
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Timeout: Koneksi terlalu lama');
        },
      );
      print('✅ Akun berhasil dibuat: ${userCredential.user!.uid}');

      String userId = userCredential.user!.uid;

      // 2. Simpan data mitra ke Firestore (TANPA UPLOAD FILE DULU)
      // Di dalam fungsi _daftarMitra(), ganti bagian penyimpanan data:

// 2. Simpan data mitra ke Firestore (ke mitra_pending dulu)
print('💾 Step 2: Menyimpan data ke Firestore...');
await _firestore.collection('mitra_pending').doc(userId).set({
  'userId': userId,
  'namaLengkap': _namaLengkapController.text.trim(),
  'email': _emailController.text.trim(),
  'telepon': _teleponController.text.trim(),
  'jenisUsaha': _selectedJenisUsaha,
  'namaUsaha': _namaUsahaController.text.trim(),
  'alamatUsaha': _alamatUsahaController.text.trim(),
  'kota': _kotaController.text.trim(),
  'kodePos': _kodePosController.text.trim(),
  'ktpFileName': _ktpFileName ?? 'Belum upload',
  'siupFileName': _siupFileName ?? 'Belum upload',
  'ktpUrl': 'pending_upload',
  'siupUrl': 'pending_upload',
  'status': 'pending',
  'createdAt': FieldValue.serverTimestamp(),
  'updatedAt': FieldValue.serverTimestamp(),
}).timeout(
  const Duration(seconds: 30),
  onTimeout: () {
    throw Exception('Timeout: Gagal menyimpan data');
  },
);
print('✅ Data berhasil disimpan ke mitra_pending');

      // 3. Update display name
      print('👤 Step 3: Update display name...');
      await userCredential.user!.updateDisplayName(_namaLengkapController.text.trim());
      print('✅ Display name updated');

      setState(() {
        _isLoading = false;
      });

      print('🎉 Registrasi berhasil!');

      // 4. Tampilkan pesan sukses
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: const [
                Icon(Icons.check_circle, color: Colors.green, size: 28),
                SizedBox(width: 12),
                Text(
                  'Registrasi Berhasil!',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Akun mitra Anda berhasil didaftarkan!',
                  style: TextStyle(fontSize: 14),
                ),
                SizedBox(height: 12),
                Text(
                  '📝 Catatan: Dokumen KTP dan SIUP dapat diupload nanti melalui profil Anda.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.orange,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'Tim kami akan menghubungi Anda untuk verifikasi.',
                  style: TextStyle(fontSize: 13),
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Back to previous page
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5B7FDB),
                ),
                child: const Text(
                  'OK',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      print('❌ FirebaseAuthException: ${e.code} - ${e.message}');
      setState(() {
        _isLoading = false;
      });

      String errorMessage = 'Terjadi kesalahan';
      
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'Email sudah terdaftar';
          break;
        case 'invalid-email':
          errorMessage = 'Format email tidak valid';
          break;
        case 'weak-password':
          errorMessage = 'Password terlalu lemah';
          break;
        case 'network-request-failed':
          errorMessage = 'Koneksi internet bermasalah';
          break;
        default:
          errorMessage = 'Terjadi kesalahan: ${e.message}';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      print('❌ General Exception: $e');
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Registrasi Mitra',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF5B7FDB), Color(0xFF4A6FD4)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Gabung Menjadi Mitra Kami",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Dapatkan penghasilan tambahan dengan bergabung menjadi mitra kami",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Info Banner
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.orange.shade700),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Upload dokumen dapat dilakukan nanti setelah registrasi',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.orange.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Form fields... (sama seperti sebelumnya)
                  _buildSectionTitle("Data Pribadi"),
                  _buildTextField("Nama Lengkap", "Masukkan nama lengkap", _namaLengkapController),
                  _buildTextField("Email", "contoh@email.com", _emailController, TextInputType.emailAddress),
                  _buildTextField("Nomor Telepon", "081234567890", _teleponController, TextInputType.phone),
                  _buildPasswordField("Password", "Masukkan password", _passwordController, _showPassword, () {
                    setState(() {
                      _showPassword = !_showPassword;
                    });
                  }),
                  _buildPasswordField("Konfirmasi Password", "Ulangi password", _konfirmasiPasswordController, _showKonfirmasiPassword, () {
                    setState(() {
                      _showKonfirmasiPassword = !_showKonfirmasiPassword;
                    });
                  }),

                  const SizedBox(height: 24),

                  _buildSectionTitle("Data Usaha"),
                  _buildDropdownField("Jenis Usaha", _selectedJenisUsaha, _jenisUsahaList),
                  _buildTextField("Nama Usaha/Bengkel", "Masukkan nama usaha", _namaUsahaController),
                  _buildTextField("Alamat Usaha", "Masukkan alamat lengkap usaha", _alamatUsahaController, null, 3),
                  _buildTextField("Kota", "Masukkan kota", _kotaController),
                  _buildTextField("Kode Pos", "12345", _kodePosController, TextInputType.number),

                  const SizedBox(height: 24),

                  _buildSectionTitle("Dokumen Persyaratan (Opsional)"),
                  _buildFileUpload(
                    "Upload KTP",
                    kIsWeb ? _ktpBytes != null : _ktpFile != null,
                    _uploadKTP,
                    _ktpFileName ?? '',
                  ),
                  const SizedBox(height: 12),
                  _buildFileUpload(
                    "Upload SIUP/TDP",
                    kIsWeb ? _siupBytes != null : _siupFile != null,
                    _uploadSIUP,
                    _siupFileName ?? '',
                  ),

                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Checkbox(
                        value: _agreeToTerms,
                        onChanged: (value) {
                          setState(() {
                            _agreeToTerms = value!;
                          });
                        },
                        activeColor: const Color(0xFF5B7FDB),
                      ),
                      const Expanded(
                        child: Text(
                          "Saya menyetujui Syarat & Ketentuan dan Kebijakan Privasi",
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _daftarMitra,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5B7FDB),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        disabledBackgroundColor: Colors.grey,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              "Daftar Sekarang",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  // Helper widgets (sama seperti sebelumnya)
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String hint, TextEditingController controller, 
                        [TextInputType? keyboardType, int maxLines = 1]) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 14,
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF5B7FDB)),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildPasswordField(String label, String hint, TextEditingController controller, 
                           bool obscureText, VoidCallback onToggle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 14,
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF5B7FDB)),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                obscureText ? Icons.visibility : Icons.visibility_off,
                color: Colors.grey.shade400,
              ),
              onPressed: onToggle,
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDropdownField(String label, String value, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF5B7FDB)),
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: const TextStyle(fontSize: 14),
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedJenisUsaha = newValue!;
                });
              },
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildFileUpload(String label, bool isUploaded, VoidCallback onUpload, String fileName) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isUploaded ? Colors.green : Colors.grey.shade300,
          width: isUploaded ? 2 : 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isUploaded ? Colors.green : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isUploaded 
                      ? fileName.isNotEmpty 
                          ? fileName 
                          : "File berhasil dipilih"
                      : "Pilih file (Opsional)",
                  style: TextStyle(
                    fontSize: 12,
                    color: isUploaded ? Colors.green : Colors.grey.shade600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onUpload,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isUploaded ? Colors.green : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isUploaded ? Colors.green : const Color(0xFF5B7FDB),
                  width: 2,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isUploaded ? Icons.check : Icons.upload,
                    color: isUploaded ? Colors.white : const Color(0xFF5B7FDB),
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isUploaded ? "Ganti" : "Pilih",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isUploaded ? Colors.white : const Color(0xFF5B7FDB),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _namaLengkapController.dispose();
    _emailController.dispose();
    _teleponController.dispose();
    _passwordController.dispose();
    _konfirmasiPasswordController.dispose();
    _namaUsahaController.dispose();
    _alamatUsahaController.dispose();
    _kotaController.dispose();
    _kodePosController.dispose();
    super.dispose();
  }
}