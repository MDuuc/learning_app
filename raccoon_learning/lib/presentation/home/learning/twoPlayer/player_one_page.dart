// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'package:flutter/material.dart' hide Ink;
import 'package:google_mlkit_digital_ink_recognition/google_mlkit_digital_ink_recognition.dart';
import 'package:provider/provider.dart';
import 'package:raccoon_learning/constants/theme/app_colors.dart';
import 'package:raccoon_learning/presentation/user/notify_provider/two_players_notifier.dart';
import 'package:raccoon_learning/presentation/widgets/widget.dart';

class PlayerOnePage extends StatefulWidget {

  PlayerOnePage({
    Key? key,
  }) : super(key: key);

  @override
  State<PlayerOnePage> createState() => _PlayerOnePageState();
}

class _PlayerOnePageState extends State<PlayerOnePage> {
  
  final String _language = 'en';
  late DigitalInkRecognizer _digitalInkRecognizer;
  final Ink _ink = Ink();
  List<StrokePoint> _points = [];
  String _recognizedText = '';
    @override
  void initState() {
    super.initState();
  _initializeModel();
  }

  Future<void> _initializeModel() async {
    _digitalInkRecognizer = DigitalInkRecognizer(languageCode: _language);
  }


  @override
  void dispose() {
    // Close the recognizer to free resources
    _digitalInkRecognizer.close();
    super.dispose();
  }
  
void _checkCorrect(String userAnswer) {
  final player = Provider.of<TwoPlayersNotifier>(context, listen: false);
    try {
      // Handle empty answer
      if (userAnswer.isEmpty) {
        flutter_toast("Empty Answer", Colors.red);
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
      if ( player.correctAnswer ==  parsedUserAnswer || player.correctCompare == userAnswer) {
        _clearPad();
        player.updatePoint(isPlayerOne: true);
        player.nextQuestion();
      } else {
        _clearPad();

      }
    } catch (e) {
      // Catch any unexpected errors
      _clearPad();
    }
}


  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
     final player = Provider.of<TwoPlayersNotifier>(context, listen: false);
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
              "You ",
              style: TextStyle(
                fontSize: screenWidth * 0.05, 
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              player.pointPlayerOne.toString(),
              style:  TextStyle(
                fontSize: screenWidth * 0.05, 
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text(
              player.pointPlayerTwo.toString(),
              style:  TextStyle(
                fontSize: screenWidth * 0.05, 
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 10),
              Text(
              " Opponent",
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
                      caculation(player.currentQuestion, context),
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
                                  _checkCorrect(_recognizedText);
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

