// lib/screens/formpage.dart
import 'package:eduticket/models/Ticket-model.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:eduticket/services/TicketService.dart';

class TicketFormPage extends StatefulWidget {
  @override
  _TicketFormPageState createState() => _TicketFormPageState();
}

class _TicketFormPageState extends State<TicketFormPage> {
  final _formKey = GlobalKey<FormState>();
  String _titre = '';
  String _description = '';
  Categorie _categorie = Categorie.technique;

  void _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      String userId = FirebaseAuth.instance.currentUser?.uid ?? '';

      // Créer un nouvel objet Ticket
      Ticket newTicket = Ticket(
        id: '', // ID généré lors de l'ajout à la base de données
        titre: _titre,
        description: _description,
        statut: Statut.attente, // Statut par défaut
        categorie: _categorie,
        dateCreation: DateTime.now(), // Date de création actuelle
        idApprenant: userId,
        idFormateur: '', // Peut être mis à jour plus tard
      );

      // Ajouter le ticket dans votre base de données
      await TicketService().ajouterTicket(newTicket);

      // Retourner à la liste des tickets après l'ajout
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Créer un Ticket'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(labelText: 'Titre'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un titre';
                  }
                  return null;
                },
                onSaved: (value) {
                  _titre = value ?? '';
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Description'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer une description';
                  }
                  return null;
                },
                onSaved: (value) {
                  _description = value ?? '';
                },
              ),
              DropdownButtonFormField<Categorie>(
                value: _categorie,
                decoration: InputDecoration(labelText: 'Catégorie'),
                items: Categorie.values.map((categorie) {
                  return DropdownMenuItem(
                    value: categorie,
                    child: Text(categorie.toString().split('.').last),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _categorie = value ?? Categorie.technique;
                  });
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('Créer Ticket'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
