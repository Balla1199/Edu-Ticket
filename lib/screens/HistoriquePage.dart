import 'package:eduticket/models/Utilisateur.dart';
import 'package:flutter/material.dart';
import 'package:eduticket/models/Ticket-model.dart';
import 'package:eduticket/services/TicketService.dart';
import 'package:eduticket/services/AuthService.dart'; // Importer AuthService
import 'package:eduticket/widgets/TicketCard.dart';

class HistoriquePage extends StatefulWidget {
  @override
  _HistoriquePageState createState() => _HistoriquePageState();
}

class _HistoriquePageState extends State<HistoriquePage> {
  List<Ticket> _resolvedTickets = [];
  String? currentUserId; // ID de l'utilisateur actuel

  @override
  void initState() {
    super.initState();
    _loadCurrentUser(); // Charger l'utilisateur actuel
    _loadResolvedTickets();
  }

  // Méthode pour charger l'utilisateur actuel
  void _loadCurrentUser() async {
    Utilisateur? utilisateur = await AuthService().getCurrentUser();
    setState(() {
      currentUserId = utilisateur?.id; // Assigner l'ID utilisateur si disponible
    });
  }

  void _loadResolvedTickets() async {
    try {
      // Appel à la méthode getResolvedTickets pour récupérer uniquement les tickets résolus
      List<Ticket> tickets = await TicketService().getResolvedTickets();
      setState(() {
        _resolvedTickets = tickets;
      });
    } catch (e) {
      print('Erreur lors du chargement des tickets résolus: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Historique des Tickets Résolus'),
      ),
      body: _resolvedTickets.isEmpty
          ? Center(child: Text('Aucun ticket résolu trouvé.'))
          : ListView.builder(
              itemCount: _resolvedTickets.length,
              itemBuilder: (context, index) {
                Ticket ticket = _resolvedTickets[index];
                return TicketCard(
                  ticket: ticket,
                  showPriseEnChargeButton: false, // Désactiver le bouton "Prise en charge"
                  showDetailsButton: true, // Afficher le bouton "Détails"
                  isFormateur: false, // Ajouter le paramètre isFormateur
                  currentUserId: currentUserId ?? '', // Passer l'ID utilisateur ou une chaîne vide
                );
              },
            ),
    );
  }
}
