import 'package:flutter/material.dart';
import 'package:raccoon_learning/constants/theme/app_colors.dart';
import 'package:raccoon_learning/data/firebase/authservice.dart';
import 'package:raccoon_learning/presentation/widgets/appbar/app_bar.dart';
import 'package:raccoon_learning/presentation/widgets/button/basic_app_button.dart';

class ChangePasswordPage extends StatelessWidget {
   ChangePasswordPage({super.key});

  final TextEditingController _currentPass = TextEditingController();
  final TextEditingController _newPass = TextEditingController();
  final TextEditingController _confirmPass = TextEditingController();

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
              _changePassword(),
              const SizedBox(height: 50,),
              _currentPassword(context),
               const SizedBox(height: 20,),
               _newPassword(context),
              const  SizedBox(height: 20,),
              _confirmPassword(context),
               const SizedBox(height: 20,),
               BasicAppButton(
                onPressed: (){
                  AuthService().changePassword(
                    _currentPass.text.trim(), 
                    _newPass.text.trim(), 
                    _confirmPass.text.trim());

                },
                title: 'Submit',
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
            ],
          ),
        ),
      ),
    );
  }
  Widget _changePassword(){
    return const Text(
      'Change Password',
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 25,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _currentPassword(BuildContext context) {
    return TextField(
      controller: _currentPass,
      obscureText: true,
      decoration: const InputDecoration(
        hintText: 'Current Password'
      ).applyDefaults(
        Theme.of(context).inputDecorationTheme
      ),
    );
  }

  Widget _newPassword(BuildContext context) {
    return TextField(
      controller: _newPass,
      obscureText: true,
      decoration: const InputDecoration(
        hintText: 'New Password'
      ).applyDefaults(
        Theme.of(context).inputDecorationTheme
      ),
    );
  }

   Widget _confirmPassword(BuildContext context) {
    return TextField(
      controller: _confirmPass,
      obscureText: true,
      decoration: const InputDecoration(
        hintText: 'New Confirm Password'
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
            'Do not remember current password?',
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
                  builder: (BuildContext context) => ChangePasswordPage()
                  )
                );
            }, 
            child: const Text(
              'Recovery',
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
