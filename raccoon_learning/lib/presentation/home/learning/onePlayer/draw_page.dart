import 'dart:async';
import 'package:flutter/material.dart' hide Ink;
import 'package:google_mlkit_digital_ink_recognition/google_mlkit_digital_ink_recognition.dart';
import 'package:provider/provider.dart';
import 'package:raccoon_learning/constants/assets/app_images.dart';
import 'package:raccoon_learning/constants/theme/app_colors.dart';
import 'package:raccoon_learning/presentation/home/analysis_data/analysis.dart';
import 'package:raccoon_learning/presentation/home/learning/grade/grade1.dart';
import 'package:raccoon_learning/presentation/home/learning/grade/grade2.dart';
import 'package:raccoon_learning/presentation/home/learning/grade/grade3.dart';
import 'package:raccoon_learning/presentation/home/learning/grade/math_question.dart';
import 'package:raccoon_learning/presentation/service/speech_recognise.dart';
import 'package:raccoon_learning/presentation/user/notify_provider/gameplay_notifier.dart';
import 'package:raccoon_learning/presentation/widgets/dialog/pause_dialog.dart';
import 'package:raccoon_learning/presentation/widgets/widget.dart';

class DrawPage extends StatefulWidget {
  final String grade;
  final String operation;
   DrawPage({super.key, required this.grade, required this.operation});

  @override
  State<DrawPage> createState() => _DrawPageState();
}

class _DrawPageState extends State<DrawPage> {
  late SpeechService _speechService;
  final String _language = 'en';
  late DigitalInkRecognizer _digitalInkRecognizer;
  final Ink _ink = Ink();
  List<StrokePoint> _points = [];
  String _recognizedText = '';

  //countime bar
  static int maxSeconds = 30;
  int seconds = maxSeconds;
  static Timer? timer;

  // Score point
  int _scorePoint = 0;
  int bestScore=0;

//3 heart for beginning
  List<String> heartIcons = ['heart', 'heart', 'heart'];

  //for question 
  String _currentQuestion = "";
  String _currentOperator = "";
  int _correctAnswer = 0;
  String _correctCompare="";
// Initialize Grade1 with the operation passed from the widget
  // late final Grade1 _grade1;

  bool _isDrawing = false;
  String _speechText='';
  
    @override
  void initState() {
    super.initState();
    _initializeModel();
  }

  Future<void> _initializeModel() async {
    _digitalInkRecognizer = DigitalInkRecognizer(languageCode: _language);
    recognizeAndGenerateQuestion(widget.grade);
    startTimer();
    final userNotifier = Provider.of<GameplayNotifier>(context, listen: false);
    bestScore = userNotifier.bestScore;
    _speechService = SpeechService();
  }


  @override
  void dispose() {
    _speechService.dispose();
    // Close the recognizer to free resources
    _digitalInkRecognizer.close();
    timer?.cancel();
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
        startTimer();
        _handleHeart(false);
        return;
      }
      // check is number
       bool isNumber = RegExp(r'^-?\d+$').hasMatch(userAnswer);
       int ?parsedUserAnswer;
       if (isNumber){
          parsedUserAnswer = int.parse(userAnswer);
       }
      // Check answer correctness and remaining time
      if ( _correctAnswer ==  parsedUserAnswer || _correctCompare == userAnswer){
        appendToMathDataCsv( operator:_currentOperator,correct:  1,time:  seconds, grade:  widget.grade );
        recognizeAndGenerateQuestion(widget.grade);
        _clearPad();
        startTimer();
        _handleScore(true);

      } else {
        appendToMathDataCsv( operator:_currentOperator,correct:  0,time:  seconds, grade:  widget.grade );
        recognizeAndGenerateQuestion(widget.grade);
        _clearPad();
        startTimer();
        _handleHeart(false);

      }
    } catch (e) {
      // Catch any unexpected errors
      recognizeAndGenerateQuestion(widget.grade);
      _clearPad();
      startTimer();
      _handleHeart(false);
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
          // Header with icons
          Container(
            color: Colors.blue.shade400,
            height: screenHeight / 7,
            width: screenWidth,
            child: 
            Padding(
              padding: const EdgeInsets.only(left: 8, right: 8, top: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: List.generate(3, (index) {
                  return Icon(
                    heartIcons[index] == 'heart'
                        ? Icons.favorite
                        : Icons.favorite_border, 
                    color: heartIcons[index] == 'heart'
                        ? Colors.red
                        : Colors.grey, 
                    size: 35,
                  );
                })
                ),
          
                  IconButton(
                    onPressed: () async {
                      stopTimer(reset: false);
                      final result = await showPauseDialog(context);

                      // Handle the result from the dialog
                      switch (result) {
                        case 'resume':
                          startTimer(reset: false);
                          break;
                        case 'restart':
                          _restartGameForPauseDialog();
                          break;
                        case 'exit':
                          _updateCoin();
                          updateBestScore(_scorePoint);
                          Navigator.pop(context);
                          break;
                      }
                    },
                    icon: const Icon(Icons.pause, color: Colors.white, size: 50,),
                  ),
                ],
              ),
            ),
          ),

          //Countime
          buildTimer(),

          //Score 
          Padding(
            padding: const EdgeInsets.all(8.0),
            child:  Row(
              children: [
                const Text(
                  "Best Score:",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600
                ),
                ),
                const SizedBox(width: 10,),
                Text(
                  bestScore.toString(),
                   style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600
                  ),
                  ),
                const Spacer(),
                const Text(
                  "Score:",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600
                ),
                ),
                const SizedBox(width: 10,),
                Text(
                  _scorePoint.toString(),
                   style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600
                  ),
                  ),
                  const SizedBox(width: 20,),
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
                child: _isDrawing
                // Speech UI
                 ? Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  shape: BoxShape.circle
                                ),
                                child: IconButton(
                                  icon: Icon(Icons.keyboard, color: Colors.white, size: 35),
                                  onPressed: (){
                                    setState(() {
                                      _isDrawing = !_isDrawing;
                                    });
                                  },
                                  tooltip: 'Speech',
                                ),
                              ),
                            ],
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ValueListenableBuilder<String>(
                          valueListenable: _speechService.textNotifier,
                          builder: (context, text, child) {
                            _speechText=text;
                            return Text(text, style: const TextStyle(fontSize: 20.0), textAlign: TextAlign.center);
                          },
                        ),
                      ),
                      GestureDetector(
                        onTapDown: (_) => _speechService.startListening((text) {
                          setState(() {}); 
                        }),
                        onTapUp: (_) => _speechService.stopListening(),
                        child: ValueListenableBuilder<bool>(
                          valueListenable: _speechService.isListeningNotifier,
                          builder: (context, isListening, child) {
                            return Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(16.0),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isListening ? Colors.red : Colors.blue,
                                    ),
                                    child: Icon(
                                      isListening ? Icons.pause : Icons.mic,
                                      size: 60.0,
                                      color: Colors.white,
                                    ),
                                  ),
                                    Padding(
                                      padding: EdgeInsets.only(right: 20),
                                      child: Align(
                                        alignment: Alignment.bottomRight,
                                        child: Container(
                                          padding: EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: Colors.green,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: IconButton(
                                            icon: const Icon(Icons.verified, color: Colors.white, size: 35),
                                            onPressed: (){
                                              if (_speechText != 'No match found') {
                                              _updateQuestion(_speechText);
                                            }
                                            setState(() {});
                                            },
                                            tooltip: 'Confirm Anwser',
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  )
                  //Draw UI
                 :Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween, 
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle
                            ),
                            child: IconButton(
                              icon: Icon(Icons.mic , color: Colors.white, size: 35),
                              onPressed: (){
                                setState(() {
                                  _isDrawing = !_isDrawing;
                                });
                              },
                              tooltip: 'Draw',
                            ),
                          ),
                        ],
                      ),
                    ),
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
                        //recognize Interface
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



  //handle Heart
  void _handleHeart(bool isCorrect) {
  setState(() {
    if (!isCorrect) {
      for (int i = 0; i < heartIcons.length; i++) {
        if (heartIcons[i] == 'heart') {
          heartIcons[i] = 'broken_heart';
          break; 
        }
      }
    }
    if (heartIcons.every((icon) => icon == 'broken_heart')) {
          timer?.cancel();
        _showGameOverDialog();
      }
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
      heartIcons = ['heart', 'heart', 'heart'];
      _scorePoint=0;
      recognizeAndGenerateQuestion(widget.grade);
      _clearPad();
      _speechService.defaultText();
      startTimer();

    });
    Navigator.pop(context);
  }

  void _restartGameForPauseDialog(){
  setState(() {
      _updateCoin();
      updateBestScore(_scorePoint);
      heartIcons = ['heart', 'heart', 'heart'];
      _scorePoint=0;
      recognizeAndGenerateQuestion(widget.grade);
      _clearPad();
      _speechService.defaultText();
      startTimer();

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


  Widget buildTimer() {
    Color progressColor = getProgressColor(seconds, maxSeconds);
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
      MathQuestion mathQuestion = _grade1.generateRandomQuestion(context: context);
      _currentQuestion = mathQuestion.question;
      _currentOperator = mathQuestion.operator;
      _correctAnswer = mathQuestion.correctAnswer;
      _correctCompare= mathQuestion.correctCompare.toString();
    });

    case 'grade_2':
       late final Grade2 _grade2;
       _grade2 = Grade2(widget.operation);
      setState(() {
      MathQuestion mathQuestion = _grade2.generateRandomQuestion(context: context);
      _currentQuestion = mathQuestion.question;
      _currentOperator = mathQuestion.operator;
      _correctAnswer = mathQuestion.correctAnswer;
    });

        case 'grade_3':
       late final Grade3 _grade3;
       _grade3 = Grade3(widget.operation);
      setState(() {
      MathQuestion mathQuestion = _grade3.generateRandomQuestion(context: context);
      _currentQuestion = mathQuestion.question;
      _currentOperator = mathQuestion.operator;
      _correctAnswer = mathQuestion.correctAnswer;
    });
    }
  }

}
