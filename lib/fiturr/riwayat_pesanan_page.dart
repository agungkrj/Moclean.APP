import 'package:flutter/material.dart';
import 'package:moclienapp/fiturr/aktivitas.dart';
import 'package:moclienapp/fiturr/beranda_page.dart';
import 'package:moclienapp/fiturr/navbar.dart';
import 'package:moclienapp/fiturr/profil_page.dart';
import 'package:moclienapp/services/firebase_order_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class RiwayatPesananPage extends StatefulWidget {
  const RiwayatPesananPage({super.key});

  @override
  State<RiwayatPesananPage> createState() => _RiwayatPesananPageState();
}

class _RiwayatPesananPageState extends State<RiwayatPesananPage> {
  int _selectedIndex = 2;
  final FirebaseOrderService _orderService = FirebaseOrderService();
  String _searchQuery = '';
  String? _userId;
  
  @override
  void initState() {
    super.initState();
    _loadUserId();
  }
  
  Future<void> _loadUserId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _userId = user.uid;
      });
    }
  }

  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const BerandaPage()));
        break;
      case 1:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AktifitasScreen()));
        break;
      case 2:
        break;
      case 3:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ProfilPage()));
        break;
    }
  }

  String _getServiceImage(String serviceName) {
    final lowerService = serviceName.toLowerCase();
    if (lowerService.contains('interior')) {
      return 'assets/interior.png';
    } else if (lowerService.contains('eksterior') || lowerService.contains('exterior')) {
      return 'assets/eksterio.png';
    } else if (lowerService.contains('komplit') || lowerService.contains('complete')) {
      return 'assets/cucikomplit.png';
    }
    return 'assets/cucikomplit.png';
  }

  String _formatCurrency(dynamic value) {
    try {
      int amount = 0;
      if (value is int) {
        amount = value;
      } else if (value is double) {
        amount = value.toInt();
      } else if (value is String) {
        amount = int.tryParse(value) ?? 0;
      }
      return NumberFormat('#,###', 'id_ID').format(amount);
    } catch (e) {
      return '0';
    }
  }

  String _getOrderFinalStatus(Map<String, dynamic> order) {
    if (order['orderStatus'] == 'dibatalkan') return 'Dibatalkan';
    return 'Selesai';
  }

  Color _getStatusColor(Map<String, dynamic> order) {
    if (order['orderStatus'] == 'dibatalkan') return Colors.redAccent;
    return Colors.green;
  }

  String _formatDate(dynamic date) {
    try {
      if (date == null) return '-';
      DateTime dateTime;
      if (date is String) {
        dateTime = DateTime.parse(date);
      } else if (date is DateTime) {
        dateTime = date;
      } else if (date.runtimeType.toString().contains('Timestamp')) {
        dateTime = DateTime.fromMillisecondsSinceEpoch(date.millisecondsSinceEpoch);
      } else {
        return '-';
      }
      return DateFormat('EEEE, dd MMMM yyyy HH:mm', 'id_ID').format(dateTime) + ' WIB';
    } catch (e) {
      return '-';
    }
  }

  String _formatDateSearch(dynamic date) {
    try {
      if (date == null) return '';
      DateTime dateTime;
      if (date is String) {
        dateTime = DateTime.parse(date);
      } else if (date is DateTime) {
        dateTime = date;
      } else if (date.runtimeType.toString().contains('Timestamp')) {
        dateTime = DateTime.fromMillisecondsSinceEpoch(date.millisecondsSinceEpoch);
      } else {
        return '';
      }
      return DateFormat('dd MMMM yyyy', 'id_ID').format(dateTime).toLowerCase();
    } catch (e) {
      return '';
    }
  }

  void _showDetailDialog(Map<String, dynamic> order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: EdgeInsets.zero,
        content: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [Colors.white, Colors.blue.shade50],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xff3D5AFE), Color(0xff5C7CFF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.receipt_long, color: Colors.white, size: 28),
                      const SizedBox(width: 12),
                      const Text('Detail Pesanan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow('ID Pesanan', order['orderId']?.toString().substring(order['orderId'].toString().length - 9) ?? '-'),
                      _buildDetailRow('Tanggal', _formatDate(order['completedAt'] ?? order['orderDate'])),
                      const Divider(height: 24),
                      _buildDetailRow('Kendaraan', '${order['brand'] ?? '-'} ${order['type'] ?? '-'}'),
                      _buildDetailRow('No. Polisi', order['plateNumber'] ?? '-'),
                      _buildDetailRow('Ukuran', order['ukuranMobil'] ?? '-'),
                      const Divider(height: 24),
                      _buildDetailRow('Jenis Layanan', order['serviceName'] ?? '-'),
                      _buildDetailRow('Harga Layanan', 'Rp ${_formatCurrency(order['servicePrice'] ?? 0)}'),
                      if (order['addons'] != null && (order['addons'] as List).isNotEmpty) ...[
                        const SizedBox(height: 8),
                        const Text('Add-ons:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black87)),
                        const SizedBox(height: 4),
                        ...((order['addons'] as List).map((addon) => Padding(
                          padding: const EdgeInsets.only(left: 12, top: 4),
                          child: Text('• ${addon['name']} - Rp ${_formatCurrency(addon['price'])}', 
                            style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                        ))),
                      ],
                      const Divider(height: 24),
                      _buildDetailRow('Total Pembayaran', 'Rp ${_formatCurrency(order['totalAmount'] ?? 0)}', isTotal: true),
                      _buildDetailRow('Status', _getOrderFinalStatus(order), valueColor: _getStatusColor(order)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
            child: const Text('Tutup', style: TextStyle(color: Color(0xff3D5AFE), fontWeight: FontWeight.bold, fontSize: 15)),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isTotal = false, Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(label, style: TextStyle(fontSize: isTotal ? 15 : 14, fontWeight: isTotal ? FontWeight.bold : FontWeight.w600, color: Colors.grey[700])),
          ),
          Expanded(
            flex: 3,
            child: Text(value, style: TextStyle(fontSize: isTotal ? 15 : 14, fontWeight: isTotal ? FontWeight.bold : FontWeight.w500, 
              color: valueColor ?? (isTotal ? Colors.green[700] : Colors.black87)), textAlign: TextAlign.right),
          ),
        ],
      ),
    );
  }

  void _showRatingDialog(double? rating, String? comment) {
    if (rating == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Belum ada penilaian untuk pesanan ini'), backgroundColor: Colors.orange, behavior: SnackBarBehavior.floating),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: EdgeInsets.zero,
        content: Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), 
            gradient: LinearGradient(colors: [Colors.white, Colors.amber.shade50], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [Colors.amber.shade400, Colors.orange.shade400], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.star_rounded, color: Colors.white, size: 28),
                    SizedBox(width: 12),
                    Text('Penilaian Anda', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text('Rating Layanan', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black87)),
                    const SizedBox(height: 12),
                    Row(mainAxisAlignment: MainAxisAlignment.center, 
                      children: List.generate(5, (index) => Icon(
                        index < rating.toInt() ? Icons.star_rounded : Icons.star_outline_rounded, color: Colors.amber, size: 36))),
                    const SizedBox(height: 8),
                    Text('${rating.toStringAsFixed(1)} / 5.0', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                    if (comment != null && comment.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      const Text('Komentar', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black87)),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), 
                          border: Border.all(color: Colors.grey.shade300)),
                        child: Text(comment, style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.5)),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 15)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FA),
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: const Color(0xff3D5AFE),
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: LinearGradient(colors: [Color(0xff3D5AFE), Color(0xff5C7CFF)], 
            begin: Alignment.topLeft, end: Alignment.bottomRight)),
        ),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(20))),
        title: const Text('Riwayat Pesanan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 20, letterSpacing: 0.5)),
        centerTitle: true,
      ),
      bottomNavigationBar: Navbar(selectedIndex: _selectedIndex, onItemTapped: _onItemTapped),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              height: 52,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), 
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4))]),
              child: TextField(
                onChanged: (value) => setState(() => _searchQuery = value),
                decoration: InputDecoration(hintText: "Cari pesanan...", hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                  prefixIcon: Icon(Icons.search_rounded, color: Colors.grey[600], size: 24), border: InputBorder.none, 
                  contentPadding: const EdgeInsets.symmetric(vertical: 16)),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _userId == null 
                ? const Center(child: CircularProgressIndicator())
                : StreamBuilder<List<Map<String, dynamic>>>(
                    stream: _orderService.getCompletedOrdersForUser(_userId!),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                      if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Icon(Icons.history, size: 80, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text('Belum Ada Riwayat Pesanan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey[600])),
                        ]));
                      }

                      final orders = snapshot.data!.where((order) {
                        if (_searchQuery.isEmpty) return true;
                        final searchLower = _searchQuery.toLowerCase();
                        return _formatDateSearch(order['completedAt'] ?? order['orderDate']).contains(searchLower) ||
                               (order['orderId']?.toString().toLowerCase() ?? '').contains(searchLower) ||
                               (order['serviceName']?.toString().toLowerCase() ?? '').contains(searchLower);
                      }).toList();

                      if (orders.isEmpty) {
                        return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Icon(Icons.search_off, size: 80, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text('Tidak Ada Hasil', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey[600])),
                        ]));
                      }

                      return ListView.builder(
                        itemCount: orders.length,
                        itemBuilder: (context, index) {
                          final order = orders[index];
                          final orderIdStr = order['orderId']?.toString() ?? '-';
                          return _buildRiwayatCard(
                            order: order,
                            tanggal: _formatDate(order['completedAt'] ?? order['orderDate']),
                            idOrder: orderIdStr.length > 9 ? orderIdStr.substring(orderIdStr.length - 9) : orderIdStr,
                            jenisLayanan: '${order['serviceName'] ?? '-'} (${order['ukuranMobil'] ?? '-'})',
                            status: _getOrderFinalStatus(order),
                            statusColor: _getStatusColor(order),
                            rating: order['rating']?.toDouble(),
                            comment: order['ratingComment'],
                          );
                        },
                      );
                    },
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRiwayatCard({
    required Map<String, dynamic> order, required String tanggal, required String idOrder,
    required String jenisLayanan, required String status, required Color statusColor,
    double? rating, String? comment,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), 
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xff3D5AFE).withOpacity(0.1), Color(0xff5C7CFF).withOpacity(0.05)], 
                begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today_rounded, size: 16, color: Color(0xff3D5AFE)),
                const SizedBox(width: 8),
                Expanded(child: Text(tanggal, style: const TextStyle(color: Colors.black87, fontSize: 13, fontWeight: FontWeight.w600))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: statusColor.withOpacity(0.15), borderRadius: BorderRadius.circular(20), 
                    border: Border.all(color: statusColor.withOpacity(0.3))),
                  child: Text(status, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 90, height: 90,
                  decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      _getServiceImage(order['serviceName'] ?? ''), 
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.blue[50], 
                          child: Icon(Icons.local_car_wash, color: Colors.blueAccent, size: 40),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Text("ID: ", style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                        Text(idOrder, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
                      ]),
                      const SizedBox(height: 6),
                      Text("${order['brand'] ?? '-'} ${order['type'] ?? '-'}", 
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87), 
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Text(jenisLayanan, style: TextStyle(fontSize: 13, color: Colors.grey[700]), 
                        maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [Color(0xff3D5AFE).withOpacity(0.1), Color(0xff5C7CFF).withOpacity(0.05)]),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text("Rp ${_formatCurrency(order['totalAmount'] ?? 0)}", 
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xff3D5AFE))),
                      ),
                      if (rating != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [Colors.amber.shade100, Colors.orange.shade50]),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.amber.shade300, width: 1),
                          ),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                            const SizedBox(width: 4),
                            Text(rating.toStringAsFixed(1), style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 13)),
                          ]),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Divider(height: 1, color: Colors.grey[200])),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.amber.shade400, width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () => _showRatingDialog(rating, comment),
                    icon: const Icon(Icons.star_outline_rounded, size: 18),
                    label: const Text("Penilaian", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xff3D5AFE),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                    ),
                    onPressed: () => _showDetailDialog(order),
                    icon: const Icon(Icons.receipt_long_rounded, size: 18, color: Colors.white),
                    label: const Text("Detail", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
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