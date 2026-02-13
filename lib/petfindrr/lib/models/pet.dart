import 'package:cloud_firestore/cloud_firestore.dart';

class Pet {
  final String id;
  final String sellerId;
  final String name;
  final String breed;
  final int age;
  final String size; // small, medium, large
  final String energyLevel; // low, medium, high
  final double price;
  final List<String> imageUrls;
  final String description;
  final String location;
  final bool isAvailable;
  final DateTime createdAt;
  final List<String> likedBy;
  final List<String> passedBy;

  Pet({
    required this.id,
    required this.sellerId,
    required this.name,
    required this.breed,
    required this.age,
    required this.size,
    required this.energyLevel,
    required this.price,
    required this.imageUrls,
    required this.description,
    required this.location,
    this.isAvailable = true,
    required this.createdAt,
    this.likedBy = const [],
    this.passedBy = const [],
  });

  
  int get sizeScore {
    switch (size.toLowerCase()) {
      case 'small': return 1;
      case 'medium': return 2;
      case 'large': return 3;
      default: return 2;
    }
  }

  int get energyScore {
    switch (energyLevel.toLowerCase()) {
      case 'low': return 1;
      case 'medium': return 2;
      case 'high': return 3;
      default: return 2;
    }
  }

  double get priceScore {
    return (price / 2000.0).clamp(0.0, 1.0);
  }

  int get ageScore {
    if (age <= 2) return 1;
    if (age <= 7) return 2;
    return 3;
  }

  List<double> get featureVector => [
        sizeScore.toDouble(),
        energyScore.toDouble(),
        priceScore,
        ageScore.toDouble(),
      ];

  factory Pet.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Pet(
      id: doc.id,
      sellerId: data['sellerId'] ?? '',
      name: data['name'] ?? '',
      breed: data['breed'] ?? '',
      age: data['age'] ?? 0,
      size: data['size'] ?? '',
      energyLevel: data['energyLevel'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      description: data['description'] ?? '',
      location: data['location'] ?? '',
      isAvailable: data['isAvailable'] ?? true,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      likedBy: List<String>.from(data['likedBy'] ?? []),
      passedBy: List<String>.from(data['passedBy'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'sellerId': sellerId,
      'name': name,
      'breed': breed,
      'age': age,
      'size': size,
      'energyLevel': energyLevel,
      'price': price,
      'imageUrls': imageUrls,
      'description': description,
      'location': location,
      'isAvailable': isAvailable,
      'createdAt': Timestamp.fromDate(createdAt),
      'likedBy': likedBy,
      'passedBy': passedBy,
    };
  }
}