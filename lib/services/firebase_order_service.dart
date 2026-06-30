import 'package:cloud_firestore/cloud_firestore.dart';

/// Firebase Order Service - Complete Version with Debug
/// 
/// Status Flow:
/// menunggu → diterima → sedang_dicuci → selesai (isCompleted: false) → selesai (isCompleted: true) → RIWAYAT

class FirebaseOrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ========================================
  // DEBUG METHODS
  // ========================================
  
  /// Debug: Check all orders in Firestore
  Future<void> debugCheckOrders(String userId) async {
    print("🔍 DEBUG: Checking all orders in Firestore...");
    
    try {
      final allOrders = await _firestore.collection('orders').get();
      
      print("📦 Total orders in database: ${allOrders.docs.length}");
      
      for (var doc in allOrders.docs) {
        final data = doc.data();
        print("─────────────────────────────────");
        print("📋 Order ID: ${doc.id}");
        print("   Status: ${data['orderStatus']}");
        print("   isCompleted: ${data['isCompleted'] ?? false}");
        print("   rated: ${data['rated'] ?? false}");
        print("   UserId: ${data['userId']}");
        print("   Customer: ${data['customerName']}");
      }
      print("─────────────────────────────────");
      
      final userOrders = await _firestore
          .collection('orders')
          .where('userId', isEqualTo: userId)
          .get();
      
      print("👤 Orders for userId '$userId': ${userOrders.docs.length}");
      
      if (userOrders.docs.isEmpty) {
        print("⚠️ PROBLEM: No orders found for this userId!");
      }
      
    } catch (e) {
      print("❌ Error debugging orders: $e");
    }
  }

  // ========================================
  // STREAMS FOR USER/CUSTOMER - DENGAN isCompleted FILTER
  // ========================================
  
  /// ⭐ Stream untuk pesanan AKTIF (belum dikonfirmasi selesai oleh user)
  /// Termasuk: menunggu, diterima, sedang_dicuci, selesai (tapi belum dikonfirmasi)
  Stream<List<Map<String, dynamic>>> getActiveOrdersForUser(String userId) {
    print("🔍 Getting active orders for userId: $userId");
    
    return _firestore
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .where('isCompleted', isEqualTo: false) // ⭐ KUNCI: Hanya yang belum completed
        .snapshots()
        .map((snapshot) {
      print("📦 Found ${snapshot.docs.length} active orders (isCompleted=false)");
      
      final activeOrders = snapshot.docs.map((doc) {
        final data = doc.data();
        print("   📋 ${doc.id}: status=${data['orderStatus']}, isCompleted=${data['isCompleted']}, rated=${data['rated']}");
        
        return {
          'orderId': doc.id,
          ...data,
        };
      }).toList();
      
      // Sort by orderDate
      activeOrders.sort((a, b) {
        final aTime = a['orderDate'];
        final bTime = b['orderDate'];
        
        if (aTime == null && bTime == null) return 0;
        if (aTime == null) return 1;
        if (bTime == null) return -1;
        
        if (aTime is Timestamp && bTime is Timestamp) {
          return bTime.compareTo(aTime);
        }
        return 0;
      });
          
      print("✅ Returning ${activeOrders.length} active orders");
      return activeOrders;
    });
  }

  /// ⭐ Stream untuk RIWAYAT (sudah dikonfirmasi selesai oleh user)
  Stream<List<Map<String, dynamic>>> getCompletedOrdersForUser(String userId) {
    print("🔍 Getting completed orders (history) for userId: $userId");
    
    return _firestore
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .where('isCompleted', isEqualTo: true) // ⭐ KUNCI: Hanya yang sudah completed
        .snapshots()
        .map((snapshot) {
      print("📦 Found ${snapshot.docs.length} completed orders (isCompleted=true)");
      
      final completedOrders = snapshot.docs.map((doc) {
        final data = doc.data();
        print("   📋 ${doc.id}: status=${data['orderStatus']}, completedAt=${data['completedAt']}");
        
        return {
          'orderId': doc.id,
          ...data,
        };
      }).toList();
      
      // Sort by completedAt
      completedOrders.sort((a, b) {
        final aTime = a['completedAt'] ?? a['orderDate'];
        final bTime = b['completedAt'] ?? b['orderDate'];
        
        if (aTime == null && bTime == null) return 0;
        if (aTime == null) return 1;
        if (bTime == null) return -1;
        
        if (aTime is Timestamp && bTime is Timestamp) {
          return bTime.compareTo(aTime);
        }
        return 0;
      });
          
      print("✅ Returning ${completedOrders.length} completed orders");
      return completedOrders;
    });
  }

  /// Stream untuk pesanan yang sedang diproses (diterima & sedang_dicuci)
  Stream<List<Map<String, dynamic>>> getProcessingOrdersForUser(String userId) {
    print("🔍 Getting processing orders for userId: $userId");
    
    return _firestore
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .where('isCompleted', isEqualTo: false)
        .snapshots()
        .map((snapshot) {
      final processingOrders = snapshot.docs
          .where((doc) {
            String status = doc.data()['orderStatus'] ?? '';
            return status == 'diterima' || status == 'sedang_dicuci';
          })
          .map((doc) {
            return {
              'orderId': doc.id,
              ...doc.data(),
            };
          })
          .toList();
          
      print("✅ Filtered to ${processingOrders.length} processing orders");
      return processingOrders;
    });
  }

  /// Stream untuk pesanan yang menunggu
  Stream<List<Map<String, dynamic>>> getWaitingOrdersForUser(String userId) {
    return _firestore
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .where('orderStatus', isEqualTo: 'menunggu')
        .where('isCompleted', isEqualTo: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return {
          'orderId': doc.id,
          ...doc.data(),
        };
      }).toList();
    });
  }

  // ========================================
  // STREAMS FOR TEKNISI/MITRA
  // ========================================

  /// Stream untuk mendapatkan semua pending orders (untuk teknisi)
  Stream<List<Map<String, dynamic>>> getAllPendingOrders() {
    print("🔍 Getting all pending orders for teknisi");
    
    return _firestore
        .collection('orders')
        .where('isCompleted', isEqualTo: false)
        .snapshots()
        .map((snapshot) {
      print("📦 Found ${snapshot.docs.length} total orders");
      
      final pendingOrders = snapshot.docs
          .where((doc) {
            String status = doc.data()['orderStatus'] ?? '';
            return status == 'menunggu' || 
                   status == 'diterima' || 
                   status == 'sedang_dicuci';
          })
          .map((doc) {
            return {
              'orderId': doc.id,
              ...doc.data(),
            };
          })
          .toList();
      
      print("✅ Filtered to ${pendingOrders.length} pending orders");
      return pendingOrders;
    });
  }

  /// Stream untuk mendapatkan orders berdasarkan mitra
  Stream<List<Map<String, dynamic>>> getOrdersForTeknisi(String mitraName) {
    return _firestore
        .collection('orders')
        .where('mitraName', isEqualTo: mitraName)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return {
          'orderId': doc.id,
          ...doc.data(),
        };
      }).toList();
    });
  }

  // ========================================
  // ORDER ACTIONS - DENGAN isCompleted LOGIC
  // ========================================

  /// Terima pesanan
  Future<bool> acceptOrder(
    String orderId, 
    String teknisiId, {
    String? teknisiName,
    String? mitraName,
    double? teknisiRating,
  }) async {
    try {
      print("✅ Accepting order: $orderId by teknisi: $teknisiId");
      
      Map<String, dynamic> updateData = {
        'orderStatus': 'diterima',
        'teknisiId': teknisiId,
        'acceptedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isCompleted': false, // ⭐ Set false saat order diterima
        'rated': false,
      };

      if (teknisiName == null || mitraName == null) {
        final mitraDoc = await _firestore.collection('mitra').doc(teknisiId).get();
        
        if (mitraDoc.exists) {
          final mitraData = mitraDoc.data()!;
          updateData['teknisiName'] = mitraData['nama_toko'] ?? 'Teknisi';
          updateData['mitraName'] = mitraData['nama_toko'] ?? 'Mitra';
          updateData['teknisiRating'] = 4.8;
          updateData['teknisiPhone'] = mitraData['no_whatsapp'] ?? '';
        } else {
          final userDoc = await _firestore.collection('users').doc(teknisiId).get();
          if (userDoc.exists) {
            final userData = userDoc.data()!;
            updateData['teknisiName'] = userData['name'] ?? 'Teknisi';
            updateData['mitraName'] = userData['mitraName'] ?? 'Mitra';
            updateData['teknisiRating'] = userData['rating'] ?? 5.0;
          } else {
            updateData['teknisiName'] = 'Teknisi';
            updateData['mitraName'] = 'Mitra';
            updateData['teknisiRating'] = 5.0;
          }
        }
      } else {
        updateData['teknisiName'] = teknisiName;
        updateData['mitraName'] = mitraName;
        updateData['teknisiRating'] = teknisiRating ?? 5.0;
      }

      await _firestore.collection('orders').doc(orderId).update(updateData);
      print("✅ Order accepted successfully");
      return true;
    } catch (e) {
      print("❌ Error accepting order: $e");
      return false;
    }
  }

  /// Mulai mengerjakan pesanan
  Future<bool> startWork(String orderId) async {
    try {
      print("🚀 Starting work on order: $orderId");
      
      await _firestore.collection('orders').doc(orderId).update({
        'orderStatus': 'sedang_dicuci',
        'startedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      print("✅ Work started successfully");
      return true;
    } catch (e) {
      print("❌ Error starting work: $e");
      return false;
    }
  }

  /// ⭐ Selesaikan pesanan oleh TEKNISI (masih tetap di Aktifitas)
  /// User masih perlu memberi rating dan konfirmasi
  Future<bool> completeOrderByTeknisi(String orderId) async {
    try {
      print("🎉 Teknisi completing order: $orderId");
      
      await _firestore.collection('orders').doc(orderId).update({
        'orderStatus': 'selesai',
        'completedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isCompleted': false, // ⭐ MASIH FALSE, menunggu konfirmasi user
        'rated': false, // Belum di-rating
      });
      
      print("✅ Order completed by teknisi, waiting for user confirmation");
      return true;
    } catch (e) {
      print("❌ Error completing order: $e");
      return false;
    }
  }

  /// ⭐ RATE ORDER - User memberi rating (pesanan tetap di Aktifitas)
  Future<bool> rateOrder(String orderId, double rating, String comment) async {
    try {
      print("⭐ User rating order: $orderId with $rating stars");
      
      await _firestore.collection('orders').doc(orderId).update({
        'rating': rating,
        'ratingComment': comment,
        'rated': true, // ⭐ Sudah di-rating
        'ratedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        // ⭐ isCompleted TETAP FALSE, menunggu konfirmasi selesai
      });

      // Update rating teknisi jika ada
      final orderDoc = await _firestore.collection('orders').doc(orderId).get();
      if (orderDoc.exists) {
        final teknisiId = orderDoc.data()?['teknisiId'];
        if (teknisiId != null && teknisiId.isNotEmpty) {
          await _updateTeknisiRating(teknisiId);
        }
      }

      print("✅ Order rated successfully, waiting for completion confirmation");
      return true;
    } catch (e) {
      print('❌ Error rating order: $e');
      return false;
    }
  }

  /// ⭐ COMPLETE ORDER - User konfirmasi pesanan selesai (BARU pindah ke Riwayat)
  Future<bool> completeOrder(String orderId) async {
    try {
      print("✅ User confirming order completion: $orderId");
      
      await _firestore.collection('orders').doc(orderId).update({
        'isCompleted': true, // ⭐ SEKARANG BARU TRUE
        'userConfirmedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      print("✅ Order moved to history");
      return true;
    } catch (e) {
      print("❌ Error confirming order completion: $e");
      return false;
    }
  }

  /// Cancel order
  Future<bool> cancelOrder(String orderId, String reason) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'orderStatus': 'dibatalkan',
        'cancelReason': reason,
        'cancelledAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isCompleted': true, // Dibatalkan langsung masuk history
      });
      return true;
    } catch (e) {
      print('Error cancelling order: $e');
      return false;
    }
  }

  // ========================================
  // QUERIES
  // ========================================

  /// Get order by ID
  Future<Map<String, dynamic>?> getOrderById(String orderId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('orders').doc(orderId).get();
      if (doc.exists) {
        return {
          'orderId': doc.id,
          ...doc.data() as Map<String, dynamic>,
        };
      }
      return null;
    } catch (e) {
      print('Error getting order: $e');
      return null;
    }
  }

  /// Stream single order
  Stream<Map<String, dynamic>?> getOrderByIdStream(String orderId) {
    return _firestore
        .collection('orders')
        .doc(orderId)
        .snapshots()
        .map((doc) {
      if (doc.exists) {
        return {
          'orderId': doc.id,
          ...doc.data() as Map<String, dynamic>,
        };
      }
      return null;
    });
  }

  /// Get all orders for user
  Stream<List<Map<String, dynamic>>> getAllOrdersForUser(String userId) {
    return _firestore
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return {
          'orderId': doc.id,
          ...doc.data(),
        };
      }).toList();
    });
  }

  // ========================================
  // PAYMENT
  // ========================================

  /// Simpan order setelah pembayaran
  Future<bool> saveOrderAfterPayment({
    required dynamic order,
    required String paymentMethod,
    required int totalAmount,
    required int biayaLayanan,
    required int biayaUkuran,
    required int biayaAdmin,
  }) async {
    try {
      Map<String, dynamic> orderData;
      
      if (order is Map<String, dynamic>) {
        orderData = order;
      } else {
        orderData = order.toMap();
      }
      
      orderData['paymentMethod'] = paymentMethod;
      orderData['totalAmount'] = totalAmount;
      orderData['biayaLayanan'] = biayaLayanan;
      orderData['biayaUkuran'] = biayaUkuran;
      orderData['biayaAdmin'] = biayaAdmin;
      orderData['orderStatus'] = 'menunggu';
      orderData['orderDate'] = FieldValue.serverTimestamp();
      orderData['createdAt'] = FieldValue.serverTimestamp();
      orderData['isCompleted'] = false; // ⭐ Set false untuk order baru
      orderData['rated'] = false;
      
      if (paymentMethod == 'QRIS') {
        orderData['isPaid'] = true;
        orderData['paidAt'] = FieldValue.serverTimestamp();
      } else {
        orderData['isPaid'] = false;
      }
      
      String orderId = orderData['orderId'] ?? '';
      
      if (orderId.isEmpty) {
        print('Error: orderId is empty');
        return false;
      }
      
      await _firestore.collection('orders').doc(orderId).set(orderData);
      
      print('Order saved successfully: $orderId');
      return true;
    } catch (e) {
      print('Error saving order after payment: $e');
      return false;
    }
  }

  // ========================================
  // RATING & REVIEW
  // ========================================

  /// Helper method untuk update average rating teknisi
  Future<void> _updateTeknisiRating(String teknisiId) async {
    try {
      final ordersSnapshot = await _firestore
          .collection('orders')
          .where('teknisiId', isEqualTo: teknisiId)
          .where('rating', isGreaterThan: 0)
          .get();

      if (ordersSnapshot.docs.isEmpty) return;

      double totalRating = 0;
      int count = 0;

      for (var doc in ordersSnapshot.docs) {
        final rating = doc.data()['rating'];
        if (rating != null && rating > 0) {
          totalRating += rating;
          count++;
        }
      }

      if (count > 0) {
        double averageRating = totalRating / count;
        
        // Update di collection 'mitra' dulu
        final mitraDoc = await _firestore.collection('mitra').doc(teknisiId).get();
        if (mitraDoc.exists) {
          await _firestore.collection('mitra').doc(teknisiId).update({
            'rating': double.parse(averageRating.toStringAsFixed(1)),
            'totalRatings': count,
            'updatedAt': FieldValue.serverTimestamp(),
          });
          print("✅ Updated mitra rating: ${averageRating.toStringAsFixed(1)}");
        } else {
          // Fallback ke collection 'users'
          final userDoc = await _firestore.collection('users').doc(teknisiId).get();
          if (userDoc.exists) {
            await _firestore.collection('users').doc(teknisiId).update({
              'rating': double.parse(averageRating.toStringAsFixed(1)),
              'totalRatings': count,
              'updatedAt': FieldValue.serverTimestamp(),
            });
            print("✅ Updated user rating: ${averageRating.toStringAsFixed(1)}");
          }
        }
      }
    } catch (e) {
      print('❌ Error updating teknisi rating: $e');
    }
  }

  /// Get order reviews
  Stream<List<Map<String, dynamic>>> getOrderReviews(String orderId) {
    return _firestore
        .collection('reviews')
        .where('orderId', isEqualTo: orderId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return {
          'reviewId': doc.id,
          ...doc.data(),
        };
      }).toList();
    });
  }

  /// Get all reviews for a teknisi
  Stream<List<Map<String, dynamic>>> getTeknisiReviews(String teknisiId) {
    return _firestore
        .collection('orders')
        .where('teknisiId', isEqualTo: teknisiId)
        .where('rating', isGreaterThan: 0)
        .orderBy('rating', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'orderId': doc.id,
          'rating': data['rating'],
          'ratingComment': data['ratingComment'],
          'customerName': data['customerName'],
          'serviceName': data['serviceName'],
          'ratedAt': data['ratedAt'],
        };
      }).toList();
    });
  }

  // ========================================
  // STATISTICS
  // ========================================

  /// Get order statistics for user
  Future<Map<String, int>> getOrderStatsForUser(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('orders')
          .where('userId', isEqualTo: userId)
          .get();

      int total = snapshot.docs.length;
      int waiting = 0;
      int processing = 0;
      int completed = 0;
      int cancelled = 0;

      for (var doc in snapshot.docs) {
        String status = doc.data()['orderStatus'] ?? '';
        bool isCompleted = doc.data()['isCompleted'] ?? false;
        
        if (isCompleted) {
          completed++;
        } else {
          switch (status) {
            case 'menunggu':
              waiting++;
              break;
            case 'diterima':
            case 'sedang_dicuci':
              processing++;
              break;
            case 'selesai':
              // Selesai tapi belum dikonfirmasi, masih aktif
              processing++;
              break;
          }
        }
      }

      return {
        'total': total,
        'waiting': waiting,
        'processing': processing,
        'completed': completed,
        'cancelled': cancelled,
      };
    } catch (e) {
      print('Error getting order stats: $e');
      return {
        'total': 0,
        'waiting': 0,
        'processing': 0,
        'completed': 0,
        'cancelled': 0,
      };
    }
  }

  /// Get order statistics for teknisi
  Future<Map<String, int>> getOrderStatsForTeknisi(String teknisiId) async {
    try {
      final snapshot = await _firestore
          .collection('orders')
          .where('teknisiId', isEqualTo: teknisiId)
          .get();

      int total = snapshot.docs.length;
      int waiting = 0;
      int processing = 0;
      int completed = 0;

      for (var doc in snapshot.docs) {
        String status = doc.data()['orderStatus'] ?? '';
        bool isCompleted = doc.data()['isCompleted'] ?? false;
        
        if (isCompleted) {
          completed++;
        } else {
          switch (status) {
            case 'menunggu':
              waiting++;
              break;
            case 'diterima':
            case 'sedang_dicuci':
              processing++;
              break;
            case 'selesai':
              processing++;
              break;
          }
        }
      }

      return {
        'total': total,
        'waiting': waiting,
        'processing': processing,
        'completed': completed,
      };
    } catch (e) {
      print('Error getting teknisi order stats: $e');
      return {
        'total': 0,
        'waiting': 0,
        'processing': 0,
        'completed': 0,
      };
    }
  }

  // ========================================
  // UTILITIES
  // ========================================

  /// Check if user has any orders
  Future<bool> hasOrders(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('orders')
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking if user has orders: $e');
      return false;
    }
  }

  /// Update payment status
  Future<bool> updatePaymentStatus(String orderId, bool isPaid) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'isPaid': isPaid,
        'paidAt': isPaid ? FieldValue.serverTimestamp() : null,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error updating payment status: $e');
      return false;
    }
  }

  /// Update order status (generic)
  Future<bool> updateOrderStatus(String orderId, String newStatus) async {
    try {
      print("🔄 Updating order $orderId to status: $newStatus");
      
      await _firestore.collection('orders').doc(orderId).update({
        'orderStatus': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      print("✅ Status updated successfully");
      return true;
    } catch (e) {
      print("❌ Error updating order status: $e");
      return false;
    }
  }

  /// Delete order (admin only)
  Future<bool> deleteOrder(String orderId) async {
    try {
      await _firestore.collection('orders').doc(orderId).delete();
      print('✅ Order deleted: $orderId');
      return true;
    } catch (e) {
      print('❌ Error deleting order: $e');
      return false;
    }
  }

  /// Search orders by keyword
  Stream<List<Map<String, dynamic>>> searchOrders(String keyword) {
    return _firestore
        .collection('orders')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .where((doc) {
            final data = doc.data();
            final orderId = doc.id.toLowerCase();
            final serviceName = (data['serviceName'] ?? '').toString().toLowerCase();
            final customerName = (data['customerName'] ?? '').toString().toLowerCase();
            final address = (data['address'] ?? '').toString().toLowerCase();
            
            final searchTerm = keyword.toLowerCase();
            
            return orderId.contains(searchTerm) ||
                   serviceName.contains(searchTerm) ||
                   customerName.contains(searchTerm) ||
                   address.contains(searchTerm);
          })
          .map((doc) {
            return {
              'orderId': doc.id,
              ...doc.data(),
            };
          })
          .toList();
    });
  }

  /// Get recent orders (limit by count)
  Stream<List<Map<String, dynamic>>> getRecentOrders(int limit) {
    return _firestore
        .collection('orders')
        .orderBy('orderDate', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return {
          'orderId': doc.id,
          ...doc.data(),
        };
      }).toList();
    });
  }

  /// Get all orders (no filter)
  Stream<List<Map<String, dynamic>>> getAllOrders() {
    return _firestore
        .collection('orders')
        .orderBy('orderDate', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return {
          'orderId': doc.id,
          ...doc.data(),
        };
      }).toList();
    });
  }

  /// Get orders by status
  Stream<List<Map<String, dynamic>>> getOrdersByStatus(String status) {
    return _firestore
        .collection('orders')
        .where('orderStatus', isEqualTo: status)
        .orderBy('orderDate', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return {
          'orderId': doc.id,
          ...doc.data(),
        };
      }).toList();
    });
  }

  /// Get orders by teknisi ID
  Stream<List<Map<String, dynamic>>> getOrdersByTeknisiId(String teknisiId) {
    return _firestore
        .collection('orders')
        .where('teknisiId', isEqualTo: teknisiId)
        .orderBy('orderDate', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return {
          'orderId': doc.id,
          ...doc.data(),
        };
      }).toList();
    });
  }

  /// Get processing orders for teknisi
  Stream<List<Map<String, dynamic>>> getProcessingOrdersForTeknisi(String teknisiId) {
    return _firestore
        .collection('orders')
        .where('teknisiId', isEqualTo: teknisiId)
        .where('isCompleted', isEqualTo: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .where((doc) {
            String status = doc.data()['orderStatus'] ?? '';
            return status == 'diterima' || status == 'sedang_dicuci';
          })
          .map((doc) {
            return {
              'orderId': doc.id,
              ...doc.data(),
            };
          })
          .toList();
    });
  }

  /// Get teknisi info stream
  Stream<Map<String, dynamic>?> getTeknisiInfo(String teknisiId) async* {
    // Cek di collection 'mitra' dulu
    final mitraStream = _firestore
        .collection('mitra')
        .doc(teknisiId)
        .snapshots();
    
    await for (var doc in mitraStream) {
      if (doc.exists) {
        yield doc.data();
        return;
      }
    }
    
    // Fallback ke collection 'users'
    final userStream = _firestore
        .collection('users')
        .doc(teknisiId)
        .snapshots();
    
    await for (var doc in userStream) {
      if (doc.exists) {
        yield doc.data();
        return;
      } else {
        yield null;
      }
    }
  }

  /// Get all orders for teknisi (including completed)
  Stream<List<Map<String, dynamic>>> getAllOrdersForTeknisi(String mitraName) {
    return _firestore
        .collection('orders')
        .where('mitraName', isEqualTo: mitraName)
        .orderBy('orderDate', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return {
          'orderId': doc.id,
          ...doc.data(),
        };
      }).toList();
    });
  }

  /// Get current user orders (for debugging)
  Future<List<Map<String, dynamic>>> getCurrentUserOrders(String userId) async {
    print("🔍 Fetching orders for userId: $userId");
    
    try {
      final snapshot = await _firestore
          .collection('orders')
          .where('userId', isEqualTo: userId)
          .get();
      
      print("📦 Found ${snapshot.docs.length} orders");
      
      final orders = snapshot.docs.map((doc) {
        final data = doc.data();
        print("   📋 ${doc.id}:");
        print("      Status: ${data['orderStatus']}");
        print("      isCompleted: ${data['isCompleted']}");
        print("      rated: ${data['rated']}");
        print("      Customer: ${data['customerName']}");
        print("      Service: ${data['serviceName']}");
        
        return {
          'orderId': doc.id,
          ...data,
        };
      }).toList();
      
      return orders;
    } catch (e) {
      print("❌ Error: $e");
      return [];
    }
  }
}