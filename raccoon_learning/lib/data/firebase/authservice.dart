import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:raccoon_learning/presentation/user/notify_provider/User_notifier.dart';
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
      Fluttertoast.showToast(
        msg: 'Username already exists!',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return null;
    }

      if (emailSnapshot.docs.isNotEmpty) {
      Fluttertoast.showToast(
        msg: 'Email already exists!',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
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
        'avatar': 'assets/images/user.png',
        'created_at': FieldValue.serverTimestamp(),
      });
    }

    return user;
  } on FirebaseAuthException catch (e) {
    print('Error: $e');
    return null;
  }
}


  // Sign In
  Future<User?> signInWithEmailPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // save user id to local
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_uid', userCredential.user?.uid ?? '');

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

    if (userId == null) {
      throw Exception('User ID not found in SharedPreferences');
    }

    // Fetch user information from Firestore
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (userDoc.exists) {
      // Extract user data
      String? userName = userDoc['username'];
      String? avatar = userDoc['avatar'];

      print(userName);
      print(avatar);


      // Load into Notifier
      final userNotifier = Provider.of<UserNotifier>(context, listen: false);
      await userNotifier.loadUserInfo(userName!, avatar! );
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


  // Signout
  Future<void> signOut() async {
    await _auth.signOut();
  }

}
