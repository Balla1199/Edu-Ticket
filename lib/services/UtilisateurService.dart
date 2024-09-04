import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:eduticket/models/utilisateur.dart';

class UtilisateurService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Méthode pour récupérer la liste des utilisateurs depuis Firestore
  Future<List<Utilisateur>> getUtilisateurs() async {
    try {
      print('Tentative de récupération des utilisateurs...');
      
      // Ajout d'un délai très court (10 millisecondes)
      await Future.delayed(Duration(milliseconds: 10));
      
      final snapshot = await _db.collection('utilisateurs').get();
      print('Récupération des utilisateurs réussie, traitement des données...');

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>?;

        if (data != null) {
          // Convertir la chaîne de caractères en valeur de l'enum Role
          Role role = _stringToRole(data['role'] as String? ?? 'apprenant');
          print('Nom récupéré depuis Firestore : ${data['nom']}');
          print('Données complètes récupérées : $data');

          return Utilisateur.fromMap({
            'id': doc.id, // Utiliser l'ID du document comme chaîne
            'nom': data['nom'] as String? ?? 'Nom Inconnu',
            'email': data['email'] as String? ?? 'email@example.com',
            'motDePasse': data['motDePasse'] as String? ?? '',
            'role': role,
          });
        } else {
          print('Avertissement: Données de l\'utilisateur null détectées pour le document ${doc.id}');
          return Utilisateur(
            id: doc.id, // Utiliser l'ID du document pour référence
            nom: 'Nom Inconnu',
            email: 'email@example.com',
            motDePasse: '',
            role: Role.apprenant,
          );
        }
      }).toList();
    } catch (e, stacktrace) {
      print('Erreur lors de la récupération des utilisateurs: $e');
      print('Détails de l\'erreur: $stacktrace');
      return [];
    }
  }

  // Méthode pour convertir une chaîne de caractères en valeur de l'enum Role
  Role _stringToRole(String roleString) {
    switch (roleString) {
      case 'administrateur':
        return Role.admin;
      case 'apprenant':
      default:
        return Role.apprenant;
    }
  }

  // Méthode pour ajouter un utilisateur dans Firestore après l'inscription
  Future<void> ajouterUtilisateurApresInscription(User user, String nom, String roleString) async {
    try {
      print('Vérification si l\'utilisateur existe déjà dans Firestore...');
      DocumentSnapshot doc = await _db.collection('utilisateurs').doc(user.uid).get();

      if (!doc.exists) {
        print('L\'utilisateur n\'existe pas dans Firestore, ajout de l\'utilisateur...');
        Role role = _stringToRole(roleString);

        Utilisateur newUser = Utilisateur(
          id: user.uid,
          nom: nom, // Utilisez le nom passé en paramètre ici
          email: user.email ?? 'email@example.com',
          motDePasse: '', // Le mot de passe ne devrait pas être stocké en clair
          role: role,
        );

        await _db.collection('utilisateurs').doc(user.uid).set(newUser.toMap());
        print('Utilisateur ajouté avec succès dans Firestore.');
      } else {
        print('L\'utilisateur existe déjà dans Firestore.');
      }
    } catch (e) {
      print('Erreur lors de l\'ajout de l\'utilisateur après l\'inscription: $e');
    }
  }

  // Méthode pour inscrire un utilisateur via Firebase Authentication et l'ajouter à Firestore
  Future<void> inscriptionUtilisateur(String email, String motDePasse, String nom, String roleString) async {
    try {
      print('Tentative d\'inscription de l\'utilisateur avec l\'email: $email');
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: motDePasse,
      );

      User? user = userCredential.user;
      if (user != null) {
        print('Inscription réussie pour l\'utilisateur avec l\'UID: ${user.uid}');
        
        // Mettre à jour le displayName de l'utilisateur dans Firebase Auth
        await user.updateProfile(displayName: nom);
        await user.reload();
        user = _auth.currentUser;

        print('Nom après la mise à jour du displayName : ${user?.displayName}');

        // Ajouter l'utilisateur dans Firestore après l'inscription
        await ajouterUtilisateurApresInscription(user!, user.displayName ?? 'Nom Inconnu', roleString);
      }
    } catch (e) {
      print('Erreur lors de l\'inscription de l\'utilisateur: $e');
    }
  }

  // Méthode pour supprimer un utilisateur depuis Firestore et Firebase Authentication
  Future<void> supprimerUtilisateur(String id) async {
    try {
      print('Tentative de suppression de l\'utilisateur avec l\'ID: $id...');
      
      // Supprimer l'utilisateur de Firestore
      await _db.collection('utilisateurs').doc(id).delete();
      print('Utilisateur supprimé de Firestore avec succès.');

      // Supprimer l'utilisateur de Firebase Authentication
      User? user = _auth.currentUser;
      if (user != null && user.uid == id) {
        await user.delete();
        print('Utilisateur supprimé de Firebase Authentication avec succès.');
      } else {
        print('L\'utilisateur actuel ne correspond pas à celui à supprimer ou est non connecté.');
      }
    } catch (e) {
      print('Erreur lors de la suppression de l\'utilisateur: $e');
    }
  }

  // Méthode pour modifier un utilisateur dans Firestore
  Future<void> modifierUtilisateur(Utilisateur utilisateur) async {
    try {
      print('Tentative de mise à jour de l\'utilisateur avec l\'ID: ${utilisateur.id}...');
      print('Nom utilisé pour la mise à jour : ${utilisateur.nom}');
      await _db.collection('utilisateurs').doc(utilisateur.id).update(utilisateur.toMap());
      print('Utilisateur mis à jour avec succès.');
    } catch (e) {
      print('Erreur lors de la mise à jour de l\'utilisateur: $e');
    }
  }
}
