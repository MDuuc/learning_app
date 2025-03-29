import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:raccoon_learning/presentation/admin/data/question/question_modle.dart';

class QuestionRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
Future<void> uploadQuestionToFirebase(QuestionModle questionModel) async {     
  try {
    await _firestore
        .collection('questions') 
        .doc(questionModel.grade.toLowerCase().replaceAll(' ', ''))  
        .collection('items')  
        .doc()  
        .set(questionModel.toMap());
  } catch (e) {
    print('Error uploading question: $e');
    rethrow; 
  }
}

Future<List<QuestionModle>> getQuestionsByGrade(String grade) async {
  final snapshot = await _firestore
      .collection('questions')
      .doc(grade.toLowerCase().replaceAll(' ', ''))
      .collection('items')
      .get();
  
  return snapshot.docs.map((doc) => QuestionModle.fromMap(doc.data())).toList();
}
}