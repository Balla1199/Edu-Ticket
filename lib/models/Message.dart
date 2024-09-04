import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String id;
  final String conversationId; // ID de la conversation associée
  final String ticketId; // ID du ticket associé
  final String senderId; // ID de l'expéditeur (apprenant ou formateur)
  final String receiverId; // ID du destinataire
  final String content; // Contenu du message
  final DateTime timestamp; // Horodatage du message

  Message({
    required this.id,
    required this.conversationId,
    required this.ticketId, // Ajouter ticketId
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.timestamp,
  });

  // Convertir un message en map pour Firestore
  Map<String, dynamic> toMap() {
    return {
      'conversationId': conversationId,
      'ticketId': ticketId, // Ajouter ticketId
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
      'timestamp': timestamp,
    };
  }

  // Créer un message à partir d'une map Firestore
  static Message fromMap(String id, Map<String, dynamic> map) {
    return Message(
      id: id,
      conversationId: map['conversationId'],
      ticketId: map['ticketId'], // Ajouter ticketId
      senderId: map['senderId'],
      receiverId: map['receiverId'],
      content: map['content'],
      timestamp: (map['timestamp'] as Timestamp).toDate(),
    );
  }
}
