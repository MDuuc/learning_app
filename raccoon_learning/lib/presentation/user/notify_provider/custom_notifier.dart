import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:raccoon_learning/presentation/home/learning/grade/grade1.dart'; 
import 'package:raccoon_learning/presentation/home/learning/grade/grade2.dart';
import 'package:raccoon_learning/presentation/home/learning/grade/grade3.dart';
import 'package:raccoon_learning/presentation/home/learning/grade/math_question.dart';
import 'package:raccoon_learning/presentation/user/notify_provider/custom_competitive_notifier.dart';

class CustomNotifier extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _opponentId;
  String? _opponentUsername;
  String? _opponentAvatarPath;
  String? _playRoomId;
  bool _isInviter = false;
  bool _shouldNavigate = false;
  StreamSubscription? _playRoomStartSubscription;

  String? get opponentId => _opponentId;
  String? get opponentUsername => _opponentUsername;
  String? get opponentAvatarPath => _opponentAvatarPath;
  String? get playRoomId => _playRoomId;
  bool get isInviter => _isInviter;
  bool get shouldNavigate => _shouldNavigate;

  Future<void> determineRole() async {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) return;

    QuerySnapshot inviterSnapshot = await _firestore
        .collection('invitations')
        .where('inviterId', isEqualTo: currentUserId)
        .where('status', isEqualTo: 'accepted')
        .limit(1)
        .get();

    if (inviterSnapshot.docs.isNotEmpty) {
      _isInviter = true;
      var invitation = inviterSnapshot.docs.first;
      _opponentId = invitation['invitedUserId'];
      DocumentSnapshot opponentDoc = await _firestore.collection('users').doc(_opponentId).get();
      _opponentUsername = opponentDoc['username'];
      _opponentAvatarPath = opponentDoc['avatar'];
    } else {
      QuerySnapshot invitedSnapshot = await _firestore
          .collection('invitations')
          .where('invitedUserId', isEqualTo: currentUserId)
          .where('status', isEqualTo: 'accepted')
          .limit(1)
          .get();

      if (invitedSnapshot.docs.isNotEmpty) {
        _isInviter = false;
        var invitation = invitedSnapshot.docs.first;
        _opponentId = invitation['inviterId'];
        DocumentSnapshot opponentDoc = await _firestore.collection('users').doc(_opponentId).get();
        _opponentUsername = opponentDoc['username'];
        _opponentAvatarPath = opponentDoc['avatar'];
      }
    }
    notifyListeners();
  }

  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    if (query.isEmpty) return [];
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) return [];
      DocumentSnapshot currentUserDoc = await _firestore.collection('users').doc(currentUserId).get();
      final currentUsername = currentUserDoc['username'] as String?;
      QuerySnapshot userSnapshot = await _firestore
          .collection('users')
          .where('username', isGreaterThanOrEqualTo: query)
          .where('username', isLessThanOrEqualTo: query + '\uf8ff')
          .where('username', isNotEqualTo: currentUsername)
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
        'play_room_id': null, // Đảm bảo play_room_id là null khi tạo mới
      });
      _isInviter = true;
      notifyListeners();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending invitation: $e')),
      );
    }
  }

  Stream<QuerySnapshot> getInvitationsStream() {
    return _firestore
        .collection('invitations')
        .where('invitedUserId', isEqualTo: _auth.currentUser?.uid)
        .where('status', isEqualTo: 'pending')
        .snapshots();
  }

  void listenForAcceptedInvitations() {
    _firestore
        .collection('invitations')
        .where('inviterId', isEqualTo: _auth.currentUser?.uid)
        .where('status', isEqualTo: 'accepted')
        .snapshots()
        .listen((snapshot) async {
      if (snapshot.docs.isNotEmpty) {
        await determineRole();
      }
    });
  }

  Future<void> updateInvitationStatus(String invitationId, String status) async {
    await _firestore.collection('invitations').doc(invitationId).update({
      'status': status,
    });
    if (status == 'accepted') {
      await determineRole();
    }
  }

  void setOpponent(String id, String username, String? avatarPath) {
    _opponentId = id;
    _opponentUsername = username;
    _opponentAvatarPath = avatarPath;
    notifyListeners();
    listenForOpponentLeaving();
  }

  Future<void> clearAcceptedInvitations() async {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) return;

    final inviterSnapshot = await _firestore
        .collection('invitations')
        .where('inviterId', isEqualTo: currentUserId)
        .where('status', isEqualTo: 'accepted')
        .get();

    for (var doc in inviterSnapshot.docs) {
      await doc.reference.delete();
    }

    final invitedSnapshot = await _firestore
        .collection('invitations')
        .where('invitedUserId', isEqualTo: currentUserId)
        .where('status', isEqualTo: 'accepted')
        .get();

    for (var doc in invitedSnapshot.docs) {
      await doc.reference.delete();
    }

    resetRoom();
    notifyListeners();
  }

  void resetRoom() {
    _opponentId = null;
    _opponentUsername = null;
    _opponentAvatarPath = null;
    _playRoomId = null; // Reset playRoomId về null
    _isInviter = false;
    notifyListeners();
  }

  void listenForOpponentLeaving() {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null || _opponentId == null) return;

    _firestore
        .collection('invitations')
        .where('status', isEqualTo: 'accepted')
        .where(Filter.or(
          Filter('inviterId', isEqualTo: currentUserId),
          Filter('invitedUserId', isEqualTo: currentUserId),
        ))
        .snapshots()
        .listen((snapshot) {
      bool hasActiveInvitation = snapshot.docs.any((doc) =>
          (doc['inviterId'] == currentUserId && doc['invitedUserId'] == _opponentId) ||
          (doc['invitedUserId'] == currentUserId && doc['inviterId'] == _opponentId));

      if (!hasActiveInvitation && _opponentId != null) {
        resetRoom();
      }
    });
  }

Future<void> createPlayRoom(BuildContext context, String opponentId, String operationSelected, String gradeSelected) async {
  if (!_isInviter) return;

  final currentUserId = _auth.currentUser?.uid;
  if (currentUserId == null) return;

  DocumentReference playRoom = _firestore.collection('play_rooms').doc();
  _playRoomId = playRoom.id;

  List<String> questions = [];
  List<int> answers = [];
  List<String> compares = [];
  String operation = operationSelected;
  String grade = gradeSelected;

  for (int i = 0; i < 30; i++) {
    switch (grade) {
      case 'grade_1':
        final grade1 = Grade1(operation);
        try {
          final MathQuestion mathQuestion = await grade1.generateRandomQuestion(context: context);
          questions.add(mathQuestion.question);
          answers.add(mathQuestion.correctAnswer);
          compares.add(mathQuestion.correctCompare ?? '');
        } catch (e) {
          print('Error generating Grade 1 question: $e');
        }
        break;
      case 'grade_2':
        final grade2 = Grade2(operation);
        try {
          final MathQuestion mathQuestion = await grade2.generateRandomQuestion(context: context);
          questions.add(mathQuestion.question);
          answers.add(mathQuestion.correctAnswer);
          compares.add(mathQuestion.correctCompare ?? '');
        } catch (e) {
          print('Error generating Grade 2 question: $e');
        }
        break;
      case 'grade_3':
        final grade3 = Grade3(operation);
        try {
          final MathQuestion mathQuestion = await grade3.generateRandomQuestion(context: context);
          questions.add(mathQuestion.question);
          answers.add(mathQuestion.correctAnswer);
          compares.add(mathQuestion.correctCompare ?? '');
        } catch (e) {
          print('Error generating Grade 3 question: $e');
        }
        break;
      default:
        print('Unsupported grade: $grade');
        break;
    }
  }

  await playRoom.set({
    currentUserId: {'score': 0, 'status': 'playing'},
    opponentId: {'score': 0, 'status': 'playing'},
    'grade': grade,
    'created_at': FieldValue.serverTimestamp(),
    'status': 'active',
    'questions': questions,
    'answers': answers,
    'compares': compares,
  });

  try {
    QuerySnapshot invitationSnapshot = await _firestore
        .collection('invitations')
        .where('inviterId', isEqualTo: currentUserId)
        .where('invitedUserId', isEqualTo: opponentId)
        .where('status', isEqualTo: 'accepted')
        .limit(1)
        .get();

    if (invitationSnapshot.docs.isNotEmpty) {
      String invitationId = invitationSnapshot.docs.first.id;
      await _firestore.collection('invitations').doc(invitationId).update({
        'play_room_id': _playRoomId,
      });
    } else {
      print('No matching accepted invitation found to update play_room_id');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No matching accepted invitation found')),
      );
    }
  } catch (e) {
    print('Error updating invitation with play_room_id: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error updating invitation: $e')),
    );
  }

  notifyListeners();
}

Future<void> resetPlayRoomId() async {
  final currentUserId = _auth.currentUser?.uid;
  if (currentUserId == null) return;

  QuerySnapshot inviterSnapshot = await _firestore
      .collection('invitations')
      .where('inviterId', isEqualTo: currentUserId)
      .where('status', isEqualTo: 'accepted')
      .limit(1)
      .get();

  if (inviterSnapshot.docs.isNotEmpty) {
    String invitationId = inviterSnapshot.docs.first.id;
    await _firestore.collection('invitations').doc(invitationId).update({
      'play_room_id': null,
    });
  }

  QuerySnapshot invitedSnapshot = await _firestore
      .collection('invitations')
      .where('invitedUserId', isEqualTo: currentUserId)
      .where('status', isEqualTo: 'accepted')
      .limit(1)
      .get();

  if (invitedSnapshot.docs.isNotEmpty) {
    String invitationId = invitedSnapshot.docs.first.id;
    await _firestore.collection('invitations').doc(invitationId).update({
      'play_room_id': null,
    });
  }

  _playRoomId = null; 
  _shouldNavigate = false;
  notifyListeners();
}

void listenForPlayRoomStart(CustomCompetitiveNotifier competitiveNotifier) {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null || _isInviter) return;

    _playRoomStartSubscription = _firestore
        .collection('invitations')
        .where('invitedUserId', isEqualTo: currentUserId)
        .where('status', isEqualTo: 'accepted')
        .snapshots()
        .listen((snapshot) async {
      if (snapshot.docs.isNotEmpty) {
        var invitation = snapshot.docs.first;
        String? playRoomId = invitation['play_room_id'];
        if (playRoomId != null && playRoomId.isNotEmpty && _playRoomId != playRoomId) {
          _playRoomId = playRoomId;
          print("Play room ID: $playRoomId");
          try {
            await competitiveNotifier.initializePlayRoom(
              _playRoomId!,
              invitation['inviterId'],
              currentUserId,
            );
            print("After initializing play room ID: $playRoomId");
            competitiveNotifier.listenToPointUpdates();
            _shouldNavigate = true; 
            notifyListeners(); 
          } catch (e) {
            print("Error in listenForPlayRoomStart: $e");
          }
        }
      }
    });
  }

void cancelSubscriptions() {
    _playRoomStartSubscription?.cancel();
  }

  void resetNavigationState() {
  _shouldNavigate = false;
  notifyListeners();
}

}