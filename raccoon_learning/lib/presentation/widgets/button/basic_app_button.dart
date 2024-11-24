import 'package:flutter/material.dart';
import 'package:raccoon_learning/constants/theme/app_colors.dart';

class BasicAppButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String title;
  final double? height;
  BasicAppButton({
    super.key, 
    required this.onPressed, 
    required this.title, 
    this.height
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary, 
        elevation: 0,
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), 
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30), 
        ),
        minimumSize: Size.fromHeight(height ?? 80), 
      ),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white, 
        ),
      ),
    );
  }
}
