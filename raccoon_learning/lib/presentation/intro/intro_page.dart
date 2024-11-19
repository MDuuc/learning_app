import 'package:flutter/material.dart';
import 'package:raccoon_learning/constants/assets/app_images.dart';
import 'package:raccoon_learning/constants/theme/app_colors.dart';
import 'package:raccoon_learning/presentation/intro/signin_or_signin_page.dart';
import 'package:raccoon_learning/presentation/widgets/button/basic_app_button.dart';

class IntroPage extends StatelessWidget {
  const IntroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
        Container(
          padding: const EdgeInsets.all(40),
          decoration: const BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.contain,
              image: AssetImage(
                AppImages.rac_intro
              )
              )
          ),
          child: Column(
            children: [
              // Align(
              //   alignment: Alignment.topCenter,
              //   child: SvgPicture.asset(
              //     fit: BoxFit.contain,
              //     AppVectors.logo,
              //   ),
              // ),
              const Spacer(),
              const Text(
                'Play Your Way to Knowledge',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 21,),
                const Text(
                'Success is no accident. It is hard work, perseverance, learning, studying, sacrifice, and most of all, love of what you are doing or learning to do.',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: AppColors.grey,
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20,),
              BasicAppButton(
                onPressed: () {
                  Navigator.push(
                    context,
                   MaterialPageRoute(builder: (BuildContext context) =>const SignupOrSigninPage())
                   );
                },
                 title: 'Get Started')
            ],
          ),
        ),
        // Container(
        //   color: Colors.black.withOpacity(0.15),
        // )
        ],
      ),
    );
  }
}