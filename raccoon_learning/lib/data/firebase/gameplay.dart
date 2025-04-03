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
      'rank_grade_1': 0,
      'rank_grade_2': 0,
      'rank_grade_3': 0,
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

void listenToAllStoreUpdates(String userId) {
  _storeSubscription = _firestore.collection('store_default').snapshots().listen(
    (snapshot) async {
      List<StoreModle> newStoreItems = [];
      // Extract store items directly from each document
      for (var doc in snapshot.docs) {
        if (doc.exists && doc.data() != null) {
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

      // Identify new items, items with price updates, and items to remove
      List<Map<String, dynamic>> itemsToAdd = [];
      List<Map<String, dynamic>> itemsToUpdate = [];
      List<Map<String, dynamic>> itemsToRemove = [];

      // Check for new items and price updates
      for (var newItem in newStoreItems) {
        int existingIndex = currentStoreItems.indexWhere((currentItem) => currentItem.image == newItem.image);
        
        if (existingIndex == -1) {
          // New item doesn't exist in user's store
          itemsToAdd.add(newItem.toMap()..['purchase'] = false);
        } else {
          // Item exists, check if price has changed
          StoreModle existingItem = currentStoreItems[existingIndex];
          if (existingItem.price != newItem.price) {
            // Price has changed, prepare update while preserving purchase status
            itemsToUpdate.add({
              'image': newItem.image,
              'price': newItem.price,
              'purchase': existingItem.purchase, // Keep the existing purchase status
            });
          }
        }
      }

      // Check for items that exist in user's store but not in store_default (to be removed)
      for (var currentItem in currentStoreItems) {
        bool existsInDefault = newStoreItems.any((newItem) => newItem.image == currentItem.image);
        if (!existsInDefault) {
          itemsToRemove.add(currentItem.toMap());
        }
      }

      // Update user data with new items, price updates, and removals
      if (itemsToAdd.isNotEmpty || itemsToUpdate.isNotEmpty || itemsToRemove.isNotEmpty) {
        // First, remove items that need to be deleted or updated
        if (itemsToRemove.isNotEmpty || itemsToUpdate.isNotEmpty) {
          await _firestore.collection('gameplay').doc(userId).update({
            'store': FieldValue.arrayRemove(
              [
                ...itemsToRemove,
                ...currentStoreItems
                    .where((item) => itemsToUpdate.any((update) => update['image'] == item.image))
                    .map((item) => item.toMap())
              ]
            ),
          });
        }

        // Then add both new items and updated items
        if (itemsToAdd.isNotEmpty || itemsToUpdate.isNotEmpty) {
          await _firestore.collection('gameplay').doc(userId).update({
            'store': FieldValue.arrayUnion(
              [...itemsToAdd, ...itemsToUpdate]
            ),
          });
        }

        // Logging
        if (itemsToAdd.isNotEmpty) {
          print('Added ${itemsToAdd.length} new store items for user $userId');
        }
        if (itemsToUpdate.isNotEmpty) {
          print('Updated price for ${itemsToUpdate.length} existing store items for user $userId');
        }
        if (itemsToRemove.isNotEmpty) {
          print('Removed ${itemsToRemove.length} store items for user $userId');
        }
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