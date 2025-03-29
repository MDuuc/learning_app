import 'package:cloud_firestore/cloud_firestore.dart';

class QuestionModle {
  final String grade;
  final String question;
  final String answer;
  
  QuestionModle(this.grade, this.question, this.answer);

  Map<String, dynamic> toMap() {
    return {
      'grade': grade,
      'question': question,
      'answer': answer,
      'timestamp': FieldValue.serverTimestamp(), 
    };
  }
  
  factory QuestionModle.fromMap(Map<String, dynamic> data) {
    return QuestionModle(
      data['grade'] ?? '',          
      data['question'] ?? '',           
      data['answer'] ?? '',    
    );
  }
}
