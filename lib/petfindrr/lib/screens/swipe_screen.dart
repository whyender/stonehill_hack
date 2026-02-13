import 'package:flutter/material.dart';
import '../models/pet.dart';
import '../models/user_profile.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../widgets/pet_card.dart';
import 'matches_screen.dart';

class SwipeScreen extends StatefulWidget {
  const SwipeScreen({super.key});

  @override
  State<SwipeScreen> createState() => _SwipeScreenState();
}

class _SwipeScreenState extends State<SwipeScreen> {
  final _authService = AuthService();
  final _firestoreService = FirestoreService();
  
  UserProfile? _userProfile;
  List<Pet> _pets = [];
  int _currentIndex = 0;
  int _likesCount = 0;
  int _passesCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserAndPets();
  }

  Future<void> _loadUserAndPets() async {
    final uid = _authService.currentUser!.uid;
    _userProfile = await _authService.getUserProfile(uid);
    
    _firestoreService.getAvailablePets(uid).listen((pets) {
      if (!mounted) return;
      
      setState(() {
        _pets = pets;
        _isLoading = false;
      });
    });
  }

  Future<void> _handleLike() async {
    if (_currentIndex >= _pets.length) return;
    
    final pet = _pets[_currentIndex];
    final uid = _authService.currentUser!.uid;
    
    setState(() {
      _likesCount++;
      _currentIndex++;
    });
    
    await _firestoreService.likePet(pet.id, uid);
    
    // Create match
    final matchId = await _firestoreService.createMatch(uid, pet.sellerId, pet.id);
    
    if (!mounted) return;
    _showMatchDialog(pet, matchId);
  }

  Future<void> _handlePass() async {
    if (_currentIndex >= _pets.length) return;
    
    final pet = _pets[_currentIndex];
    final uid = _authService.currentUser!.uid;
    
    setState(() {
      _passesCount++;
      _currentIndex++;
    });
    
    await _firestoreService.passPet(pet.id, uid);
  }

  void _showMatchDialog(Pet pet, String matchId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'yippeee',
                style: TextStyle(fontSize: 64),
              ),
              const SizedBox(height: 16),
              const Text(
                'It\'s a Match!!!!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You liked ${pet.name}!!!!!',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: Theme.of(context).primaryColor,
                          width: 2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Keep Swiping',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MatchesScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Send Message',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _calculateCompatibility(Pet pet) {
    if (_userProfile == null) return 75;
    
    int score = 0;
    int factors = 0;

    // Budget match (30 points)
    if (_userProfile!.budget != null) {
      factors++;
      final budgetDiff = (_userProfile!.budget! - pet.price).abs();
      if (budgetDiff <= 100) {
        score += 30;
      } else if (budgetDiff <= 300) {
        score += 20;
      } else if (budgetDiff <= 500) {
        score += 10;
      }
    }

    if (_userProfile!.preferredSizes != null && 
        _userProfile!.preferredSizes!.contains(pet.size)) {
      score += 25;
      factors++;
    }

    if (_userProfile!.homeSize != null) {
      factors++;
      final Map<String, List<String>> compatibleSizes = {
        'small': ['small'],
        'medium': ['small', 'medium'],
        'large': ['small', 'medium', 'large'],
      };
      if (compatibleSizes[_userProfile!.homeSize]!.contains(pet.size)) {
        score += 20;
      }
    }

    if (_userProfile!.activityLevel != null) {
      factors++;
      if (_userProfile!.activityLevel == pet.energyLevel) {
        score += 25;
      } else if ((_userProfile!.activityLevel == 'medium' && pet.energyLevel != 'medium') ||
                 (pet.energyLevel == 'medium' && _userProfile!.activityLevel != 'medium')) {
        score += 15;
      }
    }

    return factors > 0 ? score : 75;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.grey[100],
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_pets.isEmpty || _currentIndex >= _pets.length) {
      return Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            '🐾 PetMatch',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.chat, color: Colors.black),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MatchesScreen()),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.black),
              onPressed: () async {
                await _authService.signOut();
                if (!mounted) return;
                Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
              },
            ),
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'doggiee',
                style: TextStyle(fontSize: 80),
              ),
              const SizedBox(height: 24),
              const Text(
                'PLACEHOLDER FOR NO MORE PETS NEAR YOU',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'PLACEHOLDER BUT CHECK BACK LATER',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    final currentPet = _pets[_currentIndex];
    final score = _calculateCompatibility(currentPet);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          '🐾 PetMatch',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.chat, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MatchesScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            onPressed: () async {
              await _authService.signOut();
              if (!mounted) return;
              Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStat('Liked', _likesCount, Colors.green),
                Container(width: 1, height: 30, color: Colors.grey[300]),
                _buildStat('Passed', _passesCount, Colors.red),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          Expanded(
            child: GestureDetector(
              onHorizontalDragEnd: (details) {
                if (details.primaryVelocity! < -500) {
                  // Swipe left
                  _handlePass();
                } else if (details.primaryVelocity! > 500) {
                  // Swipe right
                  _handleLike();
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Stack(
                  children: [
                    if (_currentIndex + 1 < _pets.length)
                      Positioned(
                        top: 10,
                        left: 10,
                        right: 10,
                        bottom: 10,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    // Current card
                    PetCard(
                      pet: currentPet,
                      compatibilityScore: score,
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Action Buttons
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(
                  icon: Icons.close,
                  color: Colors.red,
                  onTap: _handlePass,
                ),
                _buildActionButton(
                  icon: Icons.info_outline,
                  color: Colors.blue,
                  size: 50,
                  iconSize: 24,
                  onTap: () => _showPetDetails(currentPet),
                ),
                _buildActionButton(
                  icon: Icons.favorite,
                  color: Colors.green,
                  onTap: _handleLike,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showPetDetails(Pet pet) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                pet.name,
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                '${pet.breed} • ${pet.age} years old',
                style: TextStyle(fontSize: 18, color: Colors.grey[600]),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildInfoChip(pet.size.toUpperCase(), Colors.blue),
                  const SizedBox(width: 8),
                  _buildInfoChip(pet.energyLevel.toUpperCase(), Colors.orange),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                pet.description,
                style: const TextStyle(fontSize: 16, height: 1.5),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.location_on, color: Colors.grey[600], size: 20),
                  const SizedBox(width: 4),
                  Text(
                    pet.location,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.attach_money, color: Colors.grey[600], size: 20),
                  Text(
                    '\$${pet.price.toInt()}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStat(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          '$count',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    double size = 60,
    double iconSize = 30,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: color, size: iconSize),
      ),
    );
  }
}