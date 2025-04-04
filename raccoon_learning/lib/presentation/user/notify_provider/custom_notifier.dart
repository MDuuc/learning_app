import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CustomNotifier extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _opponentId;
  String? _opponentUsername;
  String? _opponentAvatarPath;

  String? get opponentId => _opponentId;
  String? get opponentUsername => _opponentUsername;
  String? get opponentAvatarPath => _opponentAvatarPath;

  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    if (query.isEmpty) return [];

    try {
      QuerySnapshot userSnapshot = await _firestore
          .collection('users')
          .where('username', isGreaterThanOrEqualTo: query)
          .where('username', isLessThanOrEqualTo: query + '\uf8ff')
          .limit(10)
          .get();

      return userSnapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'username': doc['username'] as String,
          'avatar': doc['avatar'] as String?,
        };
      }).toList();
    } catch (e) {
      print('Error searching users: $e');
      return [];
    }
  }

  Future<void> sendInvitation(String invitedUserId, BuildContext context) async {
    try {
      await _firestore.collection('invitations').add({
        'invitedUserId': invitedUserId,
        'inviterId': _auth.currentUser?.uid,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'pending',
      });
      notifyListeners();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending invitation: $e')),
      );
    }
  }

  // Listen to the invitation
  Stream<QuerySnapshot> getInvitationsStream() {
    return _firestore
        .collection('invitations')
        .where('invitedUserId', isEqualTo: _auth.currentUser?.uid)
        .where('status', isEqualTo: 'pending')
        .snapshots();
  }

  // Listen when the invitation is accepted
  void listenForAcceptedInvitations() {
    _firestore
        .collection('invitations')
        .where('inviterId', isEqualTo: _auth.currentUser?.uid)
        .where('status', isEqualTo: 'accepted')
        .snapshots()
        .listen((snapshot) async {
      if (snapshot.docs.isNotEmpty) {
        var invitation = snapshot.docs.first;
        String invitedUserId = invitation['invitedUserId'];
        DocumentSnapshot invitedDoc = await _firestore.collection('users').doc(invitedUserId).get();
        _opponentId = invitedUserId;
        _opponentUsername = invitedDoc['username'];
        _opponentAvatarPath = invitedDoc['avatar'];
        notifyListeners();
      }
    });
  }

  // Update status invitation
  Future<void> updateInvitationStatus(String invitationId, String status) async {
    await _firestore.collection('invitations').doc(invitationId).update({
      'status': status,
    });
  }

  // Update competitor information when accepting invitation
  void setOpponent(String id, String username, String? avatarPath) {
    _opponentId = id;
    _opponentUsername = username;
    _opponentAvatarPath = avatarPath;
    notifyListeners();
  }
}