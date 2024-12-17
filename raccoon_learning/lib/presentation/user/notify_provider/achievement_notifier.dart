import 'package:flutter/material.dart';
import 'package:raccoon_learning/presentation/user/model/achievement_modle.dart';

class AchievementNotifier extends ChangeNotifier {
  List<AchievementModel> achievements = [];

  AchievementNotifier() {
    _loadAchievements();
  }

  // Load achievements from SharedPreferences and initialize them
  Future<void> _loadAchievements() async {
    // Simulate a list of achievements (you can replace this with your own list)
    achievements = [
      AchievementModel(id: '1', name: 'Achievement 1'),
      AchievementModel(id: '2', name: 'Achievement 2'),
      AchievementModel(id: '3', name: 'Achievement 3'),
    ];

    // Load the claim status for each achievement from SharedPreferences
    for (var achievement in achievements) {
      achievement.isClaimed = await AchievementModel.loadClaimStatus(achievement.id);
    }
    notifyListeners(); // Notify listeners when achievements are loaded
  }

  // Claim an achievement
  Future<void> claimAchievement(String id) async {
    final achievement = achievements.firstWhere((a) => a.id == id);
    if (!achievement.isClaimed) {
      achievement.isClaimed = true;
      await achievement.saveClaimStatus();
      notifyListeners(); // Notify listeners that the state has changed
    }
  }
}
