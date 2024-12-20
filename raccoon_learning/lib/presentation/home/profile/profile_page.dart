import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raccoon_learning/constants/theme/app_colors.dart';
import 'package:raccoon_learning/data/firebase/authservice.dart';
import 'package:raccoon_learning/presentation/home/profile/change_avatar.dart';
import 'package:raccoon_learning/presentation/home/profile/change_password_page.dart';
import 'package:raccoon_learning/presentation/intro/signin_or_signin_page.dart';
import 'package:raccoon_learning/presentation/user/notify_provider/User_notifier.dart';
import 'package:raccoon_learning/presentation/widgets/appbar/app_bar.dart';
import 'package:raccoon_learning/presentation/widgets/widget.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
 ImageProvider ?currentAvatar; 
   final AuthService _authService = AuthService();

 @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: const BasicAppBar(
        hideBack: true,
        title:  Text(
          "Profile",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.black,
      ),
      body: Consumer <UserNotifier>(builder: (context, avatar, child){
        currentAvatar =AssetImage(avatar.avatarPath);
        return  Stack(
        children: [
          // Background header
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              height: screenHeight / 6,
              decoration: const BoxDecoration(
                color: AppColors.black,
              ),
            ),
          ),
          // Main content
          Positioned(
            top: screenHeight/4,
            bottom: screenHeight/30,
            left: 0,
            right: 0,
            child:  Container(
              height: screenHeight/4 ,
              child: SingleChildScrollView(
                child: Column(
                  children: [

                    _settingTitle(context,"Change Password", icon: Icons.arrow_forward_ios_rounded, (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) => ChangePasswordPage()
                          )
                        );
                    }, ),

                    _settingTitle(context,"About Us", icon: Icons.arrow_forward_ios_rounded,() { }),
                    _settingTitle(context,"Privacy Policy", icon: Icons.arrow_forward_ios_rounded,() { }),
                    _settingTitle(context,"Terms and Conditions", icon: Icons.arrow_forward_ios_rounded,() { }),
                    _settingTitle(context,"Help & Support", icon: Icons.arrow_forward_ios_rounded,() { }),
                    _settingTitle(context,"Logout",() async{ 
                      try {
                        await _authService.signOut();
                        // Redirect to Login Page or any other page as desired
                        Navigator.pushReplacement(
                          context, 
                          MaterialPageRoute(builder: (BuildContext context) => const SignupOrSigninPage()), 
                        );
                      } catch (e) {
                        print("Error logging out: $e");
                        // You can show a snack bar or alert for error handling
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error logging out: $e')),
                        );
                      }
                     }, color: Colors.red),
                  ],
                ),
              ),
            ),
          ),
          // Avatar
          Positioned(
            top: screenHeight / 6 - 60,
            left: screenWidth / 2 - 60,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 3,
                ),
              ),
              child: GestureDetector(
                onTap: (){
                  showFullImage(context, currentAvatar!);
                },
                child: CircleAvatar(
                  backgroundColor: Colors.transparent,
                  radius: 60,
                  backgroundImage: currentAvatar,
                ),
              ),
            ),
          ),
          // Change Avatar Button
          Positioned(
            top: screenHeight / 6 + 30,
            left: screenWidth / 2 + 30,
            child: IconButton(
              onPressed: () {
               showAvatarDialog(context);
              },
              icon: const Icon(Icons.add_a_photo_outlined),
            ),
          ),
        ],
      );
      }
      )
    );
  }

Widget _settingTitle(
  BuildContext context, 
  String title, 
  VoidCallback onTap, {
  IconData? icon,
  Color? color,  // Add an optional color parameter
}) {
  double screenHeight = MediaQuery.of(context).size.height;
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 1),
    child: ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        iconColor: Colors.black,
        foregroundColor: color ?? Colors.black,
        backgroundColor:  AppColors.lightBackground, 
      ),
      child: Container(
        height: screenHeight / 10,
        padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w400,
              ),
            ),
            if (icon != null) 
              const Spacer(),
              Icon(icon), 
          ],
        ),
      ),
    ),
  );
}
}