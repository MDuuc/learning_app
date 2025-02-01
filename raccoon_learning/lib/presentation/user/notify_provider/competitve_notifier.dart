import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CompetitveNotifier extends ChangeNotifier {
 int _myScore = 0;
 int _opponentScore =0;
 String _playRoomID ="";
 String _opponentID="";
 String _userID="";
 String _statusEndMatchOpponent = "";
 String _statusEndMatchUser= "";
 bool _hasShownDialog = false;


 int get myScore => _myScore;
 int get rivalScore => _opponentScore;
 String get playRoomID => _playRoomID;
 String get opponentID => _opponentID;
 String get userID => _userID;
 String get statusEndMatchOpponent => _statusEndMatchOpponent;
 String get statusEndMatchUser => _statusEndMatchUser;
 bool get hasShownDialog => _hasShownDialog;


  set hasShownDialog(bool value) {
    _hasShownDialog = value;
    notifyListeners(); 
  }

final FirebaseFirestore _firestore = FirebaseFirestore.instance;
Future<bool> addToWaitingRoom( String grade) async {
  DocumentReference waitingRoom = _firestore.collection('waiting_room').doc(_userID);
  StreamSubscription? waitingRoomListener;
  
  await waitingRoom.set({
    'id': _userID,
    'grade': grade,
    'status': 'waiting',
    'timestamp': FieldValue.serverTimestamp(),
  });

  final completer = Completer<bool>();

  waitingRoomListener = _firestore
  .collection('waiting_room')
  .doc(_userID)
  .snapshots()
  .listen((snapshot) {
    if (snapshot.exists) {
      final data = snapshot.data() as Map<String, dynamic>;
      if (data['status'] == 'matched') {
       _playRoomID = data['play_room_id'];
       _opponentID = data['matched_with'];
        waitingRoomListener?.cancel();
        return completer.complete(true);
      }
    }
  });
    return completer.future;
}

Future<bool> createOrJoinGame( String grade) async {
  _myScore = 0;
  _opponentScore =0;
  _playRoomID ="";
  _opponentID="";
  _userID="";
  _statusEndMatchOpponent = "";
  _statusEndMatchUser= "";
  _hasShownDialog = false;
  final prefs = await SharedPreferences.getInstance();
  String? userId = prefs.getString('user_uid');
  _userID= (userId) as String;
  CollectionReference waitingRoom = _firestore.collection('waiting_room');
  DocumentReference playRoom = _firestore.collection('play_rooms').doc();
   return await _firestore.runTransaction((transaction) async {
    // Attempt to find a matching player
    final QuerySnapshot matchingPlayers = await waitingRoom
        .where('grade', isEqualTo: grade)
        .where('id', isNotEqualTo: userId)
        .where('status', isEqualTo: 'waiting')
        .orderBy('timestamp')
        .get();

    if (matchingPlayers.docs.isNotEmpty) {
      final matchingPlayer = matchingPlayers.docs.first;
      _opponentID = matchingPlayer.id;
      _playRoomID = playRoom.id;

      // Create a play room document
      transaction.set(playRoom, {
        userId: {'score': 0, 'status': 'playing'},
        _opponentID: {'score': 0, 'status': 'playing'},
        'grade': grade,
        'created_at': FieldValue.serverTimestamp(),
        'status': 'active'
      });

      // Update both players in waiting room
      transaction.set(waitingRoom.doc(userId), {
        'status': 'matched',
        'play_room_id': _playRoomID,
        'matched_with': _opponentID,
        'id': _userID,
        'grade': grade,
        'timestamp': FieldValue.serverTimestamp(),
      });

      transaction.update(waitingRoom.doc(_opponentID), {
        'status': 'matched',
        'play_room_id': _playRoomID,
        'matched_with': userId,
      });

      return true;
    } else {
      // No match found, add player to waiting room
      return await addToWaitingRoom(grade);
    }
  });

}

  // Listen to room updates for real-time score changes
  void listenToPointUpdates() {
  if ( _playRoomID.isNotEmpty) {
    _firestore.collection('play_rooms').doc(_playRoomID).snapshots().listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>?;

        if (data != null && data.containsKey(_userID) && data.containsKey(_opponentID)) {
          _myScore = data[_userID]['score'] ?? 0;
          _opponentScore = data[_opponentID]['score'] ?? 0;

          _statusEndMatchUser = data[_userID]['status'] ?? 'unknown';
          _statusEndMatchOpponent = data[_opponentID]['status'] ?? 'unknown';

          notifyListeners();
        }
      }
    });
}

  }

// delete room after finish
  Future <void> existPlayRoom()async{
    DocumentReference playRoomDoc = _firestore.collection('play_rooms').doc(_playRoomID);
    CollectionReference waitingRoom = _firestore.collection('waiting_room');
        try {
      _statusEndMatchUser="lose";
      _statusEndMatchOpponent="win";

      // Update the score for the user by incrementing it atomically
      await playRoomDoc.update({
        '$userID.status': _statusEndMatchUser,
        '$opponentID.status': _statusEndMatchOpponent,

      });
      // Notify listeners about the change
      // _statusEndMatchUser.close();
      notifyListeners();
    } catch (error) {
    }
    await waitingRoom.doc(_opponentID).delete();
    await waitingRoom.doc(_userID).delete();
  }

  // endPlayRoom
    Future <void> endPlayRoom()async{
    CollectionReference waitingRoom = _firestore.collection('waiting_room');
    await waitingRoom.doc(_opponentID).delete();
    await waitingRoom.doc(_userID).delete();
  }

  // delete waiting user if cancle match
  Future <void> deleteWaiting()async{
    CollectionReference waitingRoom = _firestore.collection('waiting_room');
    await waitingRoom.doc(_userID).delete();
  }

  // update point 
void updateScore() async {
  if (_playRoomID.isNotEmpty) {
    DocumentReference playRoomDoc = _firestore.collection('play_rooms').doc(_playRoomID);
    try {
       _myScore+=1;
      // Update the score for the user by incrementing it atomically
      await playRoomDoc.update({
        '$userID.score': _myScore,
      });
      // Notify listeners about the change
      notifyListeners();
    } catch (error) {
      print('Error updating score: $error');
    }
  } else {
    print('Error: _playRoomID is empty.');
  }
}

  // update endMatch status  
  Future <void> updateEndMatchStatus()async{
    DocumentReference playRoomDoc = _firestore.collection('play_rooms').doc(_playRoomID);
        try {
      _statusEndMatchUser="win";
      _statusEndMatchOpponent="lose";

      // Update the score for the user by incrementing it atomically
      await playRoomDoc.update({
        '$userID.status': _statusEndMatchUser,
        '$opponentID.status': _statusEndMatchOpponent,

      });
      // Notify listeners about the change
      // _statusEndMatchUser.close();
      notifyListeners();
    } catch (error) {
      print('Error out room: $error');
    }
  }




}
