import 'package:eduticket/widgets/ticket-charts.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Page d\'Accueil'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TicketCharts(), // Inclure le widget TicketCharts
      ),
    );
  }
}
