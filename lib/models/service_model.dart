// models/service_model.dart
class ServiceModel {
  final String id;
  final String name;
  final String price;
  final String image;
  final String description;
  final List<String> features;

  ServiceModel({
    this.id = '',  // Buat opsional dengan default value
    required this.name,
    required this.price,
    required this.image,
    this.description = '',
    this.features = const [],
  });

  // Convert to Map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'image': image,
      'description': description,
      'features': features,
    };
  }

  // Create from Firebase Map
  factory ServiceModel.fromMap(Map<String, dynamic> map) {
    return ServiceModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      price: map['price'] ?? '',
      image: map['image'] ?? '',
      description: map['description'] ?? '',
      features: List<String>.from(map['features'] ?? []),
    );
  }

  // Copy with method for updates
  ServiceModel copyWith({
    String? id,
    String? name,
    String? price,
    String? image,
    String? description,
    List<String>? features,
  }) {
    return ServiceModel(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      image: image ?? this.image,
      description: description ?? this.description,
      features: features ?? this.features,
    );
  }
}