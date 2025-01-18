import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:raccoon_learning/presentation/user/model/achievement_modle.dart';
import 'package:raccoon_learning/presentation/user/model/store_modle.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GameplayNotifier extends ChangeNotifier {
   int _bestScore = 0;
   int _coin = 0 ;  
   List<StoreModle> _storeItems = [];
   List<AchievementModel> _achivementLearnings = [];
   List<String> _purchasedAvatars = [];  

  int get bestScore => _bestScore;
  int get coin => _coin;
  List<StoreModle> get storeItems => _storeItems;
  List<AchievementModel> get achivementLearnings => _achivementLearnings;
  List<String> get purchasedAvatars => _purchasedAvatars;

Future<void> fetchDataFirebase(String userId) async {
  DocumentReference userDocRef = FirebaseFirestore.instance.collection('gameplay').doc(userId);

  try {
    DocumentSnapshot userDoc = await userDocRef.get();

    if (userDoc.exists) {
      Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
      // get bestScore
       if (data.containsKey('best_score') && data['best_score'] is int) {
        int bestScore = data['best_score'] as int;
        _bestScore = bestScore;
      }
      // get coin
       if (data.containsKey('coin') && data['coin'] is int) {
        int coin = data['coin'] as int;
        _coin = coin;
      }
      // get list store items
      if (data.containsKey('store') && data['store'] is List) {
        List storeList = data['store'] as List;
        _storeItems= storeList
            .map((item) => StoreModle.fromMap(item)).toList();
        sortStoreItems();
      } 

      // get list achievement learning
      if (data.containsKey('achivement_learning') && data['achivement_learning'] is List) {
        List achievementLearningList = data['achivement_learning'] as List;
        _achivementLearnings = achievementLearningList
            .map((item) => AchievementModel.fromMap(item)).toList();
        sortAchievementLearningItems();
      } 

      // get list avatar
    if (data.containsKey('avatarPurchased') && data['avatarPurchased'] is List) {
      List avatarList = data['avatarPurchased'] as List;
      _purchasedAvatars = avatarList.map((item) => item.toString()).toList();
    }
      notifyListeners();
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

  Future<void> claimAchivementLearning(AchievementModel item) async {
    final prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('user_uid');

    // Find index of the item in the local achivementLearnings list
    int itemIndex = _achivementLearnings.indexWhere((achivementItem) => achivementItem.score == item.score);
    if (itemIndex != -1) {
      // Update local item
      _achivementLearnings[itemIndex] = AchievementModel(item.description, item.score, item.coin, true); 
      sortAchievementLearningItems();
      notifyListeners();

      // Update Firebase
      try {
        DocumentReference userDoc = FirebaseFirestore.instance.collection('gameplay').doc(userId);

        // Update achivement learning list in Firestore
        await userDoc.update({
          'achivement_learning': _achivementLearnings.map((achievementItem) => {
            'description': achievementItem.description,
            'score': achievementItem.score,
            'coin': achievementItem.coin,
            'isClaimed': achievementItem.isClaimed,
          }).toList(),
          'coin': _coin + item.coin,
        });
      } catch (e) {
        print('Error updating Firebase: $e');
      }
      // handle local
        _coin += item.coin; 
    } else {
      print('Item not found in local achivement learning list.');
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

Future<void> updateCoin(int coin) async {
  // Validate coin
  if (coin < 0) {
    print("Invalid coin value: cannot be negative");
    return;
  }

  final prefs = await SharedPreferences.getInstance();
  String? userId = prefs.getString('user_uid');
  try {
    DocumentReference userDoc =
        FirebaseFirestore.instance.collection('gameplay').doc(userId);

    // Update Firestore
    await userDoc.update({
      'coin': _coin + coin,
    });

    // Handle local update
    _coin += coin;
    print(coin);
    notifyListeners();
  } catch (e) {
    print('Error updating coin on Firebase: $e');
  }
}

Future<void> updateBestScore(int point) async {
  // Validate point
  if (point < 0) {
    print("Invalid point value: cannot be negative");
    return;
  }

  final prefs = await SharedPreferences.getInstance();
  String? userId = prefs.getString('user_uid');
  try {
    DocumentReference userDoc =
        FirebaseFirestore.instance.collection('gameplay').doc(userId);

    // Update Firestore
    await userDoc.update({
      'best_score': point,
    });

    // Handle local update
    _bestScore == point;
    notifyListeners();
  } catch (e) {
    print('Error updating best Score on Firebase: $e');
  }
}


  void sortStoreItems() {
  _storeItems.sort((a, b) => a.purchase ? 1 : b.purchase ? -1 : 0);
  notifyListeners();
  }

  void sortAchievementLearningItems() {
  _achivementLearnings.sort((a, b) => a.isClaimed ? 1 : b.isClaimed ? -1 : 0);
  notifyListeners();
  }

}
