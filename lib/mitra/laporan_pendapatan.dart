import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:moclienapp/mitra/BerandaMitra.dart';
import 'package:moclienapp/mitra/profile_mitra.dart';
import 'package:moclienapp/mitra/teknisi_page.dart';
import 'costum_navbar.dart';

class LaporanPendapatan extends StatefulWidget {
  const LaporanPendapatan({Key? key}) : super(key: key);

  @override
  State<LaporanPendapatan> createState() => _LaporanPendapatanState();
}

class _LaporanPendapatanState extends State<LaporanPendapatan> {
  int _selectedIndex = 2;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  bool isLoading = true;
  int totalPesanan = 0;
  double totalPendapatan = 0;
  double komisiMoClean = 0;
  double pendapatanBersih = 0;
  List<FlSpot> chartData = [];
  Map<String, double> dailyRevenue = {};

  @override
  void initState() {
    super.initState();
    _loadRevenueData();
  }

  Future<void> _loadRevenueData() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        print("❌ No user logged in");
        setState(() => isLoading = false);
        return;
      }

      print("🔍 Loading revenue for user: ${currentUser.uid}");

      // Ambil order berdasarkan teknisiId (karena acceptOrder menyimpan teknisiId)
      QuerySnapshot snapshot = await _firestore
          .collection('orders')
          .where('teknisiId', isEqualTo: currentUser.uid)
          .where('orderStatus', isEqualTo: 'selesai')
          .get();

      print("📦 Total completed orders found: ${snapshot.docs.length}");

      double tempTotal = 0;
      int tempCount = 0;
      Map<String, double> tempDailyRevenue = {
        'Mon': 0,
        'Tue': 0,
        'Wed': 0,
        'Thu': 0,
        'Fri': 0,
        'Sat': 0,
        'Sun': 0,
      };

      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        double amount = (data['totalAmount'] ?? 0).toDouble();
        tempTotal += amount;
        tempCount++;

        print("💰 Order: ${data['serviceName']} - Rp $amount - ${data['completedAt']}");

        // Kelompokkan berdasarkan hari
        if (data['completedAt'] != null) {
          DateTime completedDate;
          if (data['completedAt'] is Timestamp) {
            completedDate = (data['completedAt'] as Timestamp).toDate();
          } else if (data['completedAt'] is String) {
            completedDate = DateTime.parse(data['completedAt']);
          } else {
            continue;
          }

          String dayName = DateFormat('EEE').format(completedDate);
          if (tempDailyRevenue.containsKey(dayName)) {
            tempDailyRevenue[dayName] = tempDailyRevenue[dayName]! + amount;
          }
        }
      }

      print("💵 Total Revenue: Rp $tempTotal from $tempCount orders");

      // Hitung komisi 10%
      double tempKomisi = tempTotal * 0.10;
      double tempBersih = tempTotal - tempKomisi;

      // Konversi ke chart data
      List<FlSpot> tempChartData = [];
      List<String> days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      for (int i = 0; i < days.length; i++) {
        double value = (tempDailyRevenue[days[i]] ?? 0) / 100000; // Skala untuk grafik
        tempChartData.add(FlSpot(i.toDouble(), value));
      }

      setState(() {
        totalPesanan = tempCount;
        totalPendapatan = tempTotal;
        komisiMoClean = tempKomisi;
        pendapatanBersih = tempBersih;
        chartData = tempChartData;
        dailyRevenue = tempDailyRevenue;
        isLoading = false;
      });
    } catch (e) {
      print("❌ Error loading revenue: $e");
      setState(() => isLoading = false);
    }
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    setState(() => _selectedIndex = index);

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => BerandaMitra()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => TeknisiPage()),
        );
        break;
      case 2:
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ProfileMitraPage()),
        );
        break;
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
          'Laporan Pendapatan',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              setState(() => isLoading = true);
              _loadRevenueData();
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadRevenueData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),

                    // Chart Section
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Grafik Pendapatan Mingguan',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '7 Hari',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.green.shade700,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 120,
                            child: chartData.isEmpty
                                ? Center(
                                    child: Text(
                                      'Belum ada data',
                                      style: TextStyle(
                                        color: Colors.grey.shade500,
                                        fontSize: 12,
                                      ),
                                    ),
                                  )
                                : LineChart(
                                    LineChartData(
                                      gridData: FlGridData(
                                        show: true,
                                        drawVerticalLine: false,
                                        horizontalInterval: 1,
                                        getDrawingHorizontalLine: (value) {
                                          return FlLine(
                                            color: Colors.grey.shade200,
                                            strokeWidth: 1,
                                          );
                                        },
                                      ),
                                      titlesData: FlTitlesData(
                                        leftTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            reservedSize: 35,
                                            interval: 1,
                                            getTitlesWidget: (value, meta) {
                                              return Text(
                                                '${(value * 100).toInt()}k',
                                                style: const TextStyle(
                                                  fontSize: 9,
                                                  color: Colors.black54,
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                        rightTitles: AxisTitles(
                                          sideTitles: SideTitles(showTitles: false),
                                        ),
                                        topTitles: AxisTitles(
                                          sideTitles: SideTitles(showTitles: false),
                                        ),
                                        bottomTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            getTitlesWidget: (value, meta) {
                                              const days = [
                                                'Sen',
                                                'Sel',
                                                'Rab',
                                                'Kam',
                                                'Jum',
                                                'Sab',
                                                'Min',
                                              ];
                                              if (value.toInt() < days.length) {
                                                return Padding(
                                                  padding: const EdgeInsets.only(top: 8),
                                                  child: Text(
                                                    days[value.toInt()],
                                                    style: const TextStyle(
                                                      fontSize: 9,
                                                      color: Colors.black54,
                                                    ),
                                                  ),
                                                );
                                              }
                                              return const Text('');
                                            },
                                          ),
                                        ),
                                      ),
                                      borderData: FlBorderData(show: false),
                                      minX: 0,
                                      maxX: 6,
                                      minY: 0,
                                      maxY: _getMaxY(),
                                      lineBarsData: [
                                        LineChartBarData(
                                          spots: chartData,
                                          isCurved: true,
                                          color: const Color(0xFF5DD3C7),
                                          barWidth: 3,
                                          dotData: FlDotData(
                                            show: true,
                                            getDotPainter: (spot, percent, barData, index) {
                                              return FlDotCirclePainter(
                                                radius: 4,
                                                color: const Color(0xFF5DD3C7),
                                                strokeWidth: 2,
                                                strokeColor: Colors.white,
                                              );
                                            },
                                          ),
                                          belowBarData: BarAreaData(
                                            show: true,
                                            color: const Color(0xFF5DD3C7).withOpacity(0.1),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Info Card
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF5669FF).withOpacity(0.1),
                            const Color(0xFF5DD3C7).withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF5669FF).withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF5669FF),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.analytics,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Laporan Pendapatan',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Ringkasan pendapatan & komisi',
                                  style: TextStyle(fontSize: 11, color: Colors.black54),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Financial Details
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildFinancialRow(
                            'Total Pesanan',
                            totalPesanan.toString(),
                            isBold: false,
                            icon: Icons.receipt_long,
                            color: Colors.blue,
                          ),
                          const SizedBox(height: 12),
                          _buildFinancialRow(
                            'Total Pendapatan',
                            'Rp ${NumberFormat('#,###', 'id_ID').format(totalPendapatan)}',
                            isBold: false,
                            icon: Icons.payments,
                            color: Colors.green,
                          ),
                          const SizedBox(height: 12),
                          _buildFinancialRow(
                            'Komisi MoClean (10%)',
                            'Rp ${NumberFormat('#,###', 'id_ID').format(komisiMoClean)}',
                            isBold: false,
                            icon: Icons.percent,
                            color: Colors.orange,
                          ),
                          const Divider(height: 24),
                          _buildFinancialRow(
                            'Pendapatan Bersih',
                            'Rp ${NumberFormat('#,###', 'id_ID').format(pendapatanBersih)}',
                            isBold: true,
                            icon: Icons.account_balance_wallet,
                            color: const Color(0xFF5669FF),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // List Income Button
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ListIncomePage(
                                dailyRevenue: dailyRevenue,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.list_alt, size: 20),
                        label: const Text(
                          'Lihat Detail Pendapatan',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5669FF),
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

  double _getMaxY() {
    if (chartData.isEmpty) return 5;
    double max = chartData.map((e) => e.y).reduce((a, b) => a > b ? a : b);
    return (max * 1.2).ceilToDouble();
  }

  Widget _buildFinancialRow(
    String label,
    String value, {
    required bool isBold,
    IconData? icon,
    Color? color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: color ?? Colors.grey),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isBold ? 14 : 12,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: isBold ? const Color(0xFF5669FF) : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

// ============== LIST INCOME PAGE ==============

class ListIncomePage extends StatefulWidget {
  final Map<String, double> dailyRevenue;

  const ListIncomePage({Key? key, required this.dailyRevenue}) : super(key: key);

  @override
  State<ListIncomePage> createState() => _ListIncomePageState();
}

class _ListIncomePageState extends State<ListIncomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  String selectedFilter = 'Semua';
  String selectedPeriod = 'Bulan Ini';
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detail Pendapatan',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF5669FF),
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.calendar_month),
            onSelected: (value) => setState(() => selectedPeriod = value),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'Hari Ini', child: Text('Hari Ini')),
              const PopupMenuItem(value: 'Minggu Ini', child: Text('Minggu Ini')),
              const PopupMenuItem(value: 'Bulan Ini', child: Text('Bulan Ini')),
              const PopupMenuItem(value: 'Semua', child: Text('Semua Waktu')),
            ],
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) => setState(() => selectedFilter = value),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'Semua', child: Text('Semua Layanan')),
              const PopupMenuItem(value: 'Premium Wash', child: Text('Premium Wash')),
              const PopupMenuItem(value: 'Standard Wash', child: Text('Standard Wash')),
              const PopupMenuItem(value: 'Express Wash', child: Text('Express Wash')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Summary Card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF5669FF), Color(0xFF5DD3C7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF5669FF).withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: StreamBuilder<QuerySnapshot>(
              stream: _getFilteredStream(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator(color: Colors.white));
                }

                // Filter manual (sama seperti di list)
                List<QueryDocumentSnapshot> allDocs = snapshot.data!.docs;
                List<QueryDocumentSnapshot> filteredDocs = allDocs;

                // Filter berdasarkan periode
                if (selectedPeriod != 'Semua') {
                  DateTime now = DateTime.now();
                  DateTime? startDate;

                  if (selectedPeriod == 'Hari Ini') {
                    startDate = DateTime(now.year, now.month, now.day);
                  } else if (selectedPeriod == 'Minggu Ini') {
                    startDate = now.subtract(Duration(days: now.weekday - 1));
                    startDate = DateTime(startDate.year, startDate.month, startDate.day);
                  } else if (selectedPeriod == 'Bulan Ini') {
                    startDate = DateTime(now.year, now.month, 1);
                  }

                  if (startDate != null) {
                    filteredDocs = filteredDocs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final completedAt = data['completedAt'];
                      
                      if (completedAt == null) return false;
                      
                      DateTime? docDate;
                      if (completedAt is Timestamp) {
                        docDate = completedAt.toDate();
                      } else if (completedAt is String) {
                        try {
                          docDate = DateTime.parse(completedAt);
                        } catch (e) {
                          return false;
                        }
                      }
                      
                      return docDate != null && docDate.isAfter(startDate!);
                    }).toList();
                  }
                }

                // Filter berdasarkan service
                if (selectedFilter != 'Semua') {
                  filteredDocs = filteredDocs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return data['serviceName'] == selectedFilter;
                  }).toList();
                }

                double totalIncome = 0;
                int totalOrders = filteredDocs.length;

                for (var doc in filteredDocs) {
                  Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                  totalIncome += (data['totalAmount'] ?? 0).toDouble();
                }

                double commission = totalIncome * 0.10;
                double netIncome = totalIncome - commission;

                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              selectedPeriod,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Rp ${NumberFormat('#,###', 'id_ID').format(netIncome)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Pendapatan Bersih',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.account_balance_wallet,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: Colors.white24),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSummaryItem(
                          'Total Order',
                          totalOrders.toString(),
                          Icons.receipt_long,
                        ),
                        _buildSummaryItem(
                          'Bruto',
                          'Rp ${NumberFormat('#,###', 'id_ID').format(totalIncome)}',
                          Icons.payments,
                        ),
                        _buildSummaryItem(
                          'Komisi',
                          'Rp ${NumberFormat('#,###', 'id_ID').format(commission)}',
                          Icons.percent,
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),

          // Filter Info
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: Colors.grey.shade700),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Filter: ${selectedPeriod == 'Semua' ? 'Semua Waktu' : selectedPeriod}${selectedFilter != 'Semua' ? ' • $selectedFilter' : ''}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // List Orders
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getFilteredStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  print("❌ StreamBuilder error: ${snapshot.error}");
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 60, color: Colors.red.shade300),
                        const SizedBox(height: 16),
                        Text(
                          'Error: ${snapshot.error}',
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => setState(() {}),
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  );
                }

                if (!snapshot.hasData) {
                  print("⚠️ No data in snapshot");
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox, size: 80, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        const Text('Tidak ada data'),
                      ],
                    ),
                  );
                }

                // Filter manual dilakukan di sini
                List<QueryDocumentSnapshot> allDocs = snapshot.data!.docs;
                List<QueryDocumentSnapshot> filteredDocs = allDocs;

                // Filter berdasarkan periode
                if (selectedPeriod != 'Semua') {
                  DateTime now = DateTime.now();
                  DateTime? startDate;

                  if (selectedPeriod == 'Hari Ini') {
                    startDate = DateTime(now.year, now.month, now.day);
                  } else if (selectedPeriod == 'Minggu Ini') {
                    startDate = now.subtract(Duration(days: now.weekday - 1));
                    startDate = DateTime(startDate.year, startDate.month, startDate.day);
                  } else if (selectedPeriod == 'Bulan Ini') {
                    startDate = DateTime(now.year, now.month, 1);
                  }

                  if (startDate != null) {
                    filteredDocs = filteredDocs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final completedAt = data['completedAt'];
                      
                      if (completedAt == null) return false;
                      
                      DateTime? docDate;
                      if (completedAt is Timestamp) {
                        docDate = completedAt.toDate();
                      } else if (completedAt is String) {
                        try {
                          docDate = DateTime.parse(completedAt);
                        } catch (e) {
                          return false;
                        }
                      }
                      
                      return docDate != null && docDate.isAfter(startDate!);
                    }).toList();
                  }
                }

                // Filter berdasarkan service
                if (selectedFilter != 'Semua') {
                  filteredDocs = filteredDocs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return data['serviceName'] == selectedFilter;
                  }).toList();
                }

                // Sort berdasarkan completedAt (descending)
                filteredDocs.sort((a, b) {
                  final aData = a.data() as Map<String, dynamic>;
                  final bData = b.data() as Map<String, dynamic>;
                  
                  final aTime = aData['completedAt'];
                  final bTime = bData['completedAt'];
                  
                  if (aTime == null && bTime == null) return 0;
                  if (aTime == null) return 1;
                  if (bTime == null) return -1;
                  
                  if (aTime is Timestamp && bTime is Timestamp) {
                    return bTime.compareTo(aTime);
                  }
                  return 0;
                });

                print("✅ Displaying ${filteredDocs.length} orders");

                if (filteredDocs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox, size: 80, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text(
                          'Belum ada pendapatan',
                          style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'di periode ini',
                          style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    Map<String, dynamic> order = filteredDocs[index].data() as Map<String, dynamic>;
                    String orderId = filteredDocs[index].id;
                    
                    return _buildIncomeCard(order, orderId);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Stream<QuerySnapshot> _getFilteredStream() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      print("❌ No user in _getFilteredStream");
      return Stream.value(
        _firestore.collection('orders').limit(0).get() as QuerySnapshot
      ).asyncMap((future) async => await future as QuerySnapshot);
    }

    print("🔍 Building filtered stream for user: ${currentUser.uid}");
    print("   Filter: $selectedFilter");
    print("   Period: $selectedPeriod");

    try {
      // Query SEDERHANA - hanya teknisiId dan status (tidak perlu composite index)
      return _firestore
          .collection('orders')
          .where('teknisiId', isEqualTo: currentUser.uid)
          .where('orderStatus', isEqualTo: 'selesai')
          .snapshots()
          .handleError((error) {
            print("❌ Stream error: $error");
          })
          .map((snapshot) {
            print("📦 Raw stream: ${snapshot.docs.length} documents");
            
            List<QueryDocumentSnapshot> filteredDocs = snapshot.docs;

            // Filter manual berdasarkan periode
            if (selectedPeriod != 'Semua') {
              DateTime now = DateTime.now();
              DateTime? startDate;

              if (selectedPeriod == 'Hari Ini') {
                startDate = DateTime(now.year, now.month, now.day);
              } else if (selectedPeriod == 'Minggu Ini') {
                startDate = now.subtract(Duration(days: now.weekday - 1));
                startDate = DateTime(startDate.year, startDate.month, startDate.day);
              } else if (selectedPeriod == 'Bulan Ini') {
                startDate = DateTime(now.year, now.month, 1);
              }

              if (startDate != null) {
                filteredDocs = filteredDocs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final completedAt = data['completedAt'];
                  
                  if (completedAt == null) return false;
                  
                  DateTime? docDate;
                  if (completedAt is Timestamp) {
                    docDate = completedAt.toDate();
                  } else if (completedAt is String) {
                    try {
                      docDate = DateTime.parse(completedAt);
                    } catch (e) {
                      return false;
                    }
                  }
                  
                  return docDate != null && docDate.isAfter(startDate!);
                }).toList();
              }
            }

            // Filter manual berdasarkan service
            if (selectedFilter != 'Semua') {
              filteredDocs = filteredDocs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return data['serviceName'] == selectedFilter;
              }).toList();
            }

            // Sort manual berdasarkan completedAt
            filteredDocs.sort((a, b) {
              final aData = a.data() as Map<String, dynamic>;
              final bData = b.data() as Map<String, dynamic>;
              
              final aTime = aData['completedAt'];
              final bTime = bData['completedAt'];
              
              if (aTime == null && bTime == null) return 0;
              if (aTime == null) return 1;
              if (bTime == null) return -1;
              
              if (aTime is Timestamp && bTime is Timestamp) {
                return bTime.compareTo(aTime); // Descending
              }
              return 0;
            });

            print("   ✅ After filtering: ${filteredDocs.length} documents");
            
            // Return snapshot asli (karena kita tidak bisa modifikasi QuerySnapshot)
            // Widget akan menggunakan filteredDocs dari snapshot.docs
            return snapshot;
          });
      
    } catch (e) {
      print("❌ Error in _getFilteredStream: $e");
      return const Stream.empty();
    }
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 18),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildIncomeCard(Map<String, dynamic> order, String orderId) {
    double amount = (order['totalAmount'] ?? 0).toDouble();
    double commission = amount * 0.10;
    double netAmount = amount - commission;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _showOrderDetail(order, orderId),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order['serviceName'] ?? 'Layanan',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.person, size: 14, color: Colors.grey.shade600),
                            const SizedBox(width: 4),
                            Text(
                              order['customerName'] ?? '-',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Text(
                      'Lunas',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.access_time, size: 14, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(order['completedAt']),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              const Divider(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Bayar',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Rp ${NumberFormat('#,###', 'id_ID').format(amount)}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
                    child: Icon(Icons.arrow_forward, size: 16, color: Colors.grey.shade400),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Pendapatan',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Rp ${NumberFormat('#,###', 'id_ID').format(netAmount)}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF5669FF),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (commission > 0) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.percent, size: 12, color: Colors.orange.shade700),
                      const SizedBox(width: 4),
                      Text(
                        'Komisi: Rp ${NumberFormat('#,###', 'id_ID').format(commission)}',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.orange.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showOrderDetail(Map<String, dynamic> order, String orderId) {
    double amount = (order['totalAmount'] ?? 0).toDouble();
    double commission = amount * 0.10;
    double netAmount = amount - commission;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF5669FF).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.receipt_long,
                      color: Color(0xFF5669FF),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Detail Transaksi',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Informasi lengkap pesanan',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildDetailSection('Informasi Pesanan', [
                _buildDetailRow('ID Order', _getShortId(orderId)),
                _buildDetailRow('Layanan', order['serviceName'] ?? '-'),
                _buildDetailRow('Status', 'Selesai', valueColor: Colors.green),
                _buildDetailRow('Tanggal', _formatDate(order['completedAt'])),
              ]),
              const SizedBox(height: 16),
              _buildDetailSection('Pelanggan', [
                _buildDetailRow('Nama', order['customerName'] ?? '-'),
                _buildDetailRow('Telepon', order['phone'] ?? '-'),
                _buildDetailRow('Kendaraan', '${order['brand']} ${order['type']}'),
              ]),
              const SizedBox(height: 16),
              _buildDetailSection('Teknisi', [
                _buildDetailRow('Nama', order['teknisiName'] ?? '-'),
                _buildDetailRow('Rating', '⭐ ${order['teknisiRating'] ?? '-'}'),
              ]),
              const SizedBox(height: 16),
              _buildDetailSection('Rincian Pembayaran', [
                _buildDetailRow('Metode', order['paymentMethod'] ?? '-'),
                _buildDetailRow('Total Bayar', 'Rp ${NumberFormat('#,###', 'id_ID').format(amount)}'),
                _buildDetailRow('Komisi (10%)', 'Rp ${NumberFormat('#,###', 'id_ID').format(commission)}', valueColor: Colors.orange),
                const Divider(height: 20),
                _buildDetailRow(
                  'Pendapatan Bersih',
                  'Rp ${NumberFormat('#,###', 'id_ID').format(netAmount)}',
                  isHighlight: true,
                ),
              ]),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5669FF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Tutup',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
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

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    Color? valueColor,
    bool isHighlight = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isHighlight ? 14 : 12,
              color: Colors.grey.shade700,
              fontWeight: isHighlight ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isHighlight ? 16 : 12,
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.w600,
              color: isHighlight
                  ? const Color(0xFF5669FF)
                  : (valueColor ?? Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  String _getShortId(String orderId) {
    if (orderId.length <= 9) return orderId;
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
      } else if (date is Timestamp) {
        dateTime = date.toDate();
      } else {
        return '-';
      }
      
      return DateFormat('dd MMM yyyy, HH:mm').format(dateTime);
    } catch (e) {
      return '-';
    }
  }
}