import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Login Admin
  Future<Map<String, dynamic>> loginAdmin(String email, String password) async {
    try {
      // Login dengan Firebase Auth
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Cek apakah user adalah admin
      DocumentSnapshot adminDoc = await _firestore
          .collection('admins')
          .doc(userCredential.user!.uid)
          .get();

      if (!adminDoc.exists) {
        // Jika bukan admin, logout
        await _auth.signOut();
        return {
          'success': false,
          'message': 'Anda tidak memiliki akses admin!',
        };
      }

      // Ambil data admin
      Map<String, dynamic> adminData = adminDoc.data() as Map<String, dynamic>;

      return {
        'success': true,
        'message': 'Login berhasil!',
        'data': {
          'uid': userCredential.user!.uid,
          'email': userCredential.user!.email,
          'name': adminData['name'] ?? 'Admin',
          'role': adminData['role'] ?? 'admin',
        }
      };
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'Email tidak terdaftar';
          break;
        case 'wrong-password':
          message = 'Password salah';
          break;
        case 'invalid-email':
          message = 'Format email tidak valid';
          break;
        case 'user-disabled':
          message = 'Akun telah dinonaktifkan';
          break;
        case 'too-many-requests':
          message = 'Terlalu banyak percobaan login. Coba lagi nanti';
          break;
        default:
          message = 'Terjadi kesalahan: ${e.message}';
      }
      return {
        'success': false,
        'message': message,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Check if user is logged in
  bool isLoggedIn() {
    return _auth.currentUser != null;
  }

  // Create Admin (untuk testing/setup awal)
  Future<Map<String, dynamic>> createAdmin({
    required String email,
    required String password,
    required String name,
    String role = 'admin',
  }) async {
    try {
      // Buat user di Firebase Auth
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Simpan data admin di Firestore
      await _firestore.collection('admins').doc(userCredential.user!.uid).set({
        'name': name,
        'email': email,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
        'isActive': true,
      });

      return {
        'success': true,
        'message': 'Admin berhasil dibuat!',
        'uid': userCredential.user!.uid,
      };
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'email-already-in-use':
          message = 'Email sudah terdaftar';
          break;
        case 'weak-password':
          message = 'Password terlalu lemah';
          break;
        default:
          message = 'Terjadi kesalahan: ${e.message}';
      }
      return {
        'success': false,
        'message': message,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  // Reset Password
  Future<Map<String, dynamic>> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return {
        'success': true,
        'message': 'Link reset password telah dikirim ke email Anda',
      };
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'Email tidak terdaftar';
          break;
        case 'invalid-email':
          message = 'Format email tidak valid';
          break;
        default:
          message = 'Terjadi kesalahan: ${e.message}';
      }
      return {
        'success': false,
        'message': message,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }
}