import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raccoon_learning/constants/assets/app_images.dart';
import 'package:raccoon_learning/constants/theme/app_colors.dart';
import 'package:raccoon_learning/presentation/home/control_page.dart';
import 'package:raccoon_learning/presentation/home/custom/custom_competitive.dart';
import 'package:raccoon_learning/presentation/user/notify_provider/User_notifier.dart';
import 'package:raccoon_learning/presentation/user/notify_provider/custom_competitive_notifier.dart';
import 'package:raccoon_learning/presentation/user/notify_provider/custom_notifier.dart';
import 'package:raccoon_learning/presentation/widgets/button/basic_app_button.dart';

class CustomPage extends StatefulWidget {
  const CustomPage({super.key});

  @override
  State<CustomPage> createState() => _CustomPageState();
}

final Map<String, String> gradeMap = {
  'Grade 1': 'grade_1',
  'Grade 2': 'grade_2',
  'Grade 3': 'grade_3',
};
final Map<String, String> operationMap = {
  'Addition': 'addition',
  'Subtraction': 'subtraction',
  'Multiplication': 'multiplication',
  'Division': 'division',
  'Mix Operation': 'mix_operations',
};

class _CustomPageState extends State<CustomPage> {
  String _gradeSelected = "Grade 1";
  String _operationSelected = "Addition";
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final customNotifier = Provider.of<CustomNotifier>(context, listen: false);
      final competitiveNotifier = Provider.of<CustomCompetitiveNotifier>(context, listen: false);
      customNotifier.resetPlayRoomId();
      competitiveNotifier.deletePlayRoom();
      customNotifier.listenForAcceptedInvitations();
      customNotifier.listenForOpponentLeaving();
      customNotifier.determineRole();
      customNotifier.listenForMessageId();
      customNotifier.listenForPlayRoomStart(competitiveNotifier);

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
          String? inviterAvatarPath = inviterDoc['avatar'];

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
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userNotifier = Provider.of<UserNotifier>(context, listen: false);
    final customNotifier = Provider.of<CustomNotifier>(context);
    final competitiveNotifier = Provider.of<CustomCompetitiveNotifier>(context, listen: false);
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    String gradeValue = gradeMap[_gradeSelected] ?? '';
    String operationValue = operationMap[_operationSelected] ?? '';

    if (customNotifier.shouldNavigate) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CustomCompetitive()),
        ).then((_) {
          customNotifier.resetNavigationState();
        });
      });
    }

    return PopScope(
      canPop: false,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: Column(
          children: [
            Container(
              height: screenHeight / 9,
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
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  DropdownButton<String>(
                    value: _gradeSelected,
                    items: <String>['Grade 1', 'Grade 2', 'Grade 3']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _gradeSelected = newValue;
                        });
                      }
                    },
                  ),
                  DropdownButton<String>(
                    value: _operationSelected,
                    items: <String>[
                      'Addition',
                      'Subtraction',
                      'Multiplication',
                      'Division',
                      'Mix Operation'
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _operationSelected = newValue;
                        });
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.logout,
                      color: Colors.red,
                    ),
                    onPressed: () async {
                      await customNotifier.clearAcceptedInvitations();
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => ControlPage()),
                        (Route<dynamic> route) => false,
                      );
                    },
                  ),
                ],
              ),
            ),
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
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Center(
                child: customNotifier.isInviter
                    ? BasicAppButton(
                        onPressed: () async {
                          if (customNotifier.opponentId != null) {
                            await customNotifier.createPlayRoom(
                              context,
                              customNotifier.opponentId!,
                              operationValue,
                              gradeValue,
                            );
                            await competitiveNotifier.initializePlayRoom(
                              customNotifier.playRoomId!,
                              customNotifier.opponentId!,
                              FirebaseAuth.instance.currentUser!.uid,
                            );
                            competitiveNotifier.listenToPointUpdates();
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const CustomCompetitive()),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please invite an opponent first')),
                            );
                          }
                        },
                        width: screenWidth / 2,
                        enabled: customNotifier.opponentId != null,
                        title: 'Play',
                      )
                    : const Text('Waiting for the host to start...'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only( bottom: 15),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 200,
                    height: 180,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                      border: const Border(
                        right: BorderSide(
                          color: Colors.black,
                          width: 2,
                        ),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 8,
                          offset: const Offset(2, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: Consumer<CustomNotifier>(
                            builder: (context, notifier, _) {
                              if (notifier.messageId == null) {
                                return const Center(child: Text('No chat available'));
                              }
                              if (notifier.messages.isEmpty) {
                                return const Center(child: Text('No messages yet'));
                              }
                              return ListView.builder(
                                padding: const EdgeInsets.all(8),
                                itemCount: notifier.messages.length,
                                itemBuilder: (context, index) {
                                  final message = notifier.messages[index];
                                  return _buildListChat(
                                    message.username,
                                    message.message,
                                  );
                                },
                                reverse: true,
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _messageController,
                                  decoration: const InputDecoration(
                                    hintText: 'Enter message...',
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                  ),
                                  style: const TextStyle(fontSize: 12),
                                  maxLines: 1,
                                  onSubmitted: (value) {
                                    if (value.trim().isNotEmpty) {
                                      Provider.of<CustomNotifier>(context, listen: false)
                                          .sendMessage(value.trim(), context);
                                      _messageController.clear();
                                    }
                                  },
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.send,
                                  color: Colors.blue,
                                  size: 24,
                                ),
                                onPressed: () {
                                  final message = _messageController.text.trim();
                                  if (message.isNotEmpty) {
                                    Provider.of<CustomNotifier>(context, listen: false)
                                        .sendMessage(message, context);
                                    _messageController.clear();
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
              color:  image == null ? Colors.grey[300] : null,
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

  Widget _buildListChat(String username, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: '$username: ',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                text: text,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}