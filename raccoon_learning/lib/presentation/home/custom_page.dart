import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raccoon_learning/constants/assets/app_images.dart';
import 'package:raccoon_learning/constants/theme/app_colors.dart';
import 'package:raccoon_learning/presentation/user/notify_provider/User_notifier.dart';
import 'package:raccoon_learning/presentation/user/notify_provider/custom_notifier.dart';
import 'package:raccoon_learning/presentation/widgets/button/basic_app_button.dart';

class CustomPage extends StatefulWidget {
  const CustomPage({super.key});

  @override
  State<CustomPage> createState() => _CustomPageState();
}

class _CustomPageState extends State<CustomPage> {
  @override
void initState() {
    super.initState();
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final customNotifier = Provider.of<CustomNotifier>(context, listen: false);
      customNotifier.listenForAcceptedInvitations();

      customNotifier.getInvitationsStream().listen((snapshot) async {
        if (snapshot.docs.isNotEmpty && mounted) {
          var invitation = snapshot.docs.first;
          String inviterId = invitation['inviterId'];
          String invitationId = invitation.id;

          DocumentSnapshot inviterDoc = await _firestore
              .collection('users')
              .doc(inviterId)
              .get();
          String inviterUsername = inviterDoc['username'];
          String? inviterAvatarPath = inviterDoc['avatarPath'];

          showDialog(
            context: context,
            builder: (dialogContext) {
              return AlertDialog(
                backgroundColor: Colors.grey.shade300,
                title: const Text('Invitation'),
                content: Text('$inviterUsername wants to invite you to play'),
                actions: [
                  TextButton(
                    onPressed: () async {
                      await customNotifier.updateInvitationStatus(invitationId, 'declined');
                      Navigator.of(dialogContext).pop();
                    },
                    child: const Text('Cancel', style: TextStyle(color: Colors.red)),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                    onPressed: () async {
                      await customNotifier.updateInvitationStatus(invitationId, 'accepted');
                      customNotifier.setOpponent(inviterId, inviterUsername, inviterAvatarPath);
                      Navigator.of(dialogContext).pop();
                    },
                    child: const Text('Confirm', style: TextStyle(color: Colors.blue)),
                  ),
                ],
              );
            },
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final userNotifier = Provider.of<UserNotifier>(context, listen: false);
    final customNotifier = Provider.of<CustomNotifier>(context); // Listen to changes
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
                _OpponentUI(
                  context,
                  customNotifier.opponentAvatarPath,
                  customNotifier.opponentUsername ?? "Opponent",
                  () => _showSearchDialog(context, customNotifier),
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: BasicAppButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Starting game...')),
                  );
                },
                width: screenWidth / 2,
                enabled: customNotifier.opponentId != null,
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
      onTap: image == null ? onTap : null,
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
                      image: NetworkImage(image),
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

  void _showSearchDialog(BuildContext context, CustomNotifier customNotifier) {
    List<Map<String, dynamic>> searchResults = [];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey.shade300,
          title: const Text('Search User'),
          content: SizedBox(
            width: double.maxFinite,
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter dialogSetState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      onChanged: (value) async {
                        if (value.isNotEmpty) {
                          searchResults = await customNotifier.searchUsers(value);
                        } else {
                          searchResults = [];
                        }
                        dialogSetState(() {});
                      },
                      decoration: const InputDecoration(
                        hintText: 'Enter username...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 150,
                      child: searchResults.isEmpty
                          ? const Center(child: Text('No users found'))
                          : ListView.builder(
                              itemCount: searchResults.length,
                              itemBuilder: (context, index) {
                                final user = searchResults[index];
                                return ListTile(
                                  title: Text(user['username']),
                                  onTap: () async {
                                    await customNotifier.sendInvitation(user['id'], context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Invitation sent to ${user['username']}')),
                                    );
                                    Navigator.of(context).pop();
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}