// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:raccoon_learning/presentation/home/learning/onePlayer/draw_page.dart';
import 'package:raccoon_learning/presentation/home/learning/twoPlayer/split_screen_page.dart';
import 'package:raccoon_learning/presentation/widgets/widget.dart';

class OperationDialog extends StatefulWidget {
  final String grade;

  const OperationDialog({
    Key? key,
    required this.grade,
  }) : super(key: key);

  @override
  State<OperationDialog> createState() => _OperationDialogState();
}

class _OperationDialogState extends State<OperationDialog> {
  bool chooseOperation = false;
  String operation = '';

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
              child: !chooseOperation
                  ? Column(
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

                        // Addition
                        buildDialogButton(
                          context,
                          text: 'Addition',
                          icon: Icons.add,
                          onPressed: () {
                            operation = 'addition';
                            setState(() {
                              chooseOperation = true;
                            });
                          },
                        ),
                        const SizedBox(height: 10),

                        // Subtraction
                        buildDialogButton(
                          context,
                          text: 'Subtraction',
                          icon: Icons.remove,
                          onPressed: () {
                            operation = 'subtraction';
                            setState(() {
                              chooseOperation = true;
                            });
                          },
                        ),
                        const SizedBox(height: 10),

                        if (widget.grade == 'grade_1') ...[
                          // Comparison
                          buildDialogButton(
                            context,
                            text: 'Comparison',
                            icon: Icons.compare_arrows,
                            onPressed: () {
                              operation = 'comparison';
                            setState(() {
                              chooseOperation = true;
                            });
                            },
                          ),
                          const SizedBox(height: 10),
                        ] else if (widget.grade == 'grade_2' ||
                            widget.grade == 'grade_3' ||
                            widget.grade == 'grade_4' ||
                            widget.grade == 'grade_5') ...[
                          // Multiplication
                          buildDialogButton(
                            context,
                            text: 'Multiplication',
                            icon: Icons.close,
                            onPressed: () {
                              operation = 'multiplication';
                            setState(() {
                              chooseOperation = true;
                            });
                            },
                          ),
                          const SizedBox(height: 10),
                        ],
                        if (widget.grade == 'grade_3' ||
                            widget.grade == 'grade_4' ||
                            widget.grade == 'grade_5') ...[
                          // Division
                          buildDialogButton(
                            context,
                            text: 'Division',
                            icon: Icons.percent_rounded,
                            onPressed: () {
                              operation = 'division';
                              setState(() {
                                chooseOperation = true;
                              });
                            },
                          ),
                          const SizedBox(height: 10),
                        ],

                        // Mix Operations
                        buildDialogButton(
                          context,
                          text: 'Mix Operations',
                          icon: Icons.calculate,
                          onPressed: () {
                            operation = 'mix_operations';
                              setState(() {
                                chooseOperation = true;
                              });
                          },
                        ),
                      ],
                    )
                  : Column(
                    mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      chooseOperation = false;
                                    });
                                  },
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
                              ),
                            ),

                            Text(
                              'Mode',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                            ),
                            Expanded(child: SizedBox()),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // 1 Player
                        buildDialogButton(
                          context,
                          text: '1 Player',
                          onPressed: () {
                             Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (BuildContext context) => DrawPage(
                                  grade: widget.grade,
                                  operation: operation,
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 10),

                        // 2 Player
                        buildDialogButton(
                          context,
                          text: '2 Player',
                          onPressed: () {
                             Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (BuildContext context) => SplitScreenPage(
                                  grade: widget.grade,
                                  operation: operation,
                                ),
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
}
