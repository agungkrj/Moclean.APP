import 'package:flutter/material.dart';
import 'package:moclienapp/fiturr/pembayaran_page.dart';
import 'package:moclienapp/models/order_model.dart';
import 'package:intl/intl.dart';

class RincianPesananPage extends StatelessWidget {
  final OrderModel order;
  
  const RincianPesananPage({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    // ===== FORMAT TANGGAL =====
    String formattedDate = DateFormat('EEEE, dd MMM yy', 'id_ID').format(order.orderDate);
    String formattedTime = DateFormat('HH:mm').format(order.createdAt);
    
    // ===== HITUNG BIAYA =====
    // Ambil angka dari harga (contoh: "Rp. 80.000" -> 80000)
    int biayaLayanan = int.parse(order.servicePrice.replaceAll(RegExp(r'[^0-9]'), ''));
    
    // Biaya berdasarkan ukuran mobil
    int biayaUkuran = 0;
    if (order.ukuranMobil == "Kecil") {
      biayaUkuran = 0;
    } else if (order.ukuranMobil == "Sedang") {
      biayaUkuran = 20000;
    } else if (order.ukuranMobil == "Besar") {
      biayaUkuran = 40000;
    }
    
    int biayaAdmin = 1500;
    int total = biayaLayanan + biayaUkuran + biayaAdmin;
    
    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Rincian Pesanan",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Konfirmasi Pesananmu",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),

            // ===== LOKASI =====
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF0FF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.black87, size: 18),
                      SizedBox(width: 6),
                      Text(
                        "Lokasi",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "[${order.customerName}] ${order.phone}",
                    style: const TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    order.address,
                    style: const TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    "Mitra: ${order.mitra}",
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF2C4A8F),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ===== DETAIL PESANAN =====
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF0FF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ID Pesanan
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "ID Pesanan",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        order.orderId.substring(order.orderId.length - 9),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Tanggal dan Waktu
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today, color: Colors.black54, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              formattedDate,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.access_time, color: Colors.black54, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              formattedTime,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  
                  // Jenis Layanan
                  const Text(
                    "Jenis Layanan",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    order.serviceName,
                    style: const TextStyle(fontSize: 13),
                  ),
                  
                  const SizedBox(height: 10),

                  // Detail Kendaraan
                  const Text(
                    "Detail Kendaraan",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    "${order.brand} ${order.type} - Plat ${order.nopolisi}",
                    style: const TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    "Ukuran: ${order.ukuranMobil}",
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  
                  const SizedBox(height: 10),

                  // Email
                  const Text(
                    "Email",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    order.email,
                    style: const TextStyle(fontSize: 13),
                  ),
                  
                  const SizedBox(height: 10),

                  // Jumlah Unit
                  const Text(
                    "Jumlah Unit",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  const SizedBox(height: 3),
                  const Text(
                    "1",
                    style: TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ===== RINCIAN BIAYA =====
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CostRow(
                    "Biaya Layanan",
                    "Rp ${NumberFormat('#,###', 'id_ID').format(biayaLayanan)}",
                  ),
                  CostRow(
                    "Biaya Ukuran (${order.ukuranMobil})",
                    "Rp ${NumberFormat('#,###', 'id_ID').format(biayaUkuran)}",
                  ),
                  CostRow(
                    "Biaya Admin",
                    "Rp ${NumberFormat('#,###', 'id_ID').format(biayaAdmin)}",
                  ),
                  const Divider(height: 20, thickness: 1),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Total",
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        "Rp ${NumberFormat('#,###', 'id_ID').format(total)}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // ===== TOMBOL AKSI =====
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  height: 42,
                  width: 120,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF1E3A8A)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Kembali",
                      style: TextStyle(
                        color: Color(0xFF1E3A8A),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 42,
                  width: 120,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E3A8A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      // LOGIKA: Kirim data order dan total ke halaman pembayaran
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PembayaranPage(
                            order: order,
                            totalAmount: total,
                            biayaLayanan: biayaLayanan,
                            biayaUkuran: biayaUkuran,
                            biayaAdmin: biayaAdmin,
                          ),
                        ),
                      );
                    },
                    child: const Text(
                      "Pesan",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// ===== WIDGET BARIS BIAYA =====
class CostRow extends StatelessWidget {
  final String title;
  final String value;
  
  const CostRow(this.title, this.value, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black87,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}