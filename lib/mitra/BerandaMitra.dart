import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:moclienapp/mitra/laporan_pendapatan.dart';
import 'package:moclienapp/mitra/order_teknis_page.dart';
import 'package:moclienapp/mitra/orderan_selesai.dart';
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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    
    // Navigasi ke halaman lain
    switch (index) {
      case 0:
        // Sudah di Home
        break;
      case 1:
        Navigator.push(context, MaterialPageRoute(builder: (context) => TeknisiPage()));
        break;
      case 2:
        Navigator.push(context, MaterialPageRoute(builder: (context) => LaporanPendapatan()));
        break;
      case 3:
        //Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF5B7FDB), Color(0xFF4A6FD4)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "MoClean",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        "Mitra Panel",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Center(
                      child: Text(
                        "KA",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF5B7FDB),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content Section
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Card 1 - Orderan Terbaru
                   // Card 1 - Orderan Terbaru
InkWell(
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const OrderTeknisiPage()),
    );
  },
  borderRadius: BorderRadius.circular(12),
  child: Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFFE8ECFF),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        Expanded(
          child: Row(
            children: [
              const Text(
                "1",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Icon(
                    Icons.receipt_long,
                    size: 16,
                    color: Colors.black54,
                  ),
                  SizedBox(height: 2),
                  Text(
                    "Orderan Terbaru",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Icon(
          Icons.chevron_right,
          color: Color(0xFF5B7FDB),
          size: 24,
        ),
      ],
    ),
  ),
),
const SizedBox(height: 12),

// Card 2 - Orderan dalam proses
InkWell(
  onTap: () {
  Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProsesOrderPage()),
    );
  },
  borderRadius: BorderRadius.circular(12),
  child: Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFFE8ECFF),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        Expanded(
          child: Row(
            children: [
              const Text(
                "2",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: Colors.black54,
                  ),
                  SizedBox(height: 2),
                  Text(
                    "Orderan dalam proses",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Icon(
          Icons.chevron_right,
          color: Color(0xFF5B7FDB),
          size: 24,
        ),
      ],
    ),
  ),
),
const SizedBox(height: 12),

// Card 3 - Orderan selesai
InkWell(
  onTap: () {
   Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => OrderanSelesaiPage()),
    );
  },
  borderRadius: BorderRadius.circular(12),
  child: Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFFE8ECFF),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        Expanded(
          child: Row(
            children: [
              const Text(
                "3",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Icon(
                    Icons.check_circle,
                    size: 16,
                    color: Colors.black54,
                  ),
                  SizedBox(height: 2),
                  Text(
                    "Orderan selesai",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Icon(
          Icons.chevron_right,
          color: Color(0xFF5B7FDB),
          size: 24,
        ),
      ],
    ),
  ),
),

                    const SizedBox(height: 24),

                    // Statistik Performa Section
                    const Text(
                      "Statistik Performa",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Orders",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Chart
                    SizedBox(
                      height: 200,
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            horizontalInterval: 20,
                            getDrawingHorizontalLine: (value) {
                              return FlLine(
                                color: Colors.grey.shade300,
                                strokeWidth: 1,
                              );
                            },
                          ),
                          titlesData: FlTitlesData(
                            show: true,
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 30,
                                interval: 1,
                                getTitlesWidget: (double value, TitleMeta meta) {
                                  const style = TextStyle(
                                    color: Colors.black54,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 11,
                                  );
                                  Widget text;
                                  switch (value.toInt()) {
                                    case 0:
                                      text = const Text('Mon', style: style);
                                      break;
                                    case 1:
                                      text = const Text('Tue', style: style);
                                      break;
                                    case 2:
                                      text = const Text('Wed', style: style);
                                      break;
                                    case 3:
                                      text = const Text('Thu', style: style);
                                      break;
                                    case 4:
                                      text = const Text('Fri', style: style);
                                      break;
                                    case 5:
                                      text = const Text('Sat', style: style);
                                      break;
                                    case 6:
                                      text = const Text('Sun', style: style);
                                      break;
                                    default:
                                      text = const Text('', style: style);
                                      break;
                                  }
                                  return SideTitleWidget(
                                    axisSide: meta.axisSide,
                                    child: text,
                                  );
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                interval: 20,
                                reservedSize: 30,
                                getTitlesWidget: (double value, TitleMeta meta) {
                                  const style = TextStyle(
                                    color: Colors.black54,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 11,
                                  );
                                  return Text(
                                    value.toInt().toString(),
                                    style: style,
                                    textAlign: TextAlign.left,
                                  );
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          minX: 0,
                          maxX: 6,
                          minY: 0,
                          maxY: 80,
                          lineBarsData: [
                            LineChartBarData(
                              spots: const [
                                FlSpot(0, 35),
                                FlSpot(1, 45),
                                FlSpot(2, 55),
                                FlSpot(3, 65),
                                FlSpot(4, 50),
                                FlSpot(5, 40),
                                FlSpot(6, 70),
                              ],
                              isCurved: true,
                              color: const Color(0xFF5B7FDB),
                              barWidth: 3,
                              isStrokeCapRound: true,
                              dotData: FlDotData(show: false),
                              belowBarData: BarAreaData(
                                show: true,
                                color: const Color(0xFF5B7FDB).withOpacity(0.1),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
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
}