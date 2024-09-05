import 'package:cloud_firestore/cloud_firestore.dart';

class Conversation {
  final String id;
  final String apprenantId;
  final String formateurId;
  final String ticketId;
  final String lastMessage;
  final DateTime lastMessageTimestamp;
  final bool hasUnreadMessages;

  Conversation({
    required this.id,
    required this.apprenantId,
    required this.formateurId,
    required this.ticketId,
    required this.lastMessage,
    required this.lastMessageTimestamp,
    required this.hasUnreadMessages,
  });

  // Conversion de la carte en objet Conversation
  factory Conversation.fromMap(String id, Map<String, dynamic> map) {
    return Conversation(
      id: id,
      apprenantId: map['apprenantId'],
      formateurId: map['formateurId'],
      ticketId: map['ticketId'],
      lastMessage: map['lastMessage'],
      lastMessageTimestamp: (map['lastMessageTimestamp'] as Timestamp).toDate(), // Conversion de Timestamp à DateTime
      hasUnreadMessages: map['hasUnreadMessages'],
    );
  }

  // Conversion de l'objet Conversation en carte
  Map<String, dynamic> toMap() {
    return {
      'apprenantId': apprenantId,
      'formateurId': formateurId,
      'ticketId': ticketId,
      'lastMessage': lastMessage,
      'lastMessageTimestamp': lastMessageTimestamp, // Firebase gère les DateTime
      'hasUnreadMessages': hasUnreadMessages,
    };
  }

  // Méthode copyWith pour créer une copie de l'objet avec certains champs modifiés
  Conversation copyWith({
    String? id,
    String? apprenantId,
    String? formateurId,
    String? ticketId,
    String? lastMessage,
    DateTime? lastMessageTimestamp,
    bool? hasUnreadMessages,
  }) {
    return Conversation(
      id: id ?? this.id,
      apprenantId: apprenantId ?? this.apprenantId,
      formateurId: formateurId ?? this.formateurId,
      ticketId: ticketId ?? this.ticketId,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTimestamp: lastMessageTimestamp ?? this.lastMessageTimestamp,
      hasUnreadMessages: hasUnreadMessages ?? this.hasUnreadMessages,
    );
  }
}
