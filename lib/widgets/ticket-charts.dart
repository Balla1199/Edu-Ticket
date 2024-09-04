import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:eduticket/models/Ticket-model.dart'; 
import 'package:eduticket/services/TicketService.dart';

class TicketCharts extends StatefulWidget {
  const TicketCharts({Key? key}) : super(key: key);

  @override
  _TicketChartsState createState() => _TicketChartsState();
}

class _TicketChartsState extends State<TicketCharts> {
  int _totalTickets = 0;
  Map<Statut, int> _statusCount = {};
  Map<Categorie, int> _categoryCount = {};

  @override
  void initState() {
    super.initState();
    _loadTicketData();
  }

  void _loadTicketData() async {
    try {
      List<Ticket> tickets = await TicketService().getTicketsByRole('someUserId', 'formateur');
      setState(() {
        _totalTickets = tickets.length;

        _statusCount = {
          Statut.attente: tickets.where((t) => t.statut == Statut.attente).length,
          Statut.enCours: tickets.where((t) => t.statut == Statut.enCours).length,
          Statut.resolu: tickets.where((t) => t.statut == Statut.resolu).length,
        };

        _categoryCount = {
          Categorie.technique: tickets.where((t) => t.categorie == Categorie.technique).length,
          Categorie.pedagogique: tickets.where((t) => t.categorie == Categorie.pedagogique).length,
        };
      });
    } catch (e) {
      print('Erreur lors du chargement des données des tickets: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Compteur de tickets
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            color: Colors.blueGrey[50],
            child: ListTile(
              leading: const Icon(
                Icons.confirmation_num,
                size: 50,
                color: Colors.deepPurple,
              ),
              title: const Text(
                'Total de Tickets',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              trailing: Text(
                '$_totalTickets',
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),

        // Diagramme circulaire
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: 180, // Limite la hauteur pour éviter le débordement
              maxWidth: double.infinity,
            ),
            child: PieChart(
              PieChartData(
                sections: _categoryCount.entries.map((entry) {
                  return PieChartSectionData(
                    color: _getColorForCategory(entry.key),
                    value: entry.value.toDouble(),
                    title: '${entry.value}',
                    radius: 90, // Ajusté pour éviter le débordement
                    titleStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  );
                }).toList(),
                borderData: FlBorderData(show: false),
                sectionsSpace: 0,
              ),
            ),
          ),
        ),
        
        // Graphique en barres
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: SizedBox(
            height: 180, // Hauteur du graphique en barres
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: _statusCount.values.isNotEmpty ? _statusCount.values.reduce((a, b) => a > b ? a : b).toDouble() : 0,
                titlesData: FlTitlesData(show: true),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(show: false),
                barGroups: _statusCount.entries.map((entry) {
                  int index = _statusCount.keys.toList().indexOf(entry.key);
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value.toDouble(),
                        color: _getColorForStatus(entry.key),
                        width: 20,
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Méthodes pour obtenir les couleurs pour les graphiques
  Color _getColorForStatus(Statut status) {
    switch (status) {
      case Statut.attente:
        return Colors.orange;
      case Statut.enCours:
        return Colors.blue;
      case Statut.resolu:
        return Colors.green;
    }
  }

  Color _getColorForCategory(Categorie category) {
    switch (category) {
      case Categorie.technique:
        return Colors.red;
      case Categorie.pedagogique:
        return Colors.yellow;
    }
  }
}
