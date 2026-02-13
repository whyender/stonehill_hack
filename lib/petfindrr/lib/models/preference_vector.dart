class PreferenceVector {
  List<double> vector;
  int updateCount;

  PreferenceVector({
    required this.vector,
    this.updateCount = 0,
  });

  factory PreferenceVector.fromUserProfile(List<double> profileVector) {
    return PreferenceVector(
      vector: List.from(profileVector),
      updateCount: 0,
    );
  }

  void update(List<double> likedFeatures, double learningRate) {
    for (int i = 0; i < vector.length; i++) {
      // Move preference center toward liked pet
      vector[i] = vector[i] + learningRate * (likedFeatures[i] - vector[i]);
    }
    updateCount++;
  }

  Map<String, dynamic> toJson() {
    return {
      'vector': vector,
      'updateCount': updateCount,
    };
  }

  factory PreferenceVector.fromJson(Map<String, dynamic> json) {
    return PreferenceVector(
      vector: List<double>.from(json['vector']),
      updateCount: json['updateCount'] ?? 0,
    );
  }

  PreferenceVector copy() {
    return PreferenceVector(
      vector: List.from(vector),
      updateCount: updateCount,
    );
  }
}