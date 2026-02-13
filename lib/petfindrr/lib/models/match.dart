import 'package:cloud_firestore/cloud_firestore.dart';

class Match {
  final String id;
  final String adopterId;
  final String sellerId;
  final String petId;
  final DateTime matchedAt;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int adopterUnreadCount;
  final int sellerUnreadCount;

  Match({
    required this.id,
    required this.adopterId,
    required this.sellerId,
    required this.petId,
    required this.matchedAt,
    this.lastMessage = '',
    required this.lastMessageTime,
    this.adopterUnreadCount = 0,
    this.sellerUnreadCount = 0,
  });

  factory Match.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Match(
      id: doc.id,
      adopterId: data['adopterId'] ?? '',
      sellerId: data['sellerId'] ?? '',
      petId: data['petId'] ?? '',
      matchedAt: (data['matchedAt'] as Timestamp).toDate(),
      lastMessage: data['lastMessage'] ?? '',
      lastMessageTime: (data['lastMessageTime'] as Timestamp).toDate(),
      adopterUnreadCount: data['adopterUnreadCount'] ?? 0,
      sellerUnreadCount: data['sellerUnreadCount'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'adopterId': adopterId,
      'sellerId': sellerId,
      'petId': petId,
      'matchedAt': Timestamp.fromDate(matchedAt),
      'lastMessage': lastMessage,
      'lastMessageTime': Timestamp.fromDate(lastMessageTime),
      'adopterUnreadCount': adopterUnreadCount,
      'sellerUnreadCount': sellerUnreadCount,
    };
  }
}