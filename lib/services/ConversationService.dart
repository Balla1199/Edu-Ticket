import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eduticket/models/Conversation.dart';
import 'package:eduticket/models/Ticket-model.dart';

class ConversationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Créer ou récupérer une conversation pour un ticket
  Future<Conversation> getOrCreateConversation(Ticket ticket) async {
    try {
      if (ticket.idApprenant == null || ticket.idFormateur == null) {
        throw ArgumentError('L\'ID de l\'apprenant et du formateur sont requis');
      }

      DocumentReference<Map<String, dynamic>> ticketRef = _firestore.collection('tickets').doc(ticket.id);
      print('Référence du ticket: ${ticketRef.id}');

      QuerySnapshot<Map<String, dynamic>> convoSnapshot = await ticketRef.collection('conversations').get();
      print('Nombre de conversations trouvées: ${convoSnapshot.docs.length}');

      if (convoSnapshot.docs.isNotEmpty) {
        DocumentSnapshot<Map<String, dynamic>> firstConvoDoc = convoSnapshot.docs.first;
        print('Première conversation trouvée: ${firstConvoDoc.id}');
        return Conversation.fromMap(firstConvoDoc.id, firstConvoDoc.data()!);
      } else {
        DocumentReference<Map<String, dynamic>> convoRef = ticketRef.collection('conversations').doc();
        print('ID de la nouvelle conversation: ${convoRef.id}');

        Conversation newConversation = Conversation(
          id: convoRef.id,
          apprenantId: ticket.idApprenant!,
          formateurId: ticket.idFormateur!,
          ticketId: ticket.id!,
          lastMessage: 'Nouvelle conversation créée',
          lastMessageTimestamp: DateTime.now(),
          hasUnreadMessages: true,
        );
        print('Nouvelle conversation créée: ${newConversation.toMap()}');

        await convoRef.set(newConversation.toMap());
        print('Nouvelle conversation enregistrée dans Firestore');

        return newConversation;
      }
    } catch (e) {
      print('Erreur lors de la récupération ou création de la conversation: $e');
      throw e;
    }
  }

  // Créer ou mettre à jour une conversation
  Future<void> createOrUpdateConversation(Conversation conversation) async {
    try {
      DocumentReference<Map<String, dynamic>> convoRef = _firestore
          .collection('tickets')
          .doc(conversation.ticketId)
          .collection('conversations')
          .doc(conversation.id);

      print('Référence de la conversation à mettre à jour: ${convoRef.id}');
      print('Données de la conversation: ${conversation.toMap()}');

      await convoRef.set(conversation.toMap(), SetOptions(merge: true));
      print('Conversation ${conversation.id} mise à jour dans Firestore');

      DocumentSnapshot<Map<String, dynamic>> snapshot = await convoRef.get();
      if (snapshot.exists) {
        print('Conversation après mise à jour: ${snapshot.data()}');
      } else {
        print('Erreur: La conversation n\'a pas été trouvée après la mise à jour');
      }
    } catch (e) {
      print('Erreur lors de la création ou mise à jour de la conversation: $e');
      throw e;
    }
  }
  
  // Méthode pour obtenir toutes les conversations d'un utilisateur
  Stream<List<Conversation>> getConversations(String userId) async* {
  try {
    print('Recherche des conversations pour l\'utilisateur: $userId');

    // Requête pour récupérer les tickets où l'utilisateur est apprenant
    QuerySnapshot<Map<String, dynamic>> ticketSnapshot = await _firestore
        .collection('tickets')
        .where('idApprenant', isEqualTo: userId)
        .get();

    // Requête pour récupérer les tickets où l'utilisateur est formateur
    QuerySnapshot<Map<String, dynamic>> ticketSnapshotFormateur = await _firestore
        .collection('tickets')
        .where('idFormateur', isEqualTo: userId)
        .get();

    List<QueryDocumentSnapshot<Map<String, dynamic>>> allTickets = [
      ...ticketSnapshot.docs,
      ...ticketSnapshotFormateur.docs
    ];

    print('Tickets trouvés pour l\'utilisateur: ${allTickets.length}');

    List<Conversation> allConversations = [];

    // Rechercher les conversations pour chaque ticket
    for (var ticketDoc in allTickets) {
      String ticketId = ticketDoc.id;
      var convoSnapshot = await _firestore
          .collection('tickets')
          .doc(ticketId)
          .collection('conversations')
          .get();

      allConversations.addAll(convoSnapshot.docs.map((doc) {
        print('Conversation trouvée dans ticket $ticketId: ${doc.id}');
        return Conversation.fromMap(doc.id, doc.data()!);
      }).toList());
    }

    if (allConversations.isEmpty) {
      print('Aucune conversation trouvée pour l\'utilisateur: $userId');
    } else {
      print('Nombre total de conversations trouvées: ${allConversations.length}');
    }

    yield allConversations;
  } catch (e) {
    print('Erreur lors de la récupération des conversations: $e');
    throw e;
  }
}

}
