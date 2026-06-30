// services/subscription_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SubscriptionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Cek apakah user sudah punya langganan aktif
  Future<Map<String, dynamic>?> getActiveSubscription(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('subscriptions')
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: 'active')
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;

      var doc = snapshot.docs.first;
      var data = doc.data() as Map<String, dynamic>;
      data['subscriptionId'] = doc.id;
      return data;
    } catch (e) {
      print('Error getting active subscription: $e');
      return null;
    }
  }

  // Buat langganan baru
  Future<bool> createSubscription({
    required String userId,
    required String packageType, // '1x' atau '2x'
    required String packageTitle,
    required int price,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      // Cek dulu apakah sudah ada langganan aktif
      var activeSubscription = await getActiveSubscription(userId);
      if (activeSubscription != null) {
        print('User already has active subscription');
        return false;
      }

      // Tentukan benefit berdasarkan paket
      int discountPercent = 15;
      int freeWashCount = packageType == '2x' ? 1 : 0;
      int usedFreeWash = 0;

      await _firestore.collection('subscriptions').add({
        'userId': userId,
        'packageType': packageType,
        'packageTitle': packageTitle,
        'price': price,
        'discountPercent': discountPercent,
        'freeWashCount': freeWashCount,
        'usedFreeWash': usedFreeWash,
        'startDate': startDate,
        'endDate': endDate,
        'status': 'active',
        'createdAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      print('Error creating subscription: $e');
      return false;
    }
  }

  // Hitung harga dengan diskon
  int calculateDiscountedPrice(int originalPrice, int discountPercent) {
    double discount = originalPrice * (discountPercent / 100);
    return (originalPrice - discount).round();
  }

  // Cek apakah bisa pakai cuci gratis
  Future<bool> canUseFreeWash(String userId) async {
    try {
      var subscription = await getActiveSubscription(userId);
      if (subscription == null) return false;

      int freeWashCount = subscription['freeWashCount'] ?? 0;
      int usedFreeWash = subscription['usedFreeWash'] ?? 0;

      return usedFreeWash < freeWashCount;
    } catch (e) {
      return false;
    }
  }

  // Gunakan cuci gratis
  Future<bool> useFreeWash(String userId) async {
    try {
      var subscription = await getActiveSubscription(userId);
      if (subscription == null) return false;

      String subscriptionId = subscription['subscriptionId'];
      int usedFreeWash = subscription['usedFreeWash'] ?? 0;

      await _firestore.collection('subscriptions').doc(subscriptionId).update({
        'usedFreeWash': usedFreeWash + 1,
      });

      return true;
    } catch (e) {
      print('Error using free wash: $e');
      return false;
    }
  }

  // Batalkan langganan
  Future<bool> cancelSubscription(String userId) async {
    try {
      var subscription = await getActiveSubscription(userId);
      if (subscription == null) return false;

      String subscriptionId = subscription['subscriptionId'];

      await _firestore.collection('subscriptions').doc(subscriptionId).update({
        'status': 'cancelled',
        'cancelledAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      print('Error cancelling subscription: $e');
      return false;
    }
  }

  // Update status langganan yang sudah expired
  Future<void> checkAndUpdateExpiredSubscriptions() async {
    try {
      DateTime now = DateTime.now();
      QuerySnapshot snapshot = await _firestore
          .collection('subscriptions')
          .where('status', isEqualTo: 'active')
          .where('endDate', isLessThan: now)
          .get();

      for (var doc in snapshot.docs) {
        await doc.reference.update({
          'status': 'expired',
          'expiredAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Error updating expired subscriptions: $e');
    }
  }

  // Dapatkan informasi benefit untuk ditampilkan
  Future<Map<String, dynamic>> getSubscriptionBenefits(String userId) async {
    var subscription = await getActiveSubscription(userId);
    
    if (subscription == null) {
      return {
        'hasSubscription': false,
        'discountPercent': 0,
        'freeWashCount': 0,
        'usedFreeWash': 0,
        'remainingFreeWash': 0,
      };
    }

    int freeWashCount = subscription['freeWashCount'] ?? 0;
    int usedFreeWash = subscription['usedFreeWash'] ?? 0;

    return {
      'hasSubscription': true,
      'packageType': subscription['packageType'],
      'packageTitle': subscription['packageTitle'],
      'discountPercent': subscription['discountPercent'] ?? 0,
      'freeWashCount': freeWashCount,
      'usedFreeWash': usedFreeWash,
      'remainingFreeWash': freeWashCount - usedFreeWash,
      'startDate': (subscription['startDate'] as Timestamp).toDate(),
      'endDate': (subscription['endDate'] as Timestamp).toDate(),
      'status': subscription['status'],
    };
  }
}