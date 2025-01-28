// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:raccoon_learning/presentation/home/learning/draw_page.dart';
import 'package:raccoon_learning/presentation/widgets/widget.dart';

class OperationDialog extends StatelessWidget {
  final String  grade;
  OperationDialog({
    Key? key,
    required this.grade,
  }) : super(key: key);

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
                    'Operation',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // +
                  buildDialogButton(
                    context,
                    text: 'Addition',
                    icon: Icons.add,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) =>  DrawPage(grade: grade, operation: 'addition',)
                          )
                        );
                    },
                  ),
                  
                  const SizedBox(height: 10),
                  
                  // -
                  buildDialogButton(
                    context,
                    text: 'Subtraction',
                    icon: Icons.remove,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) =>  DrawPage(grade: grade, operation: 'subtraction',)
                          )
                        );
                    },
                  ),
                  
                  const SizedBox(height: 10),
                  if (grade =='grade_1')...[
                    // Compare ><
                    buildDialogButton(
                      context,
                      text: 'Comparation',
                      icon: Icons.compare_arrows,
                      onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) =>  DrawPage(grade: grade, operation: 'comparation',)
                          )
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                  ]
                  else if(grade == 'grade_2')...[
                  // x
                  buildDialogButton(
                    context,
                    text: 'Multiplication ',
                    icon: Icons.close,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) =>  DrawPage(grade: grade, operation: 'multiplication',)
                          )
                        );
                    },
                  ),
                  const SizedBox(height: 10),
                  ] else if (grade=='grade_3' || grade=='grade_4' || grade=='grade_5') ...[
                    // x
                  buildDialogButton(
                    context,
                    text: 'Multiplication ',
                    icon: Icons.close,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) =>  DrawPage(grade: grade, operation: 'multiplication',)
                          )
                        );
                    },
                  ),
                  const SizedBox(height: 10),
                  // %
                  buildDialogButton(
                    context,
                    text: 'Dividision',
                    icon: Icons.percent_rounded,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) =>  DrawPage(grade: grade, operation: 'division',)
                          )
                        );
                    },
                  ),
                  const SizedBox(height: 10),
                  ],
                // Mix
                  buildDialogButton(
                    context,
                    text: 'Mix Operations',
                    icon: Icons.calculate,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) =>  DrawPage(grade: grade, operation: 'mix_operations',)
                          )
                        );                      
                    },
                  ),
                ],
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
}

