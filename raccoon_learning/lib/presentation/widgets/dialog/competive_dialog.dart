import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:raccoon_learning/presentation/home/competitive/history/history_page.dart';
import 'package:raccoon_learning/presentation/home/competitive/rank_overview_page.dart';
import 'package:raccoon_learning/presentation/widgets/dialog/waiting_dialog.dart';
import 'package:raccoon_learning/presentation/widgets/widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CompetiveDialog extends StatelessWidget {
  const CompetiveDialog({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Blurred background
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              color: Colors.black.withOpacity(0.5),
            ),
          ),
          
          // Centered Dialog
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Choose Grade',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 20),
                
                  // Grade 1
                  buildDialogButton(
                    context,
                    text: 'Grade 1',
                    onPressed: () {
                      _showDialog(context,"grade_1");
                      // Navigator.pushAndRemoveUntil(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (BuildContext context) =>  DrawCompetitve(grade: "grade_1", operation: 'mix_operations',)
                      //     ),
                      //     (Route<dynamic> route) => false,
                      //   );
                    },
                  ),
                  
                  const SizedBox(height: 10),

                // Grade 2
                  buildDialogButton(
                    context,
                    text: 'Grade 2',
                    onPressed: () {
                      _showDialog(context,"grade_2");
                      // Navigator.pushAndRemoveUntil(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (BuildContext context) =>  DrawCompetitve(grade: "grade_2", operation: 'mix_operations',)
                      //     ),
                      //     (Route<dynamic> route) => false,
                      //   );
                    },
                  ),

                const SizedBox(height: 10),
                // Grade 3
                  buildDialogButton(
                    context,
                    text: 'Grade 3',
                    onPressed: () {
                      _showDialog(context,"grade_3");
                      // Navigator.pushAndRemoveUntil(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (BuildContext context) =>  DrawCompetitve(grade: "grade_3", operation: 'mix_operations',)
                      //     ),
                      //     (Route<dynamic> route) => false,
                      //   );
                    },
                  ),

                const SizedBox(height: 10),
                // Overview Rank
                  buildDialogButton(
                    context,
                    text: 'Overview Rank',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) =>  RankOverviewPage()
                          ),
                        );
                    },
                  ),
                const SizedBox(height: 10),
                //History
                  buildDialogButton(
                    context,
                    text: 'History',
                    onPressed: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) =>  HistoryPage()
                          ),
                        );
                    },
                  ),
                ]
              ),
            ),
          ),

          // Close Button
          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
  void _showDialog(BuildContext context, String grade) {
  Navigator.pop(context);
  showDialog(
    context: context,
    builder: (context) {
      return WaitingDialog(grade: grade,); 
    },
  );
}
}
