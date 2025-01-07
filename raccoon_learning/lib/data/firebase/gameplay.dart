import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:raccoon_learning/constants/assets/app_images.dart';

class Gameplay {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

// List Avatar default
  final List<String> _purchasedAvatars = [    
    AppImages.raccoon_notifi,
    AppImages.raccoon_grade_1,
    AppImages.raccoon_grade_2,
    AppImages.raccoon_grade_3,
  ];  

  Future<void> uploadStoreItemsToFirebase(String userId) async {     
      await _firestore.collection('gameplay').doc(userId).set({
        'user_id': userId,
        'store': storeItems.map((item) => {
          'image': item['image'],
          'price': item['price'],
          'purchase': item['purchase']
        }).toList(),
        'avatarPurchased': _purchasedAvatars,
      });
    } 
  }
