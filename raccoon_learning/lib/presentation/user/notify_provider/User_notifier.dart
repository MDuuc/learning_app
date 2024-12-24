import 'package:flutter/foundation.dart';
import 'package:raccoon_learning/constants/assets/app_images.dart';
import 'package:raccoon_learning/data/firebase/authservice.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserNotifier extends ChangeNotifier {
  String _avatarPath = AppImages.user;  // Avatar default
  String _username = '';               
  int _coin = 100000;   
  List<String> _purchasedAvatars = [    // List Avatar default
    AppImages.raccoon_notifi,
    AppImages.raccoon_grade_1,
    AppImages.raccoon_grade_2,
    AppImages.raccoon_grade_3,
  ];  
  String get avatarPath => _avatarPath;
  String get username => _username;
  int get coin => _coin;
  List<String> get purchasedAvatars => _purchasedAvatars;

  // Get user in4 From FireDatabase
  Future<void> loadUserInfo(String userName, String avatar) async {
    final prefs = await SharedPreferences.getInstance();
    _avatarPath = avatar;
    _username = userName;
    _coin = prefs.getInt('user_coin') ?? 100000;

    notifyListeners();
  }

  // Save avatar to SharedPreferences and to the Firbase
  Future<void> saveAvatar(String avatarPath) async {
    // final prefs = await SharedPreferences.getInstance();
    // await prefs.setString('user_avatar', avatarPath);  // save avatar
    _avatarPath = avatarPath;  
    AuthService().updateAvatar(avatarPath);
    notifyListeners();
  }

    Future<void> saveUsername(String username) async {
    // final prefs = await SharedPreferences.getInstance();
    // await prefs.setString('username', username);
    _username = username;
    notifyListeners();
  }

    Future<void> saveCoin(int coin) async {
    // final prefs = await SharedPreferences.getInstance();
    // await prefs.setInt('user_coin', coin);
    _coin = coin;
    notifyListeners();
  }

    // Check and purchase avatar
  bool hasPurchasedAvatar(String avatarPath) {
    return _purchasedAvatars.contains(avatarPath);
  }

    Future<bool> purchaseAvatar(String avatarPath, int price) async {
    if (_coin >= price && !hasPurchasedAvatar(avatarPath)) {
      _purchasedAvatars.add(avatarPath);
      _coin -= price;

      // final prefs = await SharedPreferences.getInstance();
      // await prefs.setStringList('purchased_avatars', _purchasedAvatars);
      // await prefs.setInt('user_coin', _coin);

      notifyListeners();
      return true;
    }
    return false; // false to purchase, because  already purchased or not enought coin
  }
}
