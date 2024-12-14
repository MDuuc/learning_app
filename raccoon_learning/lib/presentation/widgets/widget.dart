import 'package:flutter/material.dart';
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