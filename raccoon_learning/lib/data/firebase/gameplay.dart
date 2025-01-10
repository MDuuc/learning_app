import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:raccoon_learning/constants/assets/app_images.dart';

class Gameplay {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final int coin = 1000; //that should be 0 in the future
  final int bestScore = 0;

  // Store items
  final List<Map<String, dynamic>> storeItems = [
    {"image": AppImages.raccoon_store_1, "price": 80, "purchase" : false},
    {"image": AppImages.raccoon_store_2, "price": 120, "purchase" : false},
    {"image": AppImages.raccoon_store_3, "price": 100, "purchase" : false},
    {"image": AppImages.raccoon_store_4, "price": 70, "purchase" : false},
    {"image": AppImages.raccoon_store_5, "price": 80, "purchase" : false},
    {"image": AppImages.raccoon_store_6, "price": 120, "purchase" : false},
    {"image": AppImages.raccoon_store_7, "price": 100, "purchase" : false},
    {"image": AppImages.raccoon_store_8, "price": 70, "purchase" : false},
    {"image": AppImages.raccoon_store_9, "price": 70, "purchase" : false},
    {"image": AppImages.raccoon_store_10, "price": 70, "purchase" : false},
  ];

  final List<Map<String, dynamic>> achivementLearning = [
    {"description": "The best score is ", "score": 10, "coin": 10, "isClaimed" : false},
    {"description": "The best score is ", "score": 20, "coin": 20, "isClaimed" : false},
    {"description": "The best score is ", "score": 30, "coin": 30, "isClaimed" : false},
    {"description": "The best score is ", "score": 40, "coin": 40, "isClaimed" : false},
    {"description": "The best score is ", "score": 50, "coin": 50, "isClaimed" : false},
    {"description": "The best score is ", "score": 60, "coin": 60, "isClaimed" : false},
    {"description": "The best score is ", "score": 70, "coin": 70, "isClaimed" : false},
    {"description": "The best score is ", "score": 80, "coin": 80, "isClaimed" : false},
    {"description": "The best score is ", "score": 90, "coin": 90, "isClaimed" : false},
    {"description": "The best score is ", "score": 100, "coin": 100, "isClaimed" : false},
  ];


// List Avatar default
  final List<String> _purchasedAvatars = [    
    AppImages.raccoon_notifi,
    AppImages.raccoon_grade_1,
    AppImages.raccoon_grade_2,
    AppImages.raccoon_grade_3,
  ];  

  Future<void> uploadDataToFirebase(String userId) async {     
      await _firestore.collection('gameplay').doc(userId).set({
        'user_id': userId,
        'best_score': bestScore,
        'coin': coin,
        'store': storeItems.map((item) => {
          'image': item['image'],
          'price': item['price'],
          'purchase': item['purchase']
        }).toList(),
        'achivement_learning': achivementLearning.map((item) => {
          'description': item['description'],
          'score': item['score'],
          'coin': item['coin'],
          'isClaimed': item['isClaimed']
        }).toList(),
        'avatarPurchased': _purchasedAvatars,
      });
    } 
  }
