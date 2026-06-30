import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class PilihLokasiPage extends StatefulWidget {
  const PilihLokasiPage({super.key});

  @override
  State<PilihLokasiPage> createState() => _PilihLokasiPageState();
}

class _PilihLokasiPageState extends State<PilihLokasiPage> with SingleTickerProviderStateMixin {
  late MapController controller;
  late AnimationController _animController;
  GeoPoint? selectedPoint;
  String? selectedAddress;

  String? selectedKecamatan;
  String? selectedKelurahan;

  final Map<String, List<String>> kelurahanData = {
    "Batu Aji": ["Bukit Tempayan", "Buliang", "Tanjung Uncang"],
    "Batu Ampar": ["Seraya", "Sungai Jodoh", "Tanjung Sengkuang"],
    "Batam Kota": ["Belian", "Sukajadi", "Teluk Tering"],
    "Sekupang": ["Tanjung Pinggir", "Tiban Baru", "Patam Lestari"],
  };

  final Map<String, GeoPoint> kecamatanCoords = {
    "Batu Aji": GeoPoint(latitude: 1.047, longitude: 103.994),
    "Batu Ampar": GeoPoint(latitude: 1.160, longitude: 104.013),
    "Batam Kota": GeoPoint(latitude: 1.104, longitude: 104.048),
    "Sekupang": GeoPoint(latitude: 1.124, longitude: 103.949),
  };

  final Map<String, Map<String, GeoPoint>> kelurahanCoords = {
    "Batu Aji": {
      "Bukit Tempayan": GeoPoint(latitude: 1.0521, longitude: 103.9892),
      "Buliang": GeoPoint(latitude: 1.0435, longitude: 104.0012),
      "Tanjung Uncang": GeoPoint(latitude: 1.0398, longitude: 103.9976),
    },
    "Batu Ampar": {
      "Seraya": GeoPoint(latitude: 1.1567, longitude: 104.0089),
      "Sungai Jodoh": GeoPoint(latitude: 1.1623, longitude: 104.0165),
      "Tanjung Sengkuang": GeoPoint(latitude: 1.1578, longitude: 104.0245),
    },
    "Batam Kota": {
      "Belian": GeoPoint(latitude: 1.1098, longitude: 104.0512),
      "Sukajadi": GeoPoint(latitude: 1.1021, longitude: 104.0456),
      "Teluk Tering": GeoPoint(latitude: 1.0976, longitude: 104.0389),
    },
    "Sekupang": {
      "Tanjung Pinggir": GeoPoint(latitude: 1.1312, longitude: 103.9523),
      "Tiban Baru": GeoPoint(latitude: 1.1189, longitude: 103.9467),
      "Patam Lestari": GeoPoint(latitude: 1.1256, longitude: 103.9389),
    },
  };

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    controller = MapController(
      initPosition: GeoPoint(latitude: 1.104, longitude: 104.048),
    );

    controller.listenerMapSingleTapping.addListener(() async {
      final GeoPoint? point = controller.listenerMapSingleTapping.value;
      if (point != null) {
        // Hapus marker sebelumnya
        await controller.removeMarkers([selectedPoint!]) .catchError((_) {});
        
        setState(() {
          selectedPoint = point;
          selectedAddress = null;
        });
        _animController.forward(from: 0);
        
        // Tambah marker baru
        await controller.addMarker(
          point,
          markerIcon: const MarkerIcon(
            icon: Icon(Icons.location_on, color: Colors.red, size: 48),
          ),
        );
        
        getAddressFromCoordinates(point);
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    controller.dispose();
    super.dispose();
  }

  void pindahKeKecamatan(String kecamatan) async {
    final pos = kecamatanCoords[kecamatan];
    if (pos != null) {
      // Hapus marker sebelumnya jika ada
      if (selectedPoint != null) {
        await controller.removeMarkers([selectedPoint!]).catchError((_) {});
      }
      
      await controller.changeLocation(pos);
      await controller.setZoom(zoomLevel: 15);
      await controller.addMarker(
        pos,
        markerIcon: const MarkerIcon(
          icon: Icon(Icons.location_on, color: Colors.blue, size: 48),
        ),
      );
      setState(() {
        selectedPoint = pos;
        selectedAddress = "Kecamatan $kecamatan";
      });
    }
  }

  void pindahKeKelurahan(String kecamatan, String kelurahan) async {
    final pos = kelurahanCoords[kecamatan]?[kelurahan];
    if (pos != null) {
      // Hapus marker sebelumnya jika ada
      if (selectedPoint != null) {
        await controller.removeMarkers([selectedPoint!]).catchError((_) {});
      }
      
      await controller.changeLocation(pos);
      await controller.setZoom(zoomLevel: 16);
      await controller.addMarker(
        pos,
        markerIcon: const MarkerIcon(
          icon: Icon(Icons.location_on, color: Colors.green, size: 48),
        ),
      );
      setState(() {
        selectedPoint = pos;
        selectedAddress = "Kelurahan $kelurahan, Kec. $kecamatan";
      });
    }
  }

  Future<void> getAddressFromCoordinates(GeoPoint point) async {
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=${point.latitude}&lon=${point.longitude}&zoom=18&addressdetails=1',
      );
      
      final response = await http.get(
        url,
        headers: {
          'User-Agent': 'FlutterApp/1.0',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final address = data['address'];
        
        setState(() {
          // Prioritas: road > neighbourhood > suburb > village
          String finalAddress = '';
          
          if (address['road'] != null) {
            finalAddress = address['road'];
          } else if (address['neighbourhood'] != null) {
            finalAddress = address['neighbourhood'];
          } else if (address['suburb'] != null) {
            finalAddress = address['suburb'];
          } else if (address['village'] != null) {
            finalAddress = address['village'];
          } else if (address['residential'] != null) {
            finalAddress = address['residential'];
          } else {
            finalAddress = "Lokasi di Batam";
          }
          
          // Tambahkan kelurahan/kecamatan jika ada
          if (address['suburb'] != null && address['road'] != null) {
            finalAddress += ", ${address['suburb']}";
          }
          
          selectedAddress = finalAddress;
        });
      } else {
        setState(() {
          selectedAddress = "Lokasi terpilih";
        });
      }
    } catch (e) {
      setState(() {
        selectedAddress = "Lokasi terpilih";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          "Pilih Lokasi",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF3C6EEF),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF3C6EEF), Color(0xFF5C8EFF)],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Tentukan Lokasi Anda",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Pilih alamat atau tandai langsung di peta",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF3C6EEF).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.location_city,
                                color: Color(0xFF3C6EEF),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              "Informasi Alamat",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _buildLabeledField(
                          label: "Provinsi",
                          icon: Icons.map_outlined,
                          child: TextFormField(
                            readOnly: true,
                            initialValue: "Kepulauan Riau",
                            style: const TextStyle(fontWeight: FontWeight.w500),
                            decoration: _inputDecoration(enabled: false),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildLabeledField(
                          label: "Kota",
                          icon: Icons.location_city_outlined,
                          child: TextFormField(
                            readOnly: true,
                            initialValue: "Batam",
                            style: const TextStyle(fontWeight: FontWeight.w500),
                            decoration: _inputDecoration(enabled: false),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildLabeledField(
                          label: "Kecamatan",
                          icon: Icons.domain,
                          child: DropdownButtonFormField<String>(
                            value: selectedKecamatan,
                            decoration: _inputDecoration(),
                            hint: const Text(
                              "Pilih Kecamatan",
                              style: TextStyle(color: Colors.grey),
                            ),
                            items: kelurahanData.keys
                                .map<DropdownMenuItem<String>>((kec) =>
                                    DropdownMenuItem<String>(
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
                        ),
                        const SizedBox(height: 16),
                        _buildLabeledField(
                          label: "Kelurahan",
                          icon: Icons.home_work_outlined,
                          child: DropdownButtonFormField<String>(
                            value: selectedKelurahan,
                            decoration: _inputDecoration(
                              enabled: selectedKecamatan != null,
                            ),
                            hint: Text(
                              selectedKecamatan == null
                                  ? "Pilih kecamatan terlebih dahulu"
                                  : "Pilih Kelurahan",
                              style: const TextStyle(color: Colors.grey),
                            ),
                            items: (selectedKecamatan == null
                                    ? <String>[]
                                    : kelurahanData[selectedKecamatan]!)
                                .map<DropdownMenuItem<String>>((kel) =>
                                    DropdownMenuItem<String>(
                                      value: kel,
                                      child: Text(kel),
                                    ))
                                .toList(),
                            onChanged: selectedKecamatan == null
                                ? null
                                : (value) {
                                    setState(() {
                                      selectedKelurahan = value;
                                    });
                                    if (value != null && selectedKecamatan != null) {
                                      pindahKeKelurahan(selectedKecamatan!, value);
                                    }
                                  },
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  _buildCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF3C6EEF).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.pin_drop,
                                color: Color(0xFF3C6EEF),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Tentukan Pinpoint",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF1A1A1A),
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    "Tap pada peta untuk menandai lokasi",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          height: 280,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: OSMFlutter(
                              controller: controller,
                              osmOption: OSMOption(
                                zoomOption: const ZoomOption(
                                  initZoom: 15,
                                  minZoomLevel: 10,
                                  maxZoomLevel: 19,
                                ),
                                userTrackingOption: const UserTrackingOption(
                                  enableTracking: false,
                                  unFollowUser: false,
                                ),
                                roadConfiguration: const RoadOption(
                                  roadColor: Colors.blueAccent,
                                ),
                                showDefaultInfoWindow: false,
                              ),
                              mapIsLoading: Container(
                                color: Colors.grey[200],
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    color: Color(0xFF3C6EEF),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (selectedPoint != null) ...[
                          const SizedBox(height: 12),
                          FadeTransition(
                            opacity: _animController,
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.green.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "Lokasi berhasil ditandai",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                            color: Colors.green,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        if (selectedAddress == null)
                                          Row(
                                            children: [
                                              SizedBox(
                                                width: 12,
                                                height: 12,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor: AlwaysStoppedAnimation<Color>(
                                                    Colors.grey[600]!,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                "Mengambil alamat...",
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey[600],
                                                  fontStyle: FontStyle.italic,
                                                ),
                                              ),
                                            ],
                                          )
                                        else
                                          Text(
                                            selectedAddress!,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[700],
                                              fontWeight: FontWeight.w500,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3C6EEF),
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shadowColor: const Color(0xFF3C6EEF).withOpacity(0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: selectedPoint == null
                          ? null
                          : () {
                              Navigator.pop(
                                context,
                                {
                                  'address': selectedAddress ?? 'Lokasi terpilih',
                                  'latitude': selectedPoint!.latitude,
                                  'longitude': selectedPoint!.longitude,
                                },
                              );
                            },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.save_outlined, size: 20),
                          SizedBox(width: 8),
                          Text(
                            "Simpan Alamat",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildLabeledField({
    required String label,
    required IconData icon,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  InputDecoration _inputDecoration({bool enabled = true}) {
    return InputDecoration(
      filled: true,
      fillColor: enabled ? Colors.grey[50] : Colors.grey[100],
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF3C6EEF), width: 2),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
    );
  }
}