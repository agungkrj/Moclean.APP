// fiturr/cuci_komplit_page.dart (FIXED)
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:moclienapp/fiturr/pesan_layanan.dart';
import 'package:moclienapp/models/service_model.dart';
import 'package:moclienapp/services/service_firebase.dart';
import 'package:moclienapp/services/subscription_service.dart';

class CuciKomplitPage extends StatefulWidget {
  const CuciKomplitPage({super.key});

  @override
  State<CuciKomplitPage> createState() => _CuciKomplitPageState();
}

class _CuciKomplitPageState extends State<CuciKomplitPage> {
  final ServiceFirebase _serviceFirebase = ServiceFirebase();
  final SubscriptionService _subscriptionService = SubscriptionService();
  Map<String, dynamic>? _subscriptionBenefits;
  bool _isLoadingBenefits = true;

  @override
  void initState() {
    super.initState();
    _loadSubscriptionBenefits();
  }

  Future<void> _loadSubscriptionBenefits() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('user_id');
      User? currentUser = FirebaseAuth.instance.currentUser;
      final effectiveUserId = currentUser?.uid ?? userId;

      if (effectiveUserId != null) {
        var benefits = await _subscriptionService.getSubscriptionBenefits(effectiveUserId);
        setState(() {
          _subscriptionBenefits = benefits;
          _isLoadingBenefits = false;
        });
      } else {
        setState(() => _isLoadingBenefits = false);
      }
    } catch (e) {
      setState(() => _isLoadingBenefits = false);
    }
  }

  int _calculateDiscountedPrice(int originalPrice) {
    if (_subscriptionBenefits != null && _subscriptionBenefits!['hasSubscription'] == true) {
      int discountPercent = _subscriptionBenefits!['discountPercent'] ?? 0;
      return _subscriptionService.calculateDiscountedPrice(originalPrice, discountPercent);
    }
    return originalPrice;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<ServiceModel?>(
        future: _serviceFirebase.getService('cuci_komplit'),
        builder: (context, snapshot) {
          // Loading
          if (snapshot.connectionState == ConnectionState.waiting || _isLoadingBenefits) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF5669FF),
              ),
            );
          }

          // Error
          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text('Gagal memuat data layanan'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => setState(() {}),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4169E1),
                    ),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          final service = snapshot.data!;
          final originalPrice = int.parse(service.price);
          final finalPrice = _calculateDiscountedPrice(originalPrice);
          final hasDiscount = originalPrice != finalPrice;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // GAMBAR FULL WIDTH
                SizedBox(
                  width: double.infinity,
                  height: 190,
                  child: Image.asset(
                    service.image,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.image_not_supported,
                          size: 60,
                          color: Colors.grey,
                        ),
                      );
                    },
                  ),
                ),

                // BAGIAN PUTIH (LABEL)
                Center(
                  child: Transform.translate(
                    offset: const Offset(0, -20),
                    child: Container(
                      width: 367,
                      height: 58,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        service.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ),

                // BENEFIT LANGGANAN BADGE
                if (_subscriptionBenefits != null && _subscriptionBenefits!['hasSubscription'] == true)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 18),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4169E1), Color(0xFF5B9BF3)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.card_giftcard, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Benefit Langganan Aktif",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "Diskon ${_subscriptionBenefits!['discountPercent']}% • ${_subscriptionBenefits!['remainingFreeWash']} Cuci Gratis Tersisa",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 20),

                // DETAIL LAYANAN
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Layanan - ${service.name}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "Harga",
                        style: TextStyle(fontSize: 13, color: Colors.black54),
                      ),
                      const SizedBox(height: 2),
                      
                      // Tampilkan harga asli dan harga diskon
                      if (hasDiscount) ...[
                        Text(
                          _formatCurrency(originalPrice.toString()),
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey.shade500,
                            decoration: TextDecoration.lineThrough,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              _formatCurrency(finalPrice.toString()),
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4169E1),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                "Hemat ${_formatCurrency((originalPrice - finalPrice).toString())}",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ] else
                        Text(
                          _formatCurrency(originalPrice.toString()),
                          style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      
                      const SizedBox(height: 12),
                      Text(
                        service.description.isNotEmpty
                            ? service.description
                            : "Membersihkan seluruh bagian mobil, baik eksterior maupun interior, menggunakan bahan dan peralatan profesional.",
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black87,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // FITUR LAYANAN
                if (service.features.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Column(
                      children: service.features
                          .map((feature) => buildFeature(feature))
                          .toList(),
                    ),
                  )
                else
                  // Default features jika belum ada di Firebase
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Column(
                      children: [
                        buildFeature("Hand Wash"),
                        buildFeature("Engine Cleaning"),
                        buildFeature("Tire Polish"),
                        buildFeature("Vacuum Interior"),
                      ],
                    ),
                  ),

                const SizedBox(height: 28),

                // TOMBOL PESAN SEKARANG
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PesanLayananPage(
                              service: ServiceModel(
                                id: service.id,
                                name: service.name,
                                price: finalPrice.toString(),
                                image: service.image,
                              ),
                              subscriptionBenefits: _subscriptionBenefits,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4169E1),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        "Pesan Sekarang",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 25),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget buildFeature(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 22),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(String price) {
    final number = int.tryParse(price) ?? 0;
    return 'Rp. ${number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    )}';
  }
}