import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raccoon_learning/constants/assets/app_images.dart';
import 'package:raccoon_learning/constants/theme/app_colors.dart';
import 'package:raccoon_learning/presentation/user/notify_provider/competitve_notifier.dart';
import 'package:raccoon_learning/presentation/widgets/appbar/app_bar.dart';

class RankOverviewPage extends StatefulWidget {
  const RankOverviewPage({super.key});

  @override
  _RankOverviewPageState createState() => _RankOverviewPageState();
}

class _RankOverviewPageState extends State<RankOverviewPage>
    with TickerProviderStateMixin {
  // Animation controllers for each card's progress bar
   AnimationController? _controller1;
   AnimationController? _controller2;
   AnimationController? _controller3;
  // Animation objects for progress values
   Animation<double>? _progressAnimation1;
   Animation<double>? _progressAnimation2;
   Animation<double>? _progressAnimation3;
  // Flag to track if ranks have been fetched
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers for each card with 1-second duration
    _controller1 = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _controller2 = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _controller3 = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    // Initialize animations with default values (0 progress) to prevent LateInitializationError
    _progressAnimation1 = Tween<double>(begin: 0.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller1!, curve: Curves.easeInOut),
    );
    _progressAnimation2 = Tween<double>(begin: 0.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller2!, curve: Curves.easeInOut),
    );
    _progressAnimation3 = Tween<double>(begin: 0.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller3!, curve: Curves.easeInOut),
    );

    // Fetch rank data after the first frame to ensure UI is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final competitiveNotifier =
          Provider.of<CompetitveNotifier>(context, listen: false);
      competitiveNotifier.fetchAndUpdateRanks().then((_) {
        // After ranks are fetched, set up animations and start them with a stagger
        setState(() {
          _setupAnimations(competitiveNotifier);
          _isLoading = false; // Mark loading as complete
        });
        _controller1!.forward();
        Future.delayed(const Duration(milliseconds: 200), () {
          _controller2!.forward();
        });
        Future.delayed(const Duration(milliseconds: 400), () {
          _controller3!.forward();
        });
      });
    });
  }

  // Set up progress animations based on current ranks
  void _setupAnimations(CompetitveNotifier notifier) {
    // Calculate progress for each grade (0 to 1)
    final progress1 = (notifier.rank_grade_1 % 100) / 100;
    final progress2 = (notifier.rank_grade_2 % 100) / 100;
    final progress3 = (notifier.rank_grade_3 % 100) / 100;

    // Update animations with new Tween values based on actual progress
    _progressAnimation1 = Tween<double>(begin: 0.0, end: progress1).animate(
      CurvedAnimation(parent: _controller1!, curve: Curves.easeInOut),
    );
    _progressAnimation2 = Tween<double>(begin: 0.0, end: progress2).animate(
      CurvedAnimation(parent: _controller2!, curve: Curves.easeInOut),
    );
    _progressAnimation3 = Tween<double>(begin: 0.0, end: progress3).animate(
      CurvedAnimation(parent: _controller3!, curve: Curves.easeInOut),
    );
  }

  // Get rank name based on total points (e.g., "IRON 2", "BRONZE 1")
  String getRankName(int points) {
    int totalLevel = (points / 100).floor() + 1; // Calculate rank tier
    int rankIndex = (totalLevel - 1) ~/ 3; // Group of 3 levels per rank
    int rankLevel = totalLevel - (rankIndex * 3); // Level within rank (1-3)
    List<String> ranks = [
      'Iron',
      'Bronze',
      'Silver',
      'Gold',
      'Platinum',
      'Diamond',
      'Ascendant'
    ];
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
      AppImages.Iron_1_Rank,
      AppImages.Iron_2_Rank,
      AppImages.Iron_3_Rank,
      AppImages.Bronze_1_Rank,
      AppImages.Bronze_2_Rank,
      AppImages.Bronze_3_Rank,
      AppImages.Silver_1_Rank,
      AppImages.Silver_2_Rank,
      AppImages.Silver_3_Rank,
      AppImages.Gold_1_Rank,
      AppImages.Gold_2_Rank,
      AppImages.Gold_3_Rank,
      AppImages.Platinum_1_Rank,
      AppImages.Platinum_2_Rank,
      AppImages.Platinum_3_Rank,
      AppImages.Diamond_1_Rank,
      AppImages.Diamond_2_Rank,
      AppImages.Diamond_3_Rank,
      AppImages.Ascendant_1_Rank,
      AppImages.Ascendant_2_Rank,
      AppImages.Ascendant_3_Rank,
    ];
    return rankImages[rankIndex * 3 + (rankLevel - 1)];
  }

  // Build a single rank card for a given grade
  Widget buildRankCard(String grade, int rank, Animation<double> progressAnimation) {
    final rankName = getRankName(rank);
    final rankImage = getRankImage(rank);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blueGrey.shade900,
            Colors.cyanAccent.withOpacity(0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Left side: Rank image and name
            Expanded(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    rankImage,
                    width: 80,
                    height: 80,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    rankName,
                    style: const TextStyle(
                      color: Colors.cyanAccent,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Grade $grade',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            // Right side: Animated progress bar
            Expanded(
              flex: 3,
              child: AnimatedBuilder(
                animation: progressAnimation,
                builder: (context, child) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "RANK RATING",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 10),
                      LinearProgressIndicator(
                        value: progressAnimation.value,
                        backgroundColor: Colors.grey[800],
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.cyanAccent,
                        ),
                        minHeight: 10,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "${(progressAnimation.value * 100).toInt()}/100",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Dispose of animation controllers to prevent memory leaks
    _controller1!.dispose();
    _controller2!.dispose();
    _controller3!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CompetitveNotifier>(
      builder: (context, competitiveNotifier, child) {
        // Show a loading indicator while ranks are being fetched
        if (_isLoading) {
          return Scaffold(
            backgroundColor: AppColors.brown_light,
            appBar: BasicAppBar(
              title: const Text(
                'Rank Overview',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: AppColors.black,
            ),
            body: const Center(
              child: CircularProgressIndicator(
                color: Colors.cyanAccent,
              ),
            ),
          );
        }

        // Get ranks for each grade
        final rankGrade1 = competitiveNotifier.rank_grade_1;
        final rankGrade2 = competitiveNotifier.rank_grade_2;
        final rankGrade3 = competitiveNotifier.rank_grade_3;

        return Scaffold(
          backgroundColor: AppColors.brown_light,
          appBar: BasicAppBar(
            title: const Text(
              'Rank Overview',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: AppColors.black,
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                buildRankCard('1', rankGrade1, _progressAnimation1!),
                buildRankCard('2', rankGrade2, _progressAnimation2!),
                buildRankCard('3', rankGrade3, _progressAnimation3!),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}