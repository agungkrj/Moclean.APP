import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:moclienapp/services/firebase_order_service.dart';
import 'package:moclienapp/services/karyawan_service.dart';
import 'package:moclienapp/models/karyawan_model.dart';
import 'package:intl/intl.dart';

class OrderTeknisiPage extends StatefulWidget {
  final String? mitraName;
  
  const OrderTeknisiPage({super.key, this.mitraName});

  @override
  State<OrderTeknisiPage> createState() => _OrderTeknisiPageState();
}

class _OrderTeknisiPageState extends State<OrderTeknisiPage> with SingleTickerProviderStateMixin {
  final FirebaseOrderService _orderService = FirebaseOrderService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  late TabController _tabController;
  Map<String, dynamic>? _mitraData;
  String selectedFilter = 'Semua';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadMitraData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadMitraData() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return;

      DocumentSnapshot doc = await _firestore.collection('mitra').doc(currentUser.uid).get();

      if (doc.exists) {
        setState(() {
          _mitraData = doc.data() as Map<String, dynamic>;
        });
      }
    } catch (e) {
      print("❌ Error loading mitra data: $e");
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3C6EEF).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.filter_list, color: Color(0xFF3C6EEF)),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Filter Status',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildFilterOption('Semua', Icons.list_alt, Colors.grey),
              _buildFilterOption('Menunggu', Icons.hourglass_empty, Colors.orange),
              _buildFilterOption('Diterima', Icons.check_circle_outline, Colors.blue),
              _buildFilterOption('Sedang Dicuci', Icons.cleaning_services, Colors.purple),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3C6EEF),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Tutup', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterOption(String label, IconData icon, Color color) {
    bool isSelected = selectedFilter == label;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: isSelected ? color.withOpacity(0.1) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () {
            setState(() => selectedFilter = label);
            Navigator.pop(context);
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected ? color : Colors.grey.shade300,
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      fontSize: 15,
                      color: isSelected ? color : Colors.black87,
                    ),
                  ),
                ),
                if (isSelected)
                  Icon(Icons.check_circle, color: color, size: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Order", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF3C6EEF),
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: const Color(0xFF3C6EEF),
            child: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              tabs: const [
                Tab(text: 'Aktif'),
                Tab(text: 'Selesai'),
              ],
            ),
          ),
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: _showFilterDialog,
              ),
              if (selectedFilter != 'Semua')
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildActiveOrdersTab(),
          _buildCompletedOrdersTab(),
        ],
      ),
    );
  }

  Widget _buildActiveOrdersTab() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: widget.mitraName != null
          ? _orderService.getOrdersForTeknisi(widget.mitraName!)
          : _orderService.getAllPendingOrders(),
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

        List<Map<String, dynamic>> orders = (snapshot.data ?? [])
            .where((order) {
              bool isCompleted = order['isCompleted'] ?? false;
              return !isCompleted;
            })
            .toList();

        if (selectedFilter != 'Semua') {
          String filterStatus = selectedFilter == 'Menunggu' ? 'menunggu'
              : selectedFilter == 'Diterima' ? 'diterima'
              : selectedFilter == 'Sedang Dicuci' ? 'sedang_dicuci' : '';
          
          orders = orders.where((order) => order['orderStatus'] == filterStatus).toList();
        }

        if (orders.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.inbox_outlined, size: 60, color: Colors.grey.shade400),
                ),
                const SizedBox(height: 16),
                Text(
                  selectedFilter == 'Semua' 
                      ? 'Belum ada pesanan aktif' 
                      : 'Tidak ada pesanan "$selectedFilter"',
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Text(
                  'Pesanan baru akan muncul di sini',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: orders.length,
          itemBuilder: (context, index) => _buildOrderCard(orders[index]),
        );
      },
    );
  }

  Widget _buildCompletedOrdersTab() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return const Center(child: Text('User tidak ditemukan'));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('orders')
          .where('teknisiId', isEqualTo: currentUser.uid)
          .where('orderStatus', isEqualTo: 'selesai')
          .where('isCompleted', isEqualTo: true)
          .snapshots(),
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

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.check_circle_outline, size: 60, color: Colors.green.shade400),
                ),
                const SizedBox(height: 16),
                Text('Belum ada pesanan selesai', style: TextStyle(fontSize: 16, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                Text('Riwayat pesanan selesai akan muncul di sini', style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
              ],
            ),
          );
        }

        final completedOrders = snapshot.data!.docs.map((doc) {
          return {
            'orderId': doc.id,
            ...doc.data() as Map<String, dynamic>,
          };
        }).toList();

        completedOrders.sort((a, b) {
          final aTime = a['completedAt'];
          final bTime = b['completedAt'];
          
          if (aTime == null && bTime == null) return 0;
          if (aTime == null) return 1;
          if (bTime == null) return -1;
          
          if (aTime is Timestamp && bTime is Timestamp) {
            return bTime.compareTo(aTime);
          }
          return 0;
        });

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: completedOrders.length,
          itemBuilder: (context, index) => _buildOrderCard(completedOrders[index], isCompleted: true),
        );
      },
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> pesanan, {bool isCompleted = false}) {
    String status = pesanan['orderStatus'] ?? 'menunggu';
    bool isWaitingConfirmation = status == 'selesai' && !(pesanan['isCompleted'] ?? false);
    
    return GestureDetector(
      onTap: () async {
        if (!isCompleted) {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailPesananTeknisiPage(
                pesanan: pesanan,
                mitraData: _mitraData,
              ),
            ),
          );
        } else {
          _showCompletedOrderDetail(pesanan);
        }
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: isCompleted ? 1 : 3,
        color: isCompleted ? Colors.grey.shade50 : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isCompleted ? Colors.grey.shade200 : Colors.transparent,
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: _getStatusColor(status).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            _getStatusIcon(status),
                            color: _getStatusColor(status),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                pesanan['serviceName'] ?? 'Layanan',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: isCompleted ? Colors.grey.shade700 : Colors.black,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'ID: ${_getShortId(pesanan['orderId'])}',
                                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor(status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _getStatusColor(status), width: 1.5),
                    ),
                    child: Text(
                      isWaitingConfirmation ? 'Konfirmasi' : _getDisplayStatus(status),
                      style: TextStyle(
                        color: _getStatusColor(status),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              
              if (isWaitingConfirmation) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.pending_outlined, size: 16, color: Colors.orange.shade700),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Menunggu rating & konfirmasi customer',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange.shade900,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              
              if (pesanan['teknisiName'] != null && !isWaitingConfirmation) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.person, size: 14, color: Colors.white),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        pesanan['teknisiName'],
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              
              Row(
                children: [
                  Icon(Icons.person_outline, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      pesanan['customerName'] ?? '-',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.directions_car_outlined, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${pesanan['brand']} ${pesanan['type']}',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
              
              if (isCompleted && pesanan['completedAt'] != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.check_circle_outline, size: 16, color: Colors.green.shade600),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _formatDate(pesanan['completedAt']),
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ),
                  ],
                ),
              ],
              
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (pesanan['rating'] != null && isCompleted)
                    Row(
                      children: [
                        Icon(Icons.star, size: 16, color: Colors.amber.shade600),
                        const SizedBox(width: 4),
                        Text(
                          pesanan['rating'].toString(),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber.shade700,
                          ),
                        ),
                      ],
                    )
                  else
                    const SizedBox(),
                  Text(
                    'Rp ${NumberFormat('#,###', 'id_ID').format(pesanan['totalAmount'] ?? 0)}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3C6EEF),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'menunggu':
        return Icons.hourglass_empty;
      case 'diterima':
        return Icons.check_circle_outline;
      case 'sedang_dicuci':
        return Icons.cleaning_services;
      case 'selesai':
        return Icons.check_circle;
      default:
        return Icons.info_outline;
    }
  }

  String _getShortId(String? orderId) {
    if (orderId == null || orderId.length <= 9) return orderId ?? '-';
    return orderId.substring(orderId.length - 9);
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
      
      return DateFormat('dd MMM yyyy, HH:mm').format(dateTime);
    } catch (e) {
      return '-';
    }
  }

  void _showCompletedOrderDetail(Map<String, dynamic> pesanan) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green.shade400, Colors.green.shade600],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.check_circle, color: Colors.white, size: 32),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Pesanan Selesai',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow('ID Order', _getShortId(pesanan['orderId'])),
                    _buildDetailRow('Layanan', pesanan['serviceName'] ?? '-'),
                    _buildDetailRow('Customer', pesanan['customerName'] ?? '-'),
                    _buildDetailRow('Kendaraan', '${pesanan['brand']} ${pesanan['type']}'),
                    _buildDetailRow('Teknisi', pesanan['teknisiName'] ?? '-'),
                    _buildDetailRow('Total', 'Rp ${NumberFormat('#,###', 'id_ID').format(pesanan['totalAmount'] ?? 0)}'),
                    if (pesanan['completedAt'] != null)
                      _buildDetailRow('Selesai', _formatDate(pesanan['completedAt'])),
                    
                    if (pesanan['rating'] != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.amber.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Rating Customer',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: List.generate(5, (index) {
                                return Icon(
                                  index < (pesanan['rating'] ?? 0).toInt() ? Icons.star : Icons.star_border,
                                  color: Colors.amber.shade600,
                                  size: 28,
                                );
                              }),
                            ),
                            if (pesanan['ratingComment'] != null && pesanan['ratingComment'].toString().isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  pesanan['ratingComment'],
                                  style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3C6EEF),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text(
                      'Tutup',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 85,
            child: Text(
              '$label:',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getDisplayStatus(String s) {
    return s == 'menunggu' ? 'Menunggu' 
        : s == 'diterima' ? 'Diterima' 
        : s == 'sedang_dicuci' ? 'Sedang Dicuci' 
        : 'Selesai';
  }

  Color _getStatusColor(String s) {
    return s == 'menunggu' ? Colors.orange 
        : s == 'diterima' ? Colors.blue 
        : s == 'sedang_dicuci' ? Colors.purple 
        : Colors.green;
  }
}

// ============== DETAIL PESANAN TEKNISI ==============

class DetailPesananTeknisiPage extends StatefulWidget {
  final Map<String, dynamic> pesanan;
  final Map<String, dynamic>? mitraData;
  
  const DetailPesananTeknisiPage({super.key, required this.pesanan, this.mitraData});

  @override
  State<DetailPesananTeknisiPage> createState() => _DetailPesananTeknisiPageState();
}

class _DetailPesananTeknisiPageState extends State<DetailPesananTeknisiPage> {
  final FirebaseOrderService _orderService = FirebaseOrderService();
  final KaryawanService _karyawanService = KaryawanService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  late String status;
  bool isLoading = false;
  Karyawan? selectedTeknisi;
  List<Karyawan> teknisiList = [];

  @override
  void initState() {
    super.initState();
    status = widget.pesanan['orderStatus'] ?? 'menunggu';
    _loadTeknisiList();
  }

  Future<void> _loadTeknisiList() async {
    _karyawanService.getAllKaryawan().listen((list) {
      if (mounted) setState(() => teknisiList = list);
    });
  }

  Future<void> _showTeknisiPicker() async {
    if (teknisiList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Belum ada teknisi. Tambahkan di menu Karyawan'), backgroundColor: Colors.orange),
      );
      return;
    }

    final result = await showDialog<Karyawan>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Pilih Teknisi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: teknisiList.length,
            itemBuilder: (context, index) {
              final tek = teknisiList[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(color: const Color(0xFF5669FF), borderRadius: BorderRadius.circular(8)),
                    child: Center(child: Text(tek.getInitials(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                  ),
                  title: Text(tek.namaLengkap, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  subtitle: Text('${tek.posisi} - ${tek.shift}', style: const TextStyle(fontSize: 12)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.pop(context, tek),
                ),
              );
            },
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal'))],
      ),
    );

    if (result != null) setState(() => selectedTeknisi = result);
  }

  Future<void> _updateStatus(String newStatus) async {
    if (newStatus == 'diterima' && selectedTeknisi == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih teknisi dulu!'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => isLoading = true);

    bool success = false;
    
    if (newStatus == 'diterima') {
      success = await _orderService.acceptOrder(
        widget.pesanan['orderId'],
        _auth.currentUser!.uid,
        teknisiName: selectedTeknisi!.namaLengkap,
        mitraName: widget.mitraData?['nama_toko'] ?? 'Mitra',
        teknisiRating: 4.8,
      );
    } else if (newStatus == 'sedang_dicuci') {
      success = await _orderService.startWork(widget.pesanan['orderId']);
    } else if (newStatus == 'selesai') {
      success = await _orderService.completeOrderByTeknisi(widget.pesanan['orderId']);
    }

    setState(() => isLoading = false);

    if (success && mounted) {
      String message = newStatus == 'diterima' 
          ? '✅ Pesanan diterima!'
          : newStatus == 'sedang_dicuci'
          ? '🚗 Cuci mobil dimulai!'
          : '🎉 Pesanan selesai! Menunggu konfirmasi customer';
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message), 
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        )
      );
      
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) Navigator.pop(context, true);
      });
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Gagal update status'), backgroundColor: Colors.red)
      );
    }
  }

  String _getDisplayStatus(String s) {
    return s == 'menunggu' ? 'Menunggu' : s == 'diterima' ? 'Diterima' : s == 'sedang_dicuci' ? 'Sedang Dicuci' : 'Selesai';
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.pesanan;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Detail Pesanan", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF3C6EEF),
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (status == 'menunggu') ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.person_add, color: Colors.blue.shade700, size: 20),
                            const SizedBox(width: 8),
                            const Text('Pilih Teknisi', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        InkWell(
                          onTap: _showTeknisiPicker,
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: selectedTeknisi != null ? const Color(0xFF5669FF) : Colors.grey.shade300,
                                width: selectedTeknisi != null ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                if (selectedTeknisi != null) ...[
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF5669FF),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Text(
                                        selectedTeknisi!.getInitials(),
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                ],
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        selectedTeknisi?.namaLengkap ?? 'Tap untuk pilih teknisi',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: selectedTeknisi != null ? FontWeight.w600 : FontWeight.normal,
                                        ),
                                      ),
                                      if (selectedTeknisi != null)
                                        Text(
                                          '${selectedTeknisi!.posisi} • ${selectedTeknisi!.shift}',
                                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                                        ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.arrow_drop_down, color: Colors.grey),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
                
                if (status != 'menunggu' && p['teknisiName'] != null) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.green.shade50, Colors.green.shade100],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.shade300),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: const Color(0xFF5669FF),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.person, color: Colors.white, size: 28),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Teknisi', style: TextStyle(fontSize: 11, color: Colors.black54)),
                              Text(
                                p['teknisiName'],
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade400,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.star, color: Colors.white, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                p['teknisiRating']?.toString() ?? '4.8',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on, color: Color(0xFF3C6EEF)),
                      const SizedBox(width: 10),
                      Expanded(child: Text(p['address'] ?? '-', style: const TextStyle(fontSize: 14))),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                _buildSection('Pesanan', [
                  _row('ID', p['orderId'] ?? '-'),
                  _row('Layanan', p['serviceName'] ?? '-'),
                  _row('Status', _getDisplayStatus(status)),
                ]),
                const SizedBox(height: 16),
                
                _buildSection('Pelanggan', [
                  _row('Nama', p['customerName'] ?? '-'),
                  _row('WhatsApp', p['phone'] ?? '-'),
                ]),
                const SizedBox(height: 16),
                
                _buildSection('Kendaraan', [
                  _row('Brand', p['brand'] ?? '-'),
                  _row('Type', p['type'] ?? '-'),
                  _row('Nopol', p['nopolisi'] ?? '-'),
                ]),
                const SizedBox(height: 16),
                
                _buildSection('Pembayaran', [
                  _row('Metode', p['paymentMethod'] ?? '-'),
                  _row('Total', 'Rp ${NumberFormat('#,###', 'id_ID').format(p['totalAmount'] ?? 0)}', bold: true),
                ]),
                const SizedBox(height: 100),
              ],
            ),
          ),

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: isLoading ? null : () {
                  if (status == 'menunggu') {
                    _updateStatus('diterima');
                  } else if (status == 'diterima') {
                    _updateStatus('sedang_dicuci');
                  } else if (status == 'sedang_dicuci') {
                    _updateStatus('selesai');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: status == 'sedang_dicuci' ? Colors.green : const Color(0xFF3C6EEF),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  status == 'menunggu' ? 'Terima Pesanan' : status == 'diterima' ? 'Mulai Cuci' : 'Selesai',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ),

          if (isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const Divider(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _row(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: TextStyle(color: Colors.grey.shade700)),
          ),
          const Text(': '),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal),
            ),
          ),
        ],
      ),
    );
  }
}