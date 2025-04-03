import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raccoon_learning/constants/theme/app_colors.dart';
import 'package:raccoon_learning/presentation/home/competitive/draw_competitve.dart';
import 'package:raccoon_learning/presentation/user/notify_provider/competitve_notifier.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class WaitingDialog extends StatefulWidget {
  final String grade;
  const WaitingDialog({super.key, required this.grade});
  

  @override
  State<WaitingDialog> createState() => _WaitingDialogState();
}

class _WaitingDialogState extends State<WaitingDialog> {
  bool isMatch = false;

  @override
  void initState() {
    super.initState();
    _checkForMatch();
  }

  Future<void> _checkForMatch() async {
    final competiveNotifer = Provider.of<CompetitveNotifier>(context, listen: false);
    final result = await competiveNotifer.createOrJoinGame(context,widget.grade);
    setState(() {
      isMatch = result;
    });

    if (isMatch) {
      _navigateToCompetitveScreen();
    }
  }

  void _navigateToCompetitveScreen() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => DrawCompetitive(
          grade: widget.grade,
          operation: 'mix_operations',
        ),
      ),
      (Route<dynamic> route) => false,
    );
  }
 @override
  Widget build(BuildContext context) {
    final competiveNotifer = Provider.of<CompetitveNotifier>(context, listen: false);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
              color: Colors.black.withOpacity(0.5),
            ),
          
          // Main container for the dialog
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              height: MediaQuery.of(context).size.height / 10,
              padding: EdgeInsets.symmetric(horizontal: 20),
              decoration:  const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(60),
                  bottomLeft: Radius.circular(60),
                ),
              ),
              child: Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 20),
                    child: Text(
                      "Waiting for player",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                    DefaultTextStyle(
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      child: AnimatedTextKit(
                        repeatForever: true, 
                        animatedTexts: [
                          WavyAnimatedText(" ..."),
                        ],
                      ),
                    ),
                  Spacer(),
                  // Close button to exit dialog
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: (){
                    competiveNotifer.deleteWaiting();
                      Navigator.of(context).pop();
                    }
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
