import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raccoon_learning/constants/assets/app_images.dart';
import 'package:raccoon_learning/constants/theme/app_colors.dart';
import 'package:raccoon_learning/presentation/user/model/achievement_modle.dart';
import 'package:raccoon_learning/presentation/user/notify_provider/gameplay_notifier.dart';
import 'package:raccoon_learning/presentation/widgets/widget.dart';

class AchievementButton extends StatefulWidget {
  final AchievementModel item;

  const AchievementButton({
    super.key,
    required this.item
  });

  @override
  State<AchievementButton> createState() => _AchievementButtonState();
}

class _AchievementButtonState extends State<AchievementButton> {
  late bool isClaimed;
  late String description;
  late int score;
  late int coin;

  @override
  void initState() {
    super.initState();
    isClaimed = widget.item.isClaimed;
    description = widget.item.description;
    score = widget.item.score;
    coin = widget.item.coin;

  }


  @override
  Widget build(BuildContext context) {
    final userNotifier = Provider.of<GameplayNotifier>(context, listen: false);
    int bestScore = userNotifier.bestScore;
    double screenHeight = MediaQuery.of(context).size.height;

    bool isEligible = bestScore >= score;

    return Consumer<GameplayNotifier>(builder: (context, gameplay, child){
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
              '$description $score',
              style: TextStyle(fontSize: 18, color: AppColors.black),
              softWrap: true,
              overflow: TextOverflow.visible,
            ),
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: isClaimed || !isEligible
                ? null // Disable button if already claimed or not eligible
               : () {
                gameplay.claimAchivementLearning(
                  AchievementModel(description, score, coin, isClaimed),
                );
                setState(() {
                isClaimed = true; 
        });
        },
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              foregroundColor: Colors.white,
              backgroundColor: isClaimed
                  ? Colors.grey // Gray if already claimed
                  : isEligible
                      ? Colors.greenAccent.shade400 // Green if eligible
                      : Colors.redAccent.shade200, // Red if not eligible
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 15),
              child: isClaimed
                  ? const Text(
                      "Claimed",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
                    )
                  : Row(
                      children: [
                        Text(
                          coin.toString(),
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w400),
                        ),
                        const SizedBox(width: 5),
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
    });
  }
}
