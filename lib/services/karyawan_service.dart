import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:moclienapp/models/karyawan_model.dart';

class KaryawanService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'karyawan';

  // Tambah Karyawan Baru
  Future<bool> tambahKaryawan(Karyawan karyawan) async {
    try {
      await _firestore.collection(_collection).add(karyawan.toMap());
      return true;
    } catch (e) {
      print('Error menambah karyawan: $e');
      return false;
    }
  }

  // Get Semua Karyawan
  Stream<List<Karyawan>> getAllKaryawan() {
    return _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return Karyawan.fromMap(doc.data(), doc.id);
          }).toList();
        });
  }

  // Get Karyawan by ID
  Future<Karyawan?> getKaryawanById(String id) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(_collection)
          .doc(id)
          .get();
      if (doc.exists) {
        return Karyawan.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      print('Error get karyawan: $e');
      return null;
    }
  }

  // Update Karyawan
  Future<bool> updateKaryawan(String id, Karyawan karyawan) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(id)
          .update(karyawan.copyWith(updatedAt: DateTime.now()).toMap());
      return true;
    } catch (e) {
      print('Error update karyawan: $e');
      return false;
    }
  }

  // Delete Karyawan
  Future<bool> deleteKaryawan(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
      return true;
    } catch (e) {
      print('Error delete karyawan: $e');
      return false;
    }
  }

  // Get Karyawan by Shift
  Stream<List<Karyawan>> getKaryawanByShift(String shift) {
    return _firestore
        .collection(_collection)
        .where('shift', isEqualTo: shift)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return Karyawan.fromMap(doc.data(), doc.id);
          }).toList();
        });
  }

  // Get Karyawan by Posisi
  Stream<List<Karyawan>> getKaryawanByPosisi(String posisi) {
    return _firestore
        .collection(_collection)
        .where('posisi', isEqualTo: posisi)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return Karyawan.fromMap(doc.data(), doc.id);
          }).toList();
        });
  }

  // Cek NIK sudah ada atau belum
  Future<bool> isNikExists(String nik) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_collection)
          .where('nik', isEqualTo: nik)
          .limit(1)
          .get();
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error cek NIK: $e');
      return false;
    }
  }
}
