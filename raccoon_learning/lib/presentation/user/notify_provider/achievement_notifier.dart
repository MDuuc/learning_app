import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raccoon_learning/presentation/user/model/achievement_modle.dart';
import 'package:raccoon_learning/presentation/user/notify_provider/User_notifier.dart';

class AchievementNotifier extends ChangeNotifier {
  List<AchievementModel> achievements = [];

  AchievementNotifier() {
    _loadAchievements();
  }

  // Load achievements from SharedPreferences and initialize them
  Future<void> _loadAchievements() async {
    // Simulate a list of achievements (you can replace this with your own list)
    achievements = [
      AchievementModel(id: '1', title: 'Achievement ', description: "The best score is ", score: 10, coin: 10),
      AchievementModel(id: '2', title: 'Achievement ', description: "The best score is ", score: 20, coin: 20),
      AchievementModel(id: '3', title: 'Achievement ', description: "The best score is ", score: 30, coin: 30),
      AchievementModel(id: '4', title: 'Achievement ', description: "The best score is ", score: 40, coin: 40),
      AchievementModel(id: '5', title: 'Achievement ', description: "The best score is ", score: 50, coin: 50),
      AchievementModel(id: '6', title: 'Achievement ', description: "The best score is ", score: 60, coin: 60),
      AchievementModel(id: '7', title: 'Achievement ', description: "The best score is ", score: 70, coin: 70),
      AchievementModel(id: '8', title: 'Achievement ', description: "The best score is ", score: 80, coin: 80),
      AchievementModel(id: '9', title: 'Achievement ', description: "The best score is ", score: 90, coin: 90),
      AchievementModel(id: '10', title: 'Achievement ', description: "The best score is ", score: 100, coin: 100),
    ];
    // Load the claim status for each achievement from SharedPreferences
    for (var achievement in achievements) {
      achievement.isClaimed = await AchievementModel.loadClaimStatus(achievement.id);
    }
    // _sortAchievements();
    notifyListeners(); 
  }

  // Claim an achievement
  Future<void> claimAchievement(String id, BuildContext context) async {
    final achievement = achievements.firstWhere((a) => a.id == id);
    if (!achievement.isClaimed) {
      //update coin
      final userNotifier = Provider.of<UserNotifier>(context, listen: false);
      int updatedCoin = userNotifier.coin + achievement.coin;
      userNotifier.saveCoin(updatedCoin);

      achievement.isClaimed = true;
      await achievement.saveClaimStatus();
    // _sortAchievements();
      notifyListeners(); // Notify listeners that the state has changed
    }
  }

  // void _sortAchievements() {
  // achievements.sort((a, b) => a.isClaimed ? 1 : (b.isClaimed ? -1 : 0));
   
  // }
}
