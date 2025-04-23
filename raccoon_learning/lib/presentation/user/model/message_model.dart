import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String username;
  final String message;

  Message({
    required this.username,
    required this.message,
  });

  factory Message.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Message(
      username: data['username'] ?? '',
      message: data['message'] ?? '',
    );
  }
}