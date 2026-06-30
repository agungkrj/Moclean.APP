import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:moclienapp/mitra/laporan_pendapatan.dart';
import 'package:moclienapp/mitra/login_mitra.dart';
import 'package:moclienapp/mitra/order_teknis_page.dart';
import 'package:moclienapp/mitra/orderan_selesai.dart';
import 'package:moclienapp/mitra/profile_mitra.dart';
import 'package:moclienapp/mitra/proses_order.dart';
import 'package:moclienapp/mitra/teknisi_page.dart';
import 'costum_navbar.dart';

class BerandaMitra extends StatefulWidget {
  const BerandaMitra({super.key});

  @override
  State<BerandaMitra> createState() => _BerandaMitraState();
}

class _BerandaMitraState extends State<BerandaMitra> {
  int _selectedIndex = 0;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Map<String, dynamic> _mitraData = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMitraData();
  }

  Future<void> _loadMitraData() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginMitraPage()),
        );
        return;
      }

      final mitraDoc = await _firestore.collection('mitra').doc(user.uid).get();
      if (mitraDoc.exists) {
        setState(() {
          _mitraData = mitraDoc.data() as Map<String, dynamic>;
        });
      }
    } catch (e) {
      print('❌ Error load mitra data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
    
    setState(() {
      _selectedIndex = index;
    });
    
    switch (index) {
      case 0:
        break;
      case 1:
        Navigator.push(context, MaterialPageRoute(builder: (context) => TeknisiPage()));
        break;
      case 2:
        Navigator.push(context, MaterialPageRoute(builder: (context) => LaporanPendapatan()));
        break;
      case 3:
        Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileMitraPage()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF5B7FDB), Color(0xFF3A5FD9)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x335B7FDB),
                    blurRadius: 20,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Selamat Datang",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _mitraData['namaLengkap'] ?? (_isLoading ? "Memuat..." : "Admin"),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.white24,
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Center(
                          child: _isLoading
                              ? const CircularProgressIndicator(strokeWidth: 2)
                              : Text(
                                  _mitraData['namaLengkap'] != null 
                                    ? _mitraData['namaLengkap'].toString().substring(0, 1).toUpperCase()
                                    : "A",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF5B7FDB),
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _mitraData['namaUsaha'] ?? (_isLoading ? "Memuat data..." : "Mitra Panel"),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),

            // Content dengan StreamBuilder langsung
            Expanded(
              child: StreamBuilder<DocumentSnapshot>(
                stream: _firestore.collection('mitra').doc(_auth.currentUser?.uid).snapshots(),
                builder: (context, mitraSnapshot) {
                  if (!mitraSnapshot.hasData) {
                    return _buildLoading();
                  }
                  
                  final mitraData = mitraSnapshot.data!.data() as Map<String, dynamic>? ?? {};
                  final mitraId = _auth.currentUser?.uid ?? '';
                  
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Overview Order",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Ringkasan order Anda",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // SATU CARD DENGAN 3 STATUS - QUERY DIPERBAIKI
                        StreamBuilder<QuerySnapshot>(
                          stream: _firestore
                              .collection('orders')
                              .snapshots(), // Ambil semua order dulu
                          builder: (context, ordersSnapshot) {
                            if (!ordersSnapshot.hasData) {
                              return _buildLoadingCard();
                            }
                            
                            final allOrders = ordersSnapshot.data!.docs;
                            int baru = 0, proses = 0, selesai = 0;
                            
                            print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
                            print('📊 TOTAL SEMUA ORDERS DI DATABASE: ${allOrders.length}');
                            print('🔑 MITRA ID SAYA: $mitraId');
                            print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
                            
                            for (var doc in allOrders) {
                              final data = doc.data() as Map<String, dynamic>;
                              
                              // Ambil semua kemungkinan field ID
                              final teknisiId = data['teknisiId']?.toString().trim() ?? '';
                              final mitraIdFromDoc = data['mitraId']?.toString().trim() ?? '';
                              final status = (data['orderStatus'] ?? data['status'] ?? '').toString().toLowerCase().trim();
                              
                              // Cek apakah order ini milik mitra yang login
                              bool isMyOrder = (teknisiId == mitraId) || (mitraIdFromDoc == mitraId);
                              
                              // Debug logging untuk setiap order
                              if (isMyOrder || allOrders.indexOf(doc) < 3) { // Tampilkan 3 order pertama atau order milik saya
                                print('─────────────────────────────────────────────');
                                print('📦 Order ID: ${doc.id}');
                                print('   Status: "$status"');
                                print('   teknisiId: "$teknisiId"');
                                print('   mitraId: "$mitraIdFromDoc"');
                                print('   Milik saya? ${isMyOrder ? "✅ YA" : "❌ TIDAK"}');
                              }
                              
                              // Hanya hitung order yang milik mitra ini
                              if (isMyOrder) {
                                // Klasifikasi status dengan berbagai kemungkinan
                                if (status == 'menunggu' || 
                                    status == 'pending' || 
                                    status == 'waiting' ||
                                    status == 'baru') {
                                  baru++;
                                  print('   ➜ Dikategorikan sebagai: BARU ✅');
                                } else if (status == 'diterima' || 
                                           status == 'sedang_dicuci' || 
                                           status == 'diproses' ||
                                           status == 'proses' ||
                                           status == 'accepted' ||
                                           status == 'processing') {
                                  proses++;
                                  print('   ➜ Dikategorikan sebagai: PROSES ✅');
                                } else if (status == 'selesai' || 
                                           status == 'completed' ||
                                           status == 'done' ||
                                           status == 'finished') {
                                  selesai++;
                                  print('   ➜ Dikategorikan sebagai: SELESAI ✅');
                                } else {
                                  print('   ➜ ⚠️ STATUS TIDAK DIKENALI: "$status"');
                                }
                              }
                            }
                            
                            print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
                            print('📊 HASIL AKHIR PERHITUNGAN:');
                            print('   🆕 Order Baru: $baru');
                            print('   ⏳ Order Proses: $proses');
                            print('   ✅ Order Selesai: $selesai');
                            print('   📈 Total Order Saya: ${baru + proses + selesai}');
                            print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
                            
                            return _buildThreeInOneCard(baru, proses, selesai);
                          },
                        ),

                        const SizedBox(height: 28),

                        // GRAFIK - 7 hari terakhir (DIPERBAIKI)
                        StreamBuilder<QuerySnapshot>(
                          stream: _firestore
                              .collection('orders')
                              .snapshots(), // Ambil semua order dulu
                          builder: (context, weeklySnapshot) {
                            List<double> weeklyData = [0, 0, 0, 0, 0, 0, 0];
                            
                            if (weeklySnapshot.hasData) {
                              final now = DateTime.now();
                              final startOfWeek = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 6));
                              
                              print('📅 PERIODE GRAFIK: ${DateFormat('dd/MM/yyyy').format(startOfWeek)} - ${DateFormat('dd/MM/yyyy').format(now)}');
                              
                              for (var doc in weeklySnapshot.data!.docs) {
                                final data = doc.data() as Map<String, dynamic>;
                                
                                // Cek kepemilikan order
                                final teknisiId = data['teknisiId']?.toString().trim() ?? '';
                                final mitraIdFromDoc = data['mitraId']?.toString().trim() ?? '';
                                bool isMyOrder = (teknisiId == mitraId) || (mitraIdFromDoc == mitraId);
                                
                                if (!isMyOrder) continue; // Skip jika bukan order saya
                                
                                // Coba berbagai field timestamp yang mungkin ada
                                dynamic createdAtField = data['orderDate'] ?? 
                                                        data['createdAt'] ?? 
                                                        data['acceptedAt'] ?? 
                                                        data['timestamp'] ??
                                                        data['tanggalOrder'];
                                
                                if (createdAtField != null) {
                                  DateTime? orderDate;
                                  
                                  try {
                                    if (createdAtField is Timestamp) {
                                      orderDate = createdAtField.toDate();
                                    } else if (createdAtField is String) {
                                      orderDate = DateTime.parse(createdAtField);
                                    } else if (createdAtField is DateTime) {
                                      orderDate = createdAtField;
                                    }
                                  } catch (e) {
                                    print('⚠️ Error parsing date for order ${doc.id}: $e');
                                    continue;
                                  }
                                  
                                  if (orderDate != null) {
                                    final daysDiff = orderDate.difference(startOfWeek).inDays;
                                    
                                    if (daysDiff >= 0 && daysDiff < 7) {
                                      weeklyData[daysDiff]++;
                                      print('✅ Order ${doc.id} pada ${DateFormat('dd/MM HH:mm').format(orderDate)} → Hari ke-$daysDiff');
                                    }
                                  }
                                }
                              }
                              
                              print('📊 DATA GRAFIK MINGGUAN: $weeklyData');
                              print('📈 TOTAL ORDER MINGGU INI: ${weeklyData.reduce((a, b) => a + b)}\n');
                            }
                            
                            return _buildChartCard(weeklyData);
                          },
                        ),

                        const SizedBox(height: 20),

                        // AKSES CEPAT
                        _buildQuickAccessCard(),

                        const SizedBox(height: 20),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Color(0xFF5B7FDB)),
          SizedBox(height: 16),
          Text('Memuat data...', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Center(
        child: CircularProgressIndicator(color: Color(0xFF5B7FDB)),
      ),
    );
  }

  // SATU CARD DENGAN 3 ITEM HORIZONTAL
  Widget _buildThreeInOneCard(int baru, int proses, int selesai) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Navigator.push(
          context, 
          MaterialPageRoute(builder: (context) => const OrderTeknisiPage())
        ),
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF5B7FDB).withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              // Order Baru (menunggu)
              Expanded(
                child: _buildOrderColumn(
                  count: baru,
                  label: "Baru",
                  icon: Icons.assignment_outlined,
                  color: const Color(0xFFFF6B6B),
                ),
              ),
              
              Container(
                width: 1,
                height: 80,
                color: Colors.grey.shade200,
                margin: const EdgeInsets.symmetric(horizontal: 16),
              ),
              
              // Proses (diterima + sedang_dicuci)
              Expanded(
                child: _buildOrderColumn(
                  count: proses,
                  label: "Proses",
                  icon: Icons.autorenew_rounded,
                  color: const Color(0xFF4ECDC4),
                ),
              ),
              
              Container(
                width: 1,
                height: 80,
                color: Colors.grey.shade200,
                margin: const EdgeInsets.symmetric(horizontal: 16),
              ),
              
              // Selesai
              Expanded(
                child: _buildOrderColumn(
                  count: selesai,
                  label: "Selesai",
                  icon: Icons.check_circle_rounded,
                  color: const Color(0xFF1DD1A1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderColumn({
    required int count,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        // Icon Container
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color, color.withOpacity(0.85)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.25),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 28),
        ),
        
        const SizedBox(height: 16),
        
        // Count
        Text(
          count.toString(),
          style: const TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w800,
            color: Colors.black87,
            height: 1.0,
            letterSpacing: -0.5,
          ),
        ),
        
        const SizedBox(height: 6),
        
        // Label
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color,
            letterSpacing: 0.2,
          ),
        ),
        
        const SizedBox(height: 2),
        
        // "order" text
        Text(
          "order",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }

  Widget _buildChartCard(List<double> weeklyData) {
    double maxValue = weeklyData.reduce((a, b) => a > b ? a : b);
    if (maxValue == 0) maxValue = 5;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 4),
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
                "Statistik 7 Hari",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F2FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  "Minggu Ini",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF5B7FDB),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        List<String> days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
                        if (value.toInt() >= 0 && value.toInt() < days.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(days[value.toInt()], style: const TextStyle(fontSize: 11)),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: 6,
                minY: 0,
                maxY: maxValue + 2,
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(7, (i) => FlSpot(i.toDouble(), weeklyData[i])),
                    isCurved: true,
                    color: const Color(0xFF5B7FDB),
                    barWidth: 3,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF5B7FDB).withOpacity(0.3),
                          const Color(0xFF5B7FDB).withOpacity(0.05),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Akses Cepat",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildQuickButton(
                icon: Icons.people_alt_outlined,
                label: "Teknisi",
                color: const Color(0xFF5B7FDB),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => TeknisiPage())),
              ),
              const SizedBox(width: 12),
              _buildQuickButton(
                icon: Icons.bar_chart_outlined,
                label: "Laporan",
                color: const Color(0xFF4ECDC4),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => LaporanPendapatan())),
              ),
              const SizedBox(width: 12),
              _buildQuickButton(
                icon: Icons.person_outline,
                label: "Profil",
                color: const Color(0xFFFF9F43),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileMitraPage())),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade100, width: 1),
            ),
            child: Column(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}