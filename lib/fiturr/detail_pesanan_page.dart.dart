import 'package:flutter/material.dart';
import 'package:moclienapp/fiturr/status_pesanan.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DetailPesananPage(),
    );
  }
}

class DetailPesananPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4361EE),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () {},
        ),
        title: const Text(
          'Detail Pesanan',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== STATUS PESANAN =====
            const Text(
              'Pesanan Diproses',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Teknisi Sedang Menuju ke Lokasi',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 18),

            // ===== INFO TEKNISI =====
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 22,
                        backgroundImage: AssetImage('assets/icon.png'), // ubah sesuai asetmu
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Budi Setiawan',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Text(
                              'AllClean Car Wash (Teknisi)',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: const [
                                Icon(Icons.phone, size: 14, color: Colors.grey),
                                SizedBox(width: 4),
                                Text(
                                  '0839-2823-1934',
                                  style: TextStyle(fontSize: 12, color: Colors.black87),
                                ),
                                SizedBox(width: 8),
                                Icon(Icons.star, color: Colors.amber, size: 14),
                                SizedBox(width: 3),
                                Text(
                                  '5.0',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ===== PROGRESS BAR =====
                  Row(
                    children: [
                      _buildProgressIcon(Icons.edit_calendar_outlined, true),
                      _buildProgressLine(true),
                      _buildProgressIcon(Icons.cleaning_services_outlined, false),
                      _buildProgressLine(false),
                      _buildProgressIcon(Icons.person_outline, false),
                      _buildProgressLine(false),
                      _buildProgressIcon(Icons.check_circle_outline, false),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ===== LOKASI =====
            _buildSectionContainer(
              icon: Icons.location_on,
              title: 'Lokasi',
              color: const Color(0xFF4361EE),
              background: const Color(0xFFE8ECFF),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  SizedBox(height: 6),
                  Text(
                    '[Panji Supanji] 0853 2493 2034',
                    style: TextStyle(fontSize: 13, color: Colors.black87),
                  ),
                  Text(
                    'Jl. Kemilau No.3, Batam Centre, Indonesia',
                    style: TextStyle(fontSize: 13, color: Colors.black87),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ===== PESANAN =====
            _buildSectionContainer(
              icon: Icons.receipt_long,
              title: 'Pesanan',
              color: const Color(0xFF4361EE),
              background: const Color(0xFFE8ECFF),
              content: Column(
                children: const [
                  SizedBox(height: 10),
                  _DetailRow(label: 'Total', value: 'RP150.000'),
                  _DetailRow(label: 'Nama', value: 'Panji Supanji'),
                  _DetailRow(label: 'Nama Merk', value: 'Toyota Rush'),
                  _DetailRow(label: 'Nomor Plat', value: 'BP 1305 S'),
                  _DetailRow(label: 'ID Pembayaran', value: '694832204'),
                  _DetailRow(label: 'ID Order', value: '219210233'),
                  _DetailRow(label: 'Tanggal Bayar', value: '2 Juli 2025-10:24'),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // ===== BUTTON =====
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                        Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => StatusPesananPage()),
                      );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4361EE),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Cek Status',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ====== COMPONENT BUILDER ======

  static Widget _buildProgressIcon(IconData icon, bool active) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: active ? const Color(0xFF4361EE) : Colors.grey[300],
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: 15,
        color: active ? Colors.white : Colors.grey[600],
      ),
    );
  }

  static Widget _buildProgressLine(bool active) {
    return Expanded(
      child: Container(
        height: 2,
        color: active ? const Color(0xFF4361EE) : Colors.grey[300],
      ),
    );
  }

  Widget _buildSectionContainer({
    required IconData icon,
    required String title,
    required Color color,
    required Color background,
    required Widget content,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          content,
        ],
      ),
    );
  }
}

// ====== DETAIL ROW COMPONENT ======
class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[800])),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
