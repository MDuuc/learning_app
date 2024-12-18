import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raccoon_learning/presentation/user/model/achievement_modle.dart';
import 'package:raccoon_learning/presentation/user/notify_provider/achievement_notifier.dart';
import 'package:raccoon_learning/presentation/home/achievement/widget/achiement_button.dart';

class LearningAchievePage extends StatelessWidget {
  const LearningAchievePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AchievementNotifier>(
        builder: (context, achievementNotifier, child) {
          final achievements = achievementNotifier.achievements;
          return achievements.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: Column(
                    children: achievements.map((achievement) {
                      return Padding(
                        padding: const EdgeInsets.all( 6),
                        child: AchievementButton(
                          id: achievement.id,
                          text: achievement.description,
                          score: achievement.score.toString(),
                          coin: achievement.coin.toString(),

                        ),
                      );
                    }).toList(),
                  ),
                );
        },
    );
  }
}
