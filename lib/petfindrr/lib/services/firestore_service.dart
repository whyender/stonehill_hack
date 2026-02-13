import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/pet.dart';
import '../models/match.dart';
import '../models/message.dart';
import '../models/user_profile.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  
  Future<void> addPet(Pet pet) async {
    await _firestore.collection('pets').add(pet.toFirestore());
  }

  Stream<List<Pet>> getAvailablePets(String adopterId) {
    return _firestore
        .collection('pets')
        .where('isAvailable', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Pet.fromFirestore(doc))
            .where((pet) => 
                !pet.likedBy.contains(adopterId) && 
                !pet.passedBy.contains(adopterId))
            .toList());
  }

  Stream<List<Pet>> getSellerPets(String sellerId) {
    return _firestore
        .collection('pets')
        .where('sellerId', isEqualTo: sellerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => 
            snapshot.docs.map((doc) => Pet.fromFirestore(doc)).toList());
  }

  Future<void> likePet(String petId, String adopterId) async {
    await _firestore.collection('pets').doc(petId).update({
      'likedBy': FieldValue.arrayUnion([adopterId]),
    });
  }

  Future<void> passPet(String petId, String adopterId) async {
    await _firestore.collection('pets').doc(petId).update({
      'passedBy': FieldValue.arrayUnion([adopterId]),
    });
  }

  Future<Pet?> getPet(String petId) async {
    final doc = await _firestore.collection('pets').doc(petId).get();
    if (doc.exists) {
      return Pet.fromFirestore(doc);
    }
    return null;
  }


  Future<String> createMatch(String adopterId, String sellerId, String petId) async {
    final match = Match(
      id: '',
      adopterId: adopterId,
      sellerId: sellerId,
      petId: petId,
      matchedAt: DateTime.now(),
      lastMessageTime: DateTime.now(),
    );

    final docRef = await _firestore.collection('matches').add(match.toFirestore());
    return docRef.id;
  }

  Stream<List<Match>> getUserMatches(String userId) {
    return _firestore
        .collection('matches')
        .where('adopterId', isEqualTo: userId)
        .snapshots()
        .asyncMap((adopterSnapshot) async {
      final sellerSnapshot = await _firestore
          .collection('matches')
          .where('sellerId', isEqualTo: userId)
          .get();

      final allDocs = [...adopterSnapshot.docs, ...sellerSnapshot.docs];
      return allDocs.map((doc) => Match.fromFirestore(doc)).toList()
        ..sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
    });
  }

  Future<Match?> getMatch(String matchId) async {
    final doc = await _firestore.collection('matches').doc(matchId).get();
    if (doc.exists) {
      return Match.fromFirestore(doc);
    }
    return null;
  }

  Future<void> sendMessage(String matchId, String senderId, String text) async {
    final message = Message(
      id: '',
      matchId: matchId,
      senderId: senderId,
      text: text,
      timestamp: DateTime.now(),
    );

    await _firestore
        .collection('matches')
        .doc(matchId)
        .collection('messages')
        .add(message.toFirestore());

    // UPDATE HTE LAST EMSSAGE ADN UNREAD CUNT
    final match = await getMatch(matchId);
    if (match != null) {
      final isAdopterSending = senderId == match.adopterId;
      await _firestore.collection('matches').doc(matchId).update({
        'lastMessage': text,
        'lastMessageTime': Timestamp.fromDate(DateTime.now()),
        if (isAdopterSending)
          'sellerUnreadCount': FieldValue.increment(1)
        else
          'adopterUnreadCount': FieldValue.increment(1),
      });
    }
  }

  Stream<List<Message>> getMessages(String matchId) {
    return _firestore
        .collection('matches')
        .doc(matchId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => 
            snapshot.docs.map((doc) => Message.fromFirestore(doc)).toList());
  }

  Future<void> markMessagesAsRead(String matchId, String userId) async {
    final match = await getMatch(matchId);
    if (match != null) {
      final isAdopter = userId == match.adopterId;
      await _firestore.collection('matches').doc(matchId).update({
        if (isAdopter)
          'adopterUnreadCount': 0
        else
          'sellerUnreadCount': 0,
      });
    }
  }



  Future<UserProfile?> getUserProfile(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists) {
      return UserProfile.fromFirestore(doc);
    }
    return null;
  }
}