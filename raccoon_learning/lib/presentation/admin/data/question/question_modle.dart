import 'package:cloud_firestore/cloud_firestore.dart';

class QuestionModle {
  final String id; 
  final String grade; 
  final String question;
  final String answer; 

  QuestionModle(this.id, this.grade, this.question, this.answer);

  // Convert the object to a map for Firestore storage
  Map<String, dynamic> toMap() {
    return {
      'grade': grade,
      'question': question,
      'answer': answer,
      'timestamp': FieldValue.serverTimestamp(), // Automatically set server timestamp
    };
  }

  // Create an instance from Firestore data, including the document ID
  factory QuestionModle.fromMap(Map<String, dynamic> data, String id) {
    return QuestionModle(
      id,
      data['grade'] ?? '',
      data['question'] ?? '',
      data['answer'] ?? '',
    );
  }
}