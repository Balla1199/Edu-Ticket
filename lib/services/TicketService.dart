import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eduticket/models/Ticket-model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TicketService {
  final CollectionReference _ticketCollection = FirebaseFirestore.instance.collection('tickets');

  Future<void> ajouterTicket(Ticket ticket) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception('Utilisateur non authentifié');
      }

      DocumentReference docRef = await _ticketCollection.add({
        'titre': ticket.titre,
        'description': ticket.description,
        'statut': ticket.statut.toString().split('.').last,
        'categorie': ticket.categorie.toString().split('.').last,
        'dateCreation': ticket.dateCreation,
        'idApprenant': ticket.idApprenant,
        'idFormateur': ticket.idFormateur,
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
      QuerySnapshot snapshot;

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
        final data = doc.data() as Map<String, dynamic>;

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
          idFormateur: data['idFormateur'] ?? '',
        );
      }).toList();

      return tickets;
    } catch (e) {
      print('Erreur lors de la récupération des tickets: $e');
      return [];
    }
  }

  // Méthode pour mettre à jour un ticket
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
//Methode pour recuper les tickets Resolu
Future<List<Ticket>> getResolvedTickets() async {
  try {
    // Requête pour récupérer les tickets ayant le statut 'resolu'
    QuerySnapshot snapshot = await _ticketCollection
        .where('statut', isEqualTo: 'resolu')
        .get();

    // Conversion des documents en objets Ticket
    List<Ticket> tickets = snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;

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
        idFormateur: data['idFormateur'] ?? '',
      );
    }).toList();

    return tickets;
  } catch (e) {
    print('Erreur lors de la récupération des tickets résolus: $e');
    return [];
  }
}

  // Méthode pour convertir une chaîne en Statut
  Statut _parseStatut(String statutString) {
    return Statut.values.firstWhere(
      (e) => e.toString().split('.').last == statutString,
      orElse: () => Statut.attente, // Valeur par défaut
    );
  }

  // Méthode pour convertir une chaîne en Categorie
  Categorie _parseCategorie(String categorieString) {
    return Categorie.values.firstWhere(
      (e) => e.toString().split('.').last == categorieString,
      orElse: () => Categorie.technique, // Valeur par défaut
    );
  }
}
