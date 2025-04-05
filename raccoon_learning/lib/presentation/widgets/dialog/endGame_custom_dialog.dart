import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raccoon_learning/constants/assets/app_images.dart';
import 'package:raccoon_learning/presentation/home/custom_page.dart';
import 'package:raccoon_learning/presentation/user/notify_provider/custom_competitive_notifier.dart';
import 'package:raccoon_learning/presentation/user/notify_provider/custom_notifier.dart';

class EndgameCustomDialog extends StatelessWidget {
  final String endMatchStatus;
  const EndgameCustomDialog({super.key, required this.endMatchStatus});

  @override
  Widget build(BuildContext context) {
    final customNotifier = Provider.of<CustomNotifier>(context, listen: false);
    final competitiveNotifier = Provider.of<CustomCompetitiveNotifier>(context, listen: false);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
      onTap: () async{
        await customNotifier.resetPlayRoomId();
        await competitiveNotifier.deletePlayRoom();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const CustomPage()), // Replace with your target page
                    (route) => false,
                  );
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
