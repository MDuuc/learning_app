import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:raccoon_learning/constants/assets/app_images.dart';
import 'package:raccoon_learning/data/firebase/authservice.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserNotifier extends ChangeNotifier {
  String _avatarPath = AppImages.user;  // Avatar default
  String _username = '';     
  String _role = '';          
  int _streakCount = 1;

  String get avatarPath => _avatarPath;
  String get username => _username;
  String get role => _role;
  int get streakCount => _streakCount;

  // Get user in4 From FireDatabase
  Future<void> loadUserInfo(String userName, String avatar, int streakCount, String role) async {
    final prefs = await SharedPreferences.getInstance();
    _avatarPath = avatar;
    _username = userName;
    _streakCount = streakCount;
    _role = role;


    // save to local
    await prefs.setString('user_name', userName);  // save username
    await prefs.setString('user_avatar', avatar);  // save avatar
    await prefs.setString('user_role', role);  // save avatar

    notifyListeners();
  }

  // Save avatar to SharedPreferences and to the Firebase
  Future<void> saveAvatar(String avatarPath) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_avatar', avatarPath);  // save avatar
    _avatarPath = avatarPath;  
    AuthService().updateAvatar(avatarPath);
    notifyListeners();
  }

    Future<void> saveUsername(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', username);
    _username = username;
    notifyListeners();
  }

  Future<void> fetchUserRole(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists) {
        _role = doc.data()?['role'] ?? 'user';
        notifyListeners();
      }
    } catch (e) {
      print("Error fetching role: $e");
      _role = 'user'; 
      notifyListeners();
    }
  }

}
