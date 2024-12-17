import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raccoon_learning/constants/assets/app_images.dart';
import 'package:raccoon_learning/constants/theme/app_colors.dart';
import 'package:raccoon_learning/main.dart';
import 'package:raccoon_learning/presentation/user/local_data/achievement_manager.dart';
import 'package:raccoon_learning/presentation/user/notify_provider/User_notifier.dart';
import 'package:raccoon_learning/presentation/user/local_data/best_score_manger.dart';

class AchiementButton extends StatefulWidget {
  final ImageProvider image;
  final String text;
  final String coin;
  final String score;
  AchiementButton({super.key, required this.image, required this.text, required this.coin, required this.score});

  @override
  State<AchiementButton> createState() => _AchiementButtonState();
}

class _AchiementButtonState extends State<AchiementButton> {
    bool _isClaimed = false;
    int ?bestScore;

       @override
  void initState() {
    super.initState();
    _initializeModel();
  }

  Future<void> _initializeModel() async {
    _loadClaimStatus() ;
    _initializeBestScore();
    setState(() {});
  }

  //get achivement status
    Future<void> _loadClaimStatus() async {
    bool claimed = await AchievementManager.loadClaimStatus('claimed_${widget.score}');
    setState(() {
      _isClaimed = claimed;
    });
  }

  // save achivement status
    Future<void> _saveClaimStatus() async {
    await AchievementManager.saveClaimStatus('claimed_${widget.score}');
    setState(() {
      _isClaimed = true;
    });
  }

  // get best score
    Future<void> _initializeBestScore() async {
    bestScore = await ScoreManager.getBestScore();
    setState(() {});
  }

  void _claimReward() {
    setState(() {
      _isClaimed = true;
    });
    _saveClaimStatus();
    _updateCoin();
  }
@override
Widget build(BuildContext context) {
  double screenHeight = MediaQuery.of(context).size.height;

  bool isEligible = bestScore != null && bestScore! >= int.parse(widget.score);

  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Container(
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
              showFullImage(context, widget.image);
            },
            child: CircleAvatar(
              backgroundColor: Colors.transparent,
              radius: 30,
              backgroundImage: widget.image,
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
              child: Text(
                _isClaimed
                    ? "Claimed"
                    : isEligible
                        ? "Claim" // Show claim if eligible
                        : "Not Achieved", // Show this if not eligible
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}


  // update the current coin
void _updateCoin() {
  if (bestScore! >= int.parse(widget.score)){
    final userNotifier = Provider.of<UserNotifier>(context, listen: false);
    int updatedCoin = userNotifier.coin + int.parse(widget.coin);
     userNotifier.saveCoin(updatedCoin);
  }
}


}

