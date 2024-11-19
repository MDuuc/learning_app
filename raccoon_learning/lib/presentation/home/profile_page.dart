import 'package:flutter/material.dart';
import 'package:raccoon_learning/presentation/widgets/appbar/app_bar.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
            appBar: BasicAppBar(hideBack: true, title: Text("Profile"),),
    );
  }
}