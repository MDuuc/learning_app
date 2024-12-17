import 'package:shared_preferences/shared_preferences.dart';

class ScoreManager {
  static const String _bestScoreKey = 'best_score';

  // Save best score
  static Future<void> saveBestScore(int score) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_bestScoreKey, score);
  }

  // Take best score
  static Future<int> getBestScore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_bestScoreKey) ?? 0; 
  }
}
