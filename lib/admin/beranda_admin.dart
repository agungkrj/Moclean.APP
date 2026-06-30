import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:moclienapp/admin/login_admin.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:moclienapp/admin/data_langganan.dart';
import 'package:moclienapp/admin/data_mitra.dart';
import 'package:moclienapp/admin/data_pengguna.dart';
import 'package:moclienapp/admin/data_pesanan.dart';
import 'package:moclienapp/admin/kelola_langganan_page.dart';
import 'package:moclienapp/admin/kelola_layanan.dart';
import 'admin_bottom_navbar.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({Key? key}) : super(key: key);

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
    setState(() => _selectedIndex = index);

    switch (index) {
      case 0:
        break;
      case 1:
        Navigator.push(context, MaterialPageRoute(builder: (context) => KelolaLayananPage()));
        break;
      case 2:
        Navigator.push(context, MaterialPageRoute(builder: (context) => KelolaLanggananPage()));
        break;
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B6B).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    size: 40,
                    color: Color(0xFFFF6B6B),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Keluar dari Aplikasi?',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Anda yakin ingin keluar dari dashboard admin?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(color: Color(0xFFE0E0E0)),
                          ),
                        ),
                        child: const Text(
                          'Batal',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.of(context).pop();
                          
                          try {
                            await FirebaseAuth.instance.signOut();
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.clear();
                            
                            if (context.mounted) {
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(builder: (context) => const LoginAdminPage()),
                                (route) => false,
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Gagal logout: $e'),
                                  backgroundColor: Colors.red,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF6B6B),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Keluar',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF5669FF),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // HEADER
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [const Color(0xFF5669FF), const Color(0xFF6B7AFF)],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('MoClean', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                        SizedBox(height: 4),
                        Text('Admin Dashboard', style: TextStyle(fontSize: 13, color: Colors.white70)),
                      ],
                    ),
                    PopupMenuButton<String>(
                      offset: const Offset(0, 60),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 8,
                      color: Colors.white,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white30, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 22,
                          child: Text(
                            'AD',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF5669FF),
                            ),
                          ),
                        ),
                      ),
                      onSelected: (String value) {
                        if (value == 'profile') {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Fitur Profil segera hadir'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        } else if (value == 'logout') {
                          _showLogoutDialog();
                        }
                      },
                      itemBuilder: (BuildContext context) => [
                        PopupMenuItem<String>(
                          value: 'profile',
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF5669FF).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.person_outline_rounded,
                                  size: 20,
                                  color: Color(0xFF5669FF),
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Profil Admin',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const PopupMenuDivider(height: 1),
                        PopupMenuItem<String>(
                          value: 'logout',
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFF6B6B).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.logout_rounded,
                                  size: 20,
                                  color: Color(0xFFFF6B6B),
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Keluar',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFFFF6B6B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // CONTENT
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FE),
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // STAT CARDS - DYNAMIC
                      StreamBuilder<QuerySnapshot>(
                        stream: _firestore.collection('users').snapshots(),
                        builder: (context, userSnapshot) {
                          return StreamBuilder<QuerySnapshot>(
                            stream: _firestore.collection('mitra').snapshots(),
                            builder: (context, mitraSnapshot) {
                              final totalUsers = userSnapshot.hasData ? userSnapshot.data!.docs.length : 0;
                              final totalMitra = mitraSnapshot.hasData ? mitraSnapshot.data!.docs.length : 0;

                              return Row(
                                children: [
                                  Expanded(
                                    child: _buildModernStatCard(
                                      title: 'Total Pengguna',
                                      value: totalUsers.toString(),
                                      icon: Icons.people_rounded,
                                      gradientColors: [const Color(0xFF667EEA), const Color(0xFF764BA2)],
                                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const DataPenggunaPage())),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: _buildModernStatCard(
                                      title: 'Total Mitra',
                                      value: totalMitra.toString(),
                                      icon: Icons.business_center_rounded,
                                      gradientColors: [const Color(0xFFF093FB), const Color(0xFFF5576C)],
                                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const DataMitraPage())),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 24),

                      // DATA PESANAN - DYNAMIC
                      _buildSectionHeader('Data Pesanan', Icons.shopping_bag_rounded, onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const DataPesananPage()));
                      }),
                      const SizedBox(height: 12),
                      StreamBuilder<QuerySnapshot>(
                        stream: _firestore.collection('orders').snapshots(),
                        builder: (context, snapshot) {
                          int masuk = 0, proses = 0, selesai = 0;

                          if (snapshot.hasData) {
                            for (var doc in snapshot.data!.docs) {
                              try {
                                final data = doc.data() as Map<String, dynamic>;
                                final status = _getOrderStatus(data);
                                
                                if (status == 'menunggu' || status == 'pending' || status == 'waiting') {
                                  masuk++;
                                } else if (status == 'diterima' || status == 'sedang_dicuci' || status == 'proses' || status == 'accepted' || status == 'processing') {
                                  proses++;
                                } else if (status == 'selesai' || status == 'completed' || status == 'done') {
                                  selesai++;
                                } else {
                                  masuk++;
                                }
                              } catch (e) {
                                masuk++;
                                print('Error membaca orderStatus pada dokumen ${doc.id}: $e');
                              }
                            }
                          }

                          return Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildModernOrderStatus('Masuk', masuk.toString(), const Color(0xFF4CAF50)),
                                _buildModernOrderStatus('Proses', proses.toString(), const Color(0xFF2196F3)),
                                _buildModernOrderStatus('Selesai', selesai.toString(), const Color(0xFF9E9E9E)),
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),

                      // LANGGANAN - UPDATED - Mengambil dari koleksi subscriptions
                      _buildSectionHeader('Langganan', Icons.calendar_today_rounded, onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const DataLanggananPage()));
                      }),
                      const SizedBox(height: 12),
                      StreamBuilder<QuerySnapshot>(
                        stream: _firestore.collection('subscriptions').snapshots(),
                        builder: (context, snapshot) {
                          int todayCount = 0;
                          double totalRevenue = 0;

                          if (snapshot.hasData) {
                            final today = DateTime.now();
                            for (var doc in snapshot.data!.docs) {
                              try {
                                final data = doc.data() as Map<String, dynamic>;
                                
                                // Hitung langganan hari ini dari createdAt atau startDate
                                Timestamp? createdAt;
                                if (data.containsKey('createdAt')) {
                                  createdAt = data['createdAt'] as Timestamp?;
                                } else if (data.containsKey('created_at')) {
                                  createdAt = data['created_at'] as Timestamp?;
                                } else if (data.containsKey('startDate')) {
                                  createdAt = data['startDate'] as Timestamp?;
                                } else if (data.containsKey('timestamp')) {
                                  createdAt = data['timestamp'] as Timestamp?;
                                }
                                
                                if (createdAt != null) {
                                  final createdDate = createdAt.toDate();
                                  if (createdDate.year == today.year &&
                                      createdDate.month == today.month &&
                                      createdDate.day == today.day) {
                                    todayCount++;
                                  }
                                }
                                
                                // Hitung total pendapatan dari priceValue (yang disimpan saat langganan dibuat)
                                if (data.containsKey('priceValue')) {
                                  totalRevenue += (data['priceValue'] ?? 0).toDouble();
                                } else if (data.containsKey('amount')) {
                                  totalRevenue += (data['amount'] ?? 0).toDouble();
                                } else if (data.containsKey('price')) {
                                  totalRevenue += (data['price'] ?? 0).toDouble();
                                } else if (data.containsKey('totalAmount')) {
                                  totalRevenue += (data['totalAmount'] ?? 0).toDouble();
                                }
                              } catch (e) {
                                print('Error membaca data subscription pada dokumen ${doc.id}: $e');
                              }
                            }
                          }

                          return Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [Colors.white, const Color(0xFFF8F9FE)]),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF5669FF).withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: const Icon(Icons.today_rounded, size: 16, color: Color(0xFF5669FF)),
                                          ),
                                          const SizedBox(width: 8),
                                          const Text('Langganan Hari Ini', style: TextStyle(fontSize: 12, color: Colors.black54)),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(todayCount.toString(), style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF5669FF))),
                                          const Padding(
                                            padding: EdgeInsets.only(bottom: 6),
                                            child: Text(' / hari', style: TextStyle(fontSize: 11, color: Colors.black45)),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Container(width: 1, height: 60, color: Colors.black.withOpacity(0.06)),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF4CAF50).withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: const Icon(Icons.account_balance_wallet_rounded, size: 16, color: Color(0xFF4CAF50)),
                                          ),
                                          const SizedBox(width: 8),
                                          const Text('Total Pendapatan', style: TextStyle(fontSize: 12, color: Colors.black54)),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          const Text('Rp', style: TextStyle(fontSize: 13, color: Colors.black87)),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              _formatCurrency(totalRevenue),
                                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF4CAF50)),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),

                      // GRAFIK - DYNAMIC
                      _buildSectionHeader('Grafik Pesanan', Icons.bar_chart_rounded),
                      const SizedBox(height: 12),
                      StreamBuilder<QuerySnapshot>(
                        stream: _firestore.collection('orders').snapshots(),
                        builder: (context, snapshot) {
                          List<double> weeklyData = [0, 0, 0, 0, 0, 0, 0];

                          if (snapshot.hasData) {
                            final now = DateTime.now();
                            final startOfWeek = now.subtract(Duration(days: now.weekday - 1));

                            for (var doc in snapshot.data!.docs) {
                              try {
                                final data = doc.data() as Map<String, dynamic>;
                                
                                Timestamp? orderTimestamp;
                                
                                if (data.containsKey('orderDate')) {
                                  orderTimestamp = data['orderDate'] as Timestamp?;
                                } else if (data.containsKey('order_date')) {
                                  orderTimestamp = data['order_date'] as Timestamp?;
                                } else if (data.containsKey('createdAt')) {
                                  orderTimestamp = data['createdAt'] as Timestamp?;
                                } else if (data.containsKey('created_at')) {
                                  orderTimestamp = data['created_at'] as Timestamp?;
                                } else if (data.containsKey('timestamp')) {
                                  orderTimestamp = data['timestamp'] as Timestamp?;
                                }
                                
                                if (orderTimestamp != null) {
                                  final orderDate = orderTimestamp.toDate();
                                  final daysDiff = orderDate.difference(startOfWeek).inDays;
                                  if (daysDiff >= 0 && daysDiff < 7) {
                                    weeklyData[daysDiff]++;
                                  }
                                }
                              } catch (e) {
                                print('Error membaca tanggal order pada dokumen ${doc.id}: $e');
                              }
                            }
                          }

                          double maxY = 10;
                          if (weeklyData.isNotEmpty) {
                            final maxValue = weeklyData.reduce((a, b) => a > b ? a : b);
                            maxY = maxValue > 0 ? (maxValue + 5).ceilToDouble() : 10;
                          }

                          return Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Orders', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87)),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF5DD3C7).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Text('Minggu Ini', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF5DD3C7))),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                SizedBox(
                                  height: 120,
                                  child: LineChart(
                                    LineChartData(
                                      gridData: FlGridData(
                                        show: true,
                                        drawVerticalLine: false,
                                        horizontalInterval: maxY > 20 ? (maxY / 4) : 5,
                                        getDrawingHorizontalLine: (value) => const FlLine(color: Color(0xFFEEEEEE), strokeWidth: 1),
                                      ),
                                      titlesData: FlTitlesData(
                                        leftTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            reservedSize: 28,
                                            interval: maxY > 20 ? (maxY / 4) : 5,
                                            getTitlesWidget: (value, meta) => Text(
                                              value.toInt().toString(),
                                              style: const TextStyle(fontSize: 9, color: Colors.black54),
                                            ),
                                          ),
                                        ),
                                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                        bottomTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            getTitlesWidget: (value, meta) {
                                              const days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
                                              if (value.toInt() >= 0 && value.toInt() < days.length) {
                                                return Padding(
                                                  padding: const EdgeInsets.only(top: 8),
                                                  child: Text(
                                                    days[value.toInt()],
                                                    style: const TextStyle(fontSize: 9, color: Colors.black54),
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
                                      maxY: maxY,
                                      lineBarsData: [
                                        LineChartBarData(
                                          spots: List.generate(7, (i) => FlSpot(i.toDouble(), weeklyData[i])),
                                          isCurved: true,
                                          color: const Color(0xFF5DD3C7),
                                          barWidth: 2.5,
                                          dotData: FlDotData(show: false),
                                          belowBarData: BarAreaData(show: false),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AdminBottomNavBar(selectedIndex: _selectedIndex, onItemTapped: _onItemTapped),
    );
  }

  String _getOrderStatus(Map<String, dynamic> data) {
    if (data.containsKey('orderStatus')) {
      return (data['orderStatus']?.toString().toLowerCase() ?? 'menunggu');
    } else if (data.containsKey('order_status')) {
      return (data['order_status']?.toString().toLowerCase() ?? 'menunggu');
    } else if (data.containsKey('status')) {
      return (data['status']?.toString().toLowerCase() ?? 'menunggu');
    } else if (data.containsKey('orderState')) {
      return (data['orderState']?.toString().toLowerCase() ?? 'menunggu');
    }
    return 'menunggu';
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000000000) {
      return '${(amount / 1000000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}K';
    }
    return amount.toStringAsFixed(0);
  }

  Widget _buildModernStatCard({
    required String title,
    required String value,
    required IconData icon,
    required List<Color> gradientColors,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: gradientColors),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: gradientColors[0].withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.25), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, size: 22, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(value, style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white)),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.25), borderRadius: BorderRadius.circular(6)),
                  child: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: const Color(0xFF5669FF).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, size: 18, color: const Color(0xFF5669FF)),
          ),
          const SizedBox(width: 10),
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
          if (onTap != null) ...[
            const SizedBox(width: 6),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.black45),
          ],
        ],
      ),
    );
  }

  Widget _buildModernOrderStatus(String label, String value, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
          child: Icon(
            label == 'Masuk' ? Icons.inbox_rounded : label == 'Proses' ? Icons.loop_rounded : Icons.check_circle_rounded,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(height: 10),
        Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.w500)),
      ],
    );
  }
}