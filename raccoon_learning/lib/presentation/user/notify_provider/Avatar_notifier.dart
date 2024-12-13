import 'package:flutter/foundation.dart';
import 'package:raccoon_learning/constants/assets/app_images.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AvatarNotifier extends ChangeNotifier {
  String _avatarPath = AppImages.user;  // Avatar default

  String get avatarPath => _avatarPath;

  // Hàm lấy dữ liệu avatar từ SharedPreferences
  Future<void> loadAvatar() async {
    final prefs = await SharedPreferences.getInstance();
    _avatarPath = prefs.getString('user_avatar') ?? '';  // get avatar from  shraredPreference
    notifyListeners();
  }

  // Hàm lưu dữ liệu avatar vào SharedPreferences
  Future<void> saveAvatar(String avatarPath) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_avatar', avatarPath);  // save avatar
    _avatarPath = avatarPath;  
    notifyListeners();
  }
}
