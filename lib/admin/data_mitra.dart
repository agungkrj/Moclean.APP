import 'package:flutter/material.dart';

class DataMitraPage extends StatelessWidget {
  const DataMitraPage({Key? key}) : super(key: key);

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
          'Data Mitra',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildMitraCard(
            context,
            status: 'AKTIF',
            nama: 'Sipaling Car Wash',
            noWhatsapp: '0812 3456 5656',
            area: 'Tiban',
            rating: 4.9,
            pesananSelesai: 20,
            pendapatan: 'Rp. 900.560',
            alamat: 'Jl. Jalan Sore Blok C No. 505, Tiban, Batam',
            statusVerifikasi: 'Aktif - Terverifikasi',
            tanggalVerifikasi: '22 Agustus 2025',
            jumlahTeknisi: 9,
            rataRataPesanan: 5,
            rataRataPendapatan: 'Rp. 350.000,00',
          ),
          const SizedBox(height: 12),
          _buildMitraCard(
            context,
            status: 'AKTIF',
            nama: 'Sipaling Car Wash',
            noWhatsapp: '0812 3456 5656',
            area: 'Tiban',
            rating: 4.9,
            pesananSelesai: 20,
            pendapatan: 'Rp. 900.560',
            alamat: 'Jl. Jalan Sore Blok C No. 505, Tiban, Batam',
            statusVerifikasi: 'Aktif - Terverifikasi',
            tanggalVerifikasi: '22 Agustus 2025',
            jumlahTeknisi: 9,
            rataRataPesanan: 5,
            rataRataPendapatan: 'Rp. 350.000,00',
          ),
          const SizedBox(height: 12),
          _buildMitraCard(
            context,
            status: 'AKTIF',
            nama: 'Sipaling Car Wash',
            noWhatsapp: '0812 3456 5656',
            area: 'Tiban',
            rating: 4.9,
            pesananSelesai: 20,
            pendapatan: 'Rp. 900.560',
            alamat: 'Jl. Jalan Sore Blok C No. 505, Tiban, Batam',
            statusVerifikasi: 'Aktif - Terverifikasi',
            tanggalVerifikasi: '22 Agustus 2025',
            jumlahTeknisi: 9,
            rataRataPesanan: 5,
            rataRataPendapatan: 'Rp. 350.000,00',
          ),
          const SizedBox(height: 12),
          _buildMitraCard(
            context,
            status: 'AKTIF',
            nama: 'Sipaling Car Wash',
            noWhatsapp: '0812 3456 5656',
            area: 'Tiban',
            rating: 4.9,
            pesananSelesai: 20,
            pendapatan: 'Rp. 900.560',
            alamat: 'Jl. Jalan Sore Blok C No. 505, Tiban, Batam',
            statusVerifikasi: 'Aktif - Terverifikasi',
            tanggalVerifikasi: '22 Agustus 2025',
            jumlahTeknisi: 9,
            rataRataPesanan: 5,
            rataRataPendapatan: 'Rp. 350.000,00',
          ),
          const SizedBox(height: 12),
          _buildMitraCard(
            context,
            status: 'AKTIF',
            nama: 'Sipaling Car Wash',
            noWhatsapp: '0812 3456 5656',
            area: 'Tiban',
            rating: 4.9,
            pesananSelesai: 20,
            pendapatan: 'Rp. 900.560',
            alamat: 'Jl. Jalan Sore Blok C No. 505, Tiban, Batam',
            statusVerifikasi: 'Aktif - Terverifikasi',
            tanggalVerifikasi: '22 Agustus 2025',
            jumlahTeknisi: 9,
            rataRataPesanan: 5,
            rataRataPendapatan: 'Rp. 350.000,00',
          ),
        ],
      ),
    );
  }

  Widget _buildMitraCard(
    BuildContext context, {
    required String status,
    required String nama,
    required String noWhatsapp,
    required String area,
    required double rating,
    required int pesananSelesai,
    required String pendapatan,
    required String alamat,
    required String statusVerifikasi,
    required String tanggalVerifikasi,
    required int jumlahTeknisi,
    required int rataRataPesanan,
    required String rataRataPendapatan,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8EBFF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'STATUS',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  status,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'NO WHATSAPP',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  noWhatsapp,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'NAMA',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  nama,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Area',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  area,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.open_in_new,
              size: 18,
              color: Colors.black54,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () {
              _showMitraDetailBottomSheet(
                context,
                nama: nama,
                noWhatsapp: noWhatsapp,
                rating: rating,
                pesananSelesai: pesananSelesai,
                pendapatan: pendapatan,
                alamat: alamat,
                statusVerifikasi: statusVerifikasi,
                tanggalVerifikasi: tanggalVerifikasi,
                jumlahTeknisi: jumlahTeknisi,
                rataRataPesanan: rataRataPesanan,
                rataRataPendapatan: rataRataPendapatan,
              );
            },
          ),
        ],
      ),
    );
  }

  void _showMitraDetailBottomSheet(
    BuildContext context, {
    required String nama,
    required String noWhatsapp,
    required double rating,
    required int pesananSelesai,
    required String pendapatan,
    required String alamat,
    required String statusVerifikasi,
    required String tanggalVerifikasi,
    required int jumlahTeknisi,
    required int rataRataPesanan,
    required String rataRataPendapatan,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Color(0xFFE8EBFF),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 20),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  nama,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  noWhatsapp,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Row(
                            children: [
                              const Icon(
                                Icons.star,
                                size: 16,
                                color: Colors.black87,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                rating.toString(),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Stats Row
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Pesanan selesai',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  pesananSelesai.toString(),
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Pendapatan',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  pendapatan,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Alamat
                      const Text(
                        'Alamat',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        alamat,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black87,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Status
                      const Text(
                        'Status',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        statusVerifikasi,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black87,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Tanggal Verifikasi
                      const Text(
                        'Tanggal Verifikasi',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        tanggalVerifikasi,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black87,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Jumlah Teknisi
                      const Text(
                        'Jumlah Teknisi',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$jumlahTeknisi Orang',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black87,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Rata-Rata Pesanan /hari
                      const Text(
                        'Rata-Rata Pesanan /hari',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        rataRataPesanan.toString(),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black87,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Rata-Rata Pendapatan /hari
                      const Text(
                        'Rata-Rata Pendapatan /hari',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        rataRataPendapatan,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black87,
                        ),
                      ),

                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}