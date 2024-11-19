import 'package:flutter/material.dart';
import 'package:raccoon_learning/presentation/widgets/appbar/app_bar.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BasicAppBar(hideBack: true, title: Text("Notification"),),
    );
  }
}