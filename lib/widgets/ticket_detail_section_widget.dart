// lib/widgets/ticket_detail_section_widget.dart
import 'package:flutter/material.dart';

class TicketDetailSectionWidget extends StatelessWidget {
  final String title;
  final String content;

  TicketDetailSectionWidget({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.blueGrey[800],
          ),
        ),
        SizedBox(height: 8),
        Text(
          content,
          style: TextStyle(fontSize: 16, color: Colors.blueGrey[900]),
        ),
        SizedBox(height: 20), // Espace entre les sections
      ],
    );
  }
}
