import 'package:flutter/foundation.dart';
import 'package:raccoon_learning/constants/assets/app_images.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserNotifier extends ChangeNotifier {
  String _avatarPath = AppImages.user;  // Avatar default
  String _username = '';               
  int _coin = 100000;   
  String get avatarPath => _avatarPath;
  String get username => _username;
  int get coin => _coin;
  // Get user in4 From SharedPreferences
  Future<void> loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    _avatarPath = prefs.getString('user_avatar') ?? AppImages.user;
    _username = prefs.getString('username') ?? '';
    _coin = prefs.getInt('user_coin') ?? 100000;
    notifyListeners();
  }

  // Save avatar to SharedPreferences
  Future<void> saveAvatar(String avatarPath) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_avatar', avatarPath);  // save avatar
    _avatarPath = avatarPath;  
    notifyListeners();
  }

    Future<void> saveUsername(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);
    _username = username;
    notifyListeners();
  }

    Future<void> saveCoin(int coin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_coin', coin);
    _coin = coin;
    notifyListeners();
  }
}
