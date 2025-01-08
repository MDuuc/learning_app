class AchievementModel {
  final String description;
  final int score;
  final int coin;
  final bool isClaimed;

  AchievementModel(this.description, this.score, this.coin, this.isClaimed);

    factory AchievementModel.fromMap(Map<String, dynamic> data) {
    return AchievementModel(
      data['description'] ?? '',          
      data['score'] ?? 0,
      data['coin'] ?? 0,           
      data['isClaimed'] ?? false,    
    );
  }
}
