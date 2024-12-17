import 'package:shared_preferences/shared_preferences.dart';

class AchievementManager {
  // Load Achievement
  static Future<bool> loadClaimStatus(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key) ?? false; // Return false if user dit not achive it yet
  }

  // Save when user achivement it, avoid to accept many times
  static Future<void> saveClaimStatus(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, true);
  }
}
