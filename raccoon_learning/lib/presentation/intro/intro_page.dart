import 'package:flutter/material.dart';
import 'package:raccoon_learning/constants/assets/app_images.dart';
import 'package:raccoon_learning/constants/theme/app_colors.dart';
import 'package:raccoon_learning/presentation/intro/signup_or_signin_page.dart';
import 'package:raccoon_learning/presentation/widgets/button/basic_app_button.dart';
import 'package:raccoon_learning/presentation/widgets/draw/model_manage.dart';

class IntroPage extends StatefulWidget {
  const IntroPage({super.key});

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isLargeScreen = screenSize.width > 600;

    return Scaffold(
      body: isLargeScreen
          ? Row(
              children: [
                Expanded(
                  flex: 1, 
                  child: Container(
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: AssetImage(AppImages.rac_intro),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1, 
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Align(
                      alignment: Alignment.center,
                      child: _buildTextContent(isLargeScreen, context),
                    ),
                  ),
                ),
              ],
            )
          : Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(40),
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.contain,
                      image: AssetImage(AppImages.rac_intro),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _buildTextContent(isLargeScreen, context),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildTextContent(bool isLargeScreen, BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Play Your Way to Knowledge',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: isLargeScreen ? 24 : 18,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 21),
        Text(
          'Success is no accident. It is hard work, perseverance, learning, studying, sacrifice, and most of all, love of what you are doing or learning to do.',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: AppColors.grey,
            fontSize: isLargeScreen ? 16 : 13,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        Center(
          child: BasicAppButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SignupOrSigninPage(),
                ),
              );
            },
            title: 'Get Started',
            width: isLargeScreen ? 300 : double.infinity,
          ),
        ),
      ],
    );
  }
}