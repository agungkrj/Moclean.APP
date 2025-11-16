import 'package:flutter/material.dart';

class DataPenggunaPage extends StatelessWidget {
  const DataPenggunaPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Data Pengguna',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildUserCard(
            context,
            status: 'AKTIF',
            nama: 'Andre Taulany',
            noWhatsapp: '0812 3456 5656',
            idPengguna: '1122',
            email: 'andre.taulany@email.com',
            alamat: 'Jl. Merdeka No. 45, Jakarta Pusat',
            tanggalBergabung: '15 Januari 2024',
          ),
          const SizedBox(height: 12),
          _buildUserCard(
            context,
            status: 'AKTIF',
            nama: 'Andre Taulany',
            noWhatsapp: '0812 3456 5656',
            idPengguna: '1122',
            email: 'andre.taulany@email.com',
            alamat: 'Jl. Merdeka No. 45, Jakarta Pusat',
            tanggalBergabung: '15 Januari 2024',
          ),
          const SizedBox(height: 12),
          _buildUserCard(
            context,
            status: 'AKTIF',
            nama: 'Andre Taulany',
            noWhatsapp: '0812 3456 5656',
            idPengguna: '1122',
            email: 'andre.taulany@email.com',
            alamat: 'Jl. Merdeka No. 45, Jakarta Pusat',
            tanggalBergabung: '15 Januari 2024',
          ),
          const SizedBox(height: 12),
          _buildUserCard(
            context,
            status: 'AKTIF',
            nama: 'Andre Taulany',
            noWhatsapp: '0812 3456 5656',
            idPengguna: '1122',
            email: 'andre.taulany@email.com',
            alamat: 'Jl. Merdeka No. 45, Jakarta Pusat',
            tanggalBergabung: '15 Januari 2024',
          ),
          const SizedBox(height: 12),
          _buildUserCard(
            context,
            status: 'AKTIF',
            nama: 'Andre Taulany',
            noWhatsapp: '0812 3456 5656',
            idPengguna: '1122',
            email: 'andre.taulany@email.com',
            alamat: 'Jl. Merdeka No. 45, Jakarta Pusat',
            tanggalBergabung: '15 Januari 2024',
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(
    BuildContext context, {
    required String status,
    required String nama,
    required String noWhatsapp,
    required String idPengguna,
    required String email,
    required String alamat,
    required String tanggalBergabung,
  }) {
    return InkWell(
      onTap: () {
        _showUserDetailDialog(
          context,
          status: status,
          nama: nama,
          noWhatsapp: noWhatsapp,
          idPengguna: idPengguna,
          email: email,
          alamat: alamat,
          tanggalBergabung: tanggalBergabung,
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFE8EBFF),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'STATUS',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    status,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'NO WHATSAPP',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    noWhatsapp,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'NAMA',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    nama,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'ID PENGGUNA',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    idPengguna,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showUserDetailDialog(
    BuildContext context, {
    required String status,
    required String nama,
    required String noWhatsapp,
    required String idPengguna,
    required String email,
    required String alamat,
    required String tanggalBergabung,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Detail Pengguna',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Avatar & Name
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: const Color(0xFF5669FF),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              nama.split(' ').map((e) => e[0]).take(2).join(),
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          nama,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4CAF50),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            status,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Details
                  _buildDetailRow(Icons.badge_outlined, 'ID Pengguna', idPengguna),
                  const SizedBox(height: 16),
                  _buildDetailRow(Icons.phone_outlined, 'No. WhatsApp', noWhatsapp),
                  const SizedBox(height: 16),
                  _buildDetailRow(Icons.email_outlined, 'Email', email),
                  const SizedBox(height: 16),
                  _buildDetailRow(Icons.location_on_outlined, 'Alamat', alamat),
                  const SizedBox(height: 16),
                  _buildDetailRow(Icons.calendar_today_outlined, 'Tanggal Bergabung', tanggalBergabung),

                  const SizedBox(height: 24),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            // Edit user
                          },
                          icon: const Icon(Icons.edit_outlined, size: 18),
                          label: const Text('Edit'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF5669FF),
                            side: const BorderSide(color: Color(0xFF5669FF)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            // Contact user
                          },
                          icon: const Icon(Icons.chat_outlined, size: 18),
                          label: const Text('Hubungi'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5669FF),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: const Color(0xFF5669FF),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}