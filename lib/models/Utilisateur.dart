enum Role {
  admin,
  formateur,
  apprenant,
}
class Utilisateur {
  String id;
  String nom;
  String email;
  String motDePasse;
  Role role;

  Utilisateur({
    required this.id,
    required this.nom,
    required this.email,
    required this.motDePasse,
    required this.role,
  });

  // Convertir l'utilisateur en Map pour le stockage, en convertissant le Role en String
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nom': nom,
      'email': email,
      'motDePasse': motDePasse,
      'role': role.toString().split('.').last, // Convertit Role en String
    };
  }

  // Créer un utilisateur à partir d'une Map, en convertissant le String en Role
  factory Utilisateur.fromMap(Map<String, dynamic> map) {
    String roleString = map['role']?.toString() ?? 'apprenant'; // Prendre le rôle sous forme de chaîne ou 'apprenant' par défaut
    Role roleEnum;

    // Essayer de convertir la chaîne en Role, si non valide, utiliser apprenant comme valeur par défaut
    try {
      roleEnum = Role.values.firstWhere(
        (e) => e.toString().split('.').last == roleString,
        orElse: () => Role.apprenant,
      );
    } catch (e) {
      print('Erreur lors de la conversion du rôle: $e');
      roleEnum = Role.apprenant;
    }

    return Utilisateur(
      id: map['id']?.toString() ?? '0',
      nom: map['nom'] as String? ?? 'Nom Inconnu',
      email: map['email'] as String? ?? 'email@example.com',
      motDePasse: map['motDePasse'] as String? ?? '',
      role: roleEnum,
    );
  }
}
