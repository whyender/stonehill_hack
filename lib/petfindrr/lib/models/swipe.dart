class Swipe {
  final String petId;
  final List<double> petFeatures;
  final bool liked;
  final DateTime timestamp;

  Swipe({
    required this.petId,
    required this.petFeatures,
    required this.liked,
    required this.timestamp,
  });

  // Factory from Pet object
  factory Swipe.fromPet(String petId, List<double> features, bool liked) {
    return Swipe(
      petId: petId,
      petFeatures: features,
      liked: liked,
      timestamp: DateTime.now(),
    );
  }

  // Serialization for persistence
  Map<String, dynamic> toJson() {
    return {
      'petId': petId,
      'petFeatures': petFeatures,
      'liked': liked,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory Swipe.fromJson(Map<String, dynamic> json) {
    return Swipe(
      petId: json['petId'],
      petFeatures: List<double>.from(json['petFeatures']),
      liked: json['liked'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}