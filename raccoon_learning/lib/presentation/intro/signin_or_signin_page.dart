import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:raccoon_learning/constants/assets/app_images.dart';
import 'package:raccoon_learning/constants/assets/app_vectors.dart';
import 'package:raccoon_learning/constants/theme/app_colors.dart';
import 'package:raccoon_learning/presentation/intro/signin_page.dart';
import 'package:raccoon_learning/presentation/intro/signup_page.dart';
import 'package:raccoon_learning/presentation/widgets/appbar/app_bar.dart';
import 'package:raccoon_learning/presentation/widgets/button/basic_app_button.dart';

class SignupOrSigninPage extends StatelessWidget {
  const SignupOrSigninPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const BasicAppBar(),
          Align(
            alignment: Alignment.topRight,
            child: SvgPicture.asset(
              AppVectors.topPattern
            ),
            ),
            Align(
            alignment: Alignment.bottomRight,
            child: SvgPicture.asset(
              AppVectors.bottomPattern
            ),
            ),
            Align(
            alignment: Alignment.bottomCenter,
            child: Image.asset(
              fit: BoxFit.contain,
              AppImages.rac_1
            ),
            ),
              Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 260,),
                  const Text(
                    'Play Your Way to Knowledge',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20
                    ),
                  ),
                  const SizedBox(
                    height: 21,
                  ),
                  const Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: const Text(
                    'The beautiful thing about learning is that no one can take it away from you.',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: AppColors.grey
                    ),
                    textAlign: TextAlign.center,
                                    ),
                  ),
               const SizedBox(
                    height: 30,
                  ),
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: BasicAppButton(
                          onPressed: (){
                            Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (BuildContext context) =>  SignupPage()
                              )
                            );

                          }, 
                          title: 'Register'),
                      ),
                    const SizedBox(
                      width: 20,
                    ),
                    Expanded(
                      flex: 1,
                      child: TextButton(
                        onPressed: (){
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (BuildContext context) =>  SigninPage()
                              )
                            );
                        }, 
                        style: TextButton.styleFrom(
                          minimumSize: const Size.fromHeight(80),
                          shape: RoundedRectangleBorder(
                           borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          'Sign In',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black
                          ),
                        )),
                    )
                    ],
                  )
                  
                ],
              ),
            )
        ],
      ),
    );
  }
}