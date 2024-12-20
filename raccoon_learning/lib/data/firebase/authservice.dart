import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;  

  // SIgnup
  Future<User?> registerWithEmailPassword(
      String email, String password, String username) async {
    try {
      // Create Account
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // user ID
      User? user = userCredential.user;

      // save username into Firestore
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'username': username,  
          'email': email,        
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
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      print('Error: $e');
      return null;
    }
  }

  // Signout
  Future<void> signOut() async {
    await _auth.signOut();
  }

}
