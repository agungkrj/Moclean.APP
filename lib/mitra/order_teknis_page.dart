import 'package:flutter/material.dart';

class OrderTeknisiPage extends StatefulWidget {
  const OrderTeknisiPage({super.key});

  @override
  State<OrderTeknisiPage> createState() => _OrderTeknisiPageState();
}

class _OrderTeknisiPageState extends State<OrderTeknisiPage> {
  List<Map<String, dynamic>> pesananList = [
    {
      "id": "934840981",
      "jenis": "Cuci Eksterior Mobil",
      "teknisi": "Super CarWash",
      "alamat": "Jl. Mitra No.4, Batam",
      "status": "Menunggu",
    },
    {
      "id": "593749481",
      "jenis": "Cuci Mobil Komplit",
      "teknisi": "Candy CarWash",
      "alamat": "Tiban Koperasi, Batam",
      "status": "Menunggu",
    },
    {
      "id": "44566555",
      "jenis": "Cuci Interior Mobil",
      "teknisi": "AZ CarWash",
      "alamat": "Jl. Serang, Batam",
      "status": "Menunggu",
    },
  ];

  void _openDetailPesanan(Map<String, dynamic> pesanan) async {
    final updatedStatus = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailPesananPage(pesanan: pesanan),
      ),
    );

    if (updatedStatus != null) {
      setState(() {
        pesanan['status'] = updatedStatus;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Order Terbaru",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF3C6EEF),
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: pesananList.length,
        itemBuilder: (context, index) {
          final pesanan = pesananList[index];
          return GestureDetector(
            onTap: () => _openDetailPesanan(pesanan),
            child: Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFF3C6EEF),
                  child: const Icon(Icons.directions_car, color: Colors.white),
                ),
                title: Text(
                  pesanan['jenis'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  "${pesanan['teknisi']}\n${pesanan['alamat']}",
                  style: const TextStyle(height: 1.4),
                ),
                trailing: const Icon(Icons.chevron_right),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ============== DETAIL PESANAN ==============

class DetailPesananPage extends StatefulWidget {
  final Map<String, dynamic> pesanan;
  const DetailPesananPage({super.key, required this.pesanan});

  @override
  State<DetailPesananPage> createState() => _DetailPesananPageState();
}

class _DetailPesananPageState extends State<DetailPesananPage> {
  late String status;

  @override
  void initState() {
    super.initState();
    status = widget.pesanan['status'];
  }

  void _updateStatus(String newStatus) {
    setState(() => status = newStatus);
  }

  @override
  Widget build(BuildContext context) {
    final pesanan = widget.pesanan;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Detail Pesanan"),
        backgroundColor: const Color(0xFF3C6EEF),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.location_on, color: Color(0xFF3C6EEF)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      pesanan['alamat'],
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Text("ID Pesanan: ${pesanan['id']}"),
            const SizedBox(height: 8),
            Text("Jenis Layanan: ${pesanan['jenis']}"),
            const SizedBox(height: 8),
            const Text("Detail Kendaraan: Suzuki Ertiga BP 1122 C"),
            const SizedBox(height: 8),
            const Text("Jumlah Unit: 1 (Satu)"),
            const SizedBox(height: 8),
            Text("Status: $status"),
            const Spacer(),

            // Tombol aksi
            if (status == "Menunggu") ...[
              ElevatedButton(
                onPressed: () {
                  _updateStatus("Diterima");
                  Navigator.pop(context, "Diterima");
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3C6EEF),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text("Terima"),
              ),
            ] else if (status == "Diterima") ...[
              ElevatedButton(
                onPressed: () {
                  _updateStatus("Sedang Dicuci");
                  Navigator.pop(context, "Sedang Dicuci");
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3C6EEF),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text("Mulai Cuci"),
              ),
            ] else ...[
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text("Selesai"),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
