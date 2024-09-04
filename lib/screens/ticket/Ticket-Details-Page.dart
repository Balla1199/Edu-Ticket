import 'package:eduticket/models/Ticket-model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DetailTicketPage extends StatelessWidget {
  final Ticket ticket;

  DetailTicketPage({required this.ticket});

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date); // Formatage de la date sans l'heure
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Détails du Ticket'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4.0, // Ajoute une ombre pour donner un effet de relief à la carte
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0), // Bordures arrondies
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Description:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                SizedBox(height: 8),
                Text(ticket.description),
                SizedBox(height: 16),
                Text(
                  'Date de Création:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                SizedBox(height: 8),
                Text(_formatDate(ticket.dateCreation)),
                SizedBox(height: 16),
                Text(
                  'Réponse:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                SizedBox(height: 8),
                Text(ticket.reponse ?? 'Aucune réponse'),
                SizedBox(height: 16),
                Text(
                  'Date de Résolution:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                SizedBox(height: 8),
                Text(ticket.dateResolution != null
                    ? _formatDate(ticket.dateResolution!)
                    : 'Non résolu'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}