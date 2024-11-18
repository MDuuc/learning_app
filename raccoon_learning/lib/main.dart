import 'package:flutter/material.dart';
import 'package:raccoon_learning/constants/theme/app_theme.dart';
import 'package:raccoon_learning/presentation/intro/intro_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const IntroPage(),
    );
  }
}
