import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raccoon_learning/constants/assets/app_images.dart';
import 'package:raccoon_learning/constants/theme/app_colors.dart';
import 'package:raccoon_learning/presentation/user/notify_provider/User_notifier.dart';
import 'package:raccoon_learning/presentation/widgets/button/basic_app_button.dart';

class CustomPage extends StatefulWidget {
  const CustomPage({super.key});

  @override
  State<CustomPage> createState() => _CustomPageState();
}

class _CustomPageState extends State<CustomPage> {
  @override
  Widget build(BuildContext context) {
    final userNotifier = Provider.of<UserNotifier>(context, listen: false);
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Column(
        children: [
          Container(
            height: screenHeight / 8,
            decoration: const BoxDecoration(
              color: AppColors.black,
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(30),
                bottomLeft: Radius.circular(30),
              ),
            ),
            child: const Center(
              child: Text(
                "Custom Room",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
          ),
          const SizedBox(height: 100),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center, 
              children: [
                _playerUI(context, userNotifier.avatarPath, userNotifier.username, () {}),
                Image(
                  image: const AssetImage(AppImages.vs),
                  height: screenWidth / 3 * 0.5, 
                  fit: BoxFit.contain,
                ),
                _OpponentUI(context, null, "Opponent", 
                (){
                  _showSearchDialog(context);
                }
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: BasicAppButton(
                onPressed: () {},
                title: 'Play',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _playerUI(BuildContext context, String image, String title, VoidCallback onTap) {
    double screenWidth = MediaQuery.of(context).size.width;
    double size = screenWidth / 3;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: NetworkImage(image),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 8), 
          Text(
            title,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }


Widget _OpponentUI(BuildContext context, String? image, String title, VoidCallback onTap) {
    double screenWidth = MediaQuery.of(context).size.width;
    double size = screenWidth / 3;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: image == null ? Colors.grey[300] : null, 
              image: image != null
                  ? DecorationImage(
                      image: AssetImage(image),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: image == null
                ? const Icon(
                    Icons.add,
                    size: 50,
                    color: Colors.black,
                  )
                : null,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showSearchDialog(BuildContext context) {
    String searchQuery = '';

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.grey.shade300,
          title: const Text('Search User'),
          content: TextField(
            onChanged: (value) {
              searchQuery = value;
            },
            decoration: const InputDecoration(
              hintText: 'Enter username...',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Cancel', style: TextStyle(color: Colors.red),),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white
              ),
              onPressed: () {
                if (searchQuery.isNotEmpty) {

                  setState(() {

                  });
                }
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Confirm', style: TextStyle(color: Colors.blue),),
            ),
          ],
        );
      },
    );
  }
}
