import 'dart:async';
import 'package:flutter/material.dart' hide Ink;
import 'package:google_mlkit_digital_ink_recognition/google_mlkit_digital_ink_recognition.dart';
import 'package:provider/provider.dart';
import 'package:raccoon_learning/constants/assets/app_images.dart';
import 'package:raccoon_learning/constants/theme/app_colors.dart';
import 'package:raccoon_learning/presentation/home/learning/grade/grade1.dart';
import 'package:raccoon_learning/presentation/home/learning/grade/grade2.dart';
import 'package:raccoon_learning/presentation/home/learning/grade/grade3.dart';
import 'package:raccoon_learning/presentation/home/learning/grade/math_question.dart';
import 'package:raccoon_learning/presentation/user/notify_provider/User_notifier.dart';
import 'package:raccoon_learning/presentation/user/notify_provider/competitve_notifier.dart';
import 'package:raccoon_learning/presentation/widgets/dialog/endGame_dialog.dart';
import 'package:raccoon_learning/presentation/widgets/widget.dart';

class DrawCompetitve extends StatefulWidget {
  final String grade;
  final String operation;
   DrawCompetitve({super.key, required this.grade, required this.operation});

  @override
  State<DrawCompetitve> createState() => _DrawCompetitveState();
}

class _DrawCompetitveState extends State<DrawCompetitve> {
  
  final String _language = 'en';
  late DigitalInkRecognizer _digitalInkRecognizer;
  final Ink _ink = Ink();
  List<StrokePoint> _points = [];
  String _recognizedText = '';

  //countime bar
  static int maxSeconds = 10000;
  int seconds = maxSeconds;
  static Timer? timer;

  // Score point

  //for question 
  String _currentQuestion = "";
  int _correctAnswer = 0;
  String _correctCompare="";
  // Initialize Grade1 with the operation passed from the widget
  // late final Grade1 _grade1;

  
    @override
  void initState() {
    super.initState();
    _initializeModel();
  }

  Future<void> _initializeModel() async {
    _digitalInkRecognizer = DigitalInkRecognizer(languageCode: _language);
    final competitiveNotifier = Provider.of<CompetitveNotifier>(context, listen: false);
    competitiveNotifier.listenToPointUpdates();
    recognizeAndGenerateQuestion(widget.grade);
    startTimer();
  }


  @override
  void dispose() {
    // Close the recognizer to free resources
    _digitalInkRecognizer.close();
    stopTimer();
    super.dispose();
  }
  
void _updateQuestion(String userAnswer) {
  final competitiveNotifier = Provider.of<CompetitveNotifier>(context, listen: false);

  setState(() {
    if (userAnswer.isNotEmpty) {
      _currentQuestion = _currentQuestion.replaceFirst("?", userAnswer);
    }
  });
  Future.delayed(const Duration(milliseconds: 500), () {
    try {
      // Handle empty answer
      if (userAnswer.isEmpty) {
        recognizeAndGenerateQuestion(widget.grade);
        _clearPad();
        startTimer();
        return;
      }
      // check is number
       bool isNumber = RegExp(r'^-?\d+$').hasMatch(userAnswer);
       int ?parsedUserAnswer;
       if (isNumber){
          parsedUserAnswer = int.parse(userAnswer);
       }
      // Check answer correctness, remaining time , if score reach to 10 end-match
      if ( _correctAnswer ==  parsedUserAnswer || _correctCompare == userAnswer) {
        recognizeAndGenerateQuestion(widget.grade);
        _clearPad();
        startTimer();
        competitiveNotifier.updateScore();
        checkScoreAndUpdateStatus();

      } else {
        recognizeAndGenerateQuestion(widget.grade);
        _clearPad();
        startTimer();
      }
    } catch (e) {
      // Catch any unexpected errors
      recognizeAndGenerateQuestion(widget.grade);
      _clearPad();
      startTimer();
    }
  });
}


  @override
  Widget build(BuildContext context) {
    final competiveNotifer = Provider.of<CompetitveNotifier>(context, listen: false);
    final userNotifer = Provider.of<UserNotifier>(context, listen: false);

    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: AppColors.brown_light,
          actions: [
          IconButton(
            onPressed: () async{
              my_alert_dialog(context, "Exit", "Are you sure to exit the match", (){
                competiveNotifer.existPlayRoom();
              }
               );
            },
            icon: Icon(Icons.exit_to_app,
            color: Colors.brown.shade500,
            size: 40,) 
          ),
        ]
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Consumer<CompetitveNotifier>(
          builder: (context, notifier, child) {
            if (!notifier.hasShownDialog&&(notifier.statusEndMatchUser == 'win' || notifier.statusEndMatchUser == 'lose')) {
              Future.microtask((){ 
              notifier.hasShownDialog=true;
              _showEndingDialog(context, notifier.statusEndMatchUser, widget.grade);});
            }
            return const SizedBox(); 
          },
        ),

          //Countime
          buildTimer(),

          //Score 
          Padding(
            padding: const EdgeInsets.all(8.0),
            child:  Row(
              children: [
               CircleAvatar(
                backgroundImage: NetworkImage(userNotifer.avatarPath),
                radius: 30,
               ),
                const SizedBox(width: 10,),
                Text(
                  "${competiveNotifer.myScore} / 10",
                   style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600
                  ),
                  ),
                const Spacer(),
               Image(image: AssetImage(
                 AppImages.vs
               ),
               height: 80,
               ),
                const Spacer(),
                 Text(
                  "${competiveNotifer.rivalScore} / 10",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600
                ),
                ),
                const SizedBox(width: 10,),
               CircleAvatar(
                backgroundImage: NetworkImage(competiveNotifer.avatarOpponent),
                radius: 30,
               ),
               //handle endMatch status
              ],
            ),
          ),
                
          // Main content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  // Drawing board placeholder
                  Expanded(
                    child: Container(
                      width: screenWidth,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: AppColors.primary, width: 8),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            offset: const Offset(4, 4),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                         fullScreenCaculation(_currentQuestion),

                        //  caculation(_recognizedText),

                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Drawing area with GestureDetector
                  Container(
                    height: screenHeight / 2,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: AppColors.primary, width: 8),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          offset: const Offset(4, 4),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween, 
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onPanStart: (DragStartDetails details) {
                              setState(() {
                                _ink.strokes.add(Stroke());
                              });
                            },
                            onPanUpdate: (DragUpdateDetails details) {
                              setState(() {
                                final RenderObject? object = context.findRenderObject();
                                final localPosition = (object as RenderBox?)?.globalToLocal(details.localPosition);

                                if (localPosition != null) {
                                  _points = List.from(_points)
                                    ..add(StrokePoint(
                                      x: localPosition.dx,
                                      y: localPosition.dy,
                                      t: DateTime.now().millisecondsSinceEpoch,
                                    ));
                                }

                                if (_ink.strokes.isNotEmpty) {
                                  _ink.strokes.last.points = _points.toList();
                                }
                              });
                            },
                            onPanEnd: (DragEndDetails details) async{
                              setState(() {
                                _points.clear();
                              });
                            //this be imported from widget.dart
                            String text= await recogniseNumber(context, _ink);
                            setState(() {
                            _recognizedText = text; // Update state correctly
                          });
                            },
                            child: CustomPaint(
                              painter: FullScreenSignature(ink: _ink),
                              size: Size.infinite,
                            ),
                          ),
                        ),

                      // Button
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly, 
                          children: [
                            Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.white, size: 35),
                                onPressed: _clearPad,
                                tooltip: 'Clear Drawing',
                              ),
                            ),
                          Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Recognize: ${_recognizedText}',
                              style: TextStyle(
                                  fontSize: screenWidth * 0.05, 
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary
                              ),
                            )
                          ),
                          Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.verified, color: Colors.white, size: 35),
                              onPressed: (){
                                if (_recognizedText != 'No match found') {
                                _updateQuestion(_recognizedText);
                              }
                              setState(() {});
                              },
                              tooltip: 'Confirm Anwser',
                            ),
                          ),
                        ],
                      ),
                    ),],
                  ),
                  )
                ],
            ),
          ),
        ),
      ],
    ),
  );
}

  //clearPad
  void _clearPad() {
    setState(() {
      _ink.strokes.clear();
      _points.clear();
      _recognizedText = '';
    });
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
        _updateQuestion(_recognizedText);
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

  Color _getProgressColor() {
    double progress = seconds / maxSeconds;

    if (progress > 0.5) {
      return Colors.green; // Color for more than 50%
    } else if (progress > 0.3) {
      return Colors.orange; // Color for between 30% and 50%
    } else {
      return Colors.red; // Color for less than 30%
    }
  }

  Widget buildTimer() {
    Color progressColor = _getProgressColor();

    return SizedBox(
      width: MediaQuery.of(context).size.width , // Full width minus padding
      height: 10, // Adjust the height of the progress bar
      child: Stack(
        children: [
          LinearProgressIndicator(
            value: seconds / maxSeconds,
            minHeight: 10,
            backgroundColor: Colors.transparent,
            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
          ),
          // Center(
          //   child: buildTime(),
          // ),
        ],
      ),
    );
  }
  // end widget countime bar handle


Future<void> recognizeAndGenerateQuestion(String grade) async {
  switch (grade) {
    case 'grade_1':
      final Grade1 _grade1 = Grade1(widget.operation); 
      try {
        final MathQuestion mathQuestion = await _grade1.generateRandomQuestion(context: context);
        setState(() {
          _currentQuestion = mathQuestion.question;
          // _currentOperator = mathQuestion.operator;
          _correctAnswer = mathQuestion.correctAnswer;
          _correctCompare = mathQuestion.correctCompare!; 
        });
      } catch (e) {
        print('Error generating question for Grade 1: $e');
      }
      break;

    case 'grade_2':
      final Grade2 _grade2 = Grade2(widget.operation); 
      try {
        final MathQuestion mathQuestion = await _grade2.generateRandomQuestion(context: context);
        setState(() {
          _currentQuestion = mathQuestion.question;
          // _currentOperator = mathQuestion.operator;
          _correctAnswer = mathQuestion.correctAnswer;
          _correctCompare = mathQuestion.correctCompare!; 
        });
      } catch (e) {
        print('Error generating question for Grade 2: $e');
      }
      break;

    case 'grade_3':
      final Grade3 _grade3 = Grade3(widget.operation); 
      try {
        final MathQuestion mathQuestion = await _grade3.generateRandomQuestion(context: context);
        setState(() {
          _currentQuestion = mathQuestion.question;
          // _currentOperator = mathQuestion.operator;
          _correctAnswer = mathQuestion.correctAnswer;
          _correctCompare = mathQuestion.correctCompare!; 
        });
      } catch (e) {
        print('Error generating question for Grade 3: $e');
      }
      break;

    default:
      print('Unsupported grade: $grade');
      break;
  }
}

  void checkScoreAndUpdateStatus(){
  final competitiveNotifier = Provider.of<CompetitveNotifier>(context, listen: false);
  if (competitiveNotifier.myScore==10 ){
    competitiveNotifier.updateEndMatchStatus();
    timer?.cancel();
  }
}

    void _showEndingDialog(BuildContext context, String status, String grade) {
    timer?.cancel();
    showDialog(
      context: context,
      builder: (context) {
        return EndgameDialog(endMatchStatus: status, grade:  grade,); 
      },
    );
}

}

