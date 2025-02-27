import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raccoon_learning/constants/assets/app_images.dart';
import 'package:raccoon_learning/constants/theme/app_colors.dart';
import 'package:raccoon_learning/presentation/home/learning/twoPlayer/first_player_page.dart';
import 'package:raccoon_learning/presentation/home/learning/twoPlayer/second_player_page.dart';
import 'package:raccoon_learning/presentation/user/notify_provider/two_players_notifier.dart';
import 'package:raccoon_learning/presentation/widgets/dialog/pause_dialog.dart';

class SplitScreenPage extends StatefulWidget {
  final String grade;
  final String operation;
  const SplitScreenPage({super.key, required this.grade, required this.operation});

  @override
  State<SplitScreenPage> createState() => _SplitScreenPageState();
}


class _SplitScreenPageState extends State<SplitScreenPage> {
  //countime bar
  static int maxSeconds = 30;
  int seconds = maxSeconds;
  static Timer? timer;

  bool _isReady = false;
  bool _isWinPlayerOne = false;
  bool _isWinPlayerTwo = false;
  bool _isDraw = false;

@override
void initState() {
  super.initState();
  Provider.of<TwoPlayersNotifier>(context, listen: false).generateQuestions(widget.grade, widget.operation);
}
@override
  void dispose(){
    stopTimer();
  super.dispose();
}

 //countime bar handle
 void startTimer({bool reset = true}) {
    timer?.cancel();
    if (reset) {
      resetTimer();
    }

     timer = Timer.periodic(Duration(seconds: 1), (_) {
      if (seconds > 0) {
        setState(() => seconds--);
      } else {
        findTheWinner();
      }
    });
  }

  void stopTimer({bool reset = true}) {
    if (reset) {
      resetTimer();
    }
    setState(() => timer?.cancel());
  }

  void resetTimer() => setState(() => seconds = maxSeconds);
  void findTheWinner() {
    final player = Provider.of<TwoPlayersNotifier>(context, listen: false);
    if (player.pointPlayerOne > player.pointPlayerTwo) {
      setState(() {
        _isWinPlayerOne = true;
        _isWinPlayerTwo = false;
      });
    } else if (player.pointPlayerOne < player.pointPlayerTwo) {
      setState(() {
        _isWinPlayerOne = false;
        _isWinPlayerTwo = true;
      });
    } else {
      setState(() {
        _isDraw = true;
      });
    }
}

    void restartGamePlay(){
     final notifier = Provider.of<TwoPlayersNotifier>(context, listen: false);
      notifier.pointPlayerOne = 0;
      notifier.pointPlayerTwo = 0;
      notifier.generateQuestions(widget.grade, widget.operation);
      notifier.clearPad();
      startTimer();  
    }

@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: AppColors.lightBackground,
    body: 
      Consumer<TwoPlayersNotifier>(
        builder: (context, notifier, child) {
          return Stack(
            children: [
            Column(
              children: [
                Expanded(
                  child: RotatedBox(
                    quarterTurns: 2,
                    child: SecondPlayerPage(
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Transform.flip(
                        flipX: true,
                        child: LinearProgressIndicator(
                          value: seconds / maxSeconds,
                          minHeight: 10,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(_getProgressColor(seconds, maxSeconds)),
                        ),
                      ),
                    ),
                    IconButton(
                        onPressed: () async {
                            stopTimer(reset: false);
                          final result = await showPauseDialog(context);
                            switch (result) {
                            case 'resume':
                              startTimer(reset: false);
                              break;
                            case 'restart':
                              restartGamePlay();
                            break;
                            case 'exit':
                            Navigator.pop(context);
                              break;
                          }
                        },
                        icon: const Icon(Icons.pause, color:  AppColors.darkGrey, size: 50),
                      ),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: seconds / maxSeconds,
                        minHeight: 10,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(_getProgressColor(seconds, maxSeconds)),
                      ),
                    ),
                  ],
                ),
                  
                Expanded(
                  child: FirstPlayerPage(
                  ),
                ),
              ],
            ),

      // This part show overlay ready, win. lose
       if(!_isReady)
        Positioned.fill(
          child: GestureDetector(
            onTap: (){
              startTimer();
              setState(() {
                _isReady=true;
              });
            },
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                color: Colors.black.withOpacity(0.5),
                alignment: Alignment.center,
                child: Image.asset(
                  AppImages.are_you_ready,
                  fit: BoxFit.contain,
                  ),
              ),
            ),
          )),

        if(_isWinPlayerOne)
        Positioned.fill(
          child: GestureDetector(
            onTap: (){
              restartGamePlay();
              setState(() {
                _isWinPlayerOne=false;
              });
            },
              child: Container(
                color: Colors.black.withOpacity(0.3),
                alignment: Alignment.center,
                child: Column(
                  children: [
                  Expanded(
                    child: RotatedBox(
                      quarterTurns: 2,
                      child: Image.asset(
                      AppImages.youLose,
                      fit: BoxFit.contain,
                      ),
                    )
                    ),
                  Expanded(
                      child: Image.asset(
                      AppImages.youWin,
                      fit: BoxFit.contain,
                      ),
                    )
                  ]
                ),
              ),
            ),
          ),

        if(_isWinPlayerTwo)
        Positioned.fill(
          child: GestureDetector(
            onTap: (){
              restartGamePlay();
              setState(() {
                _isWinPlayerTwo=false;
              });
            },
              child: Container(
                color: Colors.black.withOpacity(0.3),
                alignment: Alignment.center,
                child: Column(
                  children: [
                  Expanded(
                    child: RotatedBox(
                      quarterTurns: 2,
                      child: Image.asset(
                      AppImages.youWin,
                      fit: BoxFit.contain,
                      ),
                    )
                    ),
                  Expanded(
                      child: Image.asset(
                      AppImages.youLose,
                      fit: BoxFit.contain,
                      ),
                    )
                  ]
                ),
              ),
            ),
          ),

        if(_isDraw)
        Positioned.fill(
          child: GestureDetector(
            onTap: (){
              restartGamePlay(); 
              setState(() {
                _isDraw=false;
              });
            },
              child: Container(
                color: Colors.black.withOpacity(0.3),
                alignment: Alignment.center,
                child: Column(
                  children: [
                  Expanded(
                    child: RotatedBox(
                      quarterTurns: 2,
                      child: Image.asset(
                      AppImages.draw,
                      fit: BoxFit.contain,
                      ),
                    )
                    ),
                  Expanded(
                      child: Image.asset(
                      AppImages.draw,
                      fit: BoxFit.contain,
                      ),
                    )
                  ]
                ),
              ),
            ),
          )
            ]
          );
        },
      ),
  );
}

    Color _getProgressColor(int seconds, int maxSeconds) {
    double progress = seconds / maxSeconds;

    if (progress > 0.3) {
      return AppColors.primary; 
    } else {
      return Colors.red; 
    }
  }
}
