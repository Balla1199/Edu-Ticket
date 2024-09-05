import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eduticket/models/Message.dart';
import 'package:eduticket/models/Ticket-model.dart';
import 'package:eduticket/services/AuthService.dart';
import 'package:eduticket/services/ConversationService.dart';
import 'package:eduticket/services/TicketService.dart';
import 'package:eduticket/models/Conversation.dart';

class MessageService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TicketService _ticketService = TicketService();
  final ConversationService _conversationService = ConversationService();

  // Méthode pour créer un message et mettre à jour la conversation
  Future<void> sendMessage(String conversationId, String ticketId, String content) async {
    try {
      // Obtenez l'ID de l'utilisateur connecté (formateur)
      String senderId = (await AuthService().getCurrentUser())?.id ?? '';
      print('ID du formateur: $senderId');

      // Obtenez le ticket correspondant pour récupérer les détails
      Ticket ticket = await _ticketService.getTicketById(ticketId);
      print('Ticket récupéré: ${ticket.toMap()}');

      if (ticket.idApprenant == null || ticket.idFormateur == null) {
        throw ArgumentError('L\'ID de l\'apprenant et du formateur sont requis');
      }

      // Obtenez l'ID de l'apprenant depuis le ticket
      String receiverId = ticket.idApprenant!;
      print('ID de l\'apprenant: $receiverId');

      // Créez un nouvel ID pour le message
      String messageId = _firestore.collection('messages').doc().id;
      print('ID du message généré: $messageId');

      // Créez un nouveau message
      Message message = Message(
        id: messageId,
        conversationId: conversationId,
        ticketId: ticketId,
        senderId: senderId,
        receiverId: receiverId,
        content: content,
        timestamp: DateTime.now(),
      );
      print('Message créé: ${message.toMap()}');

      // Enregistrez le message dans Firestore
      await _firestore.collection('messages').doc(messageId).set(message.toMap());
      print('Message enregistré dans Firestore');

      // Obtenez ou créez la conversation associée au message
      Conversation conversation = await _conversationService.getOrCreateConversation(ticket);
      print('Conversation récupérée/créée: ${conversation.toMap()}');

      // Mettez à jour la conversation avec les détails du dernier message
      conversation = conversation.copyWith(
        lastMessage: content,
        lastMessageTimestamp: message.timestamp,
        hasUnreadMessages: true,
      );
      print('Conversation mise à jour: ${conversation.toMap()}');

      // Sauvegardez la conversation mise à jour dans Firestore
      await _conversationService.createOrUpdateConversation(conversation);
      print('Conversation mise à jour dans Firestore');

      print('Message envoyé avec succès.');
    } catch (e) {
      print('Erreur lors de l\'envoi du message: $e');
    }
  }
}
