import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eduticket/models/Ticket-model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TicketService {
  final CollectionReference<Map<String, dynamic>> _ticketCollection = FirebaseFirestore.instance.collection('tickets');

  Future<void> ajouterTicket(Ticket ticket) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception('Utilisateur non authentifié');
      }

      // Lors de l'ajout d'un ticket, l'idFormateur peut être nul au départ
      DocumentReference<Map<String, dynamic>> docRef = await _ticketCollection.add({
        'titre': ticket.titre,
        'description': ticket.description,
        'statut': ticket.statut.toString().split('.').last,
        'categorie': ticket.categorie.toString().split('.').last,
        'dateCreation': ticket.dateCreation,
        'idApprenant': ticket.idApprenant,
        'idFormateur': ticket.idFormateur, // Peut être nul
      });

      // Mise à jour de l'ID généré par Firestore
      await docRef.update({'id': docRef.id});
      print('Ticket ajouté avec ID: ${docRef.id}');
    } catch (e) {
      print('Erreur lors de l\'ajout du ticket: $e');
    }
  }

  Future<List<Ticket>> getTicketsByRole(String userId, String role) async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot;

      if (role == 'apprenant') {
        // L'apprenant ne voit que les tickets qu'il a créés
        snapshot = await _ticketCollection.where('idApprenant', isEqualTo: userId).get();
      } else if (role == 'formateur') {
        // Le formateur voit tous les tickets
        snapshot = await _ticketCollection.get();
      } else {
        return []; // Retourner une liste vide si le rôle n'est pas reconnu
      }

      List<Ticket> tickets = snapshot.docs.map((doc) {
        final data = doc.data();

        return Ticket(
          id: data['id'] ?? '',
          titre: data['titre'] ?? '',
          description: data['description'] ?? '',
          reponse: data.containsKey('reponse') ? data['reponse'] : null,
          statut: _parseStatut(data['statut'] ?? 'attente'),
          categorie: _parseCategorie(data['categorie'] ?? 'technique'),
          dateCreation: (data['dateCreation'] as Timestamp?)?.toDate() ?? DateTime.now(),
          dateResolution: data.containsKey('dateResolution') ? (data['dateResolution'] as Timestamp?)?.toDate() : null,
          idApprenant: data['idApprenant'] ?? '',
          idFormateur: data['idFormateur'], // Peut être nul
        );
      }).toList();

      return tickets;
    } catch (e) {
      print('Erreur lors de la récupération des tickets: $e');
      return [];
    }
  }

  Future<void> updateTicket(Ticket ticket) async {
  try {
    // Assurez-vous que l'ID du ticket est défini
    if (ticket.id.isEmpty) {
      throw Exception('L\'ID du ticket est vide');
    }

    await _ticketCollection.doc(ticket.id).update({
      'description': ticket.description,
      'statut': ticket.statut.toString().split('.').last,
      'reponse': ticket.reponse,
      'dateResolution': ticket.dateResolution,
      'idFormateur': ticket.idFormateur,
    });
    print('Ticket mis à jour avec ID: ${ticket.id}');
  } catch (e) {
    print('Erreur lors de la mise à jour du ticket: $e');
  }
}


  Future<List<Ticket>> getResolvedTickets() async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await _ticketCollection
          .where('statut', isEqualTo: 'resolu')
          .get();

      List<Ticket> tickets = snapshot.docs.map((doc) {
        final data = doc.data();

        return Ticket(
          id: data['id'] ?? '',
          titre: data['titre'] ?? '',
          description: data['description'] ?? '',
          reponse: data.containsKey('reponse') ? data['reponse'] : null,
          statut: Statut.resolu,
          categorie: _parseCategorie(data['categorie'] ?? 'technique'),
          dateCreation: (data['dateCreation'] as Timestamp?)?.toDate() ?? DateTime.now(),
          dateResolution: data.containsKey('dateResolution') ? (data['dateResolution'] as Timestamp?)?.toDate() : null,
          idApprenant: data['idApprenant'] ?? '',
          idFormateur: data['idFormateur'], // Peut être nul
        );
      }).toList();

      return tickets;
    } catch (e) {
      print('Erreur lors de la récupération des tickets résolus: $e');
      return [];
    }
  }

  Statut _parseStatut(String statutString) {
    return Statut.values.firstWhere(
      (e) => e.toString().split('.').last == statutString,
      orElse: () => Statut.attente, // Valeur par défaut
    );
  }

  Categorie _parseCategorie(String categorieString) {
    return Categorie.values.firstWhere(
      (e) => e.toString().split('.').last == categorieString,
      orElse: () => Categorie.technique, // Valeur par défaut
    );
  }

  Future<String> getApprenantIdFromTicket(String ticketId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> ticketDoc = await _ticketCollection.doc(ticketId).get();
      return ticketDoc.data()?['idApprenant'] ?? '';
    } catch (e) {
      print('Erreur lors de la récupération de l\'ID de l\'apprenant: $e');
      return '';
    }
  }
  // Méthode pour récupérer un ticket par son ID
Future<Ticket> getTicketById(String ticketId) async {
  try {
    DocumentSnapshot<Map<String, dynamic>> ticketDoc = await _ticketCollection.doc(ticketId).get();
    
    if (!ticketDoc.exists) {
      throw Exception('Ticket non trouvé');
    }

    final data = ticketDoc.data()!;

    return Ticket(
      id: data['id'] ?? '',
      titre: data['titre'] ?? '',
      description: data['description'] ?? '',
      reponse: data.containsKey('reponse') ? data['reponse'] : null,
      statut: _parseStatut(data['statut'] ?? 'attente'),
      categorie: _parseCategorie(data['categorie'] ?? 'technique'),
      dateCreation: (data['dateCreation'] as Timestamp?)?.toDate() ?? DateTime.now(),
      dateResolution: data.containsKey('dateResolution') ? (data['dateResolution'] as Timestamp?)?.toDate() : null,
      idApprenant: data['idApprenant'] ?? '',
      idFormateur: data['idFormateur'], // Peut être nul
    );
  } catch (e) {
    print('Erreur lors de la récupération du ticket par ID: $e');
    throw e;
  }
}

}
