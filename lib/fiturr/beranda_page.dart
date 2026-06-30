import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:moclienapp/fiturr/detail_page.dart';
import 'package:moclienapp/fiturr/detail_cuci_interior.dart';
import 'package:moclienapp/fiturr/cuci_komplit_page.dart';
import 'package:moclienapp/fiturr/langganan_page.dart';
import 'navbar.dart';

class BerandaPage extends StatefulWidget {
  const BerandaPage({super.key});

  @override
  State<BerandaPage> createState() => _BerandaPageState();
}

class _BerandaPageState extends State<BerandaPage> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  String _userName = '';
  String _userInitial = '';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  List<Map<String, dynamic>> _recommendedMitra = [];
  bool _isLoadingMitra = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);
    _fadeAnimation = CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);
    _animationController.forward();
    _loadUserDataSync();
    _refreshUserDataInBackground();
    _loadRecommendedMitra();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadRecommendedMitra() async {
    setState(() => _isLoadingMitra = true);
    try {
      QuerySnapshot mitraSnapshot = await FirebaseFirestore.instance
          .collection('mitra')
          .where('status', isEqualTo: 'approved')
          .limit(10)
          .get();
      
      List<Map<String, dynamic>> mitraList = [];
      
      for (var doc in mitraSnapshot.docs) {
        Map<String, dynamic> mitraData = doc.data() as Map<String, dynamic>;
        
        // Hitung rating dari collection orders (rating yang diberikan user)
        Map<String, dynamic> ratingData = await _calculateMitraRating(mitraData['nama_toko'] ?? '');
        
        mitraList.add({
          'id': doc.id,
          'namaUsaha': mitraData['nama_toko'] ?? 'Mitra',
          'namaLengkap': mitraData['nama_lengkap'] ?? '-',
          'kota': mitraData['kota'] ?? '-',
          'alamatUsaha': mitraData['alamat_usaha'] ?? '-',
          'telepon': mitraData['no_whatsapp'] ?? '-',
          'rating': ratingData['avgRating'],
          'totalReviews': ratingData['totalReviews'],
          'distance': _calculateDistance(),
        });
      }
      
      // Sort berdasarkan rating tertinggi
      mitraList.sort((a, b) {
        int ratingCompare = b['rating'].compareTo(a['rating']);
        if (ratingCompare != 0) return ratingCompare;
        // Jika rating sama, sort berdasarkan jumlah review
        return b['totalReviews'].compareTo(a['totalReviews']);
      });
      
      // Ambil top 5 mitra
      setState(() {
        _recommendedMitra = mitraList.take(5).toList();
        _isLoadingMitra = false;
      });
    } catch (e) {
      print('Error loading mitra: $e');
      setState(() => _isLoadingMitra = false);
    }
  }

  // Method untuk menghitung rata-rata rating dari collection orders
  Future<Map<String, dynamic>> _calculateMitraRating(String mitraName) async {
    try {
      QuerySnapshot orderSnapshot = await FirebaseFirestore.instance
          .collection('orders')
          .where('mitraName', isEqualTo: mitraName)
          .where('rated', isEqualTo: true)
          .get();
      
      if (orderSnapshot.docs.isEmpty) {
        return {
          'avgRating': 5.0,
          'totalReviews': 0,
        };
      }
      
      double totalRating = 0;
      int count = 0;
      
      for (var doc in orderSnapshot.docs) {
        Map<String, dynamic> orderData = doc.data() as Map<String, dynamic>;
        double rating = (orderData['rating'] ?? 0.0).toDouble();
        if (rating > 0) {
          totalRating += rating;
          count++;
        }
      }
      
      double avgRating = count > 0 ? totalRating / count : 5.0;
      
      return {
        'avgRating': double.parse(avgRating.toStringAsFixed(1)),
        'totalReviews': count,
      };
    } catch (e) {
      print('Error calculating rating: $e');
      return {
        'avgRating': 5.0,
        'totalReviews': 0,
      };
    }
  }

  String _calculateDistance() => "${(1 + (9 * (DateTime.now().millisecond / 1000))).toInt()} Km";

  void _loadUserDataSync() {
    SharedPreferences.getInstance().then((prefs) {
      final nama = prefs.getString('user_nama') ?? 'Pengguna';
      setState(() {
        _userName = nama;
        _userInitial = _getInitials(nama);
      });
    });
  }

  Future<void> _refreshUserDataInBackground() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      User? currentUser = FirebaseAuth.instance.currentUser;
      final effectiveUserId = currentUser?.uid ?? prefs.getString('user_id');
      if (effectiveUserId == null) return;
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(effectiveUserId).get();
      if (userDoc.exists) {
        final nama = (userDoc.data() as Map<String, dynamic>)['nama'] ?? currentUser?.displayName ?? 'Pengguna';
        await prefs.setString('user_nama', nama);
        if (mounted && nama != _userName) setState(() {
          _userName = nama;
          _userInitial = _getInitials(nama);
        });
      }
    } catch (e) {}
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'P';
    List<String> nameParts = name.trim().split(' ');
    if (nameParts.length >= 2) return (nameParts[0][0] + nameParts[1][0]).toUpperCase();
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
    switch (index) {
      case 1: Navigator.pushReplacementNamed(context, '/Aktifitas'); break;
      case 2: Navigator.pushReplacementNamed(context, '/riwayat'); break;
      case 3: Navigator.pushReplacementNamed(context, '/profil'); break;
    }
  }

  void _showMitraDetailDialog(Map<String, dynamic> mitra) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.75),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [Color(0xFF4169E1), Color(0xFF5B9BF3)]),
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 60, 
                      height: 60, 
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle), 
                      child: const Icon(Icons.store, color: Color(0xFF4169E1), size: 30)
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            mitra['namaUsaha'], 
                            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.star, color: Colors.amber, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                "${mitra['rating'].toStringAsFixed(1)}", 
                                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "(${mitra['totalReviews']} ulasan)", 
                                style: const TextStyle(color: Colors.white70, fontSize: 12)
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white), 
                      onPressed: () => Navigator.pop(context)
                    ),
                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildDetailRow(Icons.person, 'Pemilik', mitra['namaLengkap']),
                      const SizedBox(height: 12),
                      _buildDetailRow(Icons.location_on, 'Alamat', mitra['alamatUsaha']),
                      const SizedBox(height: 12),
                      _buildDetailRow(Icons.location_city, 'Kota', mitra['kota']),
                      const SizedBox(height: 12),
                      _buildDetailRow(Icons.phone, 'Telepon', mitra['telepon']),
                      const SizedBox(height: 12),
                      _buildDetailRow(Icons.navigation, 'Jarak', mitra['distance']),
                      const SizedBox(height: 12),
                      _buildDetailRow(
                        Icons.star_rate, 
                        'Rating', 
                        '${mitra['rating'].toStringAsFixed(1)} dari ${mitra['totalReviews']} ulasan'
                      ),
                      const SizedBox(height: 20),
                      // Tampilkan beberapa review terbaru dari orders
                      _buildRecentReviews(mitra['namaUsaha']),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Mitra ${mitra['namaUsaha']} dipilih'), 
                                backgroundColor: Colors.green
                              )
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4169E1), 
                            padding: const EdgeInsets.symmetric(vertical: 14), 
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                          ),
                          child: const Text(
                            'Pilih Mitra Ini', 
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentReviews(String mitraName) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('orders')
          .where('mitraName', isEqualTo: mitraName)
          .where('rated', isEqualTo: true)
          .orderBy('ratedAt', descending: true)
          .limit(3)
          .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.rate_review_outlined, color: Colors.grey.shade400, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Belum ada ulasan',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.rate_review, color: Color(0xFF4169E1), size: 18),
                const SizedBox(width: 6),
                const Text(
                  'Ulasan Terbaru',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...snapshot.data!.docs.map((doc) {
              Map<String, dynamic> order = doc.data() as Map<String, dynamic>;
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF4169E1).withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF4169E1).withOpacity(0.1),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            order['customerName'] ?? 'Anonymous',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              order['rating'].toString(),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      order['serviceName'] ?? '-',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    if (order['ratingComment'] != null && 
                        order['ratingComment'].toString().isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        order['ratingComment'],
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              );
            }).toList(),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8), 
          decoration: BoxDecoration(
            color: const Color(0xFF4169E1).withOpacity(0.1), 
            borderRadius: BorderRadius.circular(8)
          ), 
          child: Icon(icon, size: 20, color: const Color(0xFF4169E1))
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label, 
                style: TextStyle(
                  fontSize: 12, 
                  color: Colors.grey.shade600, 
                  fontWeight: FontWeight.w500
                )
              ),
              const SizedBox(height: 2),
              Text(
                value, 
                style: const TextStyle(
                  fontSize: 14, 
                  fontWeight: FontWeight.w600, 
                  color: Colors.black87
                )
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: RefreshIndicator(
            onRefresh: _loadRecommendedMitra,
            color: const Color(0xFF4169E1),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildModernHeader(),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Layanan Kami", 
                          style: TextStyle(
                            fontSize: 22, 
                            fontWeight: FontWeight.bold, 
                            color: Color(0xFF1E293B), 
                            letterSpacing: -0.5
                          )
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), 
                          decoration: BoxDecoration(
                            color: const Color(0xFF4169E1).withOpacity(0.1), 
                            borderRadius: BorderRadius.circular(20)
                          ), 
                          child: const Text(
                            "Populer", 
                            style: TextStyle(
                              fontSize: 12, 
                              fontWeight: FontWeight.w600, 
                              color: Color(0xFF4169E1)
                            )
                          )
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 190,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.only(left: 24, right: 24),
                      physics: const BouncingScrollPhysics(),
                      children: [
                        _buildModernLayananCard('assets/eksterio.png', "Cuci Eksterior", const Color(0xFF4169E1)),
                        const SizedBox(width: 16),
                        _buildModernLayananCard('assets/interior.png', "Cuci Interior", const Color(0xFF5B9BF3)),
                        const SizedBox(width: 16),
                        _buildModernLayananCard('assets/cucikomplit.png', "Cuci Komplit", const Color(0xFF1E3A8A)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Rekomendasi Untuk Kamu", 
                          style: TextStyle(
                            fontSize: 22, 
                            fontWeight: FontWeight.bold, 
                            color: Color(0xFF1E293B), 
                            letterSpacing: -0.5
                          )
                        ),
                        const Icon(Icons.recommend_rounded, color: Color(0xFF4169E1), size: 24),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _isLoadingMitra 
                    ? _buildLoadingMitra() 
                    : _recommendedMitra.isEmpty 
                      ? _buildEmptyMitra() 
                      : Column(
                          children: _recommendedMitra.map((m) => 
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12), 
                              child: _buildModernRekomendasiCard(m)
                            )
                          ).toList()
                        ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Navbar(selectedIndex: _selectedIndex, onItemTapped: _onItemTapped),
    );
  }

  Widget _buildLoadingMitra() => Container(
    margin: const EdgeInsets.symmetric(horizontal: 24), 
    padding: const EdgeInsets.all(20), 
    decoration: BoxDecoration(
      color: Colors.white, 
      borderRadius: BorderRadius.circular(24)
    ), 
    child: const Center(
      child: CircularProgressIndicator(color: Color(0xFF4169E1))
    )
  );

  Widget _buildEmptyMitra() => Container(
    margin: const EdgeInsets.symmetric(horizontal: 24), 
    padding: const EdgeInsets.all(20), 
    decoration: BoxDecoration(
      color: Colors.white, 
      borderRadius: BorderRadius.circular(24)
    ), 
    child: Column(
      children: [
        Icon(Icons.store_outlined, size: 48, color: Colors.grey.shade400), 
        const SizedBox(height: 12), 
        Text(
          'Belum ada mitra tersedia', 
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600)
        )
      ]
    )
  );

  Widget _buildModernHeader() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4169E1), Color(0xFF5B9BF3), Color(0xFF1E3A8A)], 
          begin: Alignment.topLeft, 
          end: Alignment.bottomRight
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(40), 
          bottomRight: Radius.circular(40)
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4169E1).withOpacity(0.3), 
            blurRadius: 20, 
            offset: const Offset(0, 10)
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8), 
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2), 
                            borderRadius: BorderRadius.circular(12)
                          ), 
                          child: const Icon(
                            Icons.auto_awesome_rounded, 
                            color: Colors.white, 
                            size: 20
                          )
                        ), 
                        const SizedBox(width: 12), 
                        const Text(
                          "MoClean", 
                          style: TextStyle(
                            color: Colors.white, 
                            fontSize: 30, 
                            fontWeight: FontWeight.bold, 
                            letterSpacing: -1
                          )
                        )
                      ]
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Halo, $_userName 👋", 
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.95), 
                        fontSize: 16, 
                        fontWeight: FontWeight.w500
                      )
                    ),
                  ],
                ),
                Container(
                  width: 56, 
                  height: 56, 
                  decoration: BoxDecoration(
                    color: Colors.white, 
                    shape: BoxShape.circle, 
                    border: Border.all(color: Colors.white, width: 3)
                  ), 
                  child: Center(
                    child: Text(
                      _userInitial, 
                      style: const TextStyle(
                        color: Color(0xFF4169E1), 
                        fontWeight: FontWeight.bold, 
                        fontSize: 20
                      )
                    )
                  )
                ),
              ],
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () => Navigator.push(
                context, 
                MaterialPageRoute(builder: (c) => const LanggananPage())
              ),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.2), 
                      Colors.white.withOpacity(0.1)
                    ]
                  ), 
                  borderRadius: BorderRadius.circular(24), 
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3), 
                    width: 1.5
                  )
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/orangkiri.png', 
                      width: 70, 
                      height: 85, 
                      fit: BoxFit.contain
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), 
                            decoration: BoxDecoration(
                              color: Colors.amber.shade400, 
                              borderRadius: BorderRadius.circular(20)
                            ), 
                            child: Row(
                              mainAxisSize: MainAxisSize.min, 
                              children: const [
                                Icon(Icons.local_offer_rounded, size: 14, color: Colors.white), 
                                SizedBox(width: 6), 
                                Text(
                                  "Promo Spesial", 
                                  style: TextStyle(
                                    color: Colors.white, 
                                    fontWeight: FontWeight.bold, 
                                    fontSize: 12
                                  )
                                )
                              ]
                            )
                          ), 
                          const SizedBox(height: 10), 
                          const Text(
                            "Cuci 3x Dapat 1x Gratis! 🎉", 
                            textAlign: TextAlign.center, 
                            style: TextStyle(
                              color: Colors.white, 
                              fontSize: 16, 
                              fontWeight: FontWeight.bold
                            )
                          )
                        ]
                      )
                    ),
                    const SizedBox(width: 8),
                    Image.asset(
                      'assets/orangkanan.png', 
                      width: 70, 
                      height: 85, 
                      fit: BoxFit.contain
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernLayananCard(String imagePath, String title, Color color) {
    return GestureDetector(
      onTap: () {
        Widget nextPage = title == "Cuci Eksterior" 
          ? const DetailPage() 
          : title == "Cuci Interior" 
            ? const DetailCuciInteriorPage() 
            : const CuciKomplitPage();
        Navigator.push(
          context, 
          PageRouteBuilder(
            pageBuilder: (c, a, s) => nextPage, 
            transitionsBuilder: (c, a, s, ch) => SlideTransition(
              position: a.drive(
                Tween(begin: const Offset(1, 0), end: Offset.zero)
                  .chain(CurveTween(curve: Curves.easeInOutCubic))
              ), 
              child: ch
            )
          )
        );
      },
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          color: Colors.white, 
          borderRadius: BorderRadius.circular(24), 
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.15), 
              blurRadius: 15, 
              offset: const Offset(0, 5)
            )
          ]
        ),
        child: Column(
          children: [
            Container(
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withOpacity(0.8)]
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24), 
                  topRight: Radius.circular(24)
                ),
              ),
              child: Center(
                child: Image.asset(
                  imagePath,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.local_car_wash_rounded, 
                      size: 40, 
                      color: Colors.white
                    );
                  },
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title, 
                      textAlign: TextAlign.center, 
                      maxLines: 2, 
                      style: const TextStyle(
                        fontSize: 14, 
                        fontWeight: FontWeight.bold, 
                        color: Color(0xFF1E293B)
                      )
                    ),
                    Container(
                      width: double.infinity, 
                      padding: const EdgeInsets.symmetric(vertical: 8), 
                      decoration: BoxDecoration(
                        color: color, 
                        borderRadius: BorderRadius.circular(12)
                      ), 
                      child: const Text(
                        "Pilih", 
                        textAlign: TextAlign.center, 
                        style: TextStyle(
                          color: Colors.white, 
                          fontSize: 12, 
                          fontWeight: FontWeight.w600
                        )
                      )
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernRekomendasiCard(Map<String, dynamic> m) {
    return GestureDetector(
      onTap: () => _showMitraDetailDialog(m),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white, 
          borderRadius: BorderRadius.circular(24), 
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4169E1).withOpacity(0.1), 
              blurRadius: 20, 
              offset: const Offset(0, 8)
            )
          ]
        ),
        child: Row(
          children: [
            Container(
              width: 70, 
              height: 70, 
              decoration: BoxDecoration(
                shape: BoxShape.circle, 
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF4169E1).withOpacity(0.2), 
                    const Color(0xFF5B9BF3).withOpacity(0.1)
                  ]
                )
              ), 
              child: ClipOval(
                child: Image.asset(
                  'assets/car.png', 
                  fit: BoxFit.cover, 
                  errorBuilder: (c, e, s) => const Icon(
                    Icons.store, 
                    size: 35, 
                    color: Color(0xFF4169E1)
                  )
                )
              )
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, 
                children: [
                  Text(
                    m['namaUsaha'], 
                    style: const TextStyle(
                      fontSize: 16, 
                      fontWeight: FontWeight.bold, 
                      color: Color(0xFF1E293B)
                    ), 
                    maxLines: 1, 
                    overflow: TextOverflow.ellipsis
                  ), 
                  const SizedBox(height: 6), 
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3), 
                        decoration: BoxDecoration(
                          color: const Color(0xFF4169E1).withOpacity(0.1), 
                          borderRadius: BorderRadius.circular(6)
                        ), 
                        child: Row(
                          children: [
                            const Icon(
                              Icons.location_on_rounded, 
                              size: 12, 
                              color: Color(0xFF4169E1)
                            ), 
                            const SizedBox(width: 3), 
                            Text(
                              m['distance'], 
                              style: const TextStyle(
                                fontSize: 11, 
                                color: Color(0xFF4169E1), 
                                fontWeight: FontWeight.w600
                              )
                            )
                          ]
                        )
                      ), 
                      const SizedBox(width: 6), 
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3), 
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.2), 
                          borderRadius: BorderRadius.circular(6)
                        ), 
                        child: Row(
                          children: [
                            const Icon(
                              Icons.star_rounded, 
                              color: Colors.amber, 
                              size: 12
                            ), 
                            const SizedBox(width: 2), 
                            Text(
                              m['rating'].toStringAsFixed(1), 
                              style: const TextStyle(
                                fontSize: 11, 
                                color: Colors.black87, 
                                fontWeight: FontWeight.w600
                              )
                            )
                          ]
                        )
                      )
                    ]
                  ), 
                  const SizedBox(height: 6), 
                  Text(
                    "${m['kota']} • ${m['totalReviews']} ulasan", 
                    style: TextStyle(
                      fontSize: 11, 
                      color: Colors.grey.shade600, 
                      fontWeight: FontWeight.w500
                    )
                  )
                ]
              )
            ),
            Container(
              padding: const EdgeInsets.all(10), 
              decoration: BoxDecoration(
                color: const Color(0xFF4169E1), 
                borderRadius: BorderRadius.circular(12)
              ), 
              child: const Icon(
                Icons.arrow_forward_rounded, 
                color: Colors.white, 
                size: 18
              )
            ),
          ],
        ),
      ),
    );
  }
}