import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raccoon_learning/presentation/user/notify_provider/achievement_notifier.dart';
import 'package:raccoon_learning/presentation/home/achievement/widget/achiement_button.dart';

class LearningAchievePage extends StatefulWidget {
  const LearningAchievePage({super.key});

  @override
  State<LearningAchievePage> createState() => _LearningAchievePageState();
}

class _LearningAchievePageState extends State<LearningAchievePage> {
    @override
  void initState() {
    super.initState();
    // Provider.of<AchievementNotifier>(context, listen: false).loadAchievements();
  }

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