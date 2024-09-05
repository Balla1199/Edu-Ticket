import 'package:eduticket/app-routes.dart';
import 'package:eduticket/models/Ticket-model.dart';
import 'package:eduticket/screens/ticket/Ticket-Details-Page.dart';
import 'package:eduticket/screens/ticket/Treat-Ticket-Page.dart';
import 'package:eduticket/services/ConversationService.dart';
import 'package:eduticket/services/TicketService.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TicketCard extends StatelessWidget {
  final Ticket ticket;
  final bool showPriseEnChargeButton;
  final bool showDetailsButton;
  final bool isFormateur;
  final String currentUserId; // Added parameter for currentUserId

  TicketCard({
    required this.ticket,
    required this.showPriseEnChargeButton,
    this.showDetailsButton = false,
    required this.isFormateur,
    required this.currentUserId, // Initialize the parameter
  });

  Color _getCardColor(Statut statut) {
    switch (statut) {
      case Statut.attente:
        return Color(0xFFE50B14);
      case Statut.enCours:
        return Color(0xFF2E78BC);
      case Statut.resolu:
        return Color(0x54000000);
      default:
        return Colors.white;
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }
Future<void> _openChat(BuildContext context) async {
  print('Tentative d\'ouverture du chat pour le ticket ${ticket.id}');

  try {
    // Récupérer l'utilisateur actuel
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      throw Exception('Utilisateur non authentifié');
    }

    // Mettre à jour le champ idFormateur du ticket avec l'ID de l'utilisateur authentifié
    ticket.idFormateur = currentUser.uid;
    await TicketService().updateTicket(ticket);

    final conversation = await ConversationService().getOrCreateConversation(ticket);

    // Log l'objet conversation obtenu pour vérifier qu'il est correct
    print('Conversation obtenue : ${conversation.id}');
    
    // Naviguer vers la page de chat
    Navigator.pushNamed(
      context,
      AppRoutes.chatPage,
      arguments: {
        'conversation': conversation,
        'currentUserId': currentUser.uid, // Pass currentUserId here
      },
    );

    print('Navigation vers ChatPage réussie.');
  } catch (e) {
    // Log les erreurs éventuelles pour aider au débogage
    print('Erreur lors de l\'ouverture du chat : $e');
  }
}



  @override
  Widget build(BuildContext context) {
    return Card(
      color: _getCardColor(ticket.statut),
      margin: EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              ticket.titre,
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              ticket.description,
              style: TextStyle(fontSize: 16.0, color: Colors.white70),
            ),
            SizedBox(height: 8.0),
            Text(
              'Catégorie: ${ticket.categorie}',
              style: TextStyle(fontSize: 14.0, color: Colors.white60),
            ),
            SizedBox(height: 8.0),
            Text(
              'Créé le ${_formatDate(ticket.dateCreation)}',
              style: TextStyle(fontSize: 14.0, color: Colors.white60),
            ),
            SizedBox(height: 12.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (showDetailsButton)
                  IconButton(
                    icon: Icon(Icons.info, color: Colors.white),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              DetailTicketPage(ticket: ticket),
                        ),
                      );
                    },
                  ),
                if (showPriseEnChargeButton && ticket.statut == Statut.attente)
                  ElevatedButton(
                    onPressed: () async {
                      ticket.statut = Statut.enCours;
                      try {
                        await TicketService().updateTicket(ticket);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TreatTicketPage(ticket: ticket),
                          ),
                        );
                      } catch (e) {
                        print('Erreur lors de la mise à jour du ticket: $e');
                      }
                    },
                    child: Text('Prise en Charge'),
                  ),
                if (isFormateur && ticket.statut == Statut.attente)
                  IconButton(
                    icon: Icon(Icons.chat, color: Colors.white),
                    onPressed: () {
                      print('Bouton de chat cliqué'); // Vérifiez que ceci s'affiche dans la console
                      _openChat(context);
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
