class Karyawan {
  final String? id;
  final String namaLengkap;
  final String nik;
  final String telepon;
  final String posisi;
  final String shift;
  final String alamat;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Karyawan({
    this.id,
    required this.namaLengkap,
    required this.nik,
    required this.telepon,
    required this.posisi,
    required this.shift,
    required this.alamat,
    required this.createdAt,
    this.updatedAt,
  });

  // Convert Karyawan to Map untuk Firebase
  Map<String, dynamic> toMap() {
    return {
      'namaLengkap': namaLengkap,
      'nik': nik,
      'telepon': telepon,
      'posisi': posisi,
      'shift': shift,
      'alamat': alamat,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // Create Karyawan from Firebase Map
  factory Karyawan.fromMap(Map<String, dynamic> map, String id) {
    return Karyawan(
      id: id,
      namaLengkap: map['namaLengkap'] ?? '',
      nik: map['nik'] ?? '',
      telepon: map['telepon'] ?? '',
      posisi: map['posisi'] ?? '',
      shift: map['shift'] ?? '',
      alamat: map['alamat'] ?? '',
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
    );
  }

  // Get initials dari nama untuk avatar
  String getInitials() {
    List<String> names = namaLengkap.trim().split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    } else if (names.isNotEmpty) {
      return names[0].substring(0, names[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return '??';
  }

  // Copy with method untuk update
  Karyawan copyWith({
    String? id,
    String? namaLengkap,
    String? nik,
    String? telepon,
    String? posisi,
    String? shift,
    String? alamat,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Karyawan(
      id: id ?? this.id,
      namaLengkap: namaLengkap ?? this.namaLengkap,
      nik: nik ?? this.nik,
      telepon: telepon ?? this.telepon,
      posisi: posisi ?? this.posisi,
      shift: shift ?? this.shift,
      alamat: alamat ?? this.alamat,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}