import 'package:flutter/material.dart';
import 'package:raccoon_learning/presentation/home/achievement/learning_archie_page.dart';

class TabControlerAchive extends StatefulWidget {
  const TabControlerAchive({super.key});

  @override
  State<TabControlerAchive> createState() => _TabControlerAchiveState();
}

class _TabControlerAchiveState extends State<TabControlerAchive> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Disable default back button
        title: const Text("Achievement"),
        centerTitle: true,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context); // Navigate back
          },
          child: Container(
            height: 50,
            width: 50,
            margin: const EdgeInsets.all(10), // Add margin for spacing
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.03),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_back_ios_new,
              size: 15,
              color: Colors.black,
            ),
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          indicatorColor: Colors.blue,
          tabs: const [
            Tab(
              text: 'Competitive',
            ),
            Tab(
              text: 'Learning',
            ),
            Tab(
              text: 'Streak',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          LearningArchiePage(),
          LearningArchiePage(),
          LearningArchiePage(),

        ],
      ),
    );
  }
}
