import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:raccoon_learning/presentation/admin/data/question/question_modle.dart';

class QuestionRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Upload a new question to Firestore and automatically generate a document ID
  Future<void> uploadQuestionToFirebase(QuestionModle questionModel) async {
    try {
      await _firestore
          .collection('questions')
          .doc(questionModel.grade.toLowerCase().replaceAll(' ', ''))
          .collection('items')
          .add(questionModel.toMap()); // Use 'add' to auto-generate ID
    } catch (e) {
      print('Error uploading question: $e');
      rethrow;
    }
  }

  // Fetch all questions for a specific grade
  Future<List<QuestionModle>> getQuestionsByGrade(String grade) async {
    final snapshot = await _firestore
        .collection('questions')
        .doc(grade.toLowerCase().replaceAll(' ', ''))
        .collection('items')
        .get();

    // Map the documents to QuestionModle instances, including their IDs
    return snapshot.docs
        .map((doc) => QuestionModle.fromMap(doc.data(), doc.id))
        .toList();
  }

  // Update an existing question using its document ID
  Future<void> updateQuestion(QuestionModle question) async {
    try {
      await _firestore
          .collection('questions')
          .doc(question.grade.toLowerCase().replaceAll(' ', ''))
          .collection('items')
          .doc(question.id)
          .update({
        'question': question.question,
        'answer': question.answer,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating question: $e');
      rethrow;
    }
  }

  // Delete a question using its document ID
  Future<void> deleteQuestion(QuestionModle question) async {
    try {
      await _firestore
          .collection('questions')
          .doc(question.grade.toLowerCase().replaceAll(' ', ''))
          .collection('items')
          .doc(question.id)
          .delete();
    } catch (e) {
      print('Error deleting question: $e');
      rethrow;
    }
  }
}