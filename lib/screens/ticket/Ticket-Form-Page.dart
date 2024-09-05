import 'package:eduticket/models/Ticket-model.dart';
import 'package:eduticket/widgets/TicketForm.dart';
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

      Ticket newTicket = Ticket(
        id: '', // ID généré lors de l'ajout à la base de données
        titre: _titre,
        description: _description,
        statut: Statut.attente,
        categorie: _categorie,
        dateCreation: DateTime.now(),
        idApprenant: userId,
        idFormateur: '',
      );

      await TicketService().ajouterTicket(newTicket);

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
        child: TicketForm(
          formKey: _formKey,
          initialTitre: _titre,
          initialDescription: _description,
          initialCategorie: _categorie,
          onTitreChanged: (titre) => _titre = titre,
          onDescriptionChanged: (description) => _description = description,
          onCategorieChanged: (categorie) => _categorie = categorie,
          onSubmit: _submitForm,
        ),
      ),
    );
  }
}
