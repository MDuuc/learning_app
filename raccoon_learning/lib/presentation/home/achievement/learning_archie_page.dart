import 'package:flutter/material.dart';
import 'package:raccoon_learning/constants/assets/app_images.dart';
import 'package:raccoon_learning/presentation/home/achievement/widget/achiement_button.dart';

class LearningArchiePage extends StatelessWidget {
  const LearningArchiePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 10,),
            AchiementButton(image: AssetImage(AppImages.raccoon_notifi), text: 'Best Score is 100'),
            AchiementButton(image: AssetImage(AppImages.raccoon_notifi), text: 'Best Score is 100'),
            AchiementButton(image: AssetImage(AppImages.raccoon_notifi), text: 'Best Score is 100'),
            AchiementButton(image: AssetImage(AppImages.raccoon_notifi), text: 'Best Score is 100'),
            AchiementButton(image: AssetImage(AppImages.raccoon_notifi), text: 'Best Score is 100'),
            AchiementButton(image: AssetImage(AppImages.raccoon_notifi), text: 'Best Score is 100'),
            AchiementButton(image: AssetImage(AppImages.raccoon_notifi), text: 'Best Score is 100'),
            AchiementButton(image: AssetImage(AppImages.raccoon_notifi), text: 'Best Score is 100'),



          ],
        ),
      ),
    );
  }
}
