import 'package:flutter/material.dart';
import 'package:moclienapp/mitra/BerandaMitra.dart';
import 'package:moclienapp/mitra/laporan_pendapatan.dart';
import 'package:moclienapp/mitra/profile_mitra.dart';
import 'package:moclienapp/mitra/tambah_mitra.dart';
import 'package:moclienapp/models/karyawan_model.dart';
import 'package:moclienapp/services/karyawan_service.dart';
import 'costum_navbar.dart';

class TeknisiPage extends StatefulWidget {
  const TeknisiPage({Key? key}) : super(key: key);

  @override
  State<TeknisiPage> createState() => _TeknisiPageState();
}

class _TeknisiPageState extends State<TeknisiPage> {
  final KaryawanService _karyawanService = KaryawanService();
  int _selectedIndex = 1; // Index 1 untuk Teknisi

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    setState(() {
      _selectedIndex = index;
    });
    
    // Navigation logic sesuai dengan yang sudah ada
    switch (index) {
      case 0:
        Navigator.push(context, MaterialPageRoute(builder: (context) => BerandaMitra()));
        break;
      case 1:
        // Sudah di halaman teknisi
        break;
      case 2:
       Navigator.push(context, MaterialPageRoute(builder: (context) => LaporanPendapatan()));
        break;
      case 3:
      Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileMitraPage()));
        break;
    }
  }

  Future<void> _navigateToTambahKaryawan() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TambahKaryawanPage()),
    );

    // Refresh otomatis karena menggunakan StreamBuilder
    if (result == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Karyawan berhasil ditambahkan'),
          backgroundColor: Color(0xFF5669FF),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _showDeleteConfirmation(BuildContext context, Karyawan karyawan) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'Hapus Karyawan',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Apakah Anda yakin ingin menghapus ${karyawan.namaLengkap} dari sistem?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                bool success = await _karyawanService.deleteKaryawan(karyawan.id!);
                
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Karyawan berhasil dihapus'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF5669FF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Karyawan',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Karyawan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'kuota teknisi & shift',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
                OutlinedButton.icon(
                  onPressed: _navigateToTambahKaryawan,
                  icon: const Icon(Icons.add, size: 16, color: Color(0xFF5669FF)),
                  label: const Text(
                    'Tambah Karyawan',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF5669FF),
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF5669FF)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ],
            ),
          ),
          
          // Employee List dengan StreamBuilder
          Expanded(
            child: StreamBuilder<List<Karyawan>>(
              stream: _karyawanService.getAllKaryawan(),
              builder: (context, snapshot) {
                // Loading state
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF5669FF),
                    ),
                  );
                }

                // Error state
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                        const SizedBox(height: 16),
                        Text(
                          'Terjadi kesalahan',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.red.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          snapshot.error.toString(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                      ],
                    ),
                  );
                }

                // Empty state
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people_outline, size: 80, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        const Text(
                          'Belum ada karyawan',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Tambahkan karyawan pertama Anda',
                          style: TextStyle(fontSize: 13, color: Colors.black38),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _navigateToTambahKaryawan,
                          icon: const Icon(Icons.add),
                          label: const Text('Tambah Karyawan'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5669FF),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Data available
                final karyawanList = snapshot.data!;
                
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: karyawanList.length,
                  itemBuilder: (context, index) {
                    final karyawan = karyawanList[index];
                    return _buildEmployeeCard(karyawan);
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
      selectedIndex: _selectedIndex,
         onItemTapped: _onItemTapped,
       ),
    );
  }

  Widget _buildEmployeeCard(Karyawan karyawan) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: Row(
        children: [
          // Avatar with Initials
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF5669FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                karyawan.getInitials(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Employee Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  karyawan.namaLengkap,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${karyawan.shift} - ${karyawan.telepon}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  karyawan.posisi,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          // Delete Button
          IconButton(
            icon: Icon(Icons.delete_outline, color: Colors.red.shade400, size: 20),
            onPressed: () => _showDeleteConfirmation(context, karyawan),
            tooltip: 'Hapus karyawan',
          ),
        ],
      ),
    );
  }
}

