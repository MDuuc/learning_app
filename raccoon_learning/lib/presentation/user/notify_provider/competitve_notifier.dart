import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CompetitveNotifier extends ChangeNotifier {
 int _myScore = 0;
 int _opponentScore =0;
 String _playRoomID ="";

 int get myScore => _myScore;
 int get rivalScore => _opponentScore;
 String get playRoomID => _playRoomID;

final FirebaseFirestore _firestore = FirebaseFirestore.instance;
Future<void> addToWaitingRoom( String grade) async {
  final prefs = await SharedPreferences.getInstance();
  String? userId = prefs.getString('user_uid');
  DocumentReference waitingRoom = _firestore.collection('waiting_room').doc(userId);
  
  await waitingRoom.set({
    'id': userId,
    'grade': grade,
    'timestamp': FieldValue.serverTimestamp(),
  });
}

Future<bool> createOrJoinGame( String grade) async {
  final prefs = await SharedPreferences.getInstance();
  String? userId = prefs.getString('user_uid');
  CollectionReference waitingRoom = _firestore.collection('waiting_room');
  DocumentReference playRooms = _firestore.collection('play_rooms').doc();

  final waitingDocs = await waitingRoom.get();
  if (waitingDocs.docs.isEmpty) {
    await addToWaitingRoom(grade);
  }

  // Get the list of waiting players with the same grade
  final QuerySnapshot matchingPlayers = await waitingRoom
      .where('grade', isEqualTo: grade)
      .where('id', isNotEqualTo: userId)
      .orderBy('timestamp',)
      .get();

      print(matchingPlayers.docs);

  if (matchingPlayers.docs.isNotEmpty) {
    // Match to opponent player
    final matchingPlayer = matchingPlayers.docs.first;
    final otherUserId = matchingPlayer.id;

    // save zoom id
    _playRoomID = playRooms.id;

    await playRooms.set({
      'User1': {'userId': userId, 'score': 0},
      'User2': {'userId': otherUserId, 'score': 0},
      'grade': grade,
    });
      // delete watiting room if match successfull
    await waitingRoom.doc(otherUserId).delete();
    await waitingRoom.doc(userId).delete();
    return true;
  } else {
    // If you haven't found an opponent, add a player to the waiting room
    await addToWaitingRoom(grade);
    return false;
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
    CollectionReference waitingRoom = _firestore.collection('play_rooms');
    await waitingRoom.doc(_playRoomID).delete();
  }

  // delete waiting user if cancle match
  Future <void> deleteWaiting()async{
      final prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('user_uid');
    CollectionReference waitingRoom = _firestore.collection('waiting_room');
    await waitingRoom.doc(userId).delete();
  }

}

