// lib/models/Ticket.dart
enum Statut { attente, enCours, resolu }
enum Categorie { technique, pedagogique }

class Ticket {
  String id;
  String titre;
  String description;
  String? reponse; // Champ réponse ajouté, rempli par le formateur après création
  Statut statut;
  Categorie categorie;
  DateTime dateCreation;
  DateTime? dateResolution;
  String idApprenant;
  String idFormateur;

  Ticket({
    required this.id,
    required this.titre,
    required this.description,
    this.reponse, // Optionnel car rempli plus tard par le formateur
    this.statut = Statut.attente, // Défini par défaut à "attente" lors de la création
    required this.categorie,
    required this.dateCreation,
    this.dateResolution,
    required this.idApprenant,
    required this.idFormateur,
  });
}
