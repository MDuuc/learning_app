import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:raccoon_learning/constants/assets/app_vectors.dart';
import 'package:raccoon_learning/constants/theme/app_colors.dart';
import 'package:raccoon_learning/presentation/intro/signin_page.dart';
import 'package:raccoon_learning/presentation/widgets/appbar/app_bar.dart';
import 'package:raccoon_learning/presentation/widgets/button/basic_app_button.dart';

class SignupPage extends StatelessWidget {
  SignupPage({super.key});

  final TextEditingController _fullName = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

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
              _fullNameField(context),
               const SizedBox(height: 20,),
               _emailField(context),
              const  SizedBox(height: 20,),
              _passwordField(context),
               const SizedBox(height: 20,),
               BasicAppButton(
                onPressed: () async{
                  // var result = await sl<SignupUseCase>().call(
                  //   params: CreateUserReq(
                  //     fullName: _fullName.text.toString(), 
                  //     email:  _email.text.toString(), 
                  //     password:  _password.text.toString()));
                  //     result.fold(
                  //       (ifLeft){
                  //         var snackBar = SnackBar(content: Text(ifLeft));
                  //         ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  //       },
                  //      (ifRight){
                  //       Navigator.pushAndRemoveUntil(
                  //         context, 
                  //         MaterialPageRoute(builder: (BuildContext context) => const HomePage()), 
                  //         (route)=> false);
                  //      }
                  //      );
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

  Widget _fullNameField(BuildContext context) {
    return TextField(
      controller: _fullName,
      decoration: const InputDecoration(
        hintText: 'Full Name'
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