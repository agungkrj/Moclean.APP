import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'navbar.dart';
import 'package:moclienapp/screens/login_page.dart';
import 'package:moclienapp/screens/pilih_lokasi_page.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({Key? key}) : super(key: key);

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  int _selectedIndex = 3;

  // Data langsung diambil dari SharedPreferences, tidak pakai default
  String _nama = '';
  String _email = '';
  String _phone = '';
  String _alamat = '';
  String _uid = '';
  String _fotoUrl = '';
  Timestamp _createdAt = Timestamp.now();

  @override
  void initState() {
    super.initState();
    _loadUserDataSync();
    _refreshUserDataInBackground();
  }

  void _loadUserDataSync() {
    // Ambil data langsung dari SharedPreferences (instant, no loading)
    SharedPreferences.getInstance().then((prefs) {
      final nama = prefs.getString('user_nama') ?? 'Pengguna';
      final email = prefs.getString('user_email') ?? '';
      final phone = prefs.getString('user_phone') ?? '';
      final uid = prefs.getString('user_id') ?? '';

      setState(() {
        _nama = nama;
        _email = email;
        _phone = phone;
        _uid = uid;
        _alamat = '';
        _fotoUrl =
            'https://ui-avatars.com/api/?name=${Uri.encodeComponent(nama)}&background=5669FF&color=fff&size=200';
        _createdAt = Timestamp.now();
      });
    });
  }

  Future<void> _refreshUserDataInBackground() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('user_id');
      User? currentUser = FirebaseAuth.instance.currentUser;

      final effectiveUserId = currentUser?.uid ?? userId;

      if (effectiveUserId == null) {
        print("⚠️ No user found");
        return;
      }

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(effectiveUserId)
          .get();

      if (userDoc.exists) {
        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;

        final nama = data['nama'] ?? currentUser?.displayName ?? 'Pengguna';
        final email = data['email'] ?? currentUser?.email ?? '';
        final phone = data['phone'] ?? '';
        final alamat = data['alamat'] ?? '';
        final fotoUrl =
            data['fotoUrl'] ??
            'https://ui-avatars.com/api/?name=${Uri.encodeComponent(nama)}&background=5669FF&color=fff&size=200';
        final createdAt = data['created_at'] ?? Timestamp.now();

        // Update SharedPreferences
        await prefs.setString('user_nama', nama);
        await prefs.setString('user_email', email);
        await prefs.setString('user_phone', phone);

        // Update UI hanya jika ada perubahan
        if (mounted) {
          setState(() {
            _nama = nama;
            _email = email;
            _phone = phone;
            _alamat = alamat;
            _uid = effectiveUserId;
            _fotoUrl = fotoUrl;
            _createdAt = createdAt is Timestamp ? createdAt : Timestamp.now();
          });
        }
      } else {
        // Buat dokumen baru jika belum ada
        final defaultData = {
          'uid': effectiveUserId,
          'email': currentUser?.email ?? prefs.getString('user_email') ?? '',
          'nama':
              currentUser?.displayName ??
              prefs.getString('user_nama') ??
              'Pengguna',
          'phone': prefs.getString('user_phone') ?? '',
          'alamat': '',
          'fotoUrl':
              'https://ui-avatars.com/api/?name=${Uri.encodeComponent(currentUser?.displayName ?? 'User')}&background=5669FF&color=fff&size=200',
          'role': 'user',
          'created_at': FieldValue.serverTimestamp(),
        };

        await FirebaseFirestore.instance
            .collection('users')
            .doc(effectiveUserId)
            .set(defaultData, SetOptions(merge: true));
      }
    } catch (e) {
      print("⚠️ Background refresh failed: $e");
    }
  }

  String get nama => _nama.isEmpty ? 'Belum diatur' : _nama;
  String get email => _email.isEmpty ? 'Belum diatur' : _email;
  String get phone => _phone.isEmpty ? 'Belum diatur' : _phone;
  String get alamat => _alamat.isEmpty ? 'Belum diatur' : _alamat;
  String get fotoUrl {
    if (_fotoUrl.isEmpty) {
      return 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(_nama.isEmpty ? 'User' : _nama)}&background=5669FF&color=fff&size=200';
    }
    return _fotoUrl;
  }

  String get idPelanggan {
    if (_uid.isNotEmpty) {
      return _uid.substring(0, _uid.length > 8 ? 8 : _uid.length).toUpperCase();
    }
    return 'N/A';
  }

  String get idSub {
    try {
      final timestamp = _createdAt.millisecondsSinceEpoch.toString();
      return timestamp.substring(timestamp.length - 10);
    } catch (e) {
      return 'N/A';
    }
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
    setState(() => _selectedIndex = index);
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/beranda');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/Aktifitas');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/riwayat');
        break;
    }
  }

  Future<void> _handleRefresh() async {
    try {
      await _refreshUserDataInBackground();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Profil diperbarui'),
            duration: Duration(seconds: 1),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print("❌ Error refresh: $e");
    }
  }

  void editProfil() {
    TextEditingController namaC = TextEditingController(
      text: nama != 'Belum diatur' ? nama : '',
    );
    TextEditingController alamatC = TextEditingController(
      text: alamat != 'Belum diatur' ? alamat : '',
    );
    TextEditingController nohpC = TextEditingController(
      text: phone != 'Belum diatur' ? phone : '',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Edit Profil",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: namaC,
                decoration: InputDecoration(
                  labelText: "Nama Lengkap",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PilihLokasiPage(),
                    ),
                  );
                  if (result != null) alamatC.text = result.toString();
                },
                child: AbsorbPointer(
                  child: TextField(
                    controller: alamatC,
                    decoration: InputDecoration(
                      labelText: "Alamat (Tap untuk pilih di peta)",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      suffixIcon: const Icon(Icons.location_on),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nohpC,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: "Nomor HP",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5669FF),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  try {
                    final prefs = await SharedPreferences.getInstance();
                    final userId = prefs.getString('user_id');

                    if (userId != null) {
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(userId)
                          .update({
                            'nama': namaC.text,
                            'alamat': alamatC.text,
                            'phone': nohpC.text,
                            'updated_at': FieldValue.serverTimestamp(),
                          });

                      // Update SharedPreferences
                      await prefs.setString('user_nama', namaC.text);
                      await prefs.setString('user_phone', nohpC.text);

                      // Update UI
                      if (mounted) {
                        setState(() {
                          _nama = namaC.text;
                          _alamat = alamatC.text;
                          _phone = nohpC.text;
                        });
                      }

                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('✅ Profil berhasil diperbarui'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('❌ Gagal update: $e')),
                    );
                  }
                },
                child: const Text(
                  "Simpan Perubahan",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void editFoto() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) {
        return SizedBox(
          height: 160,
          child: Column(
            children: [
              const SizedBox(height: 15),
              const Text(
                "Ubah Foto Profil",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.photo, color: Color(0xFF5669FF)),
                title: const Text("Pilih dari Gallery"),
                onTap: () async {
                  final newFotoUrl =
                      "https://picsum.photos/200?random=${DateTime.now().millisecondsSinceEpoch}";

                  final prefs = await SharedPreferences.getInstance();
                  final userId = prefs.getString('user_id');

                  if (userId != null) {
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(userId)
                        .update({'fotoUrl': newFotoUrl});
                  }

                  setState(() => _fotoUrl = newFotoUrl);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('✅ Foto diperbarui')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Color(0xFF5669FF)),
                title: const Text("Ambil Foto"),
                onTap: () async {
                  final newFotoUrl =
                      "https://picsum.photos/250?random=${DateTime.now().millisecondsSinceEpoch}";

                  final prefs = await SharedPreferences.getInstance();
                  final userId = prefs.getString('user_id');

                  if (userId != null) {
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(userId)
                        .update({'fotoUrl': newFotoUrl});
                  }

                  setState(() => _fotoUrl = newFotoUrl);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('✅ Foto diperbarui')),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void resetPassword() async {
    final emailToReset = email;
    if (emailToReset == 'Belum diatur' || emailToReset.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('❌ Email tidak ditemukan')));
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: emailToReset);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Link reset password dikirim'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('❌ Gagal: $e')));
    }
  }

  void logout() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Konfirmasi Keluar"),
        content: const Text("Yakin ingin keluar?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();

              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();

              print("✅ Logout berhasil");

              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (route) => false,
              );
            },
            child: const Text("Keluar", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF5669FF),
        elevation: 0,
        title: const Text(
          'Profil Kamu',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _handleRefresh,
          ),
        ],
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: const Color(0xFF5669FF),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: editFoto,
                      child: Stack(
                        children: [
                          Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFF5669FF),
                                width: 3,
                              ),
                              image: DecorationImage(
                                image: NetworkImage(fotoUrl),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Color(0xFF5669FF),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                size: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            nama,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.email,
                                size: 14,
                                color: Colors.black54,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  email,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black54,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              const Icon(
                                Icons.phone,
                                size: 14,
                                color: Colors.black54,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  phone,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black54,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                size: 14,
                                color: Colors.black54,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  alamat,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black54,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: editProfil,
                      icon: const Icon(
                        Icons.edit,
                        size: 22,
                        color: Color(0xFF5669FF),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: TextButton.icon(
                    onPressed: resetPassword,
                    icon: const Icon(
                      Icons.lock_reset,
                      size: 18,
                      color: Color(0xFF5669FF),
                    ),
                    label: const Text(
                      "Lupa Kata Sandi",
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF5669FF),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 20,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF5669FF), Color(0xFF7B8CFF)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF5669FF).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.badge,
                          color: Colors.white70,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          "ID Pelanggan",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white70,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      idPelanggan,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Container(height: 1, color: Colors.white30),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        const Icon(
                          Icons.confirmation_number,
                          color: Colors.white70,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          "ID Subscription",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white70,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      idSub,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Pengaturan",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _settingsItem(Icons.settings, "Pengaturan Aplikasi", () {}),
                    _settingsItem(Icons.security, "Pengaturan Keamanan", () {}),
                    _settingsItem(
                      Icons.accessibility_new,
                      "Aksesibilitas",
                      () {},
                    ),
                    _settingsItem(
                      Icons.help_outline,
                      "Bantuan & Laporan",
                      () {},
                    ),
                    const SizedBox(height: 25),
                    ElevatedButton.icon(
                      onPressed: logout,
                      icon: const Icon(Icons.logout, color: Colors.white),
                      label: const Text(
                        "Keluar Aplikasi",
                        style: TextStyle(color: Colors.white, fontSize: 15),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 28,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Navbar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

  Widget _settingsItem(IconData icon, String title, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF5669FF), size: 24),
        title: Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 15,
          color: Colors.black45,
        ),
        onTap: onTap,
      ),
    );
  }
}
