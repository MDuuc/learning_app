import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:raccoon_learning/constants/assets/app_vectors.dart';
import 'package:raccoon_learning/constants/theme/app_colors.dart';
import 'package:raccoon_learning/data/firebase/authservice.dart';
import 'package:raccoon_learning/presentation/admin/page/admin_page.dart';
import 'package:raccoon_learning/presentation/home/control_page.dart';
import 'package:raccoon_learning/presentation/intro/forget_password.dart';
import 'package:raccoon_learning/presentation/intro/signup_page.dart';
import 'package:raccoon_learning/presentation/user/notify_provider/User_notifier.dart';
import 'package:raccoon_learning/presentation/widgets/appbar/app_bar.dart';
import 'package:raccoon_learning/presentation/widgets/button/basic_app_button.dart';

class SigninPage extends StatefulWidget {
  const SigninPage({super.key});

  @override
  State<SigninPage> createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final AuthService _authService = AuthService();
  bool _signInFailed = false;
  bool _passwordVisible = false;

  Future<void> _handleSignIn(BuildContext context) async {
    final userNotifier = Provider.of<UserNotifier>(context, listen: false);

    try {
      final user = await _authService.signInWithEmailPassword(
        _email.text.trim(),
        _password.text.trim(),
      );

      if (user != null) {
        await userNotifier.fetchUserRole(user.uid);

        setState(() {
          _signInFailed = false;
          print("Role: ${userNotifier.role}");
        });

        if (userNotifier.role == 'admin') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const AdminPage()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const ControlPage()),
          );
        }
      } else {
        _showErrorMessage();
      }
    } catch (e) {
      _showErrorMessage();
      print("Sign-in error: $e");
    }
  }

  void _showErrorMessage() {
    setState(() {
      _signInFailed = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sign-in failed. Please try again!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Check if the screen width is large enough for web layout (> 600px is a common threshold)
    bool isWeb = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      bottomNavigationBar: _signinText(context),
      appBar: const BasicAppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: 50,
            horizontal: isWeb ? 100 : 30, // More padding on web
          ),
          child: isWeb ? _buildWebLayout(context) : _buildMobileLayout(context),
        ),
      ),
    );
  }

Widget _buildWebLayout(BuildContext context) {
  return SizedBox(
    height: MediaQuery.of(context).size.height, 
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center, 
      mainAxisAlignment: MainAxisAlignment.center, 
      children: [
        // Left column: "Sign In" text
        Expanded(
          flex: 1,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, 
            children: [
              _registerText(),
            ],
          ),
        ),
        // Right column: Form
        Expanded(
          flex: 1,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, 
            crossAxisAlignment: CrossAxisAlignment.center, 
            children: [
              _emailField(context),
              const SizedBox(height: 20),
              _passwordField(context),
              const SizedBox(height: 20),
              BasicAppButton(
                onPressed: () => _handleSignIn(context),
                title: 'Sign In',
              ),
              const SizedBox(height: 20),
              if (_signInFailed) _forgetPasswordHint(context),
              const SizedBox(height: 20),
              _dividerWithText(),
              const SizedBox(height: 60),
              _socialLoginButtons(),
            ],
          ),
        ),
      ],
    ),
  );
}

  // Mobile layout: Single column
  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _registerText(),
        const SizedBox(height: 50),
        _emailField(context),
        const SizedBox(height: 20),
        _passwordField(context),
        const SizedBox(height: 20),
        BasicAppButton(
          onPressed: () => _handleSignIn(context),
          title: 'Sign In',
        ),
        const SizedBox(height: 20),
        if (_signInFailed) _forgetPasswordHint(context),
        const SizedBox(height: 20),
        _dividerWithText(),
        const SizedBox(height: 60),
        _socialLoginButtons(),
      ],
    );
  }

  Widget _registerText() {
    return const Text(
      'Sign In',
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
      textAlign: TextAlign.center,
    );
  }

  Widget _emailField(BuildContext context) {
    return TextField(
      controller: _email,
      keyboardType: TextInputType.emailAddress,
      decoration: const InputDecoration(
        hintText: 'Enter Email',
      ).applyDefaults(Theme.of(context).inputDecorationTheme),
    );
  }

  Widget _passwordField(BuildContext context) {
    return TextField(
      controller: _password,
      obscureText: !_passwordVisible,
      decoration: InputDecoration(
        hintText: 'Password',
        suffixIcon: IconButton(
          icon: Icon(_passwordVisible ? Icons.visibility : Icons.visibility_off),
          onPressed: () {
            setState(() {
              _passwordVisible = !_passwordVisible;
            });
          },
        ),
      ).applyDefaults(Theme.of(context).inputDecorationTheme),
    );
  }

  Widget _signinText(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Not A Member?',
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          ),
          TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => SignupPage()),
              );
            },
            child: const Text(
              'Register Now',
              style: TextStyle(color: AppColors.blue),
            ),
          ),
        ],
      ),
    );
  }

  Widget _forgetPasswordHint(BuildContext context) {
    return TextButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ForgetPassword()),
        );
      },
      child: const Text(
        "Forgot your password?",
        style: TextStyle(color: AppColors.blue, fontSize: 16),
      ),
    );
  }

  Widget _dividerWithText() {
    return const Row(
      children: [
        Expanded(child: Divider(thickness: 1, color: Colors.grey)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            "Or",
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ),
        Expanded(child: Divider(thickness: 1, color: Colors.grey)),
      ],
    );
  }

  Widget _socialLoginButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () {
            // Handle Google sign-in (to be implemented)
          },
          child: SvgPicture.asset(
            AppVectors.google,
            height: 50,
            width: 50,
          ),
        ),
        const SizedBox(width: 40),
        GestureDetector(
          onTap: () {
            // Handle Apple sign-in (to be implemented)
          },
          child: SvgPicture.asset(
            AppVectors.apple,
            height: 50,
            width: 50,
          ),
        ),
      ],
    );
  }
}