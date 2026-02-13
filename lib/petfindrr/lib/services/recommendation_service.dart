import 'dart:math';
import '../models/pet.dart';
import '../models/user_profile.dart';
import '../models/swipe.dart';
import '../models/preference_vector.dart';

class RecommendationService {
  PreferenceVector _preferenceVector;
  final List<Swipe> _swipeHistory = [];
  
  static const int _maxSwipeHistory = 25;
  static const int _retrainInterval = 5;
  static const double _learningRate = 0.15;
  static const double _baseWeight = 0.6;
  static const double _adaptiveWeight = 0.4;

  RecommendationService(UserProfile userProfile)
      : _preferenceVector = PreferenceVector.fromUserProfile(
          userProfile.initialPreferenceVector,
        );

  void recordSwipe(Pet pet, bool liked) {
    final swipe = Swipe.fromPet(pet.id, pet.featureVector, liked);
    
    _swipeHistory.add(swipe);
    
    if (_swipeHistory.length > _maxSwipeHistory) {
      _swipeHistory.removeAt(0);
    }

    if (_swipeHistory.length % _retrainInterval == 0) {
      _retrain();
    }
  }

  void _retrain() {
    final likedSwipes = _swipeHistory.where((s) => s.liked).toList();
    
    if (likedSwipes.isEmpty) return;

    for (final swipe in likedSwipes) {
      _preferenceVector.update(swipe.petFeatures, _learningRate);
    }
  }

  double _calculateBaseScore(Pet pet, UserProfile userProfile) {
    int score = 0;
    int factors = 0;

    if (userProfile.budget != null) {
      factors++;
      final budgetDiff = (userProfile.budget! - pet.price).abs();
      if (budgetDiff <= 100) {
        score += 30;
      } else if (budgetDiff <= 300) {
        score += 20;
      } else if (budgetDiff <= 500) {
        score += 10;
      }
    }

    if (userProfile.preferredSizes != null && 
        userProfile.preferredSizes!.contains(pet.size)) {
      score += 25;
      factors++;
    }

    if (userProfile.homeSize != null) {
      factors++;
      final Map<String, List<String>> compatibleSizes = {
        'small': ['small'],
        'medium': ['small', 'medium'],
        'large': ['small', 'medium', 'large'],
      };
      if (compatibleSizes[userProfile.homeSize]!.contains(pet.size)) {
        score += 20;
      }
    }

    if (userProfile.activityLevel != null) {
      factors++;
      if (userProfile.activityLevel == pet.energyLevel) {
        score += 25;
      } else if ((userProfile.activityLevel == 'medium' && pet.energyLevel != 'medium') ||
                 (pet.energyLevel == 'medium' && userProfile.activityLevel != 'medium')) {
        score += 15;
      }
    }

    return factors > 0 ? score / 100.0 : 0.75;
  }

  double _calculateAdaptiveScore(Pet pet) {
    if (_preferenceVector.updateCount == 0) {
      return 0.5; 
    }

    final petVector = pet.featureVector;
    double distance = 0.0;
    
    for (int i = 0; i < petVector.length; i++) {
      final diff = petVector[i] - _preferenceVector.vector[i];
      distance += diff * diff;
    }
    distance = sqrt(distance);

    final normalizedDistance = (distance / 6.0).clamp(0.0, 1.0);
    return 1.0 - normalizedDistance;
  }

  double scoreFor(Pet pet, UserProfile userProfile) {
    final baseScore = _calculateBaseScore(pet, userProfile);
    final adaptiveScore = _calculateAdaptiveScore(pet);
    
    return (_baseWeight * baseScore) + (_adaptiveWeight * adaptiveScore);
  }

  List<Pet> rankPets(List<Pet> pets, UserProfile userProfile) {
    final scored = pets.map((pet) {
      return {
        'pet': pet,
        'score': scoreFor(pet, userProfile),
      };
    }).toList();

    scored.sort((a, b) => (b['score'] as double).compareTo(a['score'] as double));

    return scored.map((item) => item['pet'] as Pet).toList();
  }

  Map<String, dynamic> getPreferenceState() {
    return {
      'vector': _preferenceVector.vector,
      'swipeCount': _swipeHistory.length,
      'updateCount': _preferenceVector.updateCount,
      'likedCount': _swipeHistory.where((s) => s.liked).length,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'preferenceVector': _preferenceVector.toJson(),
      'swipeHistory': _swipeHistory.map((s) => s.toJson()).toList(),
    };
  }

  factory RecommendationService.fromJson(
    Map<String, dynamic> json,
    UserProfile userProfile,
  ) {
    final service = RecommendationService(userProfile);
    
    if (json['preferenceVector'] != null) {
      service._preferenceVector = PreferenceVector.fromJson(json['preferenceVector']);
    }
    
    if (json['swipeHistory'] != null) {
      service._swipeHistory.clear();
      service._swipeHistory.addAll(
        (json['swipeHistory'] as List).map((s) => Swipe.fromJson(s)),
      );
    }
    
    return service;
  }
}