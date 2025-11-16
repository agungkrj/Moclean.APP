import 'package:flutter/material.dart';

class DataPesananPage extends StatefulWidget {
  const DataPesananPage({super.key});

  @override
  State<DataPesananPage> createState() => _DataPesananPageState();
}

class _DataPesananPageState extends State<DataPesananPage> {
  int? expandedIndex;

  final List<Map<String, String>> pesananList = [
    {
      "layanan": "Cuci Eksterior Mobil",
      "id": "339489031",
      "teknisi": "Super CarWash",
      "alamat": "Tiban Mutiara No.4",
      "waktu": "12.23"
    },
    {
      "layanan": "Cuci Mobil Komplit",
      "id": "583749014",
      "teknisi": "Candy CarWash",
      "alamat": "Tiban Koperasi",
      "waktu": "12.20"
    },
    {
      "layanan": "Cuci Mobil Komplit",
      "id": "583749014",
      "teknisi": "Candy CarWash",
      "alamat": "Tiban Koperasi",
      "waktu": "12.14"
    },
    {
      "layanan": "Cuci Eksterior Mobil",
      "id": "339489031",
      "teknisi": "Super CarWash",
      "alamat": "Tiban Mutiara No.4",
      "waktu": "11.30"
    },
    {
      "layanan": "Cuci Mobil Komplit",
      "id": "583749014",
      "teknisi": "Candy CarWash",
      "alamat": "Tiban Koperasi",
      "waktu": "10.50"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back, color: Colors.black),
        ),
        title: const Text(
          "Data Pesanan",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Pesanan Masuk",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),

            Expanded(
              child: ListView.builder(
                itemCount: pesananList.length,
                itemBuilder: (context, index) {
                  final data = pesananList[index];
                  final bool expanded = expandedIndex == index;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        expandedIndex = expanded ? null : index;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.fastOutSlowIn,
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          )
                        ],
                      ),

                      child: Column(
                        children: [
                          Row(
                            children: [
                              // Icon
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE9E5FC),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(Icons.directions_car,
                                    size: 35, color: Color(0xFF6F4FF2)),
                              ),

                              const SizedBox(width: 14),

                              // Basic info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      data["layanan"]!,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 6),

                                    Text("ID Pesanan      ${data['id']}", style: const TextStyle(fontSize: 13)),
                                    Text("Teknisi             ${data['teknisi']}", style: const TextStyle(fontSize: 13)),
                                    Text("Alamat            ${data['alamat']}", style: const TextStyle(fontSize: 13)),
                                  ],
                                ),
                              ),

                              Column(
                                children: [
                                  Text(data["waktu"]!,
                                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 6),
                                  const CircleAvatar(radius: 6, backgroundColor: Color(0xFF9ACC44)),
                                ],
                              ),
                            ],
                          ),

                          // =====================
                          //    Detail Expanded
                          // =====================
                          if (expanded) ...[
                            const SizedBox(height: 12),
                            const Divider(),

                            const SizedBox(height: 10),

                            detailItem("Layanan", data["layanan"]!),
                            detailItem("ID Pesanan", data["id"]!),
                            detailItem("Teknisi", data["teknisi"]!),
                            detailItem("Alamat", data["alamat"]!),
                            detailItem("Waktu", data["waktu"]!),
                          ]
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget detailItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
              child: Text(title,
                  style: const TextStyle(fontSize: 14, color: Colors.grey))),
          Expanded(
              child: Text(value,
                  style:
                      const TextStyle(fontSize: 15, fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}
