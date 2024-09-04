import 'package:cloud_firestore/cloud_firestore.dart';

class Conversation {
  final String id;
  final String apprenantId;
  final String formateurId;
  final String ticketId; // Ajout du champ ticketId
  final String lastMessage;
  final DateTime lastMessageTimestamp;
  final bool hasUnreadMessages;

  Conversation({
    required this.id,
    required this.apprenantId,
    required this.formateurId,
    required this.ticketId, // Ajout du champ ticketId
    required this.lastMessage,
    required this.lastMessageTimestamp,
    required this.hasUnreadMessages,
  });

  // Define the copyWith method
  Conversation copyWith({
    String? id,
    String? apprenantId,
    String? formateurId,
    String? ticketId, // Ajout du champ ticketId
    String? lastMessage,
    DateTime? lastMessageTimestamp,
    bool? hasUnreadMessages,
  }) {
    return Conversation(
      id: id ?? this.id,
      apprenantId: apprenantId ?? this.apprenantId,
      formateurId: formateurId ?? this.formateurId,
      ticketId: ticketId ?? this.ticketId, // Ajout du champ ticketId
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTimestamp: lastMessageTimestamp ?? this.lastMessageTimestamp,
      hasUnreadMessages: hasUnreadMessages ?? this.hasUnreadMessages,
    );
  }

  // Conversion methods
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'apprenantId': apprenantId,
      'formateurId': formateurId,
      'ticketId': ticketId, // Ajout du champ ticketId
      'lastMessage': lastMessage,
      'lastMessageTimestamp': lastMessageTimestamp.toIso8601String(),
      'hasUnreadMessages': hasUnreadMessages,
    };
  }

  static Conversation fromMap(String id, Map<String, dynamic> map) {
    return Conversation(
      id: id,
      apprenantId: map['apprenantId'],
      formateurId: map['formateurId'],
      ticketId: map['ticketId'], // Ajout du champ ticketId
      lastMessage: map['lastMessage'],
      lastMessageTimestamp: (map['lastMessageTimestamp'] as Timestamp).toDate(), // Convertir Timestamp en DateTime
      hasUnreadMessages: map['hasUnreadMessages'],
    );
  }
}
