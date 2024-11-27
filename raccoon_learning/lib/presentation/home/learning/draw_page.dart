import 'package:flutter/material.dart' hide Ink;
import 'package:google_mlkit_digital_ink_recognition/google_mlkit_digital_ink_recognition.dart';
import 'package:raccoon_learning/constants/theme/app_colors.dart';
import 'package:raccoon_learning/presentation/home/learning/grade/grade1.dart';
import 'package:raccoon_learning/presentation/widgets/dialog/pause_dialog.dart';
import 'package:raccoon_learning/presentation/widgets/draw/model_manage.dart';

class DrawPage extends StatefulWidget {
  const DrawPage({super.key});

  @override
  State<DrawPage> createState() => _DrawPageState();
}

class _DrawPageState extends State<DrawPage> {
  final ModelManage _modelManager = ModelManage();
  final String _language = 'en';
  late DigitalInkRecognizer _digitalInkRecognizer;
  final Ink _ink = Ink();
  List<StrokePoint> _points = [];
  String _recognizedText = '';

//3 heart for beginning
  List<String> heartIcons = ['heart', 'heart', 'heart'];

  //for question 
  String _currentQuestion = "";
  int _correctAnswer = 0;

  //for grade 1
  final Grade1 _grade1 = Grade1();

  void _generateQuestion() {
    setState(() {
      _currentQuestion = _grade1.generateRandomQuestion(
        onAnswerGenerated: (answer) {
          _correctAnswer = answer;
        },
      );
    });
  }

  //update user awnser on screen
void _updateQuestion(String userAnswer) {
  setState(() {
    if (userAnswer != ''){
      _currentQuestion = _currentQuestion.replaceFirst("?", userAnswer);
    }
    });
    //delay and check awnser correct or not
  Future.delayed(const Duration(seconds: 1), () {
    if (int.parse(userAnswer) == _correctAnswer) {
      _generateQuestion();
      _clearPad();
    } else {
      _generateQuestion();
      _clearPad();
      _handleHeart(false);
    }
  });
}

    @override
  void initState() {
    super.initState();
    _initializeModel();
  }

  Future<void> _initializeModel() async {
    await _modelManager.ensureModelDownloaded(_language, context);
    _digitalInkRecognizer = DigitalInkRecognizer(languageCode: _language);
    _generateQuestion();
  }


  @override
  void dispose() {
    // Close the recognizer to free resources
    _digitalInkRecognizer.close();
    super.dispose();
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
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 60),
            height: screenHeight / 7,
            width: screenWidth,
            child: 
            Padding(
              padding: const EdgeInsets.all(8.0),
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
                  // Container(
                  //   height: 10,
                  //   width: 10,
                  //   decoration: const BoxDecoration(
                  //     color: Colors.redAccent,
                  //     shape: BoxShape.circle,
                  //   ),
                  // ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: IconButton(
                      onPressed: (){
                        showDialog(context: context, builder: (context) => const PauseDialog());
                      }, 
                      icon:  Icon(Icons.pause, color: Colors.white, size: 30),
                      ),
                  ),
                ],
              ),
            ),
          ),

           IconButton(
                  onPressed: (){
                    showDialog(context: context, builder: (context) => const PauseDialog());
                  }, 
                  icon:  Icon(Icons.pause, color: Colors.white, size: 50)),
                
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
                         caculation(_currentQuestion),

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
    mainAxisAlignment: MainAxisAlignment.spaceBetween, // Đặt các widget ở dưới đáy
    children: [
      // Chứa các nội dung khác, bạn có thể để trống nếu không cần hiển thị
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
                          icon: const Icon(Icons.delete_outline, color: Colors.white, size: 35),
                          onPressed: _clearPad,
                          tooltip: 'Clear Drawing',
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          _generateQuestion();
                          _clearPad();
                          setState(() {});
                        },
                        child: Text("Create new question"),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (_recognizedText != 'No match found') {
                            _updateQuestion(_recognizedText);
                          }
                          setState(() {});
                        },
                        child: Text("Submit"),
                      ),
                    ],
                  ),
                ),
              ],
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

  // Recognize text from strokes
  Future<void> _recogniseText() async {
    showDialog(
      context: context,
      builder: (context) => const AlertDialog(
        title: Text('Recognizing'),
      ),
      barrierDismissible: true,
    );

    try {
      final candidates = await _digitalInkRecognizer.recognize(_ink);
      _recognizedText = candidates.isNotEmpty ? candidates[0].text : '';
      print(_recognizedText);

      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }

    Navigator.pop(context);
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
        _showGameOverDialog();
      }
  });
}

void _showGameOverDialog() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Game Over'),
      content: Text('You ran out of hearts!'),
      actions: [
        TextButton(
          onPressed: () {
            // Reset game state
            setState(() {
              heartIcons = ['heart', 'heart', 'heart'];
              _generateQuestion();
            });
            Navigator.of(context).pop();
          },
          child: Text('Restart'),
        ),
      ],
    ),
  );
}

}

// Painter for rendering strokes
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
          Offset(p1.x.toDouble(), p1.y.toDouble()),
          Offset(p2.x.toDouble(), p2.y.toDouble()),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(Signature oldDelegate) => true;
}

Widget caculation (String text){
  return Text(
      text,
    style: TextStyle(
      fontSize: 40,
      fontWeight: FontWeight.w600
    ),
  );
}