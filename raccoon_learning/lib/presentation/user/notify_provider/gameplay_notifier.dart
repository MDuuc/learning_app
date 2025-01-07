import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:raccoon_learning/presentation/user/model/store_modle.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GameplayNotifier extends ChangeNotifier {
   int _coin = 100000;  
   List<StoreModle> _storeItems = [];
   List<String> _purchasedAvatars = [];  

  int get coin => _coin;
  List<StoreModle> get storeItems => _storeItems;
  List<String> get purchasedAvatars => _purchasedAvatars;

Future<void> fetchStoreItems(String userId) async {
  DocumentReference userDocRef = FirebaseFirestore.instance.collection('gameplay').doc(userId);

  try {
    DocumentSnapshot userDoc = await userDocRef.get();

    if (userDoc.exists) {
      Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
      // get list store items
      if (data.containsKey('store') && data['store'] is List) {
        List storeList = data['store'] as List;
        List<StoreModle> storeItems = storeList
            .map((item) => StoreModle.fromMap(item)).toList();
        _storeItems = storeItems;
        sortStoreItems();
        notifyListeners();
      } 
      // get list avatar
    if (data.containsKey('avatarPurchased') && data['avatarPurchased'] is List) {
      List avatarList = data['avatarPurchased'] as List;
      List<String> avatarItems = avatarList.map((item) => item.toString()).toList();
      _purchasedAvatars = avatarItems;
      sortStoreItems();
      notifyListeners();
    }
    } 
  } catch (e) {
    print('Error fetching store items: $e');
  }
}


  Future<void> purchaseItem(StoreModle item) async {
    final prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('user_uid');

  // Find index of the item in the local _storeItems list
  int itemIndex = _storeItems.indexWhere((storeItem) => storeItem.image == item.image);

  if (itemIndex != -1) {
    // Update local item
    _storeItems[itemIndex] = StoreModle(item.image, item.price, true); 
    sortStoreItems();
    notifyListeners();

    // Update Firebase
    try {
      DocumentReference userDoc = FirebaseFirestore.instance.collection('gameplay').doc(userId);

      // Update store list in Firestore
      await userDoc.update({
        'store': _storeItems.map((storeItem) => {
          'image': storeItem.image,
          'price': storeItem.price,
          'purchase': storeItem.purchase,
        }).toList(),
      });
    } catch (e) {
      print('Error updating Firebase: $e');
    }
  } else {
    print('Item not found in local storeItems list.');
  }
}


Future<bool> purchaseAvatar(String avatarPath, int price) async {
  if (_coin >= price) {
    final prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('user_uid');

    try {
      DocumentReference userDoc =
          FirebaseFirestore.instance.collection('gameplay').doc(userId);
      DocumentSnapshot userSnapshot = await userDoc.get();

      if (userSnapshot.exists) {
        Map<String, dynamic> data = userSnapshot.data() as Map<String, dynamic>;

        List<dynamic> currentAvatars = data['avatarPurchased'] ?? [];

        currentAvatars.add(avatarPath);

        await userDoc.update({
          'avatarPurchased': currentAvatars,
          'coin': _coin - price,
        });

        // handle local
        _purchasedAvatars.add(avatarPath); 
        _coin -= price; 
        notifyListeners();
        return true;
      }
    } catch (e) {
      print('Error updating avatarPurchased on Firebase: $e');
    }
  }
  return false; 
}


  void sortStoreItems() {
  _storeItems.sort((a, b) => a.purchase ? 1 : b.purchase ? -1 : 0);
  notifyListeners();
}

}
