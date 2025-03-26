import 'package:flutter/material.dart';
import 'package:raccoon_learning/data/firebase/authservice.dart';
import 'package:raccoon_learning/presentation/admin/page/dash_board.dart';
import 'package:raccoon_learning/presentation/admin/page/question_page.dart';
import 'package:raccoon_learning/presentation/admin/page/store_admin_page.dart';
import 'package:raccoon_learning/presentation/intro/signup_or_signin_page.dart'; // Add this import

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  bool _isSidebarHovered = false;
  int _selectedIndex = 0;
  

  final AuthService _authService = AuthService(); 

  final List<Widget> _pages = [
    const DashboardPage(),
    const QuestionPage(),
    const StoreAdminPage(),
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
                      _buildLogoutItem(context), // Logout item
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

  // New logout item widget
  Widget _buildLogoutItem(BuildContext context) {
    return MouseRegion(
      child: ListTile(
        leading: const Icon(
          Icons.logout,
          color: Colors.red,
        ),
        title: const Text(
          'Logout',
          style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.normal,
          ),
        ),
        onTap: () => _handleLogout(context),
        hoverColor: Colors.grey.withOpacity(0.1),
      ),
    );
  }

  // Logout function
  Future<void> _handleLogout(BuildContext context) async {
    try {
      await _authService.signOut(); 
      // Redirect to login page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => const SignupOrSigninPage(),
        ),
      );
    } catch (e) {
      print("Error logging out: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error logging out: $e')),
      );
    }
  }
}