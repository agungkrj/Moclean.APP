import 'package:flutter/material.dart';
import 'package:moclienapp/services/firebase_order_service.dart';
import 'package:intl/intl.dart';

class DetailPesananPage extends StatelessWidget {
  final String? orderId;
  
  const DetailPesananPage({super.key, this.orderId}); 

  @override
  Widget build(BuildContext context) {
    final FirebaseOrderService orderService = FirebaseOrderService();
    
    if (orderId != null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F7FB),
        appBar: _buildAppBar(context),
        body: StreamBuilder<Map<String, dynamic>?>(
          stream: orderService.getOrderByIdStream(orderId!),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 60, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Error: ${snapshot.error}'),
                  ],
                ),
              );
            }

            if (!snapshot.hasData || snapshot.data == null) {
              return const Center(child: Text('Pesanan tidak ditemukan'));
            }

            final order = snapshot.data!;
            return _buildDetailContent(context, order);
          },
        ),
      );
    }
    
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: _buildAppBar(context),
      body: _buildDetailContent(context, _getDummyOrder()),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF4361EE),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
        onPressed: () => Navigator.pop(context),
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
    );
  }

  Widget _buildDetailContent(BuildContext context, Map<String, dynamic> order) {
    final status = order['orderStatus'] ?? 'menunggu';
    final hasTeknisi = order['teknisiName'] != null && order['teknisiName'] != 'Teknisi';
    final hasRated = order['rated'] == true;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // STATUS PESANAN
          Text(
            _getStatusTitle(status),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            _getStatusSubtitle(status),
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 18),

          // INFO TEKNISI - Tampilkan jika sudah ada
          if (hasTeknisi) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF4361EE).withOpacity(0.1),
                    const Color(0xFF4361EE).withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF4361EE).withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.person_pin_circle,
                        color: const Color(0xFF4361EE),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Teknisi yang Menangani',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4361EE),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      // Avatar Teknisi
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: const Color(0xFF4361EE),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF4361EE).withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            _getInitials(order['teknisiName']),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              order['teknisiName'],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              order['mitraName'] ?? 'Teknisi',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.shade400,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.star,
                                        color: Colors.white,
                                        size: 14,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        (order['teknisiRating'] ?? 5.0).toString(),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (order['teknisiPhone'] != null) ...[
                                  const SizedBox(width: 12),
                                  Icon(Icons.phone, size: 14, color: Colors.grey[600]),
                                  const SizedBox(width: 4),
                                  Text(
                                    order['teknisiPhone'],
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ] else if (status == 'menunggu') ...[
            // Jika belum ada teknisi dan status menunggu
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.orange.shade200,
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.hourglass_empty,
                    color: Colors.orange.shade700,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Menunggu Teknisi',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Pesanan Anda sedang menunggu teknisi untuk menerimanya',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // PROGRESS BAR
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    _buildProgressIcon(Icons.edit_calendar_outlined, _isStatusActive(status, 'diterima')),
                    _buildProgressLine(_isStatusActive(status, 'diterima')),
                    _buildProgressIcon(Icons.cleaning_services_outlined, _isStatusActive(status, 'sedang_dicuci')),
                    _buildProgressLine(_isStatusActive(status, 'sedang_dicuci')),
                    _buildProgressIcon(Icons.check_circle_outline, _isStatusActive(status, 'selesai')),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildProgressLabel('Diterima'),
                    _buildProgressLabel('Proses'),
                    _buildProgressLabel('Selesai'),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // LOKASI
          _buildSectionContainer(
            icon: Icons.location_on,
            title: 'Lokasi',
            color: const Color(0xFF4361EE),
            background: const Color(0xFFE8ECFF),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(
                  '${order['customerName'] ?? '-'} • ${order['phone'] ?? '-'}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  order['address'] ?? '-',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // DETAIL PESANAN
          _buildSectionContainer(
            icon: Icons.receipt_long,
            title: 'Detail Pesanan',
            color: const Color(0xFF4361EE),
            background: const Color(0xFFE8ECFF),
            content: Column(
              children: [
                const SizedBox(height: 10),
                _DetailRow(
                  label: 'Total Bayar',
                  value: 'Rp ${NumberFormat('#,###', 'id_ID').format(order['totalAmount'] ?? 0)}',
                  isBold: true,
                ),
                const Divider(height: 20),
                _DetailRow(
                  label: 'Layanan',
                  value: order['serviceName'] ?? '-',
                ),
                _DetailRow(
                  label: 'Kendaraan',
                  value: '${order['brand'] ?? '-'} ${order['type'] ?? '-'}',
                ),
                _DetailRow(
                  label: 'No. Polisi',
                  value: order['nopolisi'] ?? '-',
                ),
                _DetailRow(
                  label: 'Ukuran Mobil',
                  value: order['ukuranMobil'] ?? '-',
                ),
                const Divider(height: 20),
                _DetailRow(
                  label: 'ID Order',
                  value: order['orderId']?.substring((order['orderId'] as String).length - 9) ?? '-',
                ),
                _DetailRow(
                  label: 'Tanggal Order',
                  value: _formatDate(order['orderDate']),
                ),
                _DetailRow(
                  label: 'Metode Bayar',
                  value: order['paymentMethod'] ?? '-',
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),

          // BUTTON - Hanya muncul jika status selesai
          if (status == 'selesai') ...[
            if (!hasRated) ...[
              // Tombol Beri Rating
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    _showRatingDialog(context, order['orderId']);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.star, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Beri Rating Mitra',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              // Tombol Konfirmasi Selesai (setelah rating)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    _showConfirmationDialog(context, order['orderId']);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.check_circle, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Konfirmasi Pesanan Selesai',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  // ====== HELPER METHODS ======

  String _getInitials(String? name) {
    if (name == null || name.isEmpty) return '?';
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  Map<String, dynamic> _getDummyOrder() {
    return {
      'customerName': 'Panji Supanji',
      'phone': '0853 2493 2034',
      'address': 'Jl. Kemilau No.3, Batam Centre, Indonesia',
      'serviceName': 'Cuci Eksterior',
      'totalAmount': 150000,
      'brand': 'Toyota',
      'type': 'Rush',
      'ukuranMobil': 'Sedan',
      'nopolisi': 'BP 1305 S',
      'orderId': '219210233',
      'orderDate': DateTime.now().toString(),
      'orderStatus': 'selesai',
      'paymentMethod': 'QRIS',
      'teknisiName': 'Budi Santoso',
      'mitraName': 'MoClean Batam',
      'teknisiPhone': '0812-3456-7890',
      'teknisiRating': 4.8,
      'rated': false,
    };
  }

  String _getStatusTitle(String status) {
    switch (status) {
      case 'menunggu':
        return 'Menunggu Konfirmasi';
      case 'diterima':
        return 'Pesanan Diterima';
      case 'sedang_dicuci':
        return 'Sedang Diproses';
      case 'selesai':
        return 'Pesanan Selesai';
      default:
        return 'Status Pesanan';
    }
  }

  String _getStatusSubtitle(String status) {
    switch (status) {
      case 'menunggu':
        return 'Menunggu teknisi menerima pesanan Anda';
      case 'diterima':
        return 'Teknisi akan segera menuju ke lokasi Anda';
      case 'sedang_dicuci':
        return 'Teknisi sedang memproses pesanan Anda';
      case 'selesai':
        return 'Silakan beri rating untuk mitra dan konfirmasi pesanan selesai';
      default:
        return 'Pesanan Anda sedang diproses';
    }
  }

  bool _isStatusActive(String currentStatus, String checkStatus) {
    const statusOrder = ['menunggu', 'diterima', 'sedang_dicuci', 'selesai'];
    final currentIndex = statusOrder.indexOf(currentStatus);
    final checkIndex = statusOrder.indexOf(checkStatus);
    
    if (currentIndex == -1 || checkIndex == -1) return false;
    return currentIndex >= checkIndex;
  }

  String _formatDate(dynamic date) {
    try {
      if (date == null) return '-';
      DateTime dateTime;
      if (date is String) {
        dateTime = DateTime.parse(date);
      } else if (date is DateTime) {
        dateTime = date;
      } else {
        return '-';
      }
      return DateFormat('d MMM yyyy, HH:mm').format(dateTime);
    } catch (e) {
      return '-';
    }
  }

  void _showRatingDialog(BuildContext context, String? orderId) {
    if (orderId == null) return;
    
    int rating = 5;
    final commentController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: const [
              Icon(Icons.star, color: Colors.amber, size: 28),
              SizedBox(width: 8),
              Text('Beri Rating Mitra', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Bagaimana pengalaman Anda dengan layanan mitra kami?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    onPressed: () => setState(() => rating = index + 1),
                    icon: Icon(
                      index < rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 40,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: commentController,
                decoration: InputDecoration(
                  hintText: 'Tulis komentar (opsional)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                final orderService = FirebaseOrderService();
                await orderService.rateOrder(
                  orderId,
                  rating.toDouble(),
                  commentController.text,
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.white),
                        SizedBox(width: 8),
                        Text('Terima kasih atas rating Anda!'),
                      ],
                    ),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text(
                'Kirim Rating',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showConfirmationDialog(BuildContext context, String? orderId) {
    if (orderId == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.check_circle_outline, color: Colors.green, size: 28),
            SizedBox(width: 8),
            Text('Konfirmasi Pesanan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: const Text(
          'Apakah Anda yakin ingin mengkonfirmasi bahwa pesanan ini sudah selesai? Pesanan akan dipindahkan ke riwayat.',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              final orderService = FirebaseOrderService();
              // Update status pesanan menjadi completed dan pindah ke history
              await orderService.completeOrder(orderId);
              
              Navigator.pop(context); // Tutup dialog
              Navigator.pop(context); // Kembali ke halaman sebelumnya
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.white),
                      SizedBox(width: 8),
                      Text('Pesanan selesai dan tersimpan di riwayat!'),
                    ],
                  ),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 3),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              'Ya, Konfirmasi',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // ====== COMPONENT BUILDERS ======

  static Widget _buildProgressIcon(IconData icon, bool active) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: active ? const Color(0xFF4361EE) : Colors.grey[300],
        shape: BoxShape.circle,
        boxShadow: active ? [
          BoxShadow(
            color: const Color(0xFF4361EE).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ] : null,
      ),
      child: Icon(
        icon,
        size: 16,
        color: active ? Colors.white : Colors.grey[600],
      ),
    );
  }

  static Widget _buildProgressLine(bool active) {
    return Expanded(
      child: Container(
        height: 3,
        decoration: BoxDecoration(
          color: active ? const Color(0xFF4361EE) : Colors.grey[300],
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  static Widget _buildProgressLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 11,
        color: Colors.grey,
        fontWeight: FontWeight.w500,
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
              const SizedBox(width: 8),
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
  final bool isBold;

  const _DetailRow({
    required this.label,
    required this.value,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
                color: isBold ? const Color(0xFF4361EE) : Colors.black87,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}