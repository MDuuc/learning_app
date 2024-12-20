
import 'package:shared_preferences/shared_preferences.dart';

class AchievementModel {
  final String id;
  final String title;
  final String description;
  final int score;
  final int coin;
  bool isClaimed;

  AchievementModel({
    required this.id,
    required this.title,
    required this.description,
    required this.score,
    required this.coin,
    this.isClaimed = false,
  });

Future<void> saveClaimStatus() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('achievement_$id', isClaimed);
}

static Future<bool> loadClaimStatus(String id) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('achievement_$id') ?? false;
}

}
