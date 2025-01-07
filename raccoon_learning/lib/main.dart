import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raccoon_learning/constants/theme/app_theme.dart';
import 'package:raccoon_learning/firebase_options.dart';
import 'package:raccoon_learning/presentation/user/notify_provider/User_notifier.dart';
import 'package:raccoon_learning/presentation/user/notify_provider/achievement_notifier.dart';
import 'package:raccoon_learning/presentation/user/notify_provider/gameplay_notifier.dart';
import 'package:raccoon_learning/wrapper.dart';

void main()  async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserNotifier()),
        ChangeNotifierProvider(create: (context) => GameplayNotifier()),
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
      home: const Wrapper(),
    );
  }

}


  