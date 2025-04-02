import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raccoon_learning/constants/assets/app_images.dart';
import 'package:raccoon_learning/presentation/home/control_page.dart';
import 'package:raccoon_learning/presentation/user/notify_provider/competitve_notifier.dart';

class RankDialog extends StatefulWidget {
  final String grade;
  const RankDialog({super.key, required this.grade});
  @override
  _RankDialogState createState() => _RankDialogState();
}

class _RankDialogState extends State<RankDialog> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;
  int rank = 0;
  String rankName = '';
  String rankImage = '';
  double progressBegin = 0.0;
  double progressEnd = 0.0;
  String statusMatch = '';
  bool isRankTransition = false;
  int previousRank = 0;
  String previousRankName = '';
  String previousRankImage = '';
  bool showNewRank = false; 
  Key rankKey = UniqueKey(); 

  @override
  void initState() {
    super.initState();
    getValueOfUser();
    getRankDetails();

    _controller = AnimationController(
      duration: const Duration(seconds: 1), 
      vsync: this,
    );

    _progressAnimation = Tween<double>(begin: progressBegin, end: progressEnd).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Bắt đầu animation
    _controller.forward().then((_) {
      if (isRankTransition) {
        setState(() {
          showNewRank = true;
          rankName = getRankName(rank);
          rankImage = getRankImage(rank);
          rankKey = UniqueKey(); 
          progressBegin = 0.0;
          progressEnd = (rank % 100) / 100;
          _progressAnimation = Tween<double>(begin: progressBegin, end: progressEnd).animate(
            CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
          );
        });
        _controller.reset();
        _controller.forward();
      }
    });
  }

  void getValueOfUser() {
    final competitiveNotifier = Provider.of<CompetitveNotifier>(context, listen: false);
    statusMatch = competitiveNotifier.statusEndMatchUser;
    if (widget.grade == 'grade_1') {
      rank = competitiveNotifier.rank_grade1;
    } else if (widget.grade == 'grade_2') {
      rank = competitiveNotifier.rank_grade2;
    } else if (widget.grade == 'grade_3') {
      rank = competitiveNotifier.rank_grade3;
    }
    previousRank = rank - (statusMatch == 'win' ? 15 : -15);
  }

  void getRankDetails() {
    int previousPointsInRank = previousRank % 100;
    int currentPointsInRank = rank % 100;
    isRankTransition = (statusMatch == 'win' && previousPointsInRank + 15 >= 100) ||
        (statusMatch == 'lose' && previousPointsInRank - 15 < 0);

    if (isRankTransition && statusMatch == 'win') {
      progressBegin = previousPointsInRank / 100;
      progressEnd = 1.0;
      previousRankName = getRankName(previousRank);
      previousRankImage = getRankImage(previousRank);
      rankName = previousRankName; // Ban đầu hiển thị rank cũ
      rankImage = previousRankImage;
    } else {
      progressBegin = previousPointsInRank / 100;
      progressEnd = currentPointsInRank / 100;
      rankName = getRankName(rank);
      rankImage = getRankImage(rank);
    }
  }

  String getRankName(int points) {
    int totalLevel = (points / 100).floor() + 1;
    int rankIndex = (totalLevel - 1) ~/ 3;
    int rankLevel = totalLevel - (rankIndex * 3);
    List<String> ranks = ['Iron', 'Bronze', 'Silver', 'Gold', 'Platinum', 'Diamond', 'Ascendant'];
    if (rankIndex >= ranks.length) {
      rankIndex = ranks.length - 1;
      rankLevel = 3;
    }
    return '${ranks[rankIndex]} $rankLevel'.toUpperCase();
  }

  String getRankImage(int points) {
    int totalLevel = (points / 100).floor() + 1;
    int rankIndex = (totalLevel - 1) ~/ 3;
    int rankLevel = totalLevel - (rankIndex * 3);
    if (rankIndex < 0) rankIndex = 0;
    if (rankLevel < 1) rankLevel = 1;
    if (rankIndex >= 7) {
      rankIndex = 6;
      rankLevel = 3;
    }
    List<String> rankImages = [
      AppImages.Iron_1_Rank, AppImages.Iron_2_Rank, AppImages.Iron_3_Rank,
      AppImages.Bronze_1_Rank, AppImages.Bronze_2_Rank, AppImages.Bronze_3_Rank,
      AppImages.Silver_1_Rank, AppImages.Silver_2_Rank, AppImages.Silver_3_Rank,
      AppImages.Gold_1_Rank, AppImages.Gold_2_Rank, AppImages.Gold_3_Rank,
      AppImages.Platinum_1_Rank, AppImages.Platinum_2_Rank, AppImages.Platinum_3_Rank,
      AppImages.Diamond_1_Rank, AppImages.Diamond_2_Rank, AppImages.Diamond_3_Rank,
      AppImages.Ascendant_1_Rank, AppImages.Ascendant_2_Rank, AppImages.Ascendant_3_Rank,
    ];
    return rankImages[rankIndex * 3 + (rankLevel - 1)];
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.9),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500), // Thời gian chuyển đổi
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(
                    scale: animation,
                    child: child,
                  ),
                );
              },
              child: Column(
                key: rankKey, // Key để AnimatedSwitcher nhận diện sự thay đổi
                children: [
                  Image.asset(
                    rankImage,
                    width: 100,
                    height: 100,
                  ),
                  SizedBox(height: 10),
                  Text(
                    rankName,
                    style: TextStyle(
                      color: Colors.cyanAccent,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            AnimatedBuilder(
              animation: _progressAnimation,
              builder: (context, child) {
                return Column(
                  children: [
                    Text(
                      "RANK RATING",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 5),
                    LinearProgressIndicator(
                      value: _progressAnimation.value,
                      backgroundColor: Colors.grey[800],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        statusMatch == 'win' ? Colors.green : Colors.red,
                      ),
                      minHeight: 10,
                    ),
                    SizedBox(height: 5),
                    Text(
                      "${(_progressAnimation.value * 100).toInt()}/100",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                );
              },
            ),
            SizedBox(height: 20),
            Text(
              statusMatch == 'win' ? "+15 RR" : "-15 RR",
              style: TextStyle(
                color: statusMatch == 'win' ? Colors.green : Colors.red,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const ControlPage()),
                  (route) => false,
                );
              },
              child: Text("Close"),
            ),
          ],
        ),
      ),
    );
  }
}