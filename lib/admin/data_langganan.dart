import 'package:flutter/material.dart';

class DataLanggananPage extends StatelessWidget {
  const DataLanggananPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ⬅️ Back + Title
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back, size: 26),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "Data Langganan",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              const Text(
                "Langganan Aktif",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 12),

              // List Card
              Expanded(
                child: ListView(
                  children: [
                    _langgananCard(
                      idPelanggan: "325341839",
                      idLangganan: "346287281",
                      paket: "Bronze",
                      mulai: "01 Jan 2026",
                      berakhir: "01 Feb 2026",
                    ),
                    _langgananCard(
                      idPelanggan: "754677645",
                      idLangganan: "344687629",
                      paket: "Bronze",
                      mulai: "01 Jan 2026",
                      berakhir: "01 Feb 2026",
                    ),
                    _langgananCard(
                      idPelanggan: "445653523",
                      idLangganan: "467858324",
                      paket: "Gold",
                      mulai: "01 Jan 2026",
                      berakhir: "01 Feb 2026",
                    ),
                    _langgananCard(
                      idPelanggan: "55665843",
                      idLangganan: "568787653",
                      paket: "Platinum",
                      mulai: "01 Jan 2026",
                      berakhir: "01 Feb 2026",
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================
  // CARD SUBSCRIPTION DESIGN
  // ============================
  Widget _langgananCard({
    required String idPelanggan,
    required String idLangganan,
    required String paket,
    required String mulai,
    required String berakhir,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE7EBFF),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row ID pelanggan
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "ID Pelanggan",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                idPelanggan,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          _detailText("ID Langganan", idLangganan),
          _detailText("Paket", paket),
          _detailText("Tanggal Mulai", mulai),
          _detailText("Tanggal Berakhir", berakhir),

          const SizedBox(height: 8),

          Align(
            alignment: Alignment.centerRight,
            child: Text(
              "batalkan",
              style: TextStyle(
                color: Colors.blue.shade800,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Reusable detail row
  Widget _detailText(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
      ],
    );
  }
}
