// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'package:flutter/material.dart' hide Ink;
import 'package:google_mlkit_digital_ink_recognition/google_mlkit_digital_ink_recognition.dart';
import 'package:provider/provider.dart';
import 'package:raccoon_learning/constants/assets/app_images.dart';
import 'package:raccoon_learning/constants/theme/app_colors.dart';
import 'package:raccoon_learning/presentation/user/notify_provider/two_players_notifier.dart';
import 'package:raccoon_learning/presentation/widgets/widget.dart';

class SecondPlayerPage extends StatefulWidget {

  SecondPlayerPage({
    Key? key,
  }) : super(key: key);

  @override
  State<SecondPlayerPage> createState() => _SecondPlayerPageState();
}

class _SecondPlayerPageState extends State<SecondPlayerPage> {
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
    Provider.of<TwoPlayersNotifier>(context, listen: false).registerClearPadSecond(_clearPad);
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
        player.updatePoint(isPlayerOne: false);
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
        padding: const EdgeInsets.symmetric(horizontal: 8),
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
              player.pointPlayerTwo.toString(),
              style:  TextStyle(
                fontSize: screenWidth * 0.05, 
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
          const Image(image: AssetImage(
                 AppImages.vs
               ),
               height: 50,
               ),
            const Spacer(),
            Text(
              player.pointPlayerOne.toString(),
              style:  TextStyle(
                fontSize: screenWidth * 0.05, 
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 10),
              Text(
              " Rival",
              style:  TextStyle(
                fontSize: screenWidth * 0.05, 
                fontWeight: FontWeight.w600,
              ),
            ),
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
                      splitScreenCaculation(player.currentQuestion, context),
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
                          painter: SplitScreenSignature(ink: _ink),
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
  //clearPad
  void _clearPad() {
    setState(() {
      _ink.strokes.clear();
      _points.clear();
      _recognizedText = '';
    });
  }
}
 


