import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raccoon_learning/constants/theme/app_theme.dart';
import 'package:raccoon_learning/presentation/home/control_page.dart';
import 'package:raccoon_learning/presentation/home/learning/draw_page.dart';
import 'package:raccoon_learning/presentation/intro/intro_page.dart';
import 'package:raccoon_learning/presentation/user/notify_provider/User_notifier.dart';
import 'package:raccoon_learning/presentation/user/notify_provider/achievement_notifier.dart';
import 'package:raccoon_learning/presentation/widgets/dialog/pause_dialog.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserNotifier()..loadUserInfo()),
        ChangeNotifierProvider(create: (context) => AchievementNotifier()),
      ],
      child: const MyApp(),
    ),
  );
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      // home: const IntroPage(),
      home: const ControlPage(),
      // home: const DrawPage(),



    );
  }
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
