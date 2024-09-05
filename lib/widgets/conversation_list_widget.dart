// lib/widgets/conversation_list_widget.dart
import 'package:eduticket/models/Conversation.dart';
import 'package:eduticket/models/Utilisateur.dart';
import 'package:eduticket/screens/Chat/Chat-Page.dart';
import 'package:eduticket/services/ConversationService.dart';
import 'package:eduticket/services/AuthService.dart';
import 'package:flutter/material.dart';

class ConversationListWidget extends StatelessWidget {
  final String userId;

  const ConversationListWidget({Key? key, required this.userId}) : super(key: key);

  Future<Utilisateur?> _getUserById(String userId) async {
    return await AuthService().getUserById(userId);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Conversation>>(
      stream: ConversationService().getConversations(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text(
              'Aucune conversation trouvée.',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          );
        }

        final conversations = snapshot.data!;

        return ListView.builder(
          padding: EdgeInsets.all(8.0),
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
                    contentPadding: EdgeInsets.symmetric(vertical: 8.0),
                    leading: CircularProgressIndicator(),
                    title: Text(
                      'Chargement...',
                      style: TextStyle(fontSize: 16),
                    ),
                    subtitle: Text(conversation.lastMessage),
                  );
                }

                if (!userSnapshot.hasData) {
                  return ListTile(
                    contentPadding: EdgeInsets.symmetric(vertical: 8.0),
                    leading: Icon(Icons.error, color: Colors.red),
                    title: Text(
                      'Utilisateur inconnu',
                      style: TextStyle(fontSize: 16),
                    ),
                    subtitle: Text(conversation.lastMessage),
                  );
                }

                final otherUser = userSnapshot.data!;

                return ListTile(
                  contentPadding: EdgeInsets.symmetric(vertical: 8.0),
                  leading: CircleAvatar(
                    backgroundImage: AssetImage('images/user.png'),
                    radius: 24,
                  ),
                  title: Text(
                    otherUser.nom,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    conversation.lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  trailing: conversation.hasUnreadMessages
                      ? Icon(
                          Icons.circle,
                          color: Colors.red,
                          size: 10,
                        )
                      : null,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatPage(
                          conversation: conversation,
                          currentUserId: userId,
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
