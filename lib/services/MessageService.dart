import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eduticket/models/Message.dart';
import 'package:eduticket/models/Utilisateur.dart';
import 'package:eduticket/services/AuthService.dart';

class MessageService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();
// Méthode pour envoyer un message
Future<void> sendMessage({
  required String ticketId,  // ID du ticket
  required String content,   // Contenu du message
  required String receiverId, // ID de l'apprenant
}) async {
  try {
    // Obtenez l'utilisateur actuellement connecté (formateur)
    Utilisateur? currentUser = await _authService.getCurrentUser();
    if (currentUser == null) {
      throw Exception('Utilisateur non authentifié');
    }

    // Créez un nouvel ID pour le message
    String messageId = _firestore.collection('messages').doc().id;

    // Créez une nouvelle conversation si elle n'existe pas encore
    String conversationId = await _getOrCreateConversationId(ticketId, currentUser.id, receiverId);

    // Créez un nouveau message
    final message = Message(
      id: messageId,
      conversationId: conversationId,
      ticketId: ticketId, // Utiliser le ticketId fourni
      senderId: currentUser.id, // Utilisez l'ID du formateur authentifié
      receiverId: receiverId,
      content: content,
      timestamp: DateTime.now(), // Utilisez l'heure actuelle comme timestamp
    );

    // Ajoutez le message à Firestore
    await _firestore.collection('messages').doc(messageId).set(message.toMap());
    print('Message envoyé avec succès');
  } catch (e) {
    print('Erreur lors de l\'envoi du message : $e');
  }
}

  // Méthode pour obtenir ou créer un ID de conversation
  Future<String> _getOrCreateConversationId(String ticketId, String senderId, String receiverId) async {
    // Vérifiez si une conversation existe déjà pour ce ticket entre ces deux utilisateurs
    var querySnapshot = await _firestore
        .collection('conversations')
        .where('ticketId', isEqualTo: ticketId)
        .where('senderId', isEqualTo: senderId)
        .where('receiverId', isEqualTo: receiverId)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      // Retourne l'ID de la conversation existante
      return querySnapshot.docs.first.id;
    } else {
      // Créez une nouvelle conversation
      String conversationId = _firestore.collection('conversations').doc().id;
      await _firestore.collection('conversations').doc(conversationId).set({
        'ticketId': ticketId,
        'senderId': senderId,
        'receiverId': receiverId,
      });
      return conversationId;
    }
  }
}
