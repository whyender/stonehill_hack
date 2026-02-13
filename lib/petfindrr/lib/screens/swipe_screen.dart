import 'package:flutter/material.dart';
import '../models/pet.dart';
import '../models/user_profile.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/recommendation_service.dart';
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
  
  RecommendationService? _recommendationService;
  UserProfile? _userProfile;
  List<Pet> _pets = [];
  int _currentIndex = 0;
  int _likesCount = 0;
  int _passesCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMockData();
  }

  void _loadMockData() {
    setState(() {
      _pets = [
        Pet(
          id: '1',
          sellerId: 'mock_seller_1',
          name: 'Luna',
          breed: 'Golden Retriever',
          age: 2,
          size: 'large',
          energyLevel: 'high',
          price: 500,
          imageUrls: ['https://images.unsplash.com/photo-1633722715463-d30f4f325e24?w=800'],
          description: 'Friendly and energetic dog looking for an active family!',
          location: 'San Francisco, CA',
          createdAt: DateTime.now(),
          likedBy: [],
          passedBy: [],
        ),
        Pet(
          id: '2',
          sellerId: 'mock_seller_2',
          name: 'Max',
          breed: 'French Bulldog',
          age: 3,
          size: 'small',
          energyLevel: 'low',
          price: 800,
          imageUrls: ['https://images.unsplash.com/photo-1583511655857-d19b40a7a54e?w=800'],
          description: 'Calm and cuddly companion perfect for apartment living.',
          location: 'Los Angeles, CA',
          createdAt: DateTime.now(),
          likedBy: [],
          passedBy: [],
        ),
        Pet(
          id: '3',
          sellerId: 'mock_seller_3',
          name: 'Bella',
          breed: 'Labrador Retriever',
          age: 1,
          size: 'large',
          energyLevel: 'high',
          price: 450,
          imageUrls: ['https://images.unsplash.com/photo-1552053831-71594a27632d?w=800'],
          description: 'Playful puppy ready to bring joy to your home!',
          location: 'Austin, TX',
          createdAt: DateTime.now(),
          likedBy: [],
          passedBy: [],
        ),
        Pet(
          id: '4',
          sellerId: 'mock_seller_4',
          name: 'Charlie',
          breed: 'Beagle',
          age: 4,
          size: 'medium',
          energyLevel: 'medium',
          price: 350,
          imageUrls: ['https://images.unsplash.com/photo-1505628346881-b72b27e84530?w=800'],
          description: 'Great with kids and loves to play!',
          location: 'Seattle, WA',
          createdAt: DateTime.now(),
          likedBy: [],
          passedBy: [],
        ),
        Pet(
          id: '5',
          sellerId: 'mock_seller_5',
          name: 'Daisy',
          breed: 'Pomeranian',
          age: 2,
          size: 'small',
          energyLevel: 'medium',
          price: 600,
          imageUrls: ['https://images.unsplash.com/photo-1546527868-ccb7ee7dfa6a?w=800'],
          description: 'Adorable fluffy companion with a sweet personality.',
          location: 'Portland, OR',
          createdAt: DateTime.now(),
          likedBy: [],
          passedBy: [],
        ),
        Pet(
          id: '6',
          sellerId: 'mock_seller_6',
          name: 'Rocky',
          breed: 'German Shepherd',
          age: 3,
          size: 'large',
          energyLevel: 'high',
          price: 700,
          imageUrls: ['https://images.unsplash.com/photo-1568572933382-74d440642117?w=800'],
          description: 'Loyal and protective, needs experienced owner.',
          location: 'Denver, CO',
          createdAt: DateTime.now(),
          likedBy: [],
          passedBy: [],
        ),
        Pet(
          id: '7',
          sellerId: 'mock_seller_7',
          name: 'Milo',
          breed: 'Corgi',
          age: 2,
          size: 'medium',
          energyLevel: 'medium',
          price: 900,
          imageUrls: ['https://images.unsplash.com/photo-1612536459960-c5f5c3c09214?w=800'],
          description: 'Smart and friendly, loves everyone!',
          location: 'Boston, MA',
          createdAt: DateTime.now(),
          likedBy: [],
          passedBy: [],
        ),
        Pet(
          id: '8',
          sellerId: 'mock_seller_8',
          name: 'Sophie',
          breed: 'Poodle',
          age: 5,
          size: 'medium',
          energyLevel: 'low',
          price: 550,
          imageUrls: ['https://images.unsplash.com/photo-1616496387351-c0e1e5b63b69?w=800'],
          description: 'Elegant and calm, perfect for seniors.',
          location: 'Miami, FL',
          createdAt: DateTime.now(),
          likedBy: [],
          passedBy: [],
        ),
      ];
      _isLoading = false;
    });

    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final uid = _authService.currentUser!.uid;
    _userProfile = await _authService.getUserProfile(uid);
    
    // Initialize recommendation service with user profile
    if (_userProfile != null) {
      _recommendationService = RecommendationService(_userProfile!);
      
      // Rank pets based on initial compatibility
      setState(() {
        _pets = _recommendationService!.rankPets(_pets, _userProfile!);
      });
    }
    
    if (mounted) setState(() {});
  }

  Future<void> _handleLike() async {
    if (_currentIndex >= _pets.length) return;
    
    final pet = _pets[_currentIndex];
    
    // Record swipe for learning
    _recommendationService?.recordSwipe(pet, true);
    
    setState(() {
      _likesCount++;
      _currentIndex++;
    });
    
    // Uncomment when using real Firebase:
    /*
    final uid = _authService.currentUser!.uid;
    await _firestoreService.likePet(pet.id, uid);
    final matchId = await _firestoreService.createMatch(uid, pet.sellerId, pet.id);
    */
    
    if (!mounted) return;
    _showMatchDialog(pet, 'mock_match_id');
  }

  Future<void> _handlePass() async {
    if (_currentIndex >= _pets.length) return;
    
    final pet = _pets[_currentIndex];
    
    // Record swipe for learning
    _recommendationService?.recordSwipe(pet, false);
    
    setState(() {
      _passesCount++;
      _currentIndex++;
    });
    
    // Uncomment when using real Firebase:
    /*
    final uid = _authService.currentUser!.uid;
    await _firestoreService.passPet(pet.id, uid);
    */
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
                '🎉',
                style: TextStyle(fontSize: 64),
              ),
              const SizedBox(height: 16),
              const Text(
                'It\'s a Match!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You liked ${pet.name}!',
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
    if (_userProfile == null || _recommendationService == null) return 75;
    
    // Use recommendation service score (0.0-1.0) and convert to percentage
    final score = _recommendationService!.scoreFor(pet, _userProfile!);
    return (score * 100).round();
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
                '🐕',
                style: TextStyle(fontSize: 80),
              ),
              const SizedBox(height: 24),
              const Text(
                'No more pets nearby!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Check back later for more matches',
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
          // Debug button (remove for production)
          IconButton(
            icon: const Icon(Icons.science, color: Colors.black),
            onPressed: () {
              if (_recommendationService != null) {
                final state = _recommendationService!.getPreferenceState();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '🧠 Swipes: ${state['swipeCount']}, Liked: ${state['likedCount']}, Updates: ${state['updateCount']}',
                    ),
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
            },
          ),
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
          // Stats Bar
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
          
          // Pet Card with Swipe Gestures
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
                    // Show next card behind for depth effect
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