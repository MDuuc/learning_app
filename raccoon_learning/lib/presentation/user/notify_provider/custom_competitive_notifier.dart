import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CustomCompetitiveNotifier extends ChangeNotifier {
  int _myScore = 0;
  int _opponentScore = 0;
  String _playRoomID = "";
  String _opponentID = "";
  String _userID = "";
  String _statusEndMatchOpponent = "";
  String _statusEndMatchUser = "";
  bool _hasShownDialog = false;
  String _avatarOpponent = "";

  List<String> _questions = [];
  List<int> _answers = [];
  List<String> _compares = [];
  int _currentQuestionIndex = 0;

  int get myScore => _myScore;
  int get opponentScore => _opponentScore;
  String get playRoomID => _playRoomID;
  String get opponentID => _opponentID;
  String get userID => _userID;
  String get statusEndMatchOpponent => _statusEndMatchOpponent;
  String get statusEndMatchUser => _statusEndMatchUser;
  bool get hasShownDialog => _hasShownDialog;
  String get avatarOpponent => _avatarOpponent;

  List<String> get questions => _questions;
  List<int> get answers => _answers;
  List<String> get compares => _compares;
  int get currentQuestionIndex => _currentQuestionIndex;
  String get currentQuestion => _questions.isNotEmpty ? _questions[_currentQuestionIndex] : "";
  int get currentAnswer => _answers.isNotEmpty ? _answers[_currentQuestionIndex] : 0;
  String get currentCompare => _compares.isNotEmpty ? _compares[_currentQuestionIndex] : "";

  set currentQuestionIndex(int value) {
    _currentQuestionIndex = value;
    notifyListeners();
  }

  set hasShownDialog(bool value) {
    _hasShownDialog = value;
    notifyListeners();
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> initializePlayRoom(String playRoomId, String opponentId, String userId) async {
    _myScore = 0;
    _opponentScore = 0;
    _playRoomID = playRoomId;
    _opponentID = opponentId;
    _userID = userId;
    _statusEndMatchOpponent = "";
    _statusEndMatchUser = "";
    _hasShownDialog = false;

    DocumentSnapshot opponentDoc = await _firestore.collection('users').doc(_opponentID).get();
    _avatarOpponent = opponentDoc['avatar'] ?? "";

    await fetchQuestions();
    notifyListeners();
  }

  void listenToPointUpdates() {
    if (_playRoomID.isNotEmpty) {
      _firestore.collection('play_rooms').doc(_playRoomID).snapshots().listen((snapshot) {
        if (snapshot.exists) {
          final data = snapshot.data() as Map<String, dynamic>?;

          if (data != null && data.containsKey(_userID) && data.containsKey(_opponentID)) {
            _myScore = data[_userID]['score'] ?? 0;
            _opponentScore = data[_opponentID]['score'] ?? 0;
            _statusEndMatchUser = data[_userID]['status'] ?? 'playing';
            _statusEndMatchOpponent = data[_opponentID]['status'] ?? 'playing';

            notifyListeners();
          }
        }
      });
    }
  }

  Future<void> updateScore() async {
    if (_playRoomID.isNotEmpty) {
      DocumentReference playRoomDoc = _firestore.collection('play_rooms').doc(_playRoomID);
      try {
        _myScore += 1;
        await playRoomDoc.update({
          '$userID.score': _myScore,
        });
        notifyListeners();
      } catch (error) {
        print('Error updating score: $error');
      }
    } else {
      print('Error: _playRoomID is empty.');
    }
  }

  Future<void> exitPlayRoom() async {
    DocumentReference playRoomDoc = _firestore.collection('play_rooms').doc(_playRoomID);
    try {
      _statusEndMatchUser = "lose";
      _statusEndMatchOpponent = "win";

      await playRoomDoc.update({
        '$userID.status': _statusEndMatchUser,
        '$opponentID.status': _statusEndMatchOpponent,
      });

      // Xóa play_room sau khi thoát
      await playRoomDoc.delete();

      notifyListeners();
    } catch (error) {
      print('Error exiting play room: $error');
    }
  }

  Future<void> updateEndMatchStatus() async {
    DocumentReference playRoomDoc = _firestore.collection('play_rooms').doc(_playRoomID);
    try {
      _statusEndMatchUser = "win";
      _statusEndMatchOpponent = "lose";

      await playRoomDoc.update({
        '$userID.status': _statusEndMatchUser,
        '$opponentID.status': _statusEndMatchOpponent,
      });

      await playRoomDoc.delete();

      notifyListeners();
    } catch (error) {
      print('Error updating end match status: $error');
    }
  }

  Future<void> fetchQuestions() async {
    if (_playRoomID.isNotEmpty) {
      try {
        DocumentSnapshot playRoomDoc = await _firestore.collection('play_rooms').doc(_playRoomID).get();
        if (playRoomDoc.exists) {
          final data = playRoomDoc.data() as Map<String, dynamic>;
          _questions = List<String>.from(data['questions'] ?? []);
          _answers = List<int>.from(data['answers'] ?? []);
          _compares = List<String>.from(data['compares'] ?? []);
          _currentQuestionIndex = 0;
          notifyListeners();
        } else {
          print('Play room document does not exist.');
        }
      } catch (e) {
        print('Error fetching questions: $e');
      }
    } else {
      print('Play room ID is empty.');
    }
  }

  Future<void> deletePlayRoom() async {
  if (_playRoomID.isNotEmpty) {
    try {
      await _firestore.collection('play_rooms').doc(_playRoomID).delete();
      _playRoomID = "";
      _myScore = 0;
      _opponentScore = 0;
      _currentQuestionIndex = 0;
      _questions.clear();
      _answers.clear();
      _compares.clear();
      notifyListeners();
    } catch (e) {
      print('Error deleting play room: $e');
    }
  }
}
}