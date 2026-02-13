import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid;
  final String email;
  final String role; //role them as either an adopter or a seller/adoptoion center
  final String? name;
  
  final double? budget;
  final String? homeSize; // small, medium, large to see if enoguh space
  final String? activityLevel; // low, medium, high for walking
  final List<String>? preferredSizes; // small, medium, large algon wiht general consensuses for size
  final List<String>? location; //in km for righ tnow but can be more specific later on with city or state
  
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