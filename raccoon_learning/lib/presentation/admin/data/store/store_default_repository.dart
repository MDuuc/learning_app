import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:raccoon_learning/presentation/admin/data/store/store_default_modle.dart';

class StoreDefaultRepository{
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
Future<void> uploadQuestionToFirebase(StoreDefaultModle storeDefaultModle) async {     
  try {
    await _firestore
        .collection('store_default') 
        .doc()  
        .set(storeDefaultModle.toMap());
  } catch (e) {
    print('Error uploading question: $e');
    rethrow; 
  }
}

Future<List<StoreDefaultModle>> getStoreDefault() async {
  final snapshot = await _firestore
      .collection('store_default')
      .get();
  return snapshot.docs.map((doc) => StoreDefaultModle.fromMap(doc.data())).toList();
}


}