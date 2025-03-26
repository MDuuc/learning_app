import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart' hide Ink;
import 'package:google_mlkit_digital_ink_recognition/google_mlkit_digital_ink_recognition.dart' as mlkit;
import 'package:google_mlkit_digital_ink_recognition/google_mlkit_digital_ink_recognition.dart';
import 'package:raccoon_learning/constants/theme/app_colors.dart';

void my_alert_dialog(BuildContext context, String title, String description, VoidCallback onPress) {
  showDialog(
    context: context,
    barrierDismissible: false, // Prevent dismissing the dialog by tapping outside
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(description),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Close dialog on cancel
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.black),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog after action
              onPress(); 
            },
            child: const Text(
              'Confirm',
              style: TextStyle(color: Colors.blue),
            ),
          ),
        ],
      );
    },
  );
}


Future<dynamic> showFullImage(BuildContext context, ImageProvider  image) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            // Full-screen image
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image(image: image),
              ),
            ),
            // Close button
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                icon: Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
              ),
            ),
          ],
        ),
      );
    },
  );
}

Future<bool?> flutter_toast (String message, Color backgroundColor){
  return Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: backgroundColor,
        textColor: Colors.white,
      );
}

Widget buildDialogButton(
  BuildContext context, {
  required String text,
  IconData? icon,
  VoidCallback? onPressed,
}) {
  return ElevatedButton(
    onPressed: onPressed,
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      minimumSize: const Size(double.infinity, 50),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    ),
    child: icon != null
        ? Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(width: 10),
              Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ],
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ],
          ),
  );
}

// Recognize Text and Check 
  Future<String> recogniseNumber(BuildContext context, mlkit.Ink ink) async {
      DigitalInkRecognizer digitalInkRecognizer = DigitalInkRecognizer(languageCode: 'en');
      final candidates = await digitalInkRecognizer.recognize(ink);
      String recognizedText = candidates.isNotEmpty ? candidates[0].text : '';
    try {
      // recognized wrong number
      switch(recognizedText){
        case 'g':
          recognizedText = '9';
          break;
        case 'o':
          recognizedText = '0';
          break;
        case 'z':
          recognizedText = '2';
          break;
        case 'c':
        case '{':
        case '(':
          recognizedText = '<';
          break;
        case '}':
        case ')':
          recognizedText = '>';
          break;
      }
      return recognizedText;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
      return recognizedText;
  }

// Split Screen Painter
class SplitScreenSignature extends CustomPainter {
  final mlkit.Ink ink;

  SplitScreenSignature({required this.ink});

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
  bool shouldRepaint(SplitScreenSignature oldDelegate) => true;
}
// Split Screen Caculation
Widget splitScreenCaculation(String text, BuildContext context) {
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

//full Screen Painter
class FullScreenSignature extends CustomPainter {
  final mlkit.Ink ink;

  FullScreenSignature({required this.ink});

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
  bool shouldRepaint(FullScreenSignature oldDelegate) => true;
}
Widget fullScreenCaculation(String text) {
  // Adjust size based on long text
  double fontSize = 40.0; // Default size
  if (text.length > 50) {
    fontSize = 25.0; 
  } else if (text.length > 30) {
    fontSize = 30.0; 
  }

  return Flexible(
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
        ),
        textAlign: TextAlign.center,
        softWrap: true,
      ),
    ),
  );
}

// Color for time - bar
  Color getProgressColor(int seconds, int maxSeconds) {
    double progress = seconds / maxSeconds;

    if (progress > 0.5) {
      return Colors.green; // Color for more than 50%
    } else if (progress > 0.3) {
      return Colors.orange; // Color for between 30% and 50%
    } else {
      return Colors.red; // Color for less than 30%
    }
  }