import 'package:eduticket/models/Ticket-model.dart';
import 'package:flutter/material.dart';
import 'package:eduticket/services/TicketService.dart';

class TreatTicketPage extends StatefulWidget {
  final Ticket ticket;

  TreatTicketPage({required this.ticket});

  @override
  _TreatTicketPageState createState() => _TreatTicketPageState();
}

class _TreatTicketPageState extends State<TreatTicketPage> {
  final _formKey = GlobalKey<FormState>();
  final _reponseController = TextEditingController();
  DateTime? _dateResolution;

  @override
  void initState() {
    super.initState();
    // Initialiser le champ de réponse avec la valeur actuelle
    _reponseController.text = widget.ticket.reponse ?? '';
  }

  void _handleSubmit() async {
    if (_formKey.currentState?.validate() ?? false) {
      // Définir la date de résolution avec la date et l'heure actuelles
      _dateResolution = DateTime.now();

      Ticket updatedTicket = Ticket(
        id: widget.ticket.id,
        titre: widget.ticket.titre,
        description: widget.ticket.description,
        reponse: _reponseController.text,
        statut: Statut.resolu,
        categorie: widget.ticket.categorie,
        dateCreation: widget.ticket.dateCreation,
        dateResolution: _dateResolution, // Attribuer la date de résolution
        idApprenant: widget.ticket.idApprenant,
        idFormateur: widget.ticket.idFormateur,
      );

      try {
        await TicketService().updateTicket(updatedTicket);
        Navigator.pop(context); // Revenir à la liste des tickets
      } catch (e) {
        print('Erreur lors de la mise à jour du ticket: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Traiter le Ticket'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _reponseController,
                decoration: InputDecoration(labelText: 'Réponse'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer une réponse';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _handleSubmit,
                child: Text('Traiter le Ticket'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
