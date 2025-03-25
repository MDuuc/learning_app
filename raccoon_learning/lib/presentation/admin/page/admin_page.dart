
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:raccoon_learning/presentation/admin/page/dash_board.dart';
import 'package:raccoon_learning/presentation/admin/page/question_page.dart';
import 'package:raccoon_learning/presentation/home/store_page.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  bool _isSidebarHovered = false;
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const DashboardPage(),
    const QuestionPage(),
    const StorePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Row(
            children: [
              MouseRegion(
                onEnter: (_) => setState(() => _isSidebarHovered = true),
                onExit: (_) => setState(() => _isSidebarHovered = false),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: _isSidebarHovered ? 220 : 200,
                  color: const Color(0xFFE5E9F0),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      const Text(
                        'DashStack',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildSidebarItem(context, 'Dashboard', Icons.dashboard, 0),
                      _buildSidebarItem(context, 'Question', Icons.app_registration_rounded, 1),
                      _buildSidebarItem(context, 'Store', Icons.store, 2),
                      const Spacer(),
                      _buildSidebarItem(context, 'Settings', Icons.settings, -1),
                      _buildSidebarItem(context, 'Logout', Icons.logout, -1),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: _pages[_selectedIndex],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSidebarItem(BuildContext context, String title, IconData icon, int index) {
    bool isSelected = _selectedIndex == index;
    return MouseRegion(
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? const Color(0xFF3B82F6) : Colors.grey,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? const Color(0xFF3B82F6) : Colors.grey,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onTap: () {
          if (index != -1) {
            setState(() => _selectedIndex = index);
          }
        },
        hoverColor: Colors.grey.withOpacity(0.1),
      ),
    );
  }
}

