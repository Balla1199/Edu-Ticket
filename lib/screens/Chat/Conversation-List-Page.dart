import 'package:eduticket/models/Conversation.dart';
import 'package:eduticket/screens/Chat/Chat-Page.dart';
import 'package:eduticket/services/ConversationService.dart';
import 'package:flutter/material.dart';

class ConversationListPage extends StatelessWidget {
  final String userId; // ID de l'utilisateur actuel (le formateur ou l'apprenant)

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
      body: StreamBuilder<List<Conversation>>(
        stream: ConversationService().getConversations(userId),
        builder: (context, snapshot) {
          // Log pour vérifier l'état de la connexion
          print('État de la connexion: ${snapshot.connectionState}');
          
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          
          // Log pour vérifier s'il y a des données ou non
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            print('Aucune conversation trouvée.');
            return Center(child: Text('Aucune conversation trouvée.'));
          }

          final conversations = snapshot.data!;
          
          // Log des conversations récupérées
          print('Conversations récupérées: ${conversations.length} conversations trouvées.');

          return ListView.builder(
            itemCount: conversations.length,
            itemBuilder: (context, index) {
              final conversation = conversations[index];
              final otherUserId = conversation.formateurId == userId
                  ? conversation.apprenantId
                  : conversation.formateurId;

              // Log pour chaque conversation affichée
              print('Conversation avec l\'autre utilisateur: $otherUserId, dernier message: ${conversation.lastMessage}');

              return ListTile(
                leading: Icon(Icons.person),
                title: Text(otherUserId), // Ici, vous pouvez améliorer pour afficher le nom de l'utilisateur
                subtitle: Text(conversation.lastMessage),
                trailing: conversation.hasUnreadMessages
                    ? Icon(Icons.circle, color: Colors.red, size: 10)
                    : null,
                onTap: () {
                  // Log pour vérifier la navigation
                  print('Ouverture du chat pour la conversation: ${conversation.id}');
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
