import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:raccoon_learning/constants/theme/app_theme.dart';
import 'package:raccoon_learning/firebase_options.dart';
import 'package:raccoon_learning/presentation/user/notify_provider/User_notifier.dart';
import 'package:raccoon_learning/presentation/user/notify_provider/analysis_data_notifier.dart';
import 'package:raccoon_learning/presentation/user/notify_provider/competitve_notifier.dart';
import 'package:raccoon_learning/presentation/user/notify_provider/custom_competitive_notifier.dart';
import 'package:raccoon_learning/presentation/user/notify_provider/custom_notifier.dart';
import 'package:raccoon_learning/presentation/user/notify_provider/gameplay_notifier.dart';
import 'package:raccoon_learning/presentation/user/notify_provider/history_notifier.dart';
import 'package:raccoon_learning/presentation/user/notify_provider/two_players_notifier.dart';
import 'package:raccoon_learning/wrapper.dart';

void main()  async{
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final analysisDataNotifier = AnalysisDataNotifier();
  await analysisDataNotifier.loadAnalysisData();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserNotifier()),
        ChangeNotifierProvider(create: (context) => GameplayNotifier()),
        ChangeNotifierProvider(create: (context) => CompetitveNotifier()),
        ChangeNotifierProvider(create: (context) => TwoPlayersNotifier()),
        ChangeNotifierProvider(create: (context) => CustomNotifier()),
        ChangeNotifierProvider(create: (context) => CustomCompetitiveNotifier()),
        ChangeNotifierProvider(create: (context) => HistoryNotifier()),
        
        ChangeNotifierProvider.value(value: analysisDataNotifier),
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


  