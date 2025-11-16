import 'package:flutter/material.dart';
import 'package:moclienapp/fiturr/rincian_pesanan.dart';

class PesanLayananPage extends StatefulWidget {
  const PesanLayananPage({super.key});

  @override
  State<PesanLayananPage> createState() => _PesanLayananPageState();
}

class _PesanLayananPageState extends State<PesanLayananPage> {
  String selectedUkuran = "Kecil";
  String selectedMitra = "Pilih Mitra Terdekat";
  String selectedBrand = "Pilih Brand";
  DateTime? selectedDate;

  final List<String> mitraList = [
    "Pilih Mitra Terdekat",
    "Mitra Batam Center",
    "Mitra Nagoya",
    "Mitra Sekupang",
    "Mitra Batu Aji",
  ];

  final Map<String, List<String>> brandByUkuran = {
    "Kecil": ["Pilih Brand", "Agya", "Ayla", "Brio", "Picanto"],
    "Sedang": ["Pilih Brand", "Avanza", "Jazz", "Yaris", "Xpander"],
    "Besar": ["Pilih Brand", "Fortuner", "Pajero", "Innova", "Alphard"],
  };

  @override
  Widget build(BuildContext context) {
    List<String> currentBrandList = brandByUkuran[selectedUkuran]!;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Pesan Layanan",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // === PILIH UKURAN MOBIL ===
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF2C4A8F),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          "Pilih Ukuran Mobil Anda",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        Icon(Icons.keyboard_arrow_down, color: Colors.white),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            buildUkuranButton("Kecil", Icons.directions_car),
                            buildUkuranButton(
                                "Sedang", Icons.directions_car_filled),
                            buildUkuranButton("Besar", Icons.airport_shuttle),
                          ],
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          "Cari Tahu Ukuran Mobil Anda",
                          style: TextStyle(
                            color: Color(0xFF4A90E2),
                            fontSize: 10,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // === ISI DATA DIRI ===
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF2C4A8F),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          "Isi Data Diri",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        Icon(Icons.keyboard_arrow_down, color: Colors.white),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                    ),
                    child: Column(
                      children: [
                        buildTextField("Nama", "Isi nama lengkap",
                            icon: Icons.person),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Expanded(
                              child: buildTextField(
                                "Nomor Whatsapp",
                                "081223456",
                                icon: Icons.phone,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: buildTextField(
                                "Email",
                                "gmail.com",
                                icon: Icons.email,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Expanded(
                              child: buildTextField(
                                "Alamat",
                                "Isi alamat lengkap",
                                icon: Icons.location_on,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: buildDropdownField(
                                "Mitra",
                                selectedMitra,
                                mitraList,
                                (val) {
                                  setState(() {
                                    selectedMitra = val!;
                                  });
                                },
                                icon: Icons.store,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () async {
                                  final pickedDate = await showDatePicker(
                                    context: context,
                                    initialDate:
                                        selectedDate ?? DateTime.now(),
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime(2100),
                                    builder: (context, child) {
                                      return Theme(
                                        data: Theme.of(context).copyWith(
                                          colorScheme:
                                              const ColorScheme.light(
                                            primary: Color(0xFF2C4A8F),
                                            onPrimary: Colors.white,
                                            onSurface: Colors.black87,
                                          ),
                                          textButtonTheme:
                                              TextButtonThemeData(
                                            style: TextButton.styleFrom(
                                              foregroundColor:
                                                  const Color(0xFF2C4A8F),
                                            ),
                                          ),
                                        ),
                                        child: SizedBox(
                                          width: 220,
                                          height: 280,
                                          child: child,
                                        ),
                                      );
                                    },
                                  );
                                  if (pickedDate != null) {
                                    setState(() {
                                      selectedDate = pickedDate;
                                    });
                                  }
                                },
                                child: AbsorbPointer(
                                  child: buildCompactTextField(
                                    "Tanggal Pesanan",
                                    selectedDate == null
                                        ? "Pilih Tanggal"
                                        : "${selectedDate!.day}-${selectedDate!.month}-${selectedDate!.year}",
                                    icon: Icons.calendar_today,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // === KENDARAAN ===
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF2C4A8F),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          "Kendaraan",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        Icon(Icons.keyboard_arrow_down, color: Colors.white),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: buildDropdownField(
                            "Brand",
                            selectedBrand,
                            currentBrandList,
                            (val) {
                              setState(() {
                                selectedBrand = val!;
                              });
                            },
                            icon: Icons.directions_car,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child:
                              buildCompactTextField("Type", "E300", icon: Icons.tag),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 1,
                          child: buildCompactTextField(
                              "No. Polisi", "B20", icon: Icons.numbers),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

           // === BUTTON (RESET + LANJUTKAN) ===
Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween, // pisahkan kiri dan kanan
  children: [
    SizedBox(
      width: 103,
      height: 29,
      child: OutlinedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.black, width: 1),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        child: const Text(
          "Reset",
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 12,
            color: Colors.black87,
          ),
        ),
      ),
    ),
    SizedBox(
      width: 103,
      height: 29,
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => RincianPesananPage()),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFD3C62DD),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        child: const Text(
          "Lanjutkan",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 12,
            color: Colors.black87,
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
  }

  // ===== COMPONENTS =====
  Widget buildTextField(String label, String hint, {required IconData icon}) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 11)),
          const SizedBox(height: 3),
          TextField(
            decoration: InputDecoration(
              prefixIcon: Icon(icon, size: 18, color: Color(0xFF2C4A8F)),
              hintText: hint,
              hintStyle: TextStyle(fontSize: 10, color: Colors.grey.shade400),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
            ),
          ),
        ],
      );

  Widget buildCompactTextField(String label, String hint,
          {required IconData icon}) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 10)),
          const SizedBox(height: 2),
          TextField(
            decoration: InputDecoration(
              prefixIcon: Icon(icon, size: 16, color: Color(0xFF2C4A8F)),
              hintText: hint,
              hintStyle: TextStyle(fontSize: 9, color: Colors.grey.shade400),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
            ),
          ),
        ],
      );

  Widget buildDropdownField(String label, String value, List<String> items,
          ValueChanged<String?> onChanged,
          {required IconData icon}) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 10)),
          const SizedBox(height: 3),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                Icon(icon, size: 16, color: const Color(0xFF2C4A8F)),
                const SizedBox(width: 6),
                Expanded(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: value,
                      isExpanded: true,
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                      icon: const Icon(Icons.keyboard_arrow_down, size: 18),
                      onChanged: onChanged,
                      items: items
                          .map((String val) => DropdownMenuItem<String>(
                                value: val,
                                child: Text(val),
                              ))
                          .toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );

  Widget buildUkuranButton(String label, IconData icon) {
    final bool isSelected = selectedUkuran == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedUkuran = label;
          selectedBrand = "Pilih Brand";
        });
      },
      child: Container(
        width: 103,
        height: 58,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2C4A8F) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? const Color(0xFF2C4A8F) : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 20,
                color: isSelected ? Colors.white : const Color(0xFF2C4A8F)),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
