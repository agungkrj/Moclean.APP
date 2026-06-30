import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class AlamatPage extends StatefulWidget {
  const AlamatPage({super.key});

  @override
  State<AlamatPage> createState() => _AlamatPageState();
}

class _AlamatPageState extends State<AlamatPage> {
  GoogleMapController? _mapController;
  LatLng _selectedLocation = const LatLng(0.9167, 104.4500); // Default Tanjung Pinang
  Marker? _selectedMarker;
  String _selectedAddress = '';
  
  final TextEditingController _provinsiController = TextEditingController(text: 'KEPULAUAN RIAU');
  final TextEditingController _kotaController = TextEditingController();
  final TextEditingController _kecamatanController = TextEditingController();
  final TextEditingController _kelurahanController = TextEditingController();
  final TextEditingController _jalanController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse || 
          permission == LocationPermission.always) {
        Position position = await Geolocator.getCurrentPosition();
        setState(() {
          _selectedLocation = LatLng(position.latitude, position.longitude);
          _updateMarker(_selectedLocation);
        });
        _getAddressFromLatLng(_selectedLocation);
        
        if (_mapController != null) {
          _mapController!.animateCamera(
            CameraUpdate.newLatLngZoom(_selectedLocation, 16),
          );
        }
      }
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  Future<void> _getAddressFromLatLng(LatLng position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        
        setState(() {
          // Update field dengan format nama jalan biasa
          _kotaController.text = place.subAdministrativeArea ?? place.locality ?? '';
          _kecamatanController.text = place.subLocality ?? '';
          _kelurahanController.text = place.locality ?? '';
          
          // Format alamat jalan sederhana
          String street = place.street ?? '';
          String thoroughfare = place.thoroughfare ?? '';
          
          if (street.isNotEmpty) {
            _jalanController.text = street;
          } else if (thoroughfare.isNotEmpty) {
            _jalanController.text = thoroughfare;
          }
          
          // Alamat lengkap untuk ditampilkan
          _selectedAddress = '${place.street ?? place.thoroughfare ?? 'Jalan tidak diketahui'}, '
              '${place.subLocality ?? ''}, ${place.locality ?? ''}';
        });
      }
    } catch (e) {
      print('Error getting address: $e');
      setState(() {
        _selectedAddress = 'Gagal mendapatkan alamat';
      });
    }
  }

  void _updateMarker(LatLng position) {
    setState(() {
      _selectedMarker = Marker(
        markerId: const MarkerId('selected_location'),
        position: position,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: InfoWindow(
          title: 'Lokasi Dipilih',
          snippet: _selectedAddress.isEmpty ? 'Mengambil alamat...' : _selectedAddress,
        ),
      );
    });
  }

  void _onMapTapped(LatLng position) {
    setState(() {
      _selectedLocation = position;
      _updateMarker(position);
    });
    _getAddressFromLatLng(position);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4169E1),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Logo
                Center(
                  child: Image.asset(
                    'assets/logo.png',
                    height: 80,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.local_car_wash_rounded,
                        size: 80,
                        color: Colors.white,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),

                // Input Provinsi
                buildTextField('Provinsi', _provinsiController, enabled: false),

                const SizedBox(height: 10),
                // Input Kota
                buildTextField('Kabupaten/Kota', _kotaController),

                const SizedBox(height: 10),
                // Input Kecamatan
                buildTextField('Kecamatan', _kecamatanController),

                const SizedBox(height: 10),
                // Input Kelurahan
                buildTextField('Kelurahan', _kelurahanController),

                const SizedBox(height: 10),
                // Input Nama Jalan
                buildTextField('Nama Jalan', _jalanController),

                const SizedBox(height: 20),

                // Container Map
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Tentukan titik lokasi kamu",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      // Alamat yang dipilih
                      if (_selectedAddress.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.location_on, 
                                color: Colors.blue, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _selectedAddress,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                      
                      const SizedBox(height: 10),
                      
                      // Google Maps
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: SizedBox(
                          height: 300,
                          child: GoogleMap(
                            initialCameraPosition: CameraPosition(
                              target: _selectedLocation,
                              zoom: 16,
                            ),
                            onMapCreated: (controller) {
                              _mapController = controller;
                            },
                            onTap: _onMapTapped,
                            markers: _selectedMarker != null 
                              ? {_selectedMarker!} 
                              : {},
                            mapType: MapType.normal,
                            myLocationEnabled: true,
                            myLocationButtonEnabled: false,
                            zoomControlsEnabled: false,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 10),
                      
                      // Tombol aksi
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _getCurrentLocation,
                              icon: const Icon(Icons.my_location, size: 18),
                              label: const Text(
                                'Lokasi Saat Ini',
                                style: TextStyle(fontSize: 12),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue.shade100,
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(vertical: 10),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                setState(() {
                                  _selectedAddress = '';
                                  _kotaController.clear();
                                  _kecamatanController.clear();
                                  _kelurahanController.clear();
                                  _jalanController.clear();
                                  _selectedMarker = null;
                                });
                              },
                              icon: const Icon(Icons.refresh, size: 18),
                              label: const Text(
                                'Reset',
                                style: TextStyle(fontSize: 12),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue.shade100,
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(vertical: 10),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Tombol simpan alamat
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_selectedMarker != null && _selectedAddress.isNotEmpty) {
                        // Simpan alamat
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Alamat berhasil disimpan!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                        Navigator.pop(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Silakan pilih lokasi terlebih dahulu'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF4169E1),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Simpan Alamat',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  "From\nGOTO",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Saya menyetujui Ketentuan Layanan & Kebijakan Privasi MoClean",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller, 
      {bool enabled = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$label :",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          enabled: enabled,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _provinsiController.dispose();
    _kotaController.dispose();
    _kecamatanController.dispose();
    _kelurahanController.dispose();
    _jalanController.dispose();
    super.dispose();
  }
}