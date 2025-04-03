import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raccoon_learning/constants/assets/app_images.dart';
import 'package:raccoon_learning/presentation/home/control_page.dart';
import 'package:raccoon_learning/presentation/user/notify_provider/competitve_notifier.dart';

// RankDialog widget to display rank changes after a match
class RankDialog extends StatefulWidget {
  final String grade; // The grade level (e.g., 'grade_1', 'grade_2', 'grade_3')
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

    // Initialize animation controller with 1-second duration
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    // Set up progress animation with easing curve
    _progressAnimation = Tween<double>(begin: progressBegin, end: progressEnd).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Start animation and handle rank transition
    _controller.forward().then((_) {
      if (isRankTransition) {
        setState(() {
          showNewRank = true;
          rankName = getRankName(rank); 
          rankImage = getRankImage(rank); 
          rankKey = UniqueKey(); 
          progressBegin = _progressAnimation.value; 
          progressEnd = (rank % 100) / 100; 
          _progressAnimation = Tween<double>(begin: progressBegin, end: progressEnd).animate(
            CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
          );
          print("Transition: rank=$rank, progressBegin=$progressBegin, progressEnd=$progressEnd");
        });
        _controller.reset(); 
        _controller.forward(); 
      }
    });
  }

  // Fetch user rank data from CompetitiveNotifier based on grade
  void getValueOfUser() {
    final competitiveNotifier = Provider.of<CompetitveNotifier>(context, listen: false);
    competitiveNotifier.fetchAndUpdateRanks();
    statusMatch = competitiveNotifier.statusEndMatchUser; 
    if (widget.grade == 'grade_1') {
      rank = competitiveNotifier.rank_grade1; 
    } else if (widget.grade == 'grade_2') {
      rank = competitiveNotifier.rank_grade2;
    } else if (widget.grade == 'grade_3') {
      rank = competitiveNotifier.rank_grade3;
    }
    // Calculate previous rank based on match result
    if(statusMatch=='win') {rank+=15;};
    previousRank = rank - (statusMatch == 'win' ? 15 : -15);
    print("Initial: rank=$rank, previousRank=$previousRank, statusMatch=$statusMatch");

  }

  // Calculate rank details and progress for display
  void getRankDetails() {
    int previousPointsInRank = previousRank % 100; 
    int currentPointsInRank = rank % 100; 

    // Check if there's a rank transition (promotion or demotion)
    isRankTransition = (statusMatch == 'win' && previousPointsInRank + 15 >= 100) ||
        (statusMatch == 'lose' && previousPointsInRank - 15 < 0);

    if (isRankTransition) {
      if (statusMatch == 'win') {
        // Handle rank promotion
        int newRankLevel = (rank / 100).floor(); 
        int newPoints = currentPointsInRank; 

        progressBegin = previousPointsInRank / 100; 
        progressEnd = newPoints / 100; 
        previousRankName = getRankName(previousRank);
        previousRankImage = getRankImage(previousRank);
        rankName = getRankName(newRankLevel * 100 + newPoints); 
        rankImage = getRankImage(newRankLevel * 100 + newPoints); 
      } else if (statusMatch == 'lose') {
        int newRankLevel = (rank / 100).floor(); 
        if (newRankLevel < 0) newRankLevel = 0; 
        int newPoints = (previousPointsInRank - 15) < 0
            ? 100 + (previousPointsInRank - 15) 
            : previousPointsInRank - 15;

        progressBegin = previousPointsInRank / 100; 
        progressEnd = newPoints / 100; 
        previousRankName = getRankName(previousRank);
        previousRankImage = getRankImage(previousRank);
        rankName = getRankName(newRankLevel * 100 + newPoints); 
        rankImage = getRankImage(newRankLevel * 100 + newPoints); 
      }
    } else {
      // No rank transition, just update progress within current rank
      progressBegin = previousPointsInRank / 100; 
      progressEnd = currentPointsInRank / 100; 
      rankName = getRankName(rank);
      rankImage = getRankImage(rank);
    }
  }

  // Get rank name based on total points (e.g., "IRON 2", "BRONZE 1")
  String getRankName(int points) {
    int totalLevel = (points / 100).floor() + 1; // Calculate rank tier
    int rankIndex = (totalLevel - 1) ~/ 3; // Group of 3 levels per rank
    int rankLevel = totalLevel - (rankIndex * 3); // Level within rank (1-3)
    List<String> ranks = ['Iron', 'Bronze', 'Silver', 'Gold', 'Platinum', 'Diamond', 'Ascendant'];
    if (rankIndex >= ranks.length) {
      rankIndex = ranks.length - 1; // Cap at highest rank
      rankLevel = 3;
    }
    return '${ranks[rankIndex]} $rankLevel'.toUpperCase();
  }

  // Get rank image path based on total points
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
    _controller.dispose(); // Clean up animation controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent, // Transparent background for dialog
      elevation: 0,
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.9), // Semi-transparent black background
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Minimize column size
          children: [
            // Animated switcher for rank image and name transition
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500), // Transition duration
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
                key: rankKey, // Unique key to trigger transition
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
            // Animated progress bar for rank rating
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
                      value: _progressAnimation.value, // Current progress value
                      backgroundColor: Colors.grey[800],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        statusMatch == 'win' ? Colors.green : Colors.red, // Color based on match result
                      ),
                      minHeight: 10,
                    ),
                    SizedBox(height: 5),
                    Text(
                      "${(_progressAnimation.value * 100).toInt()}/100", // Display progress as X/100
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
              statusMatch == 'win' ? "+${rank - previousRank} RR" : "-${previousRank - rank} RR", // Show actual rank change
              style: TextStyle(
                color: statusMatch == 'win' ? Colors.green : Colors.red,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const ControlPage()),
                  (route) => false, // Remove all previous routes
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