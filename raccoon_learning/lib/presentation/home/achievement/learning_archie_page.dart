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
            AchiementButton(image: AssetImage(AppImages.raccoon_notifi), text: 'Best Score is', score: '10', coin: '10',),
            AchiementButton(image: AssetImage(AppImages.raccoon_notifi), text: 'Best Score is', score: '20', coin: '20',),
            AchiementButton(image: AssetImage(AppImages.raccoon_notifi), text: 'Best Score is', score: '30', coin: '30',),
            AchiementButton(image: AssetImage(AppImages.raccoon_notifi), text: 'Best Score is', score: '40', coin: '40',),
            AchiementButton(image: AssetImage(AppImages.raccoon_notifi), text: 'Best Score is', score: '50', coin: '50',),
            AchiementButton(image: AssetImage(AppImages.raccoon_notifi), text: 'Best Score is', score: '60', coin: '60',),
            AchiementButton(image: AssetImage(AppImages.raccoon_notifi), text: 'Best Score is', score: '70', coin: '70',),
            AchiementButton(image: AssetImage(AppImages.raccoon_notifi), text: 'Best Score is', score: '80', coin: '80',),
            AchiementButton(image: AssetImage(AppImages.raccoon_notifi), text: 'Best Score is', score: '90', coin: '90',),
          ],
        ),
      ),
    );
  }
}
