class OrderModel {
  final String orderId;
  final String userId;
  final String serviceName;
  final String servicePrice;
  final String serviceImage;
  final String customerName;
  final String phone;
  final String email;
  final String address;
  final String mitra;
  final DateTime orderDate;
  final String ukuranMobil;
  final String brand;
  final String type;
  final String nopolisi;
  final DateTime createdAt;
  final String status;

  OrderModel({
    required this.orderId,
    required this.userId,
    required this.serviceName,
    required this.servicePrice,
    required this.serviceImage,
    required this.customerName,
    required this.phone,
    required this.email,
    required this.address,
    required this.mitra,
    required this.orderDate,
    required this.ukuranMobil,
    required this.brand,
    required this.type,
    required this.nopolisi,
    required this.createdAt,
    required this.status,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'userId': userId,
      'serviceName': serviceName,
      'servicePrice': servicePrice,
      'serviceImage': serviceImage,
      'customerName': customerName,
      'phone': phone,
      'email': email,
      'address': address,
      'mitraName': mitra,
      'orderDate': orderDate.toIso8601String(),
      'ukuranMobil': ukuranMobil,
      'brand': brand,
      'type': type,
      'nopolisi': nopolisi,
      'createdAt': createdAt.toIso8601String(),
      'orderStatus': status,
    };
  }

  // Create from Map (Firestore)
  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      orderId: map['orderId'] ?? '',
      userId: map['userId'] ?? '',
      serviceName: map['serviceName'] ?? '',
      servicePrice: map['servicePrice'] ?? '',
      serviceImage: map['serviceImage'] ?? '',
      customerName: map['customerName'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'] ?? '',
      address: map['address'] ?? '',
      mitra: map['mitraName'] ?? map['mitra'] ?? '',
      orderDate: map['orderDate'] != null 
          ? DateTime.parse(map['orderDate'])
          : DateTime.now(),
      ukuranMobil: map['ukuranMobil'] ?? '',
      brand: map['brand'] ?? '',
      type: map['type'] ?? '',
      nopolisi: map['nopolisi'] ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      status: map['orderStatus'] ?? map['status'] ?? 'pending',
    );
  }

  // Copy with (untuk update data)
  OrderModel copyWith({
    String? orderId,
    String? userId,
    String? serviceName,
    String? servicePrice,
    String? serviceImage,
    String? customerName,
    String? phone,
    String? email,
    String? address,
    String? mitra,
    DateTime? orderDate,
    String? ukuranMobil,
    String? brand,
    String? type,
    String? nopolisi,
    DateTime? createdAt,
    String? status,
  }) {
    return OrderModel(
      orderId: orderId ?? this.orderId,
      userId: userId ?? this.userId,
      serviceName: serviceName ?? this.serviceName,
      servicePrice: servicePrice ?? this.servicePrice,
      serviceImage: serviceImage ?? this.serviceImage,
      customerName: customerName ?? this.customerName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      mitra: mitra ?? this.mitra,
      orderDate: orderDate ?? this.orderDate,
      ukuranMobil: ukuranMobil ?? this.ukuranMobil,
      brand: brand ?? this.brand,
      type: type ?? this.type,
      nopolisi: nopolisi ?? this.nopolisi,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
    );
  }
}