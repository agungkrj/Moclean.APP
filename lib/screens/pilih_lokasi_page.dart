import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';

class PilihLokasiPage extends StatefulWidget {
  const PilihLokasiPage({super.key});

  @override
  State<PilihLokasiPage> createState() => _PilihLokasiPageState();
}

class _PilihLokasiPageState extends State<PilihLokasiPage> {
  late MapController controller;
  GeoPoint? selectedPoint;

  String? selectedKecamatan;
  String? selectedKelurahan;

  // Daftar kecamatan dan kelurahan di Batam (contoh, bisa kamu tambah)
  final Map<String, List<String>> kelurahanData = {
    "Batu Aji": ["Bukit Tempayan", "Buliang", "Tanjung Uncang"],
    "Batu Ampar": ["Seraya", "Sungai Jodoh", "Tanjung Sengkuang"],
    "Batam Kota": ["Belian", "Sukajadi", "Teluk Tering"],
    "Sekupang": ["Tanjung Pinggir", "Tiban Baru", "Patam Lestari"],
  };

  // Koordinat kecamatan (buat map otomatis pindah)
  final Map<String, GeoPoint> kecamatanCoords = {
    "Batu Aji": GeoPoint(latitude: 1.047, longitude: 103.994),
    "Batu Ampar": GeoPoint(latitude: 1.160, longitude: 104.013),
    "Batam Kota": GeoPoint(latitude: 1.104, longitude: 104.048),
    "Sekupang": GeoPoint(latitude: 1.124, longitude: 103.949),
  };

  @override
  void initState() {
    super.initState();
    controller = MapController(
      initPosition: GeoPoint(latitude: 1.104, longitude: 104.048), // Batam default
    );

    // Listener tap peta
    controller.listenerMapSingleTapping.addListener(() async {
      final GeoPoint? point = controller.listenerMapSingleTapping.value;
      if (point != null) {
        // Untuk menghapus marker lama, kita tidak perlu panggil removeAllMarkers
        // Langsung tambah marker baru saja (biasanya otomatis replace)
        setState(() {
          selectedPoint = point;
        });
        await controller.addMarker(
          point,
          markerIcon: const MarkerIcon(
            icon: Icon(Icons.location_on, color: Colors.red, size: 48),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void pindahKeKecamatan(String kecamatan) async {
    final pos = kecamatanCoords[kecamatan];
    if (pos != null) {
      // Pindah lokasi peta
      await controller.changeLocation(pos);
      
      // Set zoom level
      await controller.setZoom(zoomLevel: 15);
      
      // Tidak perlu removeAllMarkers, langsung tambah marker baru
      await controller.addMarker(
        pos,
        markerIcon: const MarkerIcon(
          icon: Icon(Icons.location_on, color: Colors.blue, size: 48),
        ),
      );
      
      // Update state
      setState(() {
        selectedPoint = pos;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pilih Lokasi Kamu"),
        backgroundColor: const Color(0xFF3C6EEF),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Form Alamat
            const Text("Provinsi :"),
            const SizedBox(height: 4),
            TextFormField(
              readOnly: true,
              initialValue: "KEPULAUAN RIAU",
              decoration: _inputDecoration(),
            ),
            const SizedBox(height: 12),
            const Text("Kota :"),
            const SizedBox(height: 4),
            TextFormField(
              readOnly: true,
              initialValue: "BATAM",
              decoration: _inputDecoration(),
            ),
            const SizedBox(height: 12),

            // Dropdown Kecamatan
            const Text("Kecamatan :"),
            const SizedBox(height: 4),
            DropdownButtonFormField<String>(
              value: selectedKecamatan,
              decoration: _inputDecoration(),
              hint: const Text("Pilih Kecamatan"),
              items: kelurahanData.keys
                  .map<DropdownMenuItem<String>>((kec) => DropdownMenuItem<String>(
                        value: kec,
                        child: Text(kec),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedKecamatan = value;
                  selectedKelurahan = null;
                });
                pindahKeKecamatan(value!);
              },
            ),
            const SizedBox(height: 12),

            // Dropdown Kelurahan
            const Text("Kelurahan :"),
            const SizedBox(height: 4),
            DropdownButtonFormField<String>(
              value: selectedKelurahan,
              decoration: _inputDecoration(),
              hint: const Text("Pilih Kelurahan"),
              items: (selectedKecamatan == null
                      ? <String>[]
                      : kelurahanData[selectedKecamatan]!)
                  .map<DropdownMenuItem<String>>((kel) => DropdownMenuItem<String>(
                        value: kel,
                        child: Text(kel),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedKelurahan = value;
                });
              },
            ),
            const SizedBox(height: 16),

            const Text(
              "Tentukan titik pinpoint lokasi kamu",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            SizedBox(
              height: 250,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: OSMFlutter(
                  controller: controller,
                  osmOption: OSMOption(
                    zoomOption: const ZoomOption(
                      initZoom: 15,
                      minZoomLevel: 3,
                      maxZoomLevel: 19,
                    ),
                    showDefaultInfoWindow: true,
                  ),
                  mapIsLoading:
                      const Center(child: CircularProgressIndicator()),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Tombol-tombol
            ElevatedButton.icon(
              icon: const Icon(Icons.location_on),
              label: const Text("Tandai Lokasi di Peta"),
              style: _buttonStyle(),
              onPressed: () {},
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              style: _buttonStyle(),
              onPressed: () {
                if (selectedPoint != null) {
                  Navigator.pop(
                    context,
                    "Lat: ${selectedPoint!.latitude}, Lng: ${selectedPoint!.longitude}",
                  );
                }
              },
              child: const Text("Simpan Alamat"),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  ButtonStyle _buttonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF3C6EEF),
      minimumSize: const Size(double.infinity, 48),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}