import 'package:eduticket/models/Ticket-model.dart';
import 'package:eduticket/models/Utilisateur.dart';
import 'package:flutter/material.dart';
import 'package:eduticket/services/AuthService.dart';
import 'package:eduticket/services/TicketService.dart';
import 'package:eduticket/widgets/TicketCard.dart';

import 'package:eduticket/screens/ticket/Ticket-Form-Page.dart';

class TicketListPage extends StatefulWidget {
  @override
  _TicketListPageState createState() => _TicketListPageState();
}

class _TicketListPageState extends State<TicketListPage> {
  List<Ticket> tickets = [];
  Utilisateur? currentUser;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    try {
      currentUser = await AuthService().getCurrentUser();

      if (currentUser != null) {
        await _loadTickets();
      } else {
        print('No current user found.');
      }
    } catch (e) {
      print('Error loading current user: $e');
    }
  }

  Future<void> _loadTickets() async {
    if (currentUser == null) return;

    try {
      String role = currentUser!.role.toString().split('.').last;
      List<Ticket> allTickets = await TicketService().getTicketsByRole(
        currentUser!.id,
        role,
      );

      setState(() {
        if (currentUser?.role == Role.formateur) {
          // Filtrer les tickets pour n'inclure que ceux en attente ou en cours
          tickets = allTickets.where((ticket) => 
            ticket.statut == Statut.attente || ticket.statut == Statut.enCours
          ).toList();
        } else {
          tickets = allTickets;
        }
      });
    } catch (e) {
      print('Error loading tickets: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Liste des Tickets'),
      ),
      body: tickets.isEmpty
          ? Center(child: Text('Aucun ticket disponible'))
          : ListView.builder(
              itemCount: tickets.length,
              itemBuilder: (context, index) {
                return TicketCard(
                  ticket: tickets[index],
                  showPriseEnChargeButton: currentUser?.role == Role.formateur &&
                                          tickets[index].statut == Statut.attente,
                  showDetailsButton: tickets[index].dateResolution != null,
                  isFormateur: currentUser?.role == Role.formateur, currentUserId: '', // Passer le rôle de l'utilisateur
                );
              },
            ),
      floatingActionButton: currentUser?.role == Role.apprenant
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TicketFormPage()),
                );
              },
              child: Icon(Icons.add),
              tooltip: 'Ajouter un Ticket',
            )
          : null,
    );
  }
}
