import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:raccoon_learning/constants/theme/app_colors.dart';
import 'package:raccoon_learning/data/firebase/authservice.dart';
import 'package:raccoon_learning/data/firebase/gameplay.dart';
import 'package:raccoon_learning/presentation/home/chart_page.dart';
import 'package:raccoon_learning/presentation/home/home_page.dart';
import 'package:raccoon_learning/presentation/home/notification_page.dart';
import 'package:raccoon_learning/presentation/home/profile/profile_page.dart';
import 'package:raccoon_learning/presentation/home/store_page.dart';
import 'package:raccoon_learning/presentation/user/notify_provider/analysis_data_notifier.dart';
import 'package:raccoon_learning/presentation/widgets/draw/model_manage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ControlPage extends StatefulWidget {
  const ControlPage({super.key});

  @override
  State<ControlPage> createState() => _ControlPageState();
}

class _ControlPageState extends State<ControlPage> {


  int _currentIndex = 0;

  final List<Widget> _page = [  
  const HomePage(),
  const ChartPage(),
  const StorePage(),
  const NotificationPage(),
  const ProfilePage(),
];

    //dowload model
  final ModelManage _modelManager = ModelManage();
  final String _language = 'en';
  Gameplay gameplay = Gameplay();

 @override
  void initState() {
    super.initState();
    AuthService().loadInfoOfUser(context);
     _modelManager.ensureModelDownloaded(_language, context);
     trackingStoreImage();
  }

  Future <void> trackingStoreImage()async{
    final prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('user_uid');
     gameplay.listenToAllStoreUpdates(userId!);

  }
  @override
  void dispose() {
    gameplay.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _page[_currentIndex], 
      bottomNavigationBar: CurvedNavigationBar(items: <Widget>
      [
      const Icon(Icons.dashboard, size: 30, color: Colors.white,),
      const Icon(Icons.bar_chart_rounded, size: 30, color: Colors.white,),
      const Icon(Icons.store, size: 30, color: Colors.white,),
      const Icon(Icons.notifications, size: 30, color: Colors.white,),
      const Icon(Icons.person, size: 30, color: Colors.white,)
      ],
      color: AppColors.primary,
      buttonBackgroundColor: AppColors.primary,
      backgroundColor: AppColors.lightBackground,
      animationCurve: Curves.easeInOut,
      animationDuration: const Duration(milliseconds: 500),
      onTap: (index){
        setState(() {
        _currentIndex = index;
        });
      },
      )
    );
  }
}