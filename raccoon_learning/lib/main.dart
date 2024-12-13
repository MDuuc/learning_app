import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raccoon_learning/constants/theme/app_theme.dart';
import 'package:raccoon_learning/presentation/home/control_page.dart';
import 'package:raccoon_learning/presentation/home/learning/draw_page.dart';
import 'package:raccoon_learning/presentation/intro/intro_page.dart';
import 'package:raccoon_learning/presentation/user/notify_provider/Avatar_notifier.dart';
import 'package:raccoon_learning/presentation/widgets/dialog/pause_dialog.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => AvatarNotifier()..loadAvatar(),
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
