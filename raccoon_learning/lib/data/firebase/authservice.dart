import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raccoon_learning/data/firebase/gamePlay.dart';
import 'package:raccoon_learning/presentation/home/analysis_data/analysis.dart';
import 'package:raccoon_learning/presentation/user/notify_provider/User_notifier.dart';
import 'package:raccoon_learning/presentation/user/notify_provider/competitve_notifier.dart';
import 'package:raccoon_learning/presentation/user/notify_provider/gameplay_notifier.dart';
import 'package:raccoon_learning/presentation/widgets/widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

  class AuthService {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;  

    // SIgnup
  Future<User?> registerWithEmailPassword(
    BuildContext context,  String email, String password, String username) async {
    try {
      // check user and email already exist or not
    QuerySnapshot usernameSnapshot = await _firestore
        .collection('users')
        .where('username', isEqualTo: username)
        .get();

      QuerySnapshot emailSnapshot = await _firestore
      .collection('users')
      .where('email', isEqualTo: email)
      .get();


      if (usernameSnapshot.docs.isNotEmpty) {
        flutter_toast('Username already exists!', Colors.red);
        return null;
      }

        if (emailSnapshot.docs.isNotEmpty) {
        flutter_toast('Email already exists!', Colors.red);
        return null;
      }

      // Create Account
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // User ID
      User? user = userCredential.user;

      // Save user ID to local
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_uid', user?.uid ?? '');

      // Save user data to Firestore
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'user_id': user.uid,
          'username': username,
          'email': email,
          'role': 'user',
          'avatar': 'https://wgwzbsfxetgyropkgmkq.supabase.co/storage/v1/object/public/image//user.jpg',
          'created_at': FieldValue.serverTimestamp(),
        });

      // Send Verified Email
      await sendEmailVerification();

      // Notification for user to check
      flutter_toast('Verification email sent before login!', Colors.blue);

        // create default store
        await Gameplay().uploadDataToFirebase(user.uid);
      }

      return user;
    } on FirebaseAuthException catch (e) {
      print('Error: $e');
      return null;
    }
  }

  // Verify Email
    Future<void> sendEmailVerification() async {
    User? user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
      print("Email xác thực đã được gửi!");
    }
  }

  Future<bool> isEmailVerified() async {
  User? user = FirebaseAuth.instance.currentUser;
  await user?.reload(); // Cập nhật trạng thái mới
  return user?.emailVerified ?? false;
}



  // Sign In and fetch data analysis 
  Future<User?> signInWithEmailPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // save user id to local
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_uid', userCredential.user?.uid ?? '');
      await fetchAnalyticsOnLogin();
      await analyzeCombinedData();
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      print('Error: $e');
      return null;
    }
  }

Future<void> loadInfoOfUser(BuildContext context) async {
  try {
    // Get user ID from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('user_uid');
    await updateStreak(userId!);

    if (userId.isEmpty) {
      throw Exception('User ID not found in SharedPreferences');
    }

    // Fetch user information from Firestore
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (userDoc.exists) {
      print("User Document: ${userDoc.data()}"); // print all data

      // Extract user data
      String? userName = userDoc['username'];
      String? avatar = userDoc['avatar'];
      int? streakCount = userDoc ['streak_count'];
      String? role = userDoc['role'];

      // Load into Notifier
      final userNotifier = Provider.of<UserNotifier>(context, listen: false);
      final gameplayNotifer = Provider.of<GameplayNotifier>(context, listen: false);
      final competitveNotifier = Provider.of<CompetitveNotifier>(context, listen: false);


      await userNotifier.loadUserInfo(userName!, avatar!, streakCount!, role!);
      await gameplayNotifer.fetchDataFirebase(userId);
      await competitveNotifier.fetchAndUpdateRanks();
    } else {
      throw Exception('User document not found in Firestore');
    }

    print('User info loaded successfully');
  } catch (e) {
    print('Error loading user info: $e');
  }
}


  Future<void> forgetPassword(String email) async {
  try {
    await _auth.sendPasswordResetEmail(email: email);
    print("Password reset email sent to $email");
  } catch (e) {
    print("Error: $e");
    // Optionally handle specific exceptions
  }
}

Future<void> updateAvatar(String image) async {
  try {
    // Get user ID from local storage
    final prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('user_uid');

    if (userId == null) {
      throw Exception('User ID not found in SharedPreferences');
    }

    // Update Firestore with the new image
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'avatar': image,
    });

    print('Avatar updated successfully');
  } catch (e) {
    print('Error updating avatar: $e');
  }
}

// Change password
Future<void> changePassword(String currentPassword, String newPassword, String confirmNewPassword) async {
  try {
    // Validate new password
    if (newPassword != confirmNewPassword) {
      flutter_toast('New password and confirmed password do not match.', Colors.red);
      return;
    }

    if (currentPassword == newPassword) {
      flutter_toast('New password cannot be the same as current password.', Colors.red);
      return;
    }

    // Get user data
    final prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('user_uid');
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();

    if (!userDoc.exists) {
      throw Exception('User not found.');
    }

    final email = userDoc.data()?['email'] as String?;
    if (email == null || email.isEmpty) {
      throw Exception('Email not found for this user ID.');
    }

    // Reauthenticate and update password
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('No user currently signed in.');
    }

    AuthCredential credential = EmailAuthProvider.credential(
      email: email,
      password: currentPassword,
    );

    await user.reauthenticateWithCredential(credential);
    await user.updatePassword(newPassword);
    flutter_toast('Password changed successfully.', Colors.green);

  } on FirebaseAuthException catch (e) {
    flutter_toast('Error: ${e.message}', Colors.red);
  } catch (e) {
    flutter_toast('Error: ${e.toString()}', Colors.red);
  }
}

  // Signout and push data analysys to firebase
  Future<void> signOut() async {
    await uploadAnalyticsOnLogout();
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
    await _auth.signOut();
  }

  //Handle Streak login
  Future<void> updateStreak(String userId) async {
  try {
    final userDoc = _firestore.collection('users').doc(userId);
    final userSnapshot = await userDoc.get();

    if (userSnapshot.exists) {
      final data = userSnapshot.data();
      final lastLoginTimestamp = data?['last_login'] as Timestamp?;
      final streakCount = data?['streak_count'] as int? ?? 0;

      final DateTime lastLoginDate =
        lastLoginTimestamp?.toDate() ?? DateTime.now().subtract(Duration(days: 1));
      final DateTime currentDate = DateTime.now();

      // Check next day
      if (currentDate.difference(lastLoginDate).inDays == 1) {
        await userDoc.update({
          'streak_count': streakCount + 1,
          'last_login': FieldValue.serverTimestamp(),
        });
      } else if (currentDate.difference(lastLoginDate).inDays > 1) {
        // interrupted login, reset streak
        await userDoc.update({
          'streak_count': 1,
          'last_login': FieldValue.serverTimestamp(),
        });
      }
    } else {
      // if new user, generate streak
      await userDoc.set({
        'streak_count': 1,
        'last_login': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  } catch (e) {
    print('Error updating streak: $e');
  }
}


}
