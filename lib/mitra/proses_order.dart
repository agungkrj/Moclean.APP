import 'package:flutter/material.dart';

class ProsesOrderPage extends StatelessWidget {
  const ProsesOrderPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Pesanan Sedang Diproses',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
            _buildOrderCard(
              title: 'Cuci Eksterior Mobil',
              idPesanan: '330448103910391',
              teknisi: 'Super CarWash',
              alamat: 'Tiban Mutiara No.4',
            ),
            _buildOrderCard(
              title: 'Cuci Mobil Komplit',
              idPesanan: '583744914',
              teknisi: 'Candy CarWash',
              alamat: 'Tiban Koperasi',
            ),
            _buildOrderCard(
              title: 'Cuci Eksterior Mobil',
              idPesanan: '98948329',
              teknisi: 'Pony CarWash',
              alamat: 'Jl. Rimba No.3',
            ),
            _buildOrderCard(
              title: 'Cuci Interior Mobil',
              idPesanan: '44656665',
              teknisi: 'A2 CarWash',
              alamat: 'Jl. Serong',
            ),
            _buildOrderCard(
              title: 'Cuci Interior Mobil',
              idPesanan: '44656665',
              teknisi: 'A2 CarWash',
              alamat: 'Jl. Serong',
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard({
    required String title,
    required String idPesanan,
    required String teknisi,
    required String alamat,
  }) {
    return InkWell(
      onTap: () {
        // Tambahkan aksi ketika card diklik
        // Misalnya navigasi ke detail order
        // Navigator.push(context, MaterialPageRoute(builder: (context) => DetailOrderPage(idPesanan: idPesanan)));
        print('Card diklik: $idPesanan');
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
            // Icon Circle
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
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
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
                          idPesanan,
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
                          teknisi,
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
                          alamat,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Green Dot
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Color(0xFF4CAF50),
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}