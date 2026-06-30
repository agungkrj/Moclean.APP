// fiturr/pesan_layanan.dart (FIXED)
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:moclienapp/fiturr/rincian_pesanan.dart';
import 'package:moclienapp/models/order_model.dart';
import 'package:moclienapp/screens/login_page.dart';
import 'package:moclienapp/models/service_model.dart';

class PesanLayananPage extends StatefulWidget {
  final ServiceModel service;
  final Map<String, dynamic>? subscriptionBenefits; // ✅ DITAMBAHKAN

  const PesanLayananPage({
    super.key, 
    required this.service,
    this.subscriptionBenefits, // ✅ DITAMBAHKAN
  });

  @override
  State<PesanLayananPage> createState() => _PesanLayananPageState();
}

class _PesanLayananPageState extends State<PesanLayananPage> {
  String selectedUkuran = "Kecil";
  String selectedMitraId = "";
  String selectedMitraName = "Pilih Mitra Terdekat";
  String selectedBrand = "Pilih Brand";
  DateTime? selectedDate;

  final TextEditingController namaController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController typeController = TextEditingController();
  final TextEditingController nopolisiController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isLoading = false;
  bool isLoadingMitra = false;

  List<Map<String, dynamic>> mitraList = [];

  final Map<String, List<String>> brandByUkuran = {
    "Kecil": ["Pilih Brand", "Agya", "Ayla", "Brio", "Picanto"],
    "Sedang": ["Pilih Brand", "Avanza", "Jazz", "Yaris", "Xpander"],
    "Besar": ["Pilih Brand", "Fortuner", "Pajero", "Innova", "Alphard"],
  };

  @override
  void initState() {
    super.initState();
    _checkAuthAndLoadData();
    _loadMitraFromDatabase();
  }

  Future<void> _loadMitraFromDatabase() async {
    setState(() {
      isLoadingMitra = true;
    });

    try {
      print("=== MEMUAT DATA MITRA ===");

      QuerySnapshot mitraSnapshot = await _firestore
          .collection('mitra')
          .where('status', isEqualTo: 'approved')
          .get();

      print("Jumlah mitra approved: ${mitraSnapshot.docs.length}");

      List<Map<String, dynamic>> tempMitraList = [];

      for (var doc in mitraSnapshot.docs) {
        Map<String, dynamic> mitraData = doc.data() as Map<String, dynamic>;
        tempMitraList.add({
          'id': doc.id,
          'name': mitraData['namaUsaha'] ?? 'Mitra ${doc.id.substring(0, 5)}',
          'namaLengkap': mitraData['namaLengkap'] ?? '-',
          'kota': mitraData['kota'] ?? '-',
          'alamat': mitraData['alamatUsaha'] ?? '-',
          'telepon': mitraData['telepon'] ?? '-',
        });
      }

      setState(() {
        mitraList = tempMitraList;
        isLoadingMitra = false;
      });

      print("✅ Data mitra berhasil dimuat: ${mitraList.length} mitra");
    } catch (e) {
      print("❌ Error loading mitra: $e");
      setState(() {
        isLoadingMitra = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat data mitra: $e'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  Future<void> _checkAuthAndLoadData() async {
    final currentUser = _auth.currentUser;

    print("=== CEK AUTENTIKASI ===");
    print("Current User: ${currentUser?.uid}");
    print("Email: ${currentUser?.email}");
    print("======================");

    if (currentUser == null) {
      print("❌ User belum login! Redirect ke Login Page");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Silakan login terlebih dahulu untuk memesan layanan',
            ),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );

        await Future.delayed(const Duration(milliseconds: 500));

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
      return;
    }

    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final currentUser = _auth.currentUser;

    if (currentUser != null) {
      print("✅ User terautentikasi: ${currentUser.uid}");

      try {
        final userDoc = await _firestore
            .collection('users')
            .doc(currentUser.uid)
            .get();

        if (userDoc.exists) {
          final userData = userDoc.data()!;

          print("✅ Data user ditemukan di Firestore");
          print("Nama: ${userData['nama']}");
          print("Phone: ${userData['phone']}");
          print("Email: ${userData['email']}");

          setState(() {
            namaController.text = userData['nama'] ?? userData['name'] ?? '';
            phoneController.text =
                userData['phone'] ?? userData['noTelepon'] ?? '';
            emailController.text = userData['email'] ?? currentUser.email ?? '';
            addressController.text =
                userData['alamat'] ?? userData['address'] ?? '';
          });
        } else {
          print(
            "⚠️ Data user tidak ditemukan di Firestore, gunakan data dari Auth",
          );
          setState(() {
            emailController.text = currentUser.email ?? '';
            namaController.text = currentUser.displayName ?? '';
          });
        }
      } catch (e) {
        print('❌ Error loading user data: $e');

        setState(() {
          emailController.text = currentUser.email ?? '';
          namaController.text = currentUser.displayName ?? '';
        });
      }
    }
  }

  @override
  void dispose() {
    namaController.dispose();
    phoneController.dispose();
    emailController.dispose();
    addressController.dispose();
    typeController.dispose();
    nopolisiController.dispose();
    super.dispose();
  }

  Future<void> _validateAndSave() async {
    // Cek validasi data
    if (namaController.text.isEmpty) {
      _showErrorDialog("Nama lengkap harus diisi!");
      return;
    }
    
    if (phoneController.text.isEmpty) {
      _showErrorDialog("Nomor WhatsApp harus diisi!");
      return;
    }
    
    if (emailController.text.isEmpty) {
      _showErrorDialog("Email harus diisi!");
      return;
    }
    
    if (addressController.text.isEmpty) {
      _showErrorDialog("Alamat lengkap harus diisi!");
      return;
    }
    
    if (selectedMitraId.isEmpty || selectedMitraName == "Pilih Mitra Terdekat") {
      _showErrorDialog("Pilih mitra terdekat terlebih dahulu!");
      return;
    }
    
    if (selectedDate == null) {
      _showErrorDialog("Pilih tanggal pesanan terlebih dahulu!");
      return;
    }
    
    if (selectedBrand == "Pilih Brand") {
      _showErrorDialog("Pilih brand mobil terlebih dahulu!");
      return;
    }
    
    if (typeController.text.isEmpty) {
      _showErrorDialog("Tipe mobil harus diisi!");
      return;
    }
    
    if (nopolisiController.text.isEmpty) {
      _showErrorDialog("Nomor polisi harus diisi!");
      return;
    }

    // Jika semua validasi lolos, simpan pesanan
    await saveOrderToFirebase();
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Data Belum Lengkap",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      "Tutup",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_outline,
                    color: Colors.green,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Pesanan Berhasil Dibuat!",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Pesanan Anda telah berhasil dibuat. Silakan cek rincian pesanan untuk detail lebih lanjut.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      "Lihat Rincian",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> saveOrderToFirebase() async {
    print("\n=== MULAI PROSES SIMPAN PESANAN ===");

    await _auth.currentUser?.reload();
    final currentUser = _auth.currentUser;

    print("Current User ID: ${currentUser?.uid}");
    print("Current User Email: ${currentUser?.email}");
    print("Is Anonymous: ${currentUser?.isAnonymous}");

    if (currentUser == null) {
      print("❌ GAGAL: User belum login!");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Anda harus login terlebih dahulu!'),
          backgroundColor: Colors.red,
        ),
      );

      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
      return;
    }

    print("✅ User terautentikasi: ${currentUser.uid}");

    setState(() {
      isLoading = true;
    });

    try {
      String orderId = DateTime.now().millisecondsSinceEpoch.toString();

      print("📝 Membuat order dengan ID: $orderId");
      print("🏪 Mitra dipilih: $selectedMitraName (ID: $selectedMitraId)");

      OrderModel order = OrderModel(
        orderId: orderId,
        userId: currentUser.uid,
        serviceName: widget.service.name,
        servicePrice: widget.service.price,
        serviceImage: widget.service.image,
        customerName: namaController.text,
        phone: phoneController.text,
        email: emailController.text,
        address: addressController.text,
        mitra: selectedMitraName,
        orderDate: selectedDate!,
        ukuranMobil: selectedUkuran,
        brand: selectedBrand,
        type: typeController.text,
        nopolisi: nopolisiController.text,
        createdAt: DateTime.now(),
        status: 'menunggu',
      );

      print("💾 Menyimpan order ke Firestore...");

      Map<String, dynamic> orderData = order.toMap();
      orderData['mitraId'] = selectedMitraId;

      await _firestore.collection('orders').doc(orderId).set(orderData);

      print("✅ Order berhasil disimpan!");

      setState(() {
        isLoading = false;
      });

      if (mounted) {
        print("🔄 Navigasi ke halaman rincian pesanan");

        // Tampilkan dialog sukses terlebih dahulu
        _showSuccessDialog();
        
        // Tunggu sebentar lalu navigasi
        await Future.delayed(const Duration(seconds: 2));
        
        Navigator.of(context).pop(); // Tutup dialog
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => RincianPesananPage(order: order),
          ),
        );
      }
    } catch (e) {
      print("❌ ERROR saat menyimpan order: $e");

      setState(() {
        isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan pesanan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    print("=== SELESAI PROSES SIMPAN PESANAN ===\n");
  }

  @override
  Widget build(BuildContext context) {
    List<String> currentBrandList = brandByUkuran[selectedUkuran]!;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Pesan ${widget.service.name}",
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Card Info Layanan
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          widget.service.image,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 80,
                              height: 80,
                              color: Colors.grey[300],
                              child: const Icon(
                                Icons.image,
                                color: Colors.grey,
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.service.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              widget.service.price,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2C4A8F),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Pilih Ukuran Mobil
                _buildSection(
                  title: "Pilih Ukuran Mobil Anda",
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          buildUkuranButton("Kecil", Icons.directions_car),
                          buildUkuranButton("Sedang", Icons.directions_car_filled),
                          buildUkuranButton("Besar", Icons.airport_shuttle),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "Cari Tahu Ukuran Mobil Anda",
                        style: TextStyle(
                          color: Color(0xFF4A90E2),
                          fontSize: 11,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Isi Data Diri
                _buildSection(
                  title: "Isi Data Diri",
                  child: Column(
                    children: [
                      buildTextField(
                        "Nama Lengkap",
                        "Masukkan nama lengkap",
                        namaController,
                        icon: Icons.person,
                      ),
                      const SizedBox(height: 12),
                      buildTextField(
                        "Nomor WhatsApp",
                        "Contoh: 081234567890",
                        phoneController,
                        icon: Icons.phone,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 12),
                      buildTextField(
                        "Email",
                        "email@example.com",
                        emailController,
                        icon: Icons.email,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 12),
                      buildTextField(
                        "Alamat Lengkap",
                        "Jl. Contoh No. 123",
                        addressController,
                        icon: Icons.location_on,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 12),
                      buildMitraDropdownField(),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () async {
                          final pickedDate = await showDatePicker(
                            context: context,
                            initialDate: selectedDate ?? DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2100),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: const ColorScheme.light(
                                    primary: Color(0xFF2C4A8F),
                                    onPrimary: Colors.white,
                                    onSurface: Colors.black87,
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (pickedDate != null) {
                            setState(() {
                              selectedDate = pickedDate;
                            });
                          }
                        },
                        child: AbsorbPointer(
                          child: buildTextField(
                            "Tanggal Pesanan",
                            selectedDate == null
                                ? "Pilih tanggal"
                                : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                            TextEditingController(
                              text: selectedDate == null
                                  ? ""
                                  : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                            ),
                            icon: Icons.calendar_today,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Kendaraan
                _buildSection(
                  title: "Informasi Kendaraan",
                  child: Column(
                    children: [
                      buildDropdownField(
                        "Brand Mobil",
                        selectedBrand,
                        currentBrandList,
                        (val) {
                          setState(() {
                            selectedBrand = val!;
                          });
                        },
                        icon: Icons.directions_car,
                      ),
                      const SizedBox(height: 12),
                      buildTextField(
                        "Tipe Mobil",
                        "Contoh: E300",
                        typeController,
                        icon: Icons.tag,
                      ),
                      const SizedBox(height: 12),
                      buildTextField(
                        "Nomor Polisi",
                        "Contoh: B 1234 XYZ",
                        nopolisiController,
                        icon: Icons.numbers,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Button
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          namaController.clear();
                          phoneController.clear();
                          emailController.clear();
                          addressController.clear();
                          typeController.clear();
                          nopolisiController.clear();
                          setState(() {
                            selectedUkuran = "Kecil";
                            selectedMitraId = "";
                            selectedMitraName = "Pilih Mitra Terdekat";
                            selectedBrand = "Pilih Brand";
                            selectedDate = null;
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: Color(0xFF2C4A8F), width: 1.5),
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          "Reset",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Color(0xFF2C4A8F),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _validateAndSave,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: const Color(0xFF2C4A8F),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 2,
                        ),
                        child: const Text(
                          "Lanjutkan",
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),

          if (isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFF2C4A8F),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget buildMitraDropdownField() {
    List<String> dropdownItems = ["Pilih Mitra Terdekat"];

    for (var mitra in mitraList) {
      dropdownItems.add(mitra['name']);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Mitra Terdekat",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              const Icon(Icons.store, size: 20, color: Color(0xFF2C4A8F)),
              const SizedBox(width: 12),
              Expanded(
                child: isLoadingMitra
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF2C4A8F),
                          ),
                        ),
                      )
                    : DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedMitraName,
                          isExpanded: true,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black87,
                          ),
                          icon: const Icon(Icons.keyboard_arrow_down, size: 20),
                          onChanged: (String? newValue) {
                            if (newValue != null &&
                                newValue != "Pilih Mitra Terdekat") {
                              var selectedMitra = mitraList.firstWhere(
                                (mitra) => mitra['name'] == newValue,
                              );

                              setState(() {
                                selectedMitraName = newValue;
                                selectedMitraId = selectedMitra['id'];
                              });

                              print(
                                "✅ Mitra dipilih: $newValue (ID: ${selectedMitra['id']})",
                              );
                            } else {
                              setState(() {
                                selectedMitraName = "Pilih Mitra Terdekat";
                                selectedMitraId = "";
                              });
                            }
                          },
                          items: dropdownItems.map((String val) {
                            return DropdownMenuItem<String>(
                              value: val,
                              child: Text(val),
                            );
                          }).toList(),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildTextField(
    String label,
    String hint,
    TextEditingController controller, {
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 13),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 20, color: const Color(0xFF2C4A8F)),
            hintText: hint,
            hintStyle: TextStyle(fontSize: 12, color: Colors.grey.shade400),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF2C4A8F), width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildDropdownField(
    String label,
    String value,
    List<String> items,
    ValueChanged<String?> onChanged, {
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: const Color(0xFF2C4A8F)),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: value,
                    isExpanded: true,
                    style: const TextStyle(fontSize: 13, color: Colors.black87),
                    icon: const Icon(Icons.keyboard_arrow_down, size: 20),
                    onChanged: onChanged,
                    items: items
                        .map(
                          (String val) => DropdownMenuItem<String>(
                            value: val,
                            child: Text(val),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildUkuranButton(String label, IconData icon) {
    final bool isSelected = selectedUkuran == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedUkuran = label;
          selectedBrand = "Pilih Brand";
        });
      },
      child: Container(
        width: 100,
        height: 70,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2C4A8F) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF2C4A8F) : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 28,
              color: isSelected ? Colors.white : const Color(0xFF2C4A8F),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}