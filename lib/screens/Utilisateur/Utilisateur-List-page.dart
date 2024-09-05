import 'package:flutter/material.dart';
import 'package:eduticket/models/utilisateur.dart';
import 'package:eduticket/services/UtilisateurService.dart';
import 'package:eduticket/widgets/UtilisateurCard.dart'; 

class UtilisateurListPage extends StatefulWidget {
  @override
  _UtilisateurListPageState createState() => _UtilisateurListPageState();
}

class _UtilisateurListPageState extends State<UtilisateurListPage> {
  final UtilisateurService _utilisateurService = UtilisateurService();

  List<Utilisateur> _utilisateurs = [];

  @override
  void initState() {
    super.initState();
    _loadUtilisateurs();
  }

  Future<void> _loadUtilisateurs() async {
    try {
      final utilisateurs = await _utilisateurService.getUtilisateurs();
      setState(() {
        _utilisateurs = utilisateurs;
      });
    } catch (e) {
      print('Erreur lors du chargement des utilisateurs: $e');
    }
  }

  Future<void> _supprimerUtilisateur(String id) async {
    try {
      await _utilisateurService.supprimerUtilisateur(id);
      _loadUtilisateurs();
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
          return UtilisateurCard(
            utilisateur: utilisateur,
            onDelete: () => _supprimerUtilisateur(utilisateur.id),
          );
        },
      ),
    );
  }
}
