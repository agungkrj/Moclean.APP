// services/service_firebase.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/service_model.dart';

class ServiceFirebase {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'services';

  // Get all services
  Stream<List<ServiceModel>> getServices() {
    return _firestore
        .collection(_collection)
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ServiceModel.fromMap(doc.data());
      }).toList();
    });
  }

  // Get single service
  Future<ServiceModel?> getService(String id) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(_collection)
          .doc(id)
          .get();
      
      if (doc.exists) {
        return ServiceModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Error getting service: $e');
      return null;
    }
  }

  // Update service price
  Future<bool> updateServicePrice(String id, String newPrice) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(id)
          .update({'price': newPrice});
      return true;
    } catch (e) {
      print('Error updating price: $e');
      return false;
    }
  }

  // Add new service (untuk admin)
  Future<bool> addService(ServiceModel service) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(service.id)
          .set(service.toMap());
      return true;
    } catch (e) {
      print('Error adding service: $e');
      return false;
    }
  }

  // Update entire service
  Future<bool> updateService(ServiceModel service) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(service.id)
          .update(service.toMap());
      return true;
    } catch (e) {
      print('Error updating service: $e');
      return false;
    }
  }

  // Delete service
  Future<bool> deleteService(String id) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(id)
          .delete();
      return true;
    } catch (e) {
      print('Error deleting service: $e');
      return false;
    }
  }

  // Initialize default services (jalankan sekali saja)
  Future<void> initializeDefaultServices() async {
    // Hapus data lama dulu
    try {
      final snapshot = await _firestore.collection(_collection).get();
      for (var doc in snapshot.docs) {
        await doc.reference.delete();
        print("🗑️ Deleted old data: ${doc.id}");
      }
    } catch (e) {
      print("⚠️ Error deleting old data: $e");
    }
    
    // Buat data baru dengan nama file yang BENAR
    final services = [
      ServiceModel(
        id: 'cuci_interior',
        name: 'Cuci Interior',
        price: '135000',
        image: 'assets/interior.png', // ✅ Sesuai screenshot
        description: 'Membersihkan seluruh bagian dalam mobil (interior) menggunakan vacuum cleaner dan cairan pembersih khusus interior. Mengangkat debu, kotoran, dan noda pada karpet, jok, dashboard, dan plafon mobil agar tetap bersih dan segar.',
        features: ['Vacuum Interior', 'Dashboard Cleaning', 'Carpet Wash'],
      ),
      ServiceModel(
        id: 'cuci_eksterior',
        name: 'Cuci Eksterior',
        price: '80000',
        image: 'assets/eksterio.png', // ✅ Sesuai screenshot (eksterio bukan eksterior)
        description: 'Membersihkan seluruh bagian luar mobil (eksterior) menggunakan sampo Meguiar\'s Gold Class dan peralatan standar profesional. Menghilangkan bercak atau noda berkerak pada permukaan cat serta bagian mesin.',
        features: ['Hand Wash', 'Engine Cleaning', 'Tire Polish'],
      ),
      ServiceModel(
        id: 'cuci_komplit',
        name: 'Cuci Komplit',
        price: '195000',
        image: 'assets/cucikomplit.png', // ✅ Sesuai screenshot (cucikomplit bukan komplit)
        description: 'Membersihkan seluruh bagian mobil, baik eksterior maupun interior, menggunakan bahan dan peralatan profesional. Hasilnya mobil bersih menyeluruh luar dalam, wangi, dan tampak seperti baru kembali.',
        features: ['Hand Wash', 'Engine Cleaning', 'Tire Polish', 'Vacuum Interior'],
      ),
    ];

    print("\n📝 Membuat data baru...");
    for (var service in services) {
      await addService(service);
      print("✅ Created: ${service.name} → ${service.image}");
    }
    print("🎉 Inisialisasi selesai!\n");
  }
}