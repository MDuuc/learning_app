import 'dart:async';
import 'package:flutter/material.dart' hide Ink;
import 'package:google_mlkit_digital_ink_recognition/google_mlkit_digital_ink_recognition.dart';
import 'package:provider/provider.dart';
import 'package:raccoon_learning/constants/assets/app_images.dart';
import 'package:raccoon_learning/constants/theme/app_colors.dart';
import 'package:raccoon_learning/presentation/home/learning/grade/grade1.dart';
import 'package:raccoon_learning/presentation/home/learning/grade/grade2.dart';
import 'package:raccoon_learning/presentation/home/learning/grade/grade3.dart';
import 'package:raccoon_learning/presentation/user/notify_provider/gameplay_notifier.dart';

class PlayerOnePage extends StatefulWidget {
  final String grade;
  final String operation;
   PlayerOnePage({super.key, required this.grade, required this.operation});

  @override
  State<PlayerOnePage> createState() => _PlayerOnePageState();
}

class _PlayerOnePageState extends State<PlayerOnePage> {
  
  final String _language = 'en';
  late DigitalInkRecognizer _digitalInkRecognizer;
  final Ink _ink = Ink();
  List<StrokePoint> _points = [];
  String _recognizedText = '';


  // Score point
  int _scorePoint = 0;
  int bestScore=0;

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
    recognizeAndGenerateQuestion(widget.grade);
    final userNotifier = Provider.of<GameplayNotifier>(context, listen: false);
    bestScore = userNotifier.bestScore;
  }


  @override
  void dispose() {
    // Close the recognizer to free resources
    _digitalInkRecognizer.close();
    super.dispose();
  }
  
void _updateQuestion(String userAnswer) {
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
        return;
      }
      // check is number
       bool isNumber = RegExp(r'^-?\d+$').hasMatch(userAnswer);
       int ?parsedUserAnswer;
       if (isNumber){
          parsedUserAnswer = int.parse(userAnswer);
       }
      // Check answer correctness and remaining time
      if ( _correctAnswer ==  parsedUserAnswer || _correctCompare == userAnswer) {
        recognizeAndGenerateQuestion(widget.grade);
        _clearPad();
        _handleScore(true);

      } else {
        recognizeAndGenerateQuestion(widget.grade);
        _clearPad();

      }
    } catch (e) {
      // Catch any unexpected errors
      recognizeAndGenerateQuestion(widget.grade);
      _clearPad();
    }
  });
}


  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;


    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: Column(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      // Score 
      Padding(
        padding: const EdgeInsets.only(left: 8),
        child: Row(
          children: [
            Text(
              "Best Score:",
              style: TextStyle(
                fontSize: screenWidth * 0.05, 
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              bestScore.toString(),
              style:  TextStyle(
                fontSize: screenWidth * 0.05, 
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text(
              "Score :",
              style:  TextStyle(
                fontSize: screenWidth * 0.05, 
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              _scorePoint.toString(),
              style:  TextStyle(
                fontSize: screenWidth * 0.05, 
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 20),
          ],
        ),
      ),

      // Main content
      Expanded(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              // Drawing board placeholder
              Expanded(
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      caculation(_currentQuestion, context),
                    ],
                  ),
              ),

              // Drawing area with GestureDetector
              Container(
                height: screenHeight / 3,
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
    final RenderBox object = context.findRenderObject() as RenderBox;
    final  localPosition = object.globalToLocal(details.globalPosition);

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
                        onPanEnd: (DragEndDetails details) {
                          setState(() {
                            _points.clear();
                          });
                          _recogniseText();
                        },
                        child: CustomPaint(
                          painter: Signature(ink: _ink),
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
                              icon: const Icon(Icons.delete_outline,
                                  color: Colors.white, size: 35),
                              onPressed: _clearPad,
                              tooltip: 'Clear Drawing',
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.verified,
                                  color: Colors.white, size: 35),
                              onPressed: () {
                                if (_recognizedText != 'No match found') {
                                  _updateQuestion(_recognizedText);
                                }
                                setState(() {});
                              },
                              tooltip: 'Confirm Answer',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  )
);
}

  // Recognize text from strokes
  Future<void> _recogniseText() async {
    try {
      final candidates = await _digitalInkRecognizer.recognize(_ink);
      _recognizedText = candidates.isNotEmpty ? candidates[0].text : '';
      // recognized wrong number
      switch(_recognizedText){
        case 'g':
          _recognizedText = '9';
        case 'o':
        _recognizedText = '0';
        case 'z':
        _recognizedText = '2';
        case 'c':
        _recognizedText = '<';
        case '{':
        _recognizedText = '<';
        case '(':
        _recognizedText = '<';
        case '}':
        _recognizedText = '>';
        case ')':
        _recognizedText = '>';
      }
      print(_recognizedText);
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  //clearPad
  void _clearPad() {
    setState(() {
      _ink.strokes.clear();
      _points.clear();
      _recognizedText = '';
    });
  }



//handle Score
  void _handleScore(bool isCorrect) {
  setState(() {
    if (isCorrect) {
      _scorePoint +=10;
    }
  });
}

void _showGameOverDialog() {
  double screenHeight = MediaQuery.of(context).size.height;
  double gainedCoin = _scorePoint / 10;  // Calculate the gained coin based on the score

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Game Over'),
      content: Container(
        height: screenHeight / 7,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('You ran out of hearts!', style: TextStyle(fontSize: 14),),
            const SizedBox(height: 20,),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('Your score: ', style: TextStyle(fontSize: 14)),
                Text(_scorePoint.toString(), style: TextStyle(fontSize: 14)),
              ],
            ),
            const SizedBox(height: 10,),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("Gained Coin: ", style: TextStyle(fontSize: 14)),
                Text(gainedCoin.toStringAsFixed(0), style: TextStyle(fontSize: 14)), 
                Container(
              height: 20,
              child: Image.asset(
                AppImages.coin,
              ),
          ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            // Reset game state
            _restartGame();
          },
          child: Text('Restart', style: TextStyle(fontSize: 14, color: Colors.green)),
        ),
      ],
    ),
  );
}

// update the current coin
void _updateCoin() {
  double gainedCoin = _scorePoint / 10; 
  final userNotifier = Provider.of<GameplayNotifier>(context, listen: false);
  userNotifier.updateCoin(gainedCoin.toInt());
}



void _restartGame(){
  setState(() {
      _updateCoin();
      updateBestScore(_scorePoint);
      _scorePoint=0;
      recognizeAndGenerateQuestion(widget.grade);
      _clearPad();
    });
    Navigator.pop(context);
  }

  void _restartGameForPauseDialog(){
  setState(() {
      _updateCoin();
      updateBestScore(_scorePoint);
      _scorePoint=0;
      recognizeAndGenerateQuestion(widget.grade);
      _clearPad();
    });
  }






  // save best score
  void updateBestScore(int newScore) async {
  final userNotifier = Provider.of<GameplayNotifier>(context, listen: false);

    if (newScore > bestScore) {
      userNotifier.updateBestScore(newScore);
    }
    bestScore = userNotifier.bestScore;
  }

  void recognizeAndGenerateQuestion (String grade){
    switch(grade){
      case 'grade_1':
       late final Grade1 _grade1;
       _grade1 = Grade1(widget.operation);
      setState(() {
      _currentQuestion = _grade1.generateRandomQuestion(
        onAnswerGenerated: (answer) {
          _correctAnswer = answer;
        },
        onAnswerCompare: (answer){
          _correctCompare = answer;
        }
      );
    });

    case 'grade_2':
       late final Grade2 _grade2;
       _grade2 = Grade2(widget.operation);
      setState(() {
      _currentQuestion = _grade2.generateRandomQuestion(
        onAnswerGenerated: (answer) {
          _correctAnswer = answer;
        },
      );
    });

        case 'grade_3':
       late final Grade3 _grade3;
       _grade3 = Grade3(widget.operation);
      setState(() {
      _currentQuestion = _grade3.generateRandomQuestion(
        onAnswerGenerated: (answer) {
          _correctAnswer = answer;
        },
      );
    });
    }
  }

}



// Painter 
class Signature extends CustomPainter {
  final Ink ink;

  Signature({required this.ink});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.blue
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 4.0;

    for (final stroke in ink.strokes) {
      for (int i = 0; i < stroke.points.length - 1; i++) {
        final p1 = stroke.points[i];
        final p2 = stroke.points[i + 1];
        canvas.drawLine(
          Offset(p1.x.toDouble(), p1.y.toDouble() - 100),  
          Offset(p2.x.toDouble(), p2.y.toDouble() - 100),
          paint,
        );
      }
    }
  }
  @override
  bool shouldRepaint(Signature oldDelegate) => true;
}

Widget caculation(String text, BuildContext context) {
  double screenWidth = MediaQuery.of(context).size.width;
  return Text(
    text,
    textAlign: TextAlign.center,
    style: TextStyle(
      fontSize: screenWidth * 0.06, 
      fontWeight: FontWeight.w600,
    ),
  );
}

