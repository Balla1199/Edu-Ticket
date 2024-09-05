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
  String? idFormateur; // Champ optionnel

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
    this.idFormateur, // Optionnel lors de la création
  });

  // Méthode pour attribuer l'ID du formateur lorsque le formateur répond au ticket
  void assignerFormateur(String idFormateur) {
    this.idFormateur = idFormateur;
  }

  // Convert Ticket to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titre': titre,
      'description': description,
      'reponse': reponse,
      'statut': statut.toString().split('.').last, // Convert enum to string
      'categorie': categorie.toString().split('.').last, // Convert enum to string
      'dateCreation': dateCreation.toIso8601String(),
      'dateResolution': dateResolution?.toIso8601String(),
      'idApprenant': idApprenant,
      'idFormateur': idFormateur,
    };
  }

  // Create a Ticket object from a Map
  factory Ticket.fromMap(Map<String, dynamic> map) {
    return Ticket(
      id: map['id'],
      titre: map['titre'],
      description: map['description'],
      reponse: map['reponse'],
      statut: Statut.values.firstWhere((e) => e.toString().split('.').last == map['statut']),
      categorie: Categorie.values.firstWhere((e) => e.toString().split('.').last == map['categorie']),
      dateCreation: DateTime.parse(map['dateCreation']),
      dateResolution: map['dateResolution'] != null ? DateTime.parse(map['dateResolution']) : null,
      idApprenant: map['idApprenant'],
      idFormateur: map['idFormateur'],
    );
  }
}
