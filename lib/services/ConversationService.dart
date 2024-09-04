import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eduticket/models/Conversation.dart';
import 'package:eduticket/models/Ticket-model.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:rxdart/rxdart.dart' as rxdart;

class ConversationService {
  final CollectionReference conversationCollection =
      FirebaseFirestore.instance.collection('conversations');

  // Créer ou mettre à jour une conversation
  Future<void> createOrUpdateConversation(Conversation conversation) async {
    try {
      await conversationCollection.doc(conversation.id).set(conversation.toMap());
      print('Conversation créée ou mise à jour avec succès : ${conversation.id}');
    } catch (e) {
      print('Erreur lors de la création ou de la mise à jour de la conversation : $e');
    }
  }

  // Récupérer toutes les conversations d'un utilisateur
  Stream<List<Conversation>> getConversations(String userId) {
    print('Récupération des conversations pour l\'utilisateur : $userId');

    final queryForApprenant = conversationCollection
        .where('apprenantId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Conversation.fromMap(doc.id, doc.data() as Map<String, dynamic>))
              .toList();
        });

    final queryForFormateur = conversationCollection
        .where('formateurId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Conversation.fromMap(doc.id, doc.data() as Map<String, dynamic>))
              .toList();
        });

    return rxdart.Rx.combineLatest2(
      queryForApprenant,
      queryForFormateur,
      (List<Conversation> apprenantConversations, List<Conversation> formateurConversations) {
        final allConversations = <Conversation>{};
        allConversations.addAll(apprenantConversations);
        allConversations.addAll(formateurConversations);
        return allConversations.toList();
      },
    );
  }

  // Obtenir ou créer une conversation pour un ticket
  Future<Conversation> getOrCreateConversation(Ticket ticket) async {
    try {
      // Rechercher une conversation existante liée au ticket
      final querySnapshot = await conversationCollection
          .where('ticketId', isEqualTo: ticket.id)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Si une conversation existe, la retourner
        final doc = querySnapshot.docs.first;
        return Conversation.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      } else {
        // Sinon, créer une nouvelle conversation
        final newConversation = Conversation(
          id: conversationCollection.doc().id,
          apprenantId: ticket.idApprenant,
          formateurId: ticket.idFormateur,
          ticketId: ticket.id, // Associe la conversation au ticket
          lastMessage: 'Aucun message', // Valeur par défaut ou calculée
          lastMessageTimestamp: DateTime.now(), // Valeur par défaut ou calculée
          hasUnreadMessages: false, // Valeur par défaut ou calculée
        );

        await conversationCollection.doc(newConversation.id).set(newConversation.toMap());
        return newConversation;
      }
    } catch (e) {
      throw Exception('Erreur lors de la récupération ou de la création de la conversation : $e');
    }
  }
}
