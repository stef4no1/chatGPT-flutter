import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  final String message;
  final bool isMe;

  const MessageBubble({Key? key, required this.message, required this.isMe})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(isMe ? 12.0 : 0.0),
              topRight: Radius.circular(isMe ? 0.0 : 12.0),
              bottomLeft: Radius.circular(12.0),
              bottomRight: Radius.circular(12.0),
            ),
            color: isMe ? Color(0xFFFFA500) : Colors.white,
            border: Border.all(
              color: Colors.purple[700]!,
              width: 1,
            ),
          ),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.7,
          ),
          padding: EdgeInsets.symmetric(
            vertical: 10.0,
            horizontal: 16.0,
          ),
          child: Wrap(
            children: [
              Text(
                message,
                style: TextStyle(
                  color: isMe ? Colors.white : Colors.black,
                  fontSize: 16.0,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}