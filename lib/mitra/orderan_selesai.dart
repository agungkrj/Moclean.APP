import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:moclienapp/services/firebase_order_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderanSelesaiPage extends StatefulWidget {
  const OrderanSelesaiPage({Key? key}) : super(key: key);

  @override
  State<OrderanSelesaiPage> createState() => _OrderanSelesaiPageState();
}

class _OrderanSelesaiPageState extends State<OrderanSelesaiPage> {
  final FirebaseOrderService orderService = FirebaseOrderService();

  @override
  void initState() {
    super.initState();
    _debugInfo();
  }

  void _debugInfo() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    print("═══════════════════════════════════════");
    print("📱 ORDERAN SELESAI PAGE");
    print("👤 User ID: $userId");
    print("📧 Email: ${FirebaseAuth.instance.currentUser?.email}");
    print("═══════════════════════════════════════");
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

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
          'Orderan Selesai',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // Debug button
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.green),
            onPressed: () async {
              if (userId != null) {
                await orderService.debugCheckOrders(userId);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Check console for debug info'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: userId == null
          ? const Center(child: Text('User belum login'))
          : StreamBuilder<List<Map<String, dynamic>>>(
              stream: orderService.getCompletedOrdersForUser(userId),
              builder: (context, snapshot) {
                // Debug connection state
                print("🔄 Connection State: ${snapshot.connectionState}");

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  print("❌ Stream Error: ${snapshot.error}");
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 60, color: Colors.red),
                        const SizedBox(height: 16),
                        Text('Error: ${snapshot.error}'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {}); // Refresh
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  print("📭 No completed orders found");
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_outline, size: 80, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text(
                          'Belum ada order selesai',
                          style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Order selesai akan muncul di sini',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                        ),
                        const SizedBox(height: 24),
                        OutlinedButton.icon(
                          onPressed: () {
                            setState(() {}); // Refresh
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Refresh'),
                        ),
                      ],
                    ),
                  );
                }

                final orders = snapshot.data!;
                print("✅ Found ${orders.length} completed orders");

                return RefreshIndicator(
                  onRefresh: () async {
                    setState(() {});
                    await Future.delayed(const Duration(milliseconds: 500));
                  },
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 16, top: 8),
                    itemCount: orders.length + 1, // +1 for header
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        // Header
                        return Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Riwayat Pesanan Selesai',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${orders.length} Order',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green.shade700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      final o = orders[index - 1];
                      return _buildOrderCard(
                        context: context,
                        title: o['serviceName'] ?? 'Layanan',
                        idPesanan: o['orderId'],
                        teknisi: o['teknisiName'] ?? '-',
                        alamat: o['address'] ?? '-',
                        total: o['totalAmount'] ?? 0,
                        tanggal: o['completedAt'],
                        brand: o['brand'] ?? '',
                        type: o['type'] ?? '',
                        order: o,
                      );
                    },
                  ),
                );
              },
            ),
    );
  }

  Widget _buildOrderCard({
    required BuildContext context,
    required String title,
    required String idPesanan,
    required String teknisi,
    required String alamat,
    required int total,
    required String brand,
    required String type,
    required Map<String, dynamic> order,
    dynamic tanggal,
  }) {
    String formattedDate = '-';
    if (tanggal != null && tanggal is Timestamp) {
      formattedDate = DateFormat('dd MMM yyyy • HH:mm', 'id_ID')
          .format(tanggal.toDate());
    }

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        // Show detail dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Detail Order Selesai'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _dialogRow('Order ID', idPesanan),
                  _dialogRow('Service', title),
                  _dialogRow('Customer', order['customerName'] ?? '-'),
                  _dialogRow('Teknisi', teknisi),
                  _dialogRow('Kendaraan', '$brand $type'),
                  _dialogRow('Address', alamat),
                  _dialogRow('Total', 'Rp ${NumberFormat('#,###', 'id_ID').format(total)}'),
                  _dialogRow('Selesai pada', formattedDate),
                  _dialogRow('User ID', order['userId'] ?? '-'),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFE8EBFF),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: const BoxDecoration(
                    color: Color(0xFF5669FF),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.directions_car,
                      color: Colors.white, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.green, width: 1),
                            ),
                            child: const Text(
                              'Selesai',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.green,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      _row('ID', idPesanan.substring(
                          idPesanan.length > 9 ? idPesanan.length - 9 : 0)),
                      _row('Teknisi', teknisi),
                      _row('Kendaraan', '$brand $type'),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 12, color: Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Text(
                            formattedDate,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Pembayaran',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                  Text(
                    'Rp ${NumberFormat('#,###', 'id_ID').format(total)}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5669FF),
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

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Text(label,
                style: const TextStyle(fontSize: 12, color: Colors.black54)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(fontSize: 12, color: Colors.black87)),
          ),
        ],
      ),
    );
  }

  Widget _dialogRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const Text(': '),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}