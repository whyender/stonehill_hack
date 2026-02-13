import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid;
  final String email;
  final String role; 
  final String? name;
  
  
  final double? budget;
  final String? homeSize;
  final String? activityLevel; 
  final List<String>? preferredSizes;
  final List<String>? location;
  
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfile({
    required this.uid,
    required this.email,
    required this.role,
    this.name,
    this.budget,
    this.homeSize,
    this.activityLevel,
    this.preferredSizes,
    this.location,
    required this.createdAt,
    required this.updatedAt,
  });

  
  
  int get homeSizeScore {
    if (homeSize == null) return 2;
    switch (homeSize!.toLowerCase()) {
      case 'small': return 1;
      case 'medium': return 2;
      case 'large': return 3;
      default: return 2;
    }
  }

  int get activityScore {
    if (activityLevel == null) return 2;
    switch (activityLevel!.toLowerCase()) {
      case 'low': return 1;
      case 'medium': return 2;
      case 'high': return 3;
      default: return 2;
    }
  }

  double get budgetScore {
    if (budget == null) return 0.5;
    return (budget! / 2000.0).clamp(0.0, 1.0);
  }

  List<int> get preferredSizeScores {
    if (preferredSizes == null || preferredSizes!.isEmpty) return [1, 2, 3];
    return preferredSizes!.map((size) {
      switch (size.toLowerCase()) {
        case 'small': return 1;
        case 'medium': return 2;
        case 'large': return 3;
        default: return 2;
      }
    }).toList();
  }

  
  List<double> get initialPreferenceVector => [
        homeSizeScore.toDouble(),
        activityScore.toDouble(),
        budgetScore,
        2.0, 
      ];

  

  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserProfile(
      uid: doc.id,
      email: data['email'] ?? '',
      role: data['role'] ?? '',
      name: data['name'],
      budget: data['budget']?.toDouble(),
      homeSize: data['homeSize'],
      activityLevel: data['activityLevel'],
      preferredSizes: data['preferredSizes'] != null 
          ? List<String>.from(data['preferredSizes']) 
          : null,
      location: data['location'] != null 
          ? List<String>.from(data['location']) 
          : null,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'role': role,
      'name': name,
      'budget': budget,
      'homeSize': homeSize,
      'activityLevel': activityLevel,
      'preferredSizes': preferredSizes,
      'location': location,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}