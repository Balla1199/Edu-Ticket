import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:eduticket/models/Conversation.dart';
import 'package:eduticket/models/Message.dart';
import 'package:eduticket/services/ConversationService.dart';
import 'package:eduticket/widgets/MessageBubble.dart'; 

class ChatPage extends StatefulWidget {
  final Conversation conversation;
  final String currentUserId;

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
      final receiverId = widget.conversation.formateurId == widget.currentUserId
          ? widget.conversation.apprenantId
          : widget.conversation.formateurId;

      final ticketId = widget.conversation.ticketId;

      final newMessage = Message(
        id: messagesCollection.doc().id,
        conversationId: widget.conversation.id,
        ticketId: ticketId,
        senderId: widget.currentUserId,
        receiverId: receiverId,
        content: text,
        timestamp: DateTime.now(),
      );

      try {
        await messagesCollection.doc(newMessage.id).set(newMessage.toMap());

        final updatedConversation = widget.conversation.copyWith(
          lastMessage: text,
          lastMessageTimestamp: DateTime.now(),
          hasUnreadMessages: true,
        );
        await ConversationService().createOrUpdateConversation(updatedConversation);

        _messageController.clear();
      } catch (e) {
        print('Erreur lors de l\'envoi du message : $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Chat avec ${widget.conversation.formateurId == widget.currentUserId ? 'Apprenant' : 'Formateur'}',
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Message>>(
              stream: messagesCollection
                  .where('conversationId', isEqualTo: widget.conversation.id)
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
                  return Center(child: Text('Erreur : ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('Aucun message'));
                }

                final messages = snapshot.data!;
                messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message.senderId == widget.currentUserId;
                    return MessageBubble(message: message, isMe: isMe); // Appel du widget MessageBubble
                  },
                );
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Padding(
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
    );
  }
}
