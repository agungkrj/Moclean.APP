import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:moclienapp/services/firebase_order_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProsesOrderPage extends StatefulWidget {
  const ProsesOrderPage({Key? key}) : super(key: key);

  @override
  State<ProsesOrderPage> createState() => _ProsesOrderPageState();
}

class _ProsesOrderPageState extends State<ProsesOrderPage> {
  final FirebaseOrderService orderService = FirebaseOrderService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  @override
  void initState() {
    super.initState();
    _debugInfo();
    _detailedDebug();
  }

  void _debugInfo() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    print("═══════════════════════════════════════");
    print("📱 PROSES ORDER PAGE");
    print("👤 User ID: $userId");
    print("📧 Email: ${FirebaseAuth.instance.currentUser?.email}");
    print("═══════════════════════════════════════");
  }

  Future<void> _detailedDebug() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    print("\n🔍 ========== DETAILED DEBUG ==========");
    
    try {
      // 1. Cek semua orders untuk user ini
      final allUserOrders = await _firestore
          .collection('orders')
          .where('userId', isEqualTo: userId)
          .get();
      
      print("📦 Total orders untuk userId ini: ${allUserOrders.docs.length}");
      
      if (allUserOrders.docs.isEmpty) {
        print("⚠️ TIDAK ADA ORDER SAMA SEKALI untuk user ini!");
        print("💡 Kemungkinan:");
        print("   1. Order dibuat dengan userId yang berbeda");
        print("   2. Belum pernah buat order");
        return;
      }

      // 2. Group by status
      Map<String, int> statusCount = {};
      
      for (var doc in allUserOrders.docs) {
        final data = doc.data();
        final status = data['orderStatus'] ?? 'unknown';
        statusCount[status] = (statusCount[status] ?? 0) + 1;
        
        print("\n📋 Order: ${doc.id}");
        print("   Status: $status");
        print("   Service: ${data['serviceName']}");
        print("   Teknisi: ${data['teknisiName'] ?? 'belum ada'}");
        print("   Customer: ${data['customerName']}");
      }

      print("\n📊 RINGKASAN STATUS:");
      statusCount.forEach((status, count) {
        print("   $status: $count order");
      });

      // 3. Cek khusus untuk processing orders
      final processingCount = (statusCount['diterima'] ?? 0) + 
                             (statusCount['sedang_dicuci'] ?? 0);
      
      print("\n✅ Order yang SEHARUSNYA muncul di Proses: $processingCount");
      print("   - Diterima: ${statusCount['diterima'] ?? 0}");
      print("   - Sedang Dicuci: ${statusCount['sedang_dicuci'] ?? 0}");

      if (processingCount == 0) {
        print("\n⚠️ TIDAK ADA ORDER DENGAN STATUS 'diterima' atau 'sedang_dicuci'");
        print("💡 Solusi:");
        print("   1. Buat order baru sebagai customer");
        print("   2. Login sebagai teknisi dan TERIMA order tersebut");
        print("   3. Order akan muncul di halaman Proses");
      }

    } catch (e) {
      print("❌ Error saat debug: $e");
    }
    
    print("========================================\n");
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
          'Order Proses',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        actions: [
          // Debug button
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.blue),
            onPressed: () async {
              if (userId != null) {
                await _detailedDebug();
                await orderService.debugCheckOrders(userId);
                
                // Show dialog dengan info
                if (mounted) {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Debug Info'),
                      content: const Text(
                        'Lihat console log untuk detail lengkap!\n\n'
                        'Yang dicek:\n'
                        '✓ Total orders user\n'
                        '✓ Status setiap order\n'
                        '✓ Order yang seharusnya muncul\n\n'
                        'Jika tidak ada order "diterima" atau "sedang_dicuci", '
                        'order tidak akan muncul di halaman ini.'
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: userId == null
          ? const Center(child: Text('User belum login'))
          : StreamBuilder<List<Map<String, dynamic>>>(
              stream: orderService.getProcessingOrdersForUser(userId),
              builder: (context, snapshot) {
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
                  print("📭 No processing orders found");
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox_outlined, size: 80, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text(
                          'Belum ada pesanan diproses',
                          style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Order akan muncul di sini setelah\nteknisi menerima pesanan',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                        ),
                        const SizedBox(height: 24),
                        
                        // Tombol Debug
                        OutlinedButton.icon(
                          onPressed: () async {
                            await _detailedDebug();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Cek console log untuk detail!'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          icon: const Icon(Icons.bug_report),
                          label: const Text('Debug: Cek Kenapa Kosong'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.orange,
                          ),
                        ),
                        
                        const SizedBox(height: 12),
                        
                        OutlinedButton.icon(
                          onPressed: () {
                            setState(() {}); // Refresh
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Refresh'),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Info Card
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 32),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.lightbulb_outline, color: Colors.blue.shade700, size: 32),
                              const SizedBox(height: 8),
                              Text(
                                'Cara Menampilkan Order',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade900,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '1. Buat order sebagai customer\n'
                                '2. Login sebagai teknisi\n'
                                '3. Terima order di "Order Terbaru"\n'
                                '4. Order akan muncul di sini',
                                style: TextStyle(fontSize: 12, color: Colors.blue.shade800),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final orders = snapshot.data!;
                print("✅ Found ${orders.length} processing orders");

                return RefreshIndicator(
                  onRefresh: () async {
                    setState(() {});
                    await Future.delayed(const Duration(milliseconds: 500));
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Pesanan Sedang Diproses',
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
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${orders.length} Order',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        ...orders.map((order) => _buildOrderCard(
                              context: context,
                              order: order,
                            )),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildOrderCard({
    required BuildContext context,
    required Map<String, dynamic> order,
  }) {
    String statusText = order['orderStatus'] == 'diterima' 
        ? 'Diterima' 
        : order['orderStatus'] == 'sedang_dicuci' 
            ? 'Sedang Dicuci' 
            : 'Diproses';
    
    Color statusColor = order['orderStatus'] == 'diterima' 
        ? Colors.blue 
        : order['orderStatus'] == 'sedang_dicuci' 
            ? Colors.purple 
            : Colors.orange;

    return InkWell(
      onTap: () {
        print('Card diklik: ${order['orderId']}');
        
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Detail Order'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _dialogRow('Order ID', order['orderId'] ?? '-'),
                  _dialogRow('Service', order['serviceName'] ?? '-'),
                  _dialogRow('Status', statusText),
                  _dialogRow('Customer', order['customerName'] ?? '-'),
                  _dialogRow('Teknisi', order['teknisiName'] ?? '-'),
                  _dialogRow('Address', order['address'] ?? '-'),
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
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFE8EBFF),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: const BoxDecoration(
                color: Color(0xFF5669FF),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.directions_car,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order['serviceName'] ?? 'Layanan',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        width: 75,
                        child: Text(
                          'ID Pesanan',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          order['orderId']?.substring(
                                  order['orderId'].length > 9 
                                      ? order['orderId'].length - 9 
                                      : 0) ??
                              '-',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        width: 75,
                        child: Text(
                          'Teknisi',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          order['teknisiName'] ?? '-',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        width: 75,
                        child: Text(
                          'Alamat',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          order['address'] ?? '-',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: statusColor, width: 1),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: statusColor,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
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
            width: 80,
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