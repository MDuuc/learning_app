import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raccoon_learning/constants/assets/app_images.dart';
import 'package:raccoon_learning/presentation/home/control_page.dart';
import 'package:raccoon_learning/presentation/user/notify_provider/competitve_notifier.dart';
import 'package:raccoon_learning/presentation/widgets/dialog/rank_dialog.dart';

class EndgameDialog extends StatelessWidget {
  final String endMatchStatus;
  final String grade;
  const EndgameDialog({super.key, required this.endMatchStatus, required this.grade});

  @override
  Widget build(BuildContext context) {
    final competiveNotifer = Provider.of<CompetitveNotifier>(context, listen: false);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
      onTap: () {
                competiveNotifer.endPlayRoom();
                // Show RankDialog as a dialog instead of pushing it as a route
                showDialog(
                  context: context,
                  builder: (context) => RankDialog(grade: grade), // Pass the grade here
                ).then((_) {
                  // After RankDialog is dismissed, navigate to a new page or clear stack
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const ControlPage()), // Replace with your target page
                    (route) => false,
                  );
                });
              },
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Main dialog content
            Align(
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (endMatchStatus == 'win')
                  // Display  image
                    Image.asset(
                      AppImages.youWin,
                      fit: BoxFit.contain,
                    )
                   else if  (endMatchStatus == 'lose')
                      Image.asset(
                      AppImages.youLose,
                      fit: BoxFit.contain,
                    ),
                  const SizedBox(height: 20), 
                  // Display the "Tap anywhere to get out" text
                  const Text(
                    "Tap anywhere to get out",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
