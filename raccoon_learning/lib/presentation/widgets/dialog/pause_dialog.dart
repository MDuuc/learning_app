import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:raccoon_learning/constants/theme/app_colors.dart';

class PauseDialog extends StatelessWidget {
  const PauseDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Blurred background
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              color: Colors.black.withOpacity(0.1),
            ),
          ),
          
          // Centered Dialog
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Game Paused',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Resume Button
                  _buildDialogButton(
                    context,
                    text: 'Resume',
                    icon: Icons.play_arrow,
                    color: Colors.green,
                    onPressed: () {
                      Navigator.of(context).pop('resume');
                    },
                  ),
                  
                  const SizedBox(height: 10),
                  
                  // Play Again Button
                  _buildDialogButton(
                    context,
                    text: 'Play Again',
                    icon: Icons.replay,
                    color: Colors.blue,
                    onPressed: () {
                      Navigator.of(context).pop('restart');
                    },
                  ),
                  
                  const SizedBox(height: 10),
                  
                  // Exit Button
                  _buildDialogButton(
                    context,
                    text: 'Exit',
                    icon: Icons.exit_to_app,
                    color: Colors.red,
                    onPressed: () {
                      Navigator.of(context).pop('exit');
                    },
                  ),
                ],
              ),
            ),
          ),

          // Close Button
          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              iconSize: 30,
              icon: const Icon(Icons.close, color: AppColors.darkGrey),
              onPressed: () => Navigator.of(context).pop('resume'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogButton(
    BuildContext context, {
    required String text,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
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
      ),
    );
  }
}

// Usage in your game/activity
Future<String?> showPauseDialog(BuildContext context) async {
  final result = await showDialog<String>(
    context: context,
    barrierColor: Colors.transparent,
    builder: (context) => const PauseDialog(),
  );

  switch (result) {
    case 'resume':
      // Handle resume logic
      break;
    case 'restart':
      // Handle restart logic
      break;
    case 'exit':
      // Handle exit logic
      break;
  }
  return result;
}