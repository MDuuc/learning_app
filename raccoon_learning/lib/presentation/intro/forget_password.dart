import 'package:flutter/material.dart';
import 'package:raccoon_learning/data/firebase/authservice.dart';
import 'package:raccoon_learning/presentation/widgets/appbar/app_bar.dart';
import 'package:raccoon_learning/presentation/widgets/button/basic_app_button.dart';

class ForgetPassword extends StatelessWidget {
  ForgetPassword({super.key});

  final TextEditingController _email = TextEditingController();
  final AuthService _authService = AuthService();


  @override
   Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BasicAppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _registerText(),
              const SizedBox(height: 50,),
               _emailField(context),
              const SizedBox(height: 20,),
               BasicAppButton(
                onPressed: () 
                async{
                  await _authService.forgetPassword(_email.text.toString(),
                );
                },
                title: 'Sent to Email',
               ),
               const SizedBox(height: 20,),
            ],
          ),
        ),
      ),
    );
  }
  Widget _registerText(){
    return const Text(
      'Forget Password',
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 25,
      ),
      textAlign: TextAlign.center,
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
}