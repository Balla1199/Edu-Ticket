import 'package:eduticket/models/Ticket-model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:eduticket/widgets/ticket_detail_section_widget.dart';

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
        title: Text('Détails du Ticket', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blueGrey[800],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 8.0, // Ombrage plus profond pour un effet plus marqué
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0), // Bordures arrondies plus douces
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TicketDetailSectionWidget(
                  title: 'Description:',
                  content: ticket.description,
                ),
                TicketDetailSectionWidget(
                  title: 'Date de Création:',
                  content: _formatDate(ticket.dateCreation),
                ),
                TicketDetailSectionWidget(
                  title: 'Réponse:',
                  content: ticket.reponse ?? 'Aucune réponse',
                ),
                TicketDetailSectionWidget(
                  title: 'Date de Résolution:',
                  content: ticket.dateResolution != null
                      ? _formatDate(ticket.dateResolution!)
                      : 'Non résolu',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
