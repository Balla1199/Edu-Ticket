import 'package:eduticket/models/Conversation.dart';
import 'package:eduticket/screens/Chat/Chat-Page.dart';
import 'package:eduticket/services/ConversationService.dart';
import 'package:flutter/material.dart';

class ConversationListPage extends StatelessWidget {
  final String userId; // ID de l'utilisateur actuel (le formateur ou l'apprenant)

  ConversationListPage({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Conversations'),
      ),
      body: StreamBuilder<List<Conversation>>(
        stream: ConversationService().getConversations(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Aucune conversation trouvée.'));
          }
          final conversations = snapshot.data!;
          return ListView.builder(
            itemCount: conversations.length,
            itemBuilder: (context, index) {
              final conversation = conversations[index];
              final otherUserId = conversation.formateurId == userId
                  ? conversation.apprenantId
                  : conversation.formateurId;

              return ListTile(
                leading: Icon(Icons.person),
                title: Text(otherUserId),
                subtitle: Text(conversation.lastMessage),
                trailing: conversation.hasUnreadMessages
                    ? Icon(Icons.circle, color: Colors.red, size: 10)
                    : null,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatPage(
                        conversation: conversation,
                        currentUserId: userId, // Passe l'ID de l'utilisateur actuel
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
