import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; 
import 'package:eduticket/models/Message.dart'; 

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isMe;

  MessageBubble({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
        padding: EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: isMe ? Colors.blue[100] : Colors.grey[300],
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12.0),
            topRight: Radius.circular(12.0),
            bottomLeft: isMe ? Radius.circular(12.0) : Radius.circular(0),
            bottomRight: isMe ? Radius.circular(0) : Radius.circular(12.0),
          ),
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              message.content,
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 5.0),
            Text(
              DateFormat('HH:mm').format(message.timestamp),
              style: TextStyle(fontSize: 12.0, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
