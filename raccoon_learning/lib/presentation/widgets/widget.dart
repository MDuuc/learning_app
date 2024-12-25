import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:raccoon_learning/constants/theme/app_colors.dart';

Widget my_alert_dialog (BuildContext context, String title, String description, VoidCallback onpress){
  return AlertDialog(
    title:  Text(title),
    content:  Text(description),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancle', style: TextStyle(color: AppColors.black),),
      ),
      TextButton(
        onPressed: () {
          onpress();
          Navigator.pop(context);
        },
        style: ButtonStyle(

        ),
        child: const Text(
          'Confirm',
          style: TextStyle(
            color: AppColors.primary
          ),
          ),
      ),
    ],
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