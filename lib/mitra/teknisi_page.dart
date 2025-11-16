import 'package:flutter/material.dart';
import 'package:moclienapp/mitra/BerandaMitra.dart';
import 'package:moclienapp/mitra/tambah_mitra.dart';
import 'costum_navbar.dart'; // Import navbar custom

class TeknisiPage extends StatefulWidget {
  const TeknisiPage({Key? key}) : super(key: key);

  @override
  State<TeknisiPage> createState() => _TeknisiPageState();
}

class _TeknisiPageState extends State<TeknisiPage> {
  int _selectedIndex = 1; // Index 1 untuk Teknisi

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    setState(() {
      _selectedIndex = index;
    });
    
    switch (index) {
      case 0:
        Navigator.push(context, MaterialPageRoute(builder: (context) => BerandaMitra()));
        break;
      case 1:
        // Sudah di halaman teknisi
        break;
      case 2:
        
      case 3:
        
    }
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
                  onPressed: () {
                    Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const TambahKaryawanPage()),
                  );
                  },
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
          
          // Employee List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildEmployeeCard('LF', 'LYOD. F', 'shift pagi - 0812 - XXXX'),
                _buildEmployeeCard('JA', 'JAVIER. A', 'shift pagi - 0812 - XXXX'),
                _buildEmployeeCard('AM', 'ALICIA. M', 'shift pagi - 0812 - XXXX'),
                _buildEmployeeCard('US', 'ULER. S', 'shift pagi - 0812 - XXXX'),
                _buildEmployeeCard('FL', 'FRONTERA. L', 'shift pagi - 0812 - XXXX'),
                _buildEmployeeCard('AJ', 'AGUNG. J', 'shift pagi - 0812 - XXXX'),
                _buildEmployeeCard('MA', 'MEGANTO. A', 'shift pagi - 0812 - XXXX'),
                const SizedBox(height: 80),
              ],
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

  Widget _buildEmployeeCard(String initials, String name, String info) {
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
                initials,
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
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  info,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}