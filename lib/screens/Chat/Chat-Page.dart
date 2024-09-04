import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eduticket/models/Conversation.dart';
import 'package:eduticket/models/Message.dart';

import 'package:eduticket/services/ConversationService.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  final Conversation conversation;
  final String currentUserId; // ID de l'utilisateur actuel (formateur)

  ChatPage({required this.conversation, required this.currentUserId});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final CollectionReference messagesCollection = FirebaseFirestore.instance.collection('messages');

  Future<void> _sendMessage() async {
  final text = _messageController.text.trim();
  if (text.isNotEmpty) {
    // Détermine l'ID du destinataire en fonction de l'ID du formateur connecté
    final receiverId = widget.conversation.formateurId == widget.currentUserId
        ? widget.conversation.apprenantId // Si le formateur est l'expéditeur, alors le destinataire est l'apprenant
        : widget.conversation.formateurId; // Sinon, c'est le formateur qui est le destinataire

    final ticketId = widget.conversation.ticketId; // Obtenez l'ID du ticket depuis la conversation

    final newMessage = Message(
      id: messagesCollection.doc().id,
      conversationId: widget.conversation.id,
      ticketId: ticketId, // Utiliser le ticketId fourni
      senderId: widget.currentUserId, // Le formateur est l'expéditeur
      receiverId: receiverId, // L'apprenant est le destinataire
      content: text,
      timestamp: DateTime.now(),
    );

    try {
      await messagesCollection.doc(newMessage.id).set(newMessage.toMap());
      
      // Mettre à jour la conversation avec le dernier message
      final updatedConversation = widget.conversation.copyWith(
        lastMessage: text,
        lastMessageTimestamp: DateTime.now(),
        hasUnreadMessages: true,
      );
      await ConversationService().createOrUpdateConversation(updatedConversation);
      
      _messageController.clear();
      print('Message envoyé : ${newMessage.content}');
    } catch (e) {
      print('Erreur lors de l\'envoi du message : $e');
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat avec ${widget.conversation.formateurId == widget.currentUserId ? widget.conversation.apprenantId : widget.conversation.formateurId}'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Message>>(
              stream: messagesCollection
                  .where('conversationId', isEqualTo: widget.conversation.id)
                  .orderBy('timestamp', descending: true)
                  .snapshots()
                  .map((snapshot) {
                    return snapshot.docs.map((doc) {
                      final message = Message.fromMap(doc.id, doc.data() as Map<String, dynamic>);
                      return message;
                    }).toList();
                  }),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  print('Erreur lors de la récupération des messages : ${snapshot.error}');
                  return Center(child: Text('Erreur : ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  print('Aucun message trouvé pour la conversation ${widget.conversation.id}');
                  return Center(child: Text('Aucun message'));
                }

                final messages = snapshot.data!.map((message) {
                  print('Message récupéré : ${message.content} de ${message.senderId}');
                  return ListTile(
                    title: Text(message.content),
                    subtitle: Text(message.senderId),
                    tileColor: message.senderId == widget.currentUserId ? Colors.blue[100] : Colors.grey[300],
                  );
                }).toList();

                return ListView(
                  reverse: true,
                  children: messages,
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Tapez votre message',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 8.0),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
