import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DataMitraPage extends StatefulWidget {
  const DataMitraPage({Key? key}) : super(key: key);

  @override
  State<DataMitraPage> createState() => _DataMitraPageState();
}

class _DataMitraPageState extends State<DataMitraPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _filterStatus = 'Semua';
  int _totalPending = 0;
  int _totalApproved = 0;
  int _totalRejected = 0;
  bool _isLoadingStats = false;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    setState(() {
      _isLoadingStats = true;
    });

    try {
      // Hitung mitra pending
      var pendingSnapshot = await _firestore.collection('mitra')
          .where('status', isEqualTo: 'pending')
          .count()
          .get();
      _totalPending = pendingSnapshot.count ?? 0;

      // Hitung mitra approved
      var approvedSnapshot = await _firestore.collection('mitra')
          .where('status', isEqualTo: 'approved')
          .count()
          .get();
      _totalApproved = approvedSnapshot.count ?? 0;

      // Hitung mitra rejected
      var rejectedSnapshot = await _firestore.collection('mitra')
          .where('status', isEqualTo: 'rejected')
          .count()
          .get();
      _totalRejected = rejectedSnapshot.count ?? 0;

    } catch (e) {
      print('Error loading statistics: $e');
      // Reset to 0 on error
      _totalPending = 0;
      _totalApproved = 0;
      _totalRejected = 0;
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingStats = false;
        });
      }
    }
  }

  // Helper functions
  Color getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'MENUNGGU REVIEW';
      case 'approved':
        return 'DISETUJUI';
      case 'rejected':
        return 'DITOLAK';
      default:
        return status.toUpperCase();
    }
  }

  String formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return '-';
    try {
      return DateFormat('dd MMM yyyy HH:mm').format(timestamp.toDate());
    } catch (e) {
      return '-';
    }
  }

  String formatDateOnly(Timestamp? timestamp) {
    if (timestamp == null) return '-';
    try {
      return DateFormat('dd MMMM yyyy').format(timestamp.toDate());
    } catch (e) {
      return '-';
    }
  }

  // Fungsi untuk approve mitra
  Future<void> _approveMitra(String mitraId, Map<String, dynamic> mitraData) async {
    try {
      // Update status di collection mitra
      await _firestore.collection('mitra').doc(mitraId).update({
        'status': 'approved',
        'approvedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Catat log admin action
      await _firestore.collection('admin_actions').add({
        'mitraId': mitraId,
        'mitraName': mitraData['namaLengkap'],
        'mitraEmail': mitraData['email'],
        'action': 'approve',
        'timestamp': FieldValue.serverTimestamp(),
        'adminId': _auth.currentUser?.uid ?? 'unknown',
        'adminEmail': _auth.currentUser?.email ?? 'unknown',
      });

      // Update user role
      await _firestore.collection('users').doc(mitraId).set({
        'userId': mitraId,
        'email': mitraData['email'],
        'role': 'mitra',
        'status': 'approved',
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Update statistics
      await _loadStatistics();

      // Beri notifikasi
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Mitra ${mitraData['namaLengkap']} berhasil disetujui'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Gagal menyetujui mitra: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  // Fungsi untuk reject mitra
  Future<void> _rejectMitra(String mitraId, Map<String, dynamic> mitraData, String reason) async {
    try {
      // Update status di collection mitra
      await _firestore.collection('mitra').doc(mitraId).update({
        'status': 'rejected',
        'rejectionReason': reason,
        'rejectedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Catat log admin action
      await _firestore.collection('admin_actions').add({
        'mitraId': mitraId,
        'mitraName': mitraData['namaLengkap'],
        'mitraEmail': mitraData['email'],
        'action': 'reject',
        'reason': reason,
        'timestamp': FieldValue.serverTimestamp(),
        'adminId': _auth.currentUser?.uid ?? 'unknown',
        'adminEmail': _auth.currentUser?.email ?? 'unknown',
      });

      // Update user role
      await _firestore.collection('users').doc(mitraId).set({
        'userId': mitraId,
        'email': mitraData['email'],
        'role': 'mitra_rejected',
        'status': 'rejected',
        'rejectionReason': reason,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Update statistics
      await _loadStatistics();

      // Beri notifikasi
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('⚠️ Mitra ${mitraData['namaLengkap']} ditolak'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Gagal menolak mitra: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  // Dialog untuk approve
  void _showApproveDialog(BuildContext context, String mitraId, Map<String, dynamic> mitraData) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 24),
            SizedBox(width: 8),
            Text(
              'Setujui Mitra',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Apakah Anda yakin ingin menyetujui mitra ini?'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nama: ${mitraData['namaLengkap']}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text('Email: ${mitraData['email']}'),
                  const SizedBox(height: 4),
                  Text('Usaha: ${mitraData['namaUsaha']}'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Setelah disetujui, mitra akan dapat login ke sistem.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('BATAL'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _approveMitra(mitraId, mitraData);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'SETUJUI',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // Dialog untuk reject
  void _showRejectDialog(BuildContext context, String mitraId, Map<String, dynamic> mitraData) {
    TextEditingController reasonController = TextEditingController();
    final _formKey = GlobalKey<FormState>();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Row(
              children: [
                Icon(Icons.cancel, color: Colors.red, size: 24),
                SizedBox(width: 8),
                Text(
                  'Tolak Mitra',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Apakah Anda yakin ingin menolak mitra ini?'),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Nama: ${mitraData['namaLengkap']}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text('Email: ${mitraData['email']}'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Alasan Penolakan*',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: reasonController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Masukkan alasan penolakan...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.all(12),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Harap isi alasan penolakan';
                        }
                        if (value.length < 10) {
                          return 'Alasan minimal 10 karakter';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        setState(() {});
                      },
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${reasonController.text.length}/200 karakter',
                      style: TextStyle(
                        fontSize: 12,
                        color: reasonController.text.length > 200 ? Colors.red : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('BATAL'),
              ),
              ElevatedButton(
                onPressed: reasonController.text.isEmpty || reasonController.text.length > 200
                    ? null
                    : () {
                        if (_formKey.currentState!.validate()) {
                          Navigator.pop(context);
                          _rejectMitra(mitraId, mitraData, reasonController.text);
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'TOLAK',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Widget untuk statistik
  Widget _buildStatCard(String title, int count, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 4),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _isLoadingStats 
                ? SizedBox(
                    height: 24,
                    child: Center(
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: color,
                        ),
                      ),
                    ),
                  )
                : Text(
                    count.toString(),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Data Mitra',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        actions: [
          // Filter dropdown
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _filterStatus,
                  icon: const Icon(Icons.filter_list, color: Colors.black54, size: 20),
                  items: ['Semua', 'pending', 'approved', 'rejected']
                      .map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value == 'Semua' ? 'Semua Status' : 
                        value == 'pending' ? 'Menunggu Review' :
                        value == 'approved' ? 'Disetujui' : 'Ditolak',
                        style: const TextStyle(fontSize: 14),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _filterStatus = newValue!;
                    });
                  },
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Statistics Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildStatCard('Menunggu', _totalPending, Colors.orange, Icons.schedule),
                const SizedBox(width: 8),
                _buildStatCard('Disetujui', _totalApproved, Colors.green, Icons.check_circle),
                const SizedBox(width: 8),
                _buildStatCard('Ditolak', _totalRejected, Colors.red, Icons.cancel),
              ],
            ),
          ),

          // Divider
          Container(height: 1, color: Colors.grey.shade200),

          // List of Mitra
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _filterStatus == 'Semua'
                  ? _firestore.collection('mitra')
                      .orderBy('createdAt', descending: true)
                      .snapshots()
                  : _firestore.collection('mitra')
                      .where('status', isEqualTo: _filterStatus)
                      .orderBy('createdAt', descending: true)
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          'Error: ${snapshot.error}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _filterStatus == 'pending' 
                            ? Icons.hourglass_empty 
                            : Icons.people_outline,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _filterStatus == 'pending' 
                            ? 'Tidak ada mitra menunggu review'
                            : 'Tidak ada data mitra',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _filterStatus == 'pending'
                            ? 'Semua pendaftaran mitra telah direview'
                            : 'Coba ubah filter status',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var mitraData = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                    var mitraId = snapshot.data!.docs[index].id;
                    
                    return _buildMitraCard(
                      mitraData: mitraData,
                      mitraId: mitraId,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMitraCard({
    required Map<String, dynamic> mitraData,
    required String mitraId,
  }) {
    String status = mitraData['status'] ?? 'pending';
    Color statusColor = getStatusColor(status);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: statusColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            _showMitraDetailBottomSheet(
              context,
              mitraData: mitraData,
              mitraId: mitraId,
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row with status and actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: statusColor.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            status == 'pending' ? Icons.schedule :
                            status == 'approved' ? Icons.check_circle :
                            Icons.cancel,
                            size: 14,
                            color: statusColor,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            getStatusText(status),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Action buttons for pending status
                    if (status == 'pending')
                      Row(
                        children: [
                          // Approve button
                          InkWell(
                            onTap: () => _showApproveDialog(context, mitraId, mitraData),
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.green.shade200),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.check, size: 14, color: Colors.green),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Terima',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Reject button
                          InkWell(
                            onTap: () => _showRejectDialog(context, mitraId, mitraData),
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.red.shade200),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.close, size: 14, color: Colors.red),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Tolak',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),

                const SizedBox(height: 16),

                // Mitra Info
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile icon
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 20,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    // Mitra details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            mitraData['namaLengkap'] ?? '-',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            mitraData['namaUsaha'] ?? '-',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            mitraData['email'] ?? '-',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            mitraData['telepon'] ?? '-',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Additional Info
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Jenis Usaha',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            mitraData['jenisUsaha'] ?? '-',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tanggal Daftar',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            formatTimestamp(mitraData['createdAt']),
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Documents Info
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: (mitraData['ktpFileName'] ?? '').contains('Belum')
                            ? Colors.red.shade50
                            : Colors.green.shade50,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'KTP: ${(mitraData['ktpFileName'] ?? 'Belum upload').length > 15 
                            ? '${(mitraData['ktpFileName'] ?? 'Belum upload').substring(0, 15)}...' 
                            : mitraData['ktpFileName'] ?? 'Belum upload'}',
                        style: TextStyle(
                          fontSize: 10,
                          color: (mitraData['ktpFileName'] ?? '').contains('Belum')
                              ? Colors.red.shade700
                              : Colors.green.shade700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: (mitraData['siupFileName'] ?? '').contains('Belum')
                            ? Colors.red.shade50
                            : Colors.green.shade50,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'SIUP: ${(mitraData['siupFileName'] ?? 'Belum upload').length > 15 
                            ? '${(mitraData['siupFileName'] ?? 'Belum upload').substring(0, 15)}...' 
                            : mitraData['siupFileName'] ?? 'Belum upload'}',
                        style: TextStyle(
                          fontSize: 10,
                          color: (mitraData['siupFileName'] ?? '').contains('Belum')
                              ? Colors.red.shade700
                              : Colors.green.shade700,
                        ),
                      ),
                    ),
                  ],
                ),

                // View Details Button
                if (status != 'pending')
                  const SizedBox(height: 12),
                if (status != 'pending')
                  Align(
                    alignment: Alignment.centerRight,
                    child: InkWell(
                      onTap: () {
                        _showMitraDetailBottomSheet(
                          context,
                          mitraData: mitraData,
                          mitraId: mitraId,
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Lihat Detail',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.blue.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(Icons.chevron_right, size: 16, color: Colors.blue.shade700),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Detail Bottom Sheet
  void _showMitraDetailBottomSheet(
    BuildContext context, {
    required Map<String, dynamic> mitraData,
    required String mitraId,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 8, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Detail Mitra',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: getStatusColor(mitraData['status'] ?? 'pending').withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        getStatusText(mitraData['status'] ?? 'pending'),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: getStatusColor(mitraData['status'] ?? 'pending'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile Section
                      Center(
                        child: Column(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(40),
                              ),
                              child: const Icon(
                                Icons.person,
                                size: 40,
                                color: Colors.blue,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              mitraData['namaLengkap'] ?? '-',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              mitraData['namaUsaha'] ?? '-',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Info Grid
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 3,
                        children: [
                          _buildDetailInfoCard('Email', mitraData['email'] ?? '-', Icons.email),
                          _buildDetailInfoCard('Telepon', mitraData['telepon'] ?? '-', Icons.phone),
                          _buildDetailInfoCard('Jenis Usaha', mitraData['jenisUsaha'] ?? '-', Icons.business),
                          _buildDetailInfoCard('Kota', mitraData['kota'] ?? '-', Icons.location_city),
                          _buildDetailInfoCard('Kode Pos', mitraData['kodePos'] ?? '-', Icons.location_on),
                          _buildDetailInfoCard('Tanggal Daftar', formatDateOnly(mitraData['createdAt']), Icons.calendar_today),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Alamat Section
                      const Text(
                        'Alamat Usaha',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          mitraData['alamatUsaha'] ?? '-',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Dokumen Section
                      const Text(
                        'Dokumen',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDocumentCard(
                              'KTP',
                              mitraData['ktpFileName'] ?? 'Belum upload',
                              (mitraData['ktpFileName'] ?? '').contains('Belum') 
                                ? Colors.red 
                                : Colors.green,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildDocumentCard(
                              'SIUP',
                              mitraData['siupFileName'] ?? 'Belum upload',
                              (mitraData['siupFileName'] ?? '').contains('Belum') 
                                ? Colors.red 
                                : Colors.green,
                            ),
                          ),
                        ],
                      ),

                      // Rejection Reason if rejected
                      if (mitraData['status'] == 'rejected' && mitraData['rejectionReason'] != null) ...[
                        const SizedBox(height: 24),
                        const Text(
                          'Alasan Penolakan',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Text(
                            mitraData['rejectionReason']!,
                            style: const TextStyle(fontSize: 14, color: Colors.red),
                          ),
                        ),
                      ],

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailInfoCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentCard(String title, String fileName, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            fileName,
            style: TextStyle(
              fontSize: 11,
              color: color,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}