import 'package:flutter/material.dart';
import 'package:raccoon_learning/constants/assets/app_images.dart';
import 'package:raccoon_learning/constants/theme/app_colors.dart';
import 'package:raccoon_learning/presentation/widgets/appbar/app_bar.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BasicAppBar(hideBack: true, title: Text("Notification"),),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 50,),
            notif(context),
            notif(context),
            notif(context),
            notif(context),
            notif(context),
            notif(context),
            notif(context),
            notif(context),



        
          ],
        ),
      ),
    );
  }
}

Widget notif(BuildContext context) {
  double screenHeight = MediaQuery.of(context).size.height;
  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        foregroundColor: AppColors.brown_light,
        backgroundColor: AppColors.black,
      ),
      child: Container(
        constraints: BoxConstraints(
          minHeight: screenHeight / 10,
        ),
        padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: Colors.transparent,
              radius: 30,
              backgroundImage: AssetImage(AppImages.raccoon_notifi),
            ),
            const SizedBox(width: 15),
            Expanded(  // Make sure the Text widget takes available space
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Achivement",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    "Congratulations! You got the Raccoon Fire Avatar.",
                    style: TextStyle(
                      fontSize: 14,
                    ),
                    softWrap: true, // Allow text to wrap
                    overflow: TextOverflow.visible, // Ensure the text wraps properly
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
