import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
