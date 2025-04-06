import 'dart:async';
import 'package:flutter/material.dart' hide Ink;
import 'package:google_mlkit_digital_ink_recognition/google_mlkit_digital_ink_recognition.dart';
import 'package:provider/provider.dart';
import 'package:raccoon_learning/constants/assets/app_images.dart';
import 'package:raccoon_learning/constants/theme/app_colors.dart';
import 'package:raccoon_learning/presentation/user/notify_provider/User_notifier.dart';
import 'package:raccoon_learning/presentation/user/notify_provider/competitve_notifier.dart';
import 'package:raccoon_learning/presentation/widgets/dialog/endGame_dialog.dart';
import 'package:raccoon_learning/presentation/widgets/widget.dart';
import 'package:vibration/vibration.dart';

class DrawCompetitive extends StatefulWidget {
  final String grade;
  const DrawCompetitive({super.key, required this.grade});

  @override
  State<DrawCompetitive> createState() => _DrawCompetitiveState();
}

class _DrawCompetitiveState extends State<DrawCompetitive> {
  final String _language = 'en';
  late DigitalInkRecognizer _digitalInkRecognizer;
  final Ink _ink = Ink();
  List<StrokePoint> _points = [];
  String _recognizedText = '';

  // Timer
  static int maxSeconds = 30; // Changed to 30 seconds for reasonable question duration
  int seconds = maxSeconds;
  static Timer? timer;

  // Question state
  String _currentQuestion = "";
  int _correctAnswer = 0;
  String _correctCompare = "";

  @override
  void initState() {
    super.initState();
    _initializeModel();
  }

  Future<void> _initializeModel() async {
    _digitalInkRecognizer = DigitalInkRecognizer(languageCode: _language);
    final competitiveNotifier = Provider.of<CompetitveNotifier>(context, listen: false);
    await competitiveNotifier.fetchQuestions();
    competitiveNotifier.listenToPointUpdates();
    updateCurrentQuestion(); // Load first question
    startTimer();
  }

  @override
  void dispose() {
    _digitalInkRecognizer.close();
    stopTimer();
    super.dispose();
  }

  void updateCurrentQuestion() {
    final competitiveNotifier = Provider.of<CompetitveNotifier>(context, listen: false);
    setState(() {
      if (competitiveNotifier.questions.isNotEmpty &&
          competitiveNotifier.currentQuestionIndex < competitiveNotifier.questions.length) {
        _currentQuestion = competitiveNotifier.currentQuestion;
        _correctAnswer = competitiveNotifier.currentAnswer;
        _correctCompare = competitiveNotifier.currentCompare;
      } else {
        _currentQuestion = "No question available";
        _correctAnswer = 0;
        _correctCompare = "";
        Future.microtask(() {
          my_alert_dialog(context, "Error", "No questions available. Exiting match.", () {
            competitiveNotifier.existPlayRoom();
            Navigator.pop(context);
          });
        });
      }
    });
  }

  void _updateQuestion(String userAnswer) {
    final competitiveNotifier = Provider.of<CompetitveNotifier>(context, listen: false);

    setState(() {
      if (userAnswer.isNotEmpty) {
        _currentQuestion = _currentQuestion.replaceFirst("?", userAnswer);
      }
    });

    Future.delayed(const Duration(milliseconds: 200), () async {
      try {
        // Handle empty answer
        if (userAnswer.isEmpty) {
          if (competitiveNotifier.currentQuestionIndex < competitiveNotifier.questions.length - 1) {
            competitiveNotifier.currentQuestionIndex++;
            updateCurrentQuestion();
          } else {
            await competitiveNotifier.updateEndMatchStatus();
          }
          _clearPad();
          startTimer();
          return;
        }

        // Check if answer is a number
        bool isNumber = RegExp(r'^-?\d+$').hasMatch(userAnswer);
        int? parsedUserAnswer;
        if (isNumber) {
          parsedUserAnswer = int.parse(userAnswer);
        }

        // Check answer correctness
        if (_correctAnswer == parsedUserAnswer || _correctCompare == userAnswer) {
          await competitiveNotifier.updateScore();
          checkScoreAndUpdateStatus();
      }else{
        Vibration.vibrate(duration: 150);
        flutter_toast('Correct Answer: $_correctAnswer', Colors.green);
      }

        // Move to next question
        if (competitiveNotifier.currentQuestionIndex < competitiveNotifier.questions.length - 1) {
          competitiveNotifier.currentQuestionIndex++;
          updateCurrentQuestion();
        } else {
          await competitiveNotifier.updateEndMatchStatus();
        }
        _clearPad();
        startTimer();
      } catch (e) {
        print('Error processing answer: $e');
        if (competitiveNotifier.currentQuestionIndex < competitiveNotifier.questions.length - 1) {
          competitiveNotifier.currentQuestionIndex++;
          updateCurrentQuestion();
        } else {
          await competitiveNotifier.updateEndMatchStatus();
        }
        _clearPad();
        startTimer();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final competitiveNotifier = Provider.of<CompetitveNotifier>(context, listen: false);
    final userNotifier = Provider.of<UserNotifier>(context, listen: false);

    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return PopScope(
      canPop: false, // not allow to back, until u press out
      child: Scaffold(
        backgroundColor: AppColors.lightBackground,
        appBar: AppBar(
          backgroundColor: AppColors.brown_light,
          actions: [
            IconButton(
              onPressed: () {
                my_alert_dialog(context, "Exit", "Are you sure to exit the match?", () {
                  competitiveNotifier.existPlayRoom();
                });
              },
              icon: Icon(
                Icons.exit_to_app,
                color: Colors.brown.shade500,
                size: 40,
              ),
            ),
          ],
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Consumer<CompetitveNotifier>(
              builder: (context, notifier, child) {
                if (!notifier.hasShownDialog &&
                    (notifier.statusEndMatchUser == 'win' || notifier.statusEndMatchUser == 'lose')) {
                  Future.microtask(() {
                    notifier.hasShownDialog = true;
                    _showEndingDialog(context, notifier.statusEndMatchUser, widget.grade);
                  });
                }
                return const SizedBox();
              },
            ),
      
            // Timer
            buildTimer(),
      
            // Score
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(userNotifier.avatarPath),
                    radius: 30,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "${competitiveNotifier.myScore} / 10",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Image(
                    image: const AssetImage(AppImages.vs),
                    height: 80,
                  ),
                  const Spacer(),
                  Text(
                    "${competitiveNotifier.rivalScore} / 10",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 10),
                  CircleAvatar(
                    backgroundImage: NetworkImage(competitiveNotifier.avatarOpponent),
                    radius: 30,
                  ),
                ],
              ),
            ),
      
            // Main content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    // Question display
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
                          ],
                        ),
                      ),
                    ),
      
                    const SizedBox(height: 30),
      
                    // Drawing area
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
                                          t: DateTime.now().millisecondsSinceEpoch));
                                  }
      
                                  if (_ink.strokes.isNotEmpty) {
                                    _ink.strokes.last.points = _points.toList();
                                  }
                                });
                              },
                              onPanEnd: (DragEndDetails details) async {
                                setState(() {
                                  _points.clear();
                                });
                                String text = await recogniseNumber(context, _ink);
                                setState(() {
                                  _recognizedText = text;
                                });
                              },
                              child: CustomPaint(
                                painter: FullScreenSignature(ink: _ink),
                                size: Size.infinite,
                              ),
                            ),
                          ),
      
                          // Buttons
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
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
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'Recognize: $_recognizedText',
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.05,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: IconButton(
                                    icon: const Icon(Icons.verified, color: Colors.white, size: 35),
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
        ),
      ),
    );
  }

  // Clear drawing pad
  void _clearPad() {
    setState(() {
      _ink.strokes.clear();
      _points.clear();
      _recognizedText = '';
    });
  }

  // Timer handling
  void startTimer({bool reset = true}) {
    timer?.cancel();
    if (reset) {
      resetTimer();
    }

    timer = Timer.periodic(const Duration(seconds: 1), (_) {
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
      return Colors.green;
    } else if (progress > 0.3) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  Widget buildTimer() {
    Color progressColor = _getProgressColor();

    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: 10,
      child: Stack(
        children: [
          LinearProgressIndicator(
            value: seconds / maxSeconds,
            minHeight: 10,
            backgroundColor: Colors.transparent,
            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
          ),
        ],
      ),
    );
  }

  void checkScoreAndUpdateStatus() {
    final competitiveNotifier = Provider.of<CompetitveNotifier>(context, listen: false);
    if (competitiveNotifier.myScore >= 10) {
      competitiveNotifier.updateEndMatchStatus();
      timer?.cancel();
    }
  }

  void _showEndingDialog(BuildContext context, String status, String grade) {
    timer?.cancel();
    showDialog(
      context: context,
      builder: (context) {
        return EndgameDialog(endMatchStatus: status, grade: grade);
      },
    );
  }
}