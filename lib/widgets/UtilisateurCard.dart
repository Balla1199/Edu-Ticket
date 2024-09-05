import 'package:flutter/material.dart';
import 'package:eduticket/models/utilisateur.dart';

class UtilisateurCard extends StatelessWidget {
  final Utilisateur utilisateur;
  final VoidCallback onDelete;

  UtilisateurCard({required this.utilisateur, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
      elevation: 8,
      shadowColor: Colors.grey.withOpacity(0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(15.0), // Ajout d'un effet d'ondulation au clic
        onTap: () {
          // Optionnel : Ajouter une action lors du clic sur la carte
        },
        child: ListTile(
          contentPadding: EdgeInsets.all(20.0),
          leading: CircleAvatar(
            radius: 30.0,
            backgroundColor: Colors.blueAccent.withOpacity(0.2), // Fond de l'avatar
            child: Icon(Icons.person, color: Colors.blueAccent, size: 30), // Icône d'utilisateur
          ),
          title: Text(
            utilisateur.nom,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18.0,
              color: Colors.blueGrey[900], // Couleur du nom de l'utilisateur
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              utilisateur.email,
              style: TextStyle(
                fontSize: 15.0,
                color: Colors.blueGrey[600], // Couleur de l'email
              ),
            ),
          ),
          trailing: IconButton(
            icon: Icon(Icons.delete, color: Colors.redAccent), // Icône de suppression en rouge
            onPressed: onDelete, // Action lors de la suppression
            splashRadius: 24.0, // Rayon de l'animation au clic sur le bouton de suppression
          ),
        ),
      ),
    );
  }
}
