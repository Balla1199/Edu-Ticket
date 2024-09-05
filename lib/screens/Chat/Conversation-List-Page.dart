// lib/screens/Chat/conversation_list_page.dart
import 'package:flutter/material.dart';
import 'package:eduticket/widgets/conversation_list_widget.dart';

class ConversationListPage extends StatelessWidget {
  final String userId;

  ConversationListPage({required this.userId}) {
    // Affichage de l'ID utilisateur pour débogage
    print('ID de l\'utilisateur dans ConversationListPage (constructeur): $userId');
  }

  @override
  Widget build(BuildContext context) {
    // Affichage de l'ID utilisateur pour débogage
    print('ID de l\'utilisateur dans ConversationListPage (build): $userId');

    return Scaffold(
      appBar: AppBar(
        title: Text('Conversations'),
      ),
      body: ConversationListWidget(userId: userId), // Utilisation du nouveau widget
    );
  }
}
