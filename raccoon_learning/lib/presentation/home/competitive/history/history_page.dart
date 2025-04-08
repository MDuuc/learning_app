import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; 
import 'package:raccoon_learning/constants/assets/app_images.dart';
import 'package:raccoon_learning/constants/theme/app_colors.dart';
import 'package:raccoon_learning/presentation/home/competitive/history/model/grade_history_model.dart';
import 'package:raccoon_learning/presentation/user/notify_provider/history_notifier.dart';



class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Load data when widget initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HistoryNotifier>(context, listen: false)
          .loadCompetitiveHistory();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            "History",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.03),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                size: 15,
                color: Colors.black,
              ),
            ),
          ),
          bottom: TabBar(
            controller: _tabController,
            labelColor: AppColors.brown_light,
            unselectedLabelColor: AppColors.black.withOpacity(0.6),
            indicatorColor: AppColors.brown_light,
            labelStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            tabs: const [
              Tab(text: 'Grade 1'),
              Tab(text: 'Grade 2'),
              Tab(text: 'Grade 3'),
            ],
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(
            color: AppColors.lightBackground,
          ),
          child: Consumer<HistoryNotifier>(
            builder: (context, historyNotifier, child) {
              if (historyNotifier.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              return TabBarView(
                controller: _tabController,
                children: [
                  _buildGradeTab(context, historyNotifier, 'grade_1'),
                  _buildGradeTab(context, historyNotifier, 'grade_2'),
                  _buildGradeTab(context, historyNotifier, 'grade_3'),
                ],
              );
            },
          ),
        )
    );
  }

  Widget _buildGradeTab(BuildContext context, HistoryNotifier notifier, String grade) {
    final gradeHistory = notifier.gradeHistories.firstWhere(
      (gh) {
        return gh.grade == grade;
      },
      orElse: () => GradeHistoryModel(grade: grade, histories: []),
    );

    if (gradeHistory.histories.isEmpty) {
      return const Center(child: Text('No history available'));
    }
    //reverse list to get newest
    final reversedHistories = gradeHistory.histories.reversed.toList();

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            ...reversedHistories.map((history) {
              final score = history.userScore != null && history.opponentScore != null
                  ? '${history.userScore} - ${history.opponentScore}'
                  : 'N/A';
              final isWin = history.status == 'win';
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: winCard(context, isWin: isWin, score: score),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}

// Keep your winCard widget as is
Widget winCard(BuildContext context, {required bool isWin, required String score}) {
  double screenHeight = MediaQuery.of(context).size.height;
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: isWin
                ? [AppColors.brown_light, AppColors.brown_light.withOpacity(0.7)]
                : [AppColors.grey, AppColors.grey.withOpacity(0.7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(isWin ? "You won this match!" : "Better luck next time!")),
              );
            },
            child: Container(
              constraints: BoxConstraints(
                minHeight: screenHeight / 9,
              ),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.transparent,
                    radius: 30,
                    backgroundImage: AssetImage(
                      isWin ? AppImages.win_raccoon : AppImages.lose_raccoon,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isWin ? "Victory!" : "Defeat",
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Colors.black26,
                                offset: Offset(1, 1),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Score: $score",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isWin ? Icons.star : Icons.close,
                    color: isWin ? Colors.green : Colors.redAccent,
                    size: 30,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}