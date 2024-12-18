import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raccoon_learning/constants/assets/app_images.dart';
import 'package:raccoon_learning/constants/theme/app_colors.dart';
import 'package:raccoon_learning/main.dart';
import 'package:raccoon_learning/presentation/user/local_data/best_score_manger.dart';
import 'package:raccoon_learning/presentation/user/notify_provider/achievement_notifier.dart';
import 'package:raccoon_learning/presentation/user/model/achievement_modle.dart';

class AchievementButton extends StatefulWidget {
  final String id;
  final String text;
  final String coin;
  final String score;
  
  const AchievementButton({
    super.key, 
    required this.text, 
    required this.coin, 
    required this.score, 
    required this.id
  });

  @override
  State<AchievementButton> createState() => _AchievementButtonState();
}

class _AchievementButtonState extends State<AchievementButton> {
  bool _isClaimed = false;
  int? bestScore;

  @override
  void initState() {
    super.initState();
    _initializeModel();
  }

  Future<void> _initializeModel() async {
    await _loadClaimStatus();
    await _initializeBestScore();
  }

  // Get achievement claim status
  Future<void> _loadClaimStatus() async {
    bool claimed = await AchievementModel.loadClaimStatus(widget.id);
    setState(() {
      _isClaimed = claimed;
    });
  }

  // Get best score
  Future<void> _initializeBestScore() async {
    bestScore = await ScoreManager.getBestScore();
    setState(() {});
  }

  void _claimReward() {
    // Check if achievement is eligible before claiming
    if (bestScore != null && bestScore! >= int.parse(widget.score)) {
      // Use the AchievementNotifier to claim the achievement
      final achievementNotifier = Provider.of<AchievementNotifier>(context, listen: false);
      achievementNotifier.claimAchievement(widget.id, context);

      setState(() {
        _isClaimed = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    bool isEligible = bestScore != null && bestScore! >= int.parse(widget.score);

    return Container(
        constraints: BoxConstraints(
          minHeight: screenHeight / 10,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: AppColors.brown_light,
        ),
        padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                showFullImage(context, AssetImage(AppImages.raccoon_notifi));
              },
              child: CircleAvatar(
                backgroundColor: Colors.transparent,
                radius: 30,
                backgroundImage: AssetImage(AppImages.raccoon_notifi),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                '${widget.text} ${widget.score}',
                style: TextStyle(fontSize: 18, color: AppColors.black),
                softWrap: true,
                overflow: TextOverflow.visible,
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: !isEligible
                  ? null // Disable button if not eligible
                  : _isClaimed
                      ? null // Disable if already claimed
                      : _claimReward,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                foregroundColor: Colors.white,
                backgroundColor: _isClaimed
                    ? Colors.grey
                    : isEligible
                        ? Colors.greenAccent.shade400
                        : Colors.redAccent.shade200, // Not eligible button style
              ),
  child: Padding(
  padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 15),
  child: _isClaimed
      ? const Text(
          "Claimed",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
        )
      : isEligible
          ? Row(
              children: [
                 Text(
                  widget.coin,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
                ),
                const SizedBox(width: 1), 
                Container(
                  height: 25,
                  child: Image.asset(AppImages.coin),
                ),
              ],
            )
          : Row(
              children: [
                 Text(
                  widget.coin,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
                ),
                const SizedBox(width: 1), 
                Container(
                  height: 25,
                  child: Image.asset(AppImages.coin),
                ),
              ],
            ),
),

            ),
          ],
        ),
      );
  }
}