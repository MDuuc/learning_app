import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raccoon_learning/presentation/home/achievement/widget/achiement_button.dart';
import 'package:raccoon_learning/presentation/user/model/achievement_modle.dart';
import 'package:raccoon_learning/presentation/user/notify_provider/gameplay_notifier.dart';

class LearningAchievePage extends StatelessWidget {
  const LearningAchievePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameplayNotifier>(
        builder: (context, achievement, child) {
          final achievements = achievement.achivementLearnings;
          return achievements.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: Column(
                    children: achievements.map((achievement) {
                      return Padding(
                        padding: const EdgeInsets.all( 6),
                        child: AchievementButton( item: AchievementModel(achievement.description, achievement.score, achievement.coin, achievement.isClaimed),
                        ),
                      );
                    }).toList(),
                  ),
                );
        },
    );
  }
}