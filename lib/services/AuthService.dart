import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eduticket/models/Utilisateur.dart';
import 'package:firebase_auth/firebase_auth.dart';


class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Méthode pour obtenir l'utilisateur actuellement connecté
  Future<Utilisateur?> getCurrentUser() async {
    User? user = _auth.currentUser;

    if (user != null) {
      DocumentSnapshot<Map<String, dynamic>> userData = await _firestore.collection('utilisateurs').doc(user.uid).get();
      if (userData.exists) {
        Utilisateur utilisateur = Utilisateur.fromMap(userData.data()!);
        print('Utilisateur récupéré: ${utilisateur.nom}, Rôle: ${utilisateur.role}');
        return utilisateur;
      }
    }
    print('Aucun utilisateur connecté ou données utilisateur non trouvées.');
    return null; // Aucun utilisateur connecté ou données utilisateur non trouvées
  }

  Future<String> getCurrentFormateurId() async {
  Utilisateur? utilisateur = await getCurrentUser();
  return utilisateur?.id ?? ''; // Retourne l'ID de l'utilisateur ou une chaîne vide si aucun utilisateur n'est connecté
}

  // Méthode pour enregistrer un nouvel utilisateur
  Future<Utilisateur?> registerWithEmailAndPassword(String id, String nom, String email, String motDePasse, Role role) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: motDePasse);
      User? user = result.user;

      if (user != null) {
        Utilisateur utilisateur = Utilisateur(
          id: id,
          nom: nom,
          email: email,
          motDePasse: motDePasse,
          role: role,
        );

        // Enregistrement des informations supplémentaires dans Firestore
        await _firestore.collection('utilisateurs').doc(user.uid).set(utilisateur.toMap());

        print('Inscription réussie pour l\'utilisateur: ${utilisateur.nom}');
        print('Rôle enregistré: ${utilisateur.role}');
        return utilisateur;
      } else {
        print('Erreur lors de la création de l\'utilisateur.');
        return null;
      }
    } catch (e) {
      print('Erreur lors de l\'inscription: $e');
      return null;
    }
  }

  // Méthode pour initialiser l'administrateur par défaut
  Future<void> initializeDefaultAdmin() async {
    try {
      print('Vérification de l\'existence de l\'administrateur par défaut');
      var usersCollection = _firestore.collection('utilisateurs');
      var querySnapshot = await usersCollection.where('role', isEqualTo: 'admin').get();

      if (querySnapshot.docs.isEmpty) {
        print('Aucun administrateur trouvé, création en cours...');
        await registerWithEmailAndPassword(
          '1', // ID par défaut
          'Admin', // Nom par défaut
          'admin@example.com', // Email par défaut
          'admin123', // Mot de passe par défaut
          Role.admin, // Rôle par défaut
        );
        print('Administrateur par défaut créé avec succès.');
      } else {
        print('Administrateur déjà existant.');
      }
    } catch (e) {
      print('Erreur lors de l\'initialisation de l\'administrateur par défaut: $e');
    }
  }

  // Méthode pour la connexion avec email et mot de passe
  Future<Utilisateur?> signInWithEmailAndPassword(String email, String motDePasse) async {
    try {
      UserCredential result = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: motDePasse);
      User? user = result.user;

      if (user != null) {
        // Récupérer les données utilisateur depuis Firestore
        DocumentSnapshot<Map<String, dynamic>> userData = await FirebaseFirestore.instance.collection('utilisateurs').doc(user.uid).get();

        if (userData.exists) {
          Utilisateur utilisateur = Utilisateur.fromMap(userData.data()!);
          print('Connexion réussie pour l\'utilisateur: ${utilisateur.nom}, Rôle: ${utilisateur.role}');
          return utilisateur;
        } else {
          print('Le document n\'existe pas pour cet utilisateur. Création d\'un nouveau document...');
          Utilisateur newUser = Utilisateur(
            id: user.uid,
            nom: "Nouveau Utilisateur",
            email: email,
            motDePasse: motDePasse,
            role: Role.apprenant, // Par défaut
          );
          await FirebaseFirestore.instance.collection('utilisateurs').doc(user.uid).set(newUser.toMap());
          print('Nouvel utilisateur créé: ${newUser.nom}, Rôle: ${newUser.role}');
          return newUser;
        }
      } else {
        print('Utilisateur non trouvé après la connexion.');
        return null;
      }
    } catch (e) {
      print('Erreur lors de la connexion: $e');
      return null;
    }
  }

  //Méthode pour se déconnecter
  Future<void> logout() async {
    try {
      await _auth.signOut();
      print('Utilisateur déconnecté avec succès.');
    } catch (e) {
      print('Erreur lors de la déconnexion: $e');
    }
  }
  
  
  
}
