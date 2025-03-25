import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raccoon_learning/presentation/admin/page/admin_page.dart';
import 'package:raccoon_learning/presentation/home/control_page.dart';
import 'package:raccoon_learning/presentation/intro/intro_page.dart';
import 'package:raccoon_learning/presentation/user/notify_provider/User_notifier.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  Future<String?> _getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_role');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<String?>(
        future: _getUserRole(),
        builder: (context, roleSnapshot) {
          return StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, authSnapshot) {
              if (authSnapshot.connectionState == ConnectionState.waiting || 
                  roleSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (authSnapshot.hasError || roleSnapshot.hasError) {
                return const Center(
                  child: Text("Error"),
                );
              } else {
                if (authSnapshot.data == null) {
                  return IntroPage();
                } else {
                  String? userRole = roleSnapshot.data;
                  if (userRole == 'admin') {
                    return AdminPage();
                  } else {
                    return ControlPage();
                  }
                }
              }
            },
          );
        },
      ),
    );
  }
}
