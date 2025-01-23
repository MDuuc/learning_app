import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CompetitveNotifier extends ChangeNotifier {
 int _myScore = 0;
 int _opponentScore =0;
 String _playRoomID ="";
 String _opponentID="";

 int get myScore => _myScore;
 int get rivalScore => _opponentScore;
 String get playRoomID => _playRoomID;
 String get opponentID => _opponentID;


final FirebaseFirestore _firestore = FirebaseFirestore.instance;
Future<bool> addToWaitingRoom( String grade) async {
  final prefs = await SharedPreferences.getInstance();
  String? userId = prefs.getString('user_uid');
  DocumentReference waitingRoom = _firestore.collection('waiting_room').doc(userId);
  StreamSubscription? _waitingRoomListener;
  
  await waitingRoom.set({
    'id': userId,
    'grade': grade,
    'status': 'waiting',
    'timestamp': FieldValue.serverTimestamp(),
  });

  final completer = Completer<bool>();

  _waitingRoomListener = _firestore
  .collection('waiting_room')
  .doc(userId)
  .snapshots()
  .listen((snapshot) {
    if (snapshot.exists) {
      final data = snapshot.data() as Map<String, dynamic>;
      if (data['status'] == 'matched') {
        _waitingRoomListener?.cancel();
        return completer.complete(true);
      }
    }
  });
    return completer.future;
}

Future<bool> createOrJoinGame( String grade) async {
  final prefs = await SharedPreferences.getInstance();
  String? userId = prefs.getString('user_uid');
  CollectionReference waitingRoom = _firestore.collection('waiting_room');
  DocumentReference playRooms = _firestore.collection('play_rooms').doc();

  // Get the list of waiting players with the same grade
  final QuerySnapshot matchingPlayers = await waitingRoom
      .where('grade', isEqualTo: grade)
      .where('id', isNotEqualTo: userId)
      .where('status', isEqualTo: 'waiting')
      .orderBy('timestamp',)
      .get();


  if (matchingPlayers.docs.isNotEmpty) {
    // Match to opponent player
    final matchingPlayer = matchingPlayers.docs.first;
     _opponentID = matchingPlayer.id;

    // save zoom id
    _playRoomID = playRooms.id;

    await playRooms.set({
      'User1': {'userId': userId, 'score': 0},
      'User2': {'userId': _opponentID, 'score': 0},
      'grade': grade,
    });
      // update watiting room if match successfull
    await waitingRoom.doc(userId).set({
      'id': userId,
      'grade': grade,
      'status': 'matched',
      'playRoomID': _playRoomID,
      'timestamp': FieldValue.serverTimestamp(),

    });
    
    await waitingRoom.doc(_opponentID).update({
      'status': 'matched', 
      'playRoomID': _playRoomID
    });
    return true;
  } else {
    // If you haven't found an opponent, add a player to the waiting room
    return addToWaitingRoom(grade);
  }
}

  // Listen to room updates for real-time score changes
  void listenToRoomUpdates() {
    if (_playRoomID.isNotEmpty) {
      _firestore.collection('play_rooms').doc(_playRoomID).snapshots().listen((snapshot) {
        if (snapshot.exists) {
          final data = snapshot.data() as Map<String, dynamic>;

          // Update the scores and notify listeners
          _myScore = data['User1']['score'];
          _opponentScore = data['User2']['score'];
          notifyListeners();
        }
      });
    }
  }

// delete room after finish
  Future <void> deletePlayRoom()async{
    final prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('user_uid');
    CollectionReference playRoom = _firestore.collection('play_rooms');
    CollectionReference waitingRoom = _firestore.collection('waiting_room');
    await playRoom.doc(_playRoomID).delete();
    await waitingRoom.doc(_opponentID).delete();
    await waitingRoom.doc(userId).delete();
  }

  // delete waiting user if cancle match
  Future <void> deleteWaiting()async{
      final prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('user_uid');
    CollectionReference waitingRoom = _firestore.collection('waiting_room');
    await waitingRoom.doc(userId).delete();
  }

}
