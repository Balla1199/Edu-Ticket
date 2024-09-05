// lib/widgets/conversation_list_widget.dart
import 'package:eduticket/models/Conversation.dart';
import 'package:eduticket/models/Utilisateur.dart';
import 'package:eduticket/screens/Chat/Chat-Page.dart';
import 'package:eduticket/services/ConversationService.dart';
import 'package:eduticket/services/AuthService.dart';
import 'package:flutter/material.dart';

class ConversationListWidget extends StatelessWidget {
  final String userId;

  ConversationListWidget({required this.userId});

  Future<Utilisateur?> _getUserById(String userId) async {
    return await AuthService().getUserById(userId);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Conversation>>(
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

            return FutureBuilder<Utilisateur?>(
              future: _getUserById(otherUserId),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return ListTile(
                    leading: CircularProgressIndicator(),
                    title: Text('Chargement...'),
                    subtitle: Text(conversation.lastMessage),
                  );
                }

                if (!userSnapshot.hasData) {
                  return ListTile(
                    leading: Icon(Icons.error),
                    title: Text('Utilisateur inconnu'),
                    subtitle: Text(conversation.lastMessage),
                  );
                }

                final otherUser = userSnapshot.data!;

                return ListTile(
                  leading: Icon(Icons.person),
                  title: Text(otherUser.nom), // Affiche le nom de l'utilisateur
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
        );
      },
    );
  }
}
