import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:raccoon_learning/constants/assets/app_images.dart';
import 'package:raccoon_learning/presentation/user/model/store_modle.dart';

class Gameplay {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final int coin = 1000; // Initial coin value, should be 0 in the future
  final int bestScore = 0; // Initial best score
  StreamSubscription? _storeSubscription; // Subscription to listen for store updates

  // List to hold store items locally
  List<StoreModle> storeItems = [];

  // Achievement list with description, score, coin reward, and claim status
  final List<Map<String, dynamic>> achivementLearning = [
    {"description": "The best score is ", "score": 10, "coin": 10, "isClaimed": false},
    {"description": "The best score is ", "score": 20, "coin": 20, "isClaimed": false},
    {"description": "The best score is ", "score": 30, "coin": 30, "isClaimed": false},
    {"description": "The best score is ", "score": 40, "coin": 40, "isClaimed": false},
    {"description": "The best score is ", "score": 50, "coin": 50, "isClaimed": false},
    {"description": "The best score is ", "score": 60, "coin": 60, "isClaimed": false},
    {"description": "The best score is ", "score": 70, "coin": 70, "isClaimed": false},
    {"description": "The best score is ", "score": 80, "coin": 80, "isClaimed": false},
    {"description": "The best score is ", "score": 90, "coin": 90, "isClaimed": false},
    {"description": "The best score is ", "score": 100, "coin": 100, "isClaimed": false},
  ];

  // String urlSupabass= "https://wgwzbsfxetgyropkgmkq.supabase.co/storage/v1/object/public/image//";   try but error somehow

  // Default purchased avatars
final List<String> _purchasedAvatars = [
  'https://wgwzbsfxetgyropkgmkq.supabase.co/storage/v1/object/public/image//raccoon_grade_1.jpg', 
  'https://wgwzbsfxetgyropkgmkq.supabase.co/storage/v1/object/public/image//raccoon_grade_2.jpg', 
  'https://wgwzbsfxetgyropkgmkq.supabase.co/storage/v1/object/public/image//raccoon_grade_3.jpg', 
  'https://wgwzbsfxetgyropkgmkq.supabase.co/storage/v1/object/public/image//raccoon_notifi.jpg',  
];

// Method to fetch initial store items from Firestore
Future<void> fetchStoreItemsFromFirebase() async {
  try {
    QuerySnapshot<Map<String, dynamic>> snapshot =
        await _firestore.collection('store_default').get();

    storeItems.clear();
    for (var doc in snapshot.docs) {
      if (doc.exists && doc.data() != null) {
        // Create a StoreModle directly from the document data
        Map<String, dynamic> storeItemData = {
          'image': doc.data()['avatarurl'] ?? '',
          'price': doc.data()['price'] ?? 0,
          'purchase': false, 
        };
        storeItems.add(StoreModle.fromMap(storeItemData));
      }
    }
    print('Fetched store items from Firestore: ${storeItems.length}');
  } catch (e) {
    print('Error fetching store items: $e');
  }
}

  // Method to upload initial user data to Firestore when creating a new account
  Future<void> uploadDataToFirebase(String userId) async {
    await fetchStoreItemsFromFirebase(); // Fetch initial store items
    await _firestore.collection('gameplay').doc(userId).set({
      'user_id': userId,
      'best_score': bestScore,
      'coin': coin,
      'store': storeItems.map((item) => item.toMap()..['purchase'] = false).toList(), // Set all items as unpurchased initially
      'achivement_learning': achivementLearning.map((item) => {
        'description': item['description'],
        'score': item['score'],
        'coin': item['coin'],
        'isClaimed': item['isClaimed']
      }).toList(),
      'avatarPurchased': _purchasedAvatars,
    }, SetOptions(merge: false)); // Overwrite data only on initial creation
    print('Initial data uploaded for user $userId');
  }

// Method to listen for updates in store_default and sync new items to user data
void listenToAllStoreUpdates(String userId) {
  _storeSubscription = _firestore.collection('store_default').snapshots().listen(
    (snapshot) async {
      List<StoreModle> newStoreItems = [];
      // Extract store items directly from each document
      for (var doc in snapshot.docs) {
        if (doc.exists && doc.data() != null) {
          // Create a StoreModle directly from the document data
          Map<String, dynamic> storeItemData = {
            'image': doc.data()['avatarurl'] ?? '',
            'price': doc.data()['price'] ?? 0,
            'purchase': false, // Default value for purchase
          };
          newStoreItems.add(StoreModle.fromMap(storeItemData));
        }
      }

      // Fetch current user data from Firestore
      DocumentSnapshot userDoc = await _firestore.collection('gameplay').doc(userId).get();
      if (!userDoc.exists) return;

      List<dynamic> currentStore = userDoc.get('store') ?? [];
      List<StoreModle> currentStoreItems = currentStore.map((item) => StoreModle.fromMap(item)).toList();

      // Identify new items by comparing image (assuming image is unique)
      List<Map<String, dynamic>> itemsToAdd = [];
      for (var newItem in newStoreItems) {
        bool exists = currentStoreItems.any((currentItem) => currentItem.image == newItem.image);
        if (!exists) {
          itemsToAdd.add(newItem.toMap()..['purchase'] = false); // Add new item with purchase = false
        }
      }

      // Update user data with new items if any
      if (itemsToAdd.isNotEmpty) {
        await _firestore.collection('gameplay').doc(userId).update({
          'store': FieldValue.arrayUnion(itemsToAdd), // Add only new items without overwriting
        });
        print('Added ${itemsToAdd.length} new store items for user $userId');
      }
    },
    onError: (error) {
      print('Error listening to store updates: $error');
    },
  );
}

  // Method to clean up resources when the object is no longer needed
  void dispose() {
    _storeSubscription?.cancel(); // Cancel the subscription to avoid memory leaks
    print('Store subscription cancelled');
  }
}