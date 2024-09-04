import 'package:eduticket/services/UtilisateurService.dart';
import 'package:flutter/material.dart';
import 'package:eduticket/models/utilisateur.dart';
class UtilisateurListPage extends StatefulWidget {
  @override
  _UtilisateurListPageState createState() => _UtilisateurListPageState();
}

class _UtilisateurListPageState extends State<UtilisateurListPage> {
  final UtilisateurService _utilisateurService = UtilisateurService(); // Création de l'instance de UtilisateurService

  List<Utilisateur> _utilisateurs = [];

  @override
  void initState() {
    super.initState();
    _loadUtilisateurs(); // Charger les utilisateurs lors de l'initialisation
  }

  // Méthode pour charger la liste des utilisateurs depuis Firestore
  Future<void> _loadUtilisateurs() async {
    try {
      final utilisateurs = await _utilisateurService.getUtilisateurs(); // Utiliser l'instance pour appeler la méthode
      setState(() {
        _utilisateurs = utilisateurs;
      });
    } catch (e) {
      print('Erreur lors du chargement des utilisateurs: $e');
    }
  }

  // Méthode pour supprimer un utilisateur
  Future<void> _supprimerUtilisateur(String id) async {
    try {
      await _utilisateurService.supprimerUtilisateur(id); // Utiliser l'instance pour appeler la méthode
      _loadUtilisateurs(); // Recharge la liste après suppression
    } catch (e) {
      print('Erreur lors de la suppression de l\'utilisateur: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Liste des utilisateurs'),
      ),
      body: ListView.builder(
        itemCount: _utilisateurs.length,
        itemBuilder: (context, index) {
          final utilisateur = _utilisateurs[index];
          return ListTile(
            title: Text(utilisateur.nom),
            subtitle: Text(utilisateur.email),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () => _supprimerUtilisateur(utilisateur.id),
            ),
          );
        },
      ),
    );
  }
}
