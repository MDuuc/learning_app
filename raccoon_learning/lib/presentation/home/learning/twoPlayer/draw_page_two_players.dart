import 'package:flutter/material.dart';
import 'package:raccoon_learning/constants/theme/app_colors.dart';
import 'package:raccoon_learning/presentation/home/learning/twoPlayer/player_one_page.dart';
import 'package:raccoon_learning/presentation/home/learning/twoPlayer/player_two_page.dart';
import 'package:raccoon_learning/presentation/widgets/dialog/pause_dialog.dart';

class DrawPageTwoPlayers extends StatefulWidget {
  final String grade;
  final String operation;
  const DrawPageTwoPlayers({super.key, required this.grade, required this.operation});

  @override
  State<DrawPageTwoPlayers> createState() => _DrawPageTwoPlayersState();
}

class _DrawPageTwoPlayersState extends State<DrawPageTwoPlayers> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body:  Column(
      children: [
          Expanded(
            child: RotatedBox(
              quarterTurns: 2,
              child: Navigator(
                onGenerateRoute: (settings) {
                  return MaterialPageRoute(
                    builder: (_) => PlayerOnePage(grade: widget.grade, operation: widget.operation),
                  );
                },
              ),
            ),
          ),

          Row(
          children: [
            Expanded(
              child: Divider(
                thickness: 8, 
                color: AppColors.primary, 
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 2), 
              child: IconButton(
                onPressed: () async {
                  final result = await showPauseDialog(context);

                  // Handle the result from the dialog
                  switch (result) {
                    case 'resume':
                      // startTimer(reset: false);
                      break;
                    case 'restart':
                      // _restartGameForPauseDialog();
                      break;
                    case 'exit':
                      // _updateCoin();
                      // updateBestScore(_scorePoint);
                      Navigator.pop(context);
                      break;
                  }
                },
                icon: const Icon(Icons.pause, color: Colors.green, size: 50,),
              ),
            ),
            Expanded(
              child: Divider(
                thickness: 8,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
          Expanded(
          child: Navigator(
              onGenerateRoute: (settings){
                return MaterialPageRoute(builder: (_) => PlayerOnePage(grade: widget.grade, operation: widget.operation));
              },
            ),
          )
      ],
    ),
    );
  }
}