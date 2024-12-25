import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:raccoon_learning/constants/assets/app_vectors.dart';
import 'package:raccoon_learning/constants/theme/app_colors.dart';
import 'package:raccoon_learning/data/firebase/authservice.dart';
import 'package:raccoon_learning/presentation/home/control_page.dart';
import 'package:raccoon_learning/presentation/intro/signin_page.dart';
import 'package:raccoon_learning/presentation/widgets/appbar/app_bar.dart';
import 'package:raccoon_learning/presentation/widgets/button/basic_app_button.dart';

class SignupPage extends StatelessWidget {
  SignupPage({super.key});

  final TextEditingController _userName = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: _signinText(context),
      appBar: const BasicAppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _registerText(),
              const SizedBox(height: 50,),
              _userNameField(context),
               const SizedBox(height: 20,),
               _emailField(context),
              const  SizedBox(height: 20,),
              _passwordField(context),
               const SizedBox(height: 20,),
               BasicAppButton(
               onPressed: () async {
                final user = await _authService.registerWithEmailPassword(
                  context,
                  _email.text.toString().trim(),
                  _password.text.toString().trim(),
                  _userName.text.toString().trim(),
                );

                if (user != null) {
                  // Registration was successful, navigate to ControlPage
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (BuildContext context) => const ControlPage()),
                    (route) => false,
                  );
                } 
              },

                title: 'Create Account',
               ),
                              const SizedBox(height: 20,),
                 // horizontal line
                 const Row(
                  children: [
                    Expanded(
                      child: Divider(
                        thickness: 1, 
                        color: Colors.grey, 
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10), 
                      child: Text(
                        "Or",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16, 
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        thickness: 1,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
            const SizedBox(height: 60), 
          // Social icons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Google Icon
              GestureDetector(
                onTap: () {
                  // Handle Google sign-in
                },
                child: SvgPicture.asset(
                  AppVectors.google,
                  height: 50,
                  width: 50,
                ),
              ),
              const SizedBox(width: 40),
              // Apple Icon
              GestureDetector(
                onTap: () {
                  // Handle Apple sign-in
                },
                child: SvgPicture.asset(
                  AppVectors.apple, 
                  height: 50,
                  width: 50,
                ),
              ),
            ],
          ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _registerText(){
    return const Text(
      'Register',
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 25,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _userNameField(BuildContext context) {
    return TextField(
      controller: _userName,
      decoration: const InputDecoration(
        hintText: 'User Name'
      ).applyDefaults(
        Theme.of(context).inputDecorationTheme
      ),
    );
  }

  Widget _emailField(BuildContext context) {
    return TextField(
      controller: _email,
      decoration: const InputDecoration(
        hintText: 'Enter Email'
      ).applyDefaults(
        Theme.of(context).inputDecorationTheme
      ),
    );
  }

   Widget _passwordField(BuildContext context) {
    return TextField(
      controller: _password,
      obscureText: true,
      decoration: const InputDecoration(
        hintText: 'Password'
      ).applyDefaults(
        Theme.of(context).inputDecorationTheme
      ),
    );
   }

     Widget _signinText(BuildContext context){
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
         const  Text(
            'Do you have an account?',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14
            ),
          ),
          TextButton(
            onPressed: (){
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => SigninPage()
                  )
                );
            }, 
            child: const Text(
              'Sign In',
              style: TextStyle(
                color: AppColors.blue,
              ),
            )
            )
        ],
      ),
    );
  }
}