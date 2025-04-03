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
 String _avatarOpponent = "";
 //rank
 int _rank_grade_1 = 0;
 int _rank_grade_2 = 0;
 int _rank_grade_3 = 0;



 int get myScore => _myScore;
 int get rivalScore => _opponentScore;
 String get playRoomID => _playRoomID;
 String get opponentID => _opponentID;
 String get userID => _userID;
 String get statusEndMatchOpponent => _statusEndMatchOpponent;
 String get statusEndMatchUser => _statusEndMatchUser;
 bool get hasShownDialog => _hasShownDialog;
String get avatarOpponent => _avatarOpponent;
//rank
int get rank_grade_1 => _rank_grade_1;
int get rank_grade_2 => _rank_grade_2;
int get rank_grade_3 => _rank_grade_3;




  set hasShownDialog(bool value) {
    _hasShownDialog = value;
    notifyListeners(); 
  }

final FirebaseFirestore _firestore = FirebaseFirestore.instance;
Future<bool> addToWaitingRoom(String grade) async {
  DocumentReference waitingRoom = _firestore.collection('waiting_room').doc(_userID);
  StreamSubscription? waitingRoomListener;

  // Fetch the player's score from the gameplay collection
  DocumentSnapshot gameplayDoc = await _firestore.collection('gameplay').doc(_userID).get();
  int playerScore = 0;
  if (gameplayDoc.exists) {
    Map<String, dynamic> gameplayData = gameplayDoc.data() as Map<String, dynamic>;
    // Assuming the score for the specific grade is stored like 'rank_grade_1', 'rank_grade_2', etc.
    playerScore = gameplayData['rank_$grade'] ?? 0;
  }

  // Add player to waiting room with their score
  await waitingRoom.set({
    'id': _userID,
    'grade': grade,
    'status': 'waiting',
    'score': playerScore, // Store the player's score
    'timestamp': FieldValue.serverTimestamp(),
  });

  final completer = Completer<bool>();

  waitingRoomListener = _firestore
      .collection('waiting_room')
      .doc(_userID)
      .snapshots()
      .listen((snapshot) async {
    if (snapshot.exists) {
      final data = snapshot.data() as Map<String, dynamic>;
      if (data['status'] == 'matched') {
        _playRoomID = data['play_room_id'];
        _opponentID = data['matched_with'];
        DocumentSnapshot opponentDoc = await _firestore.collection('users').doc(_opponentID).get();
        _avatarOpponent = opponentDoc['avatar'];
        waitingRoomListener?.cancel();
        completer.complete(true);
      }
    }
  });

  return completer.future;
}

Future<bool> createOrJoinGame(String grade) async {
  _myScore = 0;
  _opponentScore = 0;
  _playRoomID = "";
  _opponentID = "";
  _userID = "";
  _statusEndMatchOpponent = "";
  _statusEndMatchUser = "";
  _hasShownDialog = false;

  final prefs = await SharedPreferences.getInstance();
  String? userId = prefs.getString('user_uid');
  _userID = userId as String;

  // Fetch the current player's score from the gameplay collection
  DocumentSnapshot gameplayDoc = await _firestore.collection('gameplay').doc(_userID).get();
  int myScore = 0;
  if (gameplayDoc.exists) {
    Map<String, dynamic> gameplayData = gameplayDoc.data() as Map<String, dynamic>;
    myScore = gameplayData['rank_$grade'] ?? 0;
  }

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
      // Filter players based on score difference (<= 300)
      DocumentSnapshot? matchingPlayer;
      for (var player in matchingPlayers.docs) {
        int opponentScore = player['score'] ?? 0;
        if ((myScore - opponentScore).abs() <= 600) {
          matchingPlayer = player;
          break;
        }
      }

      if (matchingPlayer != null) {
        _opponentID = matchingPlayer.id;
        _playRoomID = playRoom.id;
        DocumentSnapshot opponentDoc = await _firestore.collection('users').doc(_opponentID).get();

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
          'score': myScore, // Include score for consistency
          'timestamp': FieldValue.serverTimestamp(),
        });

        transaction.update(waitingRoom.doc(_opponentID), {
          'status': 'matched',
          'play_room_id': _playRoomID,
          'matched_with': userId,
        });

        // Get opponent avatar
        _avatarOpponent = opponentDoc['avatar'];

        return true;
      }
    }

    // No suitable match found, add player to waiting room
    return await addToWaitingRoom(grade);
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
Future<void> existPlayRoom() async {
  DocumentReference playRoomDoc = _firestore.collection('play_rooms').doc(_playRoomID);
  CollectionReference waitingRoom = _firestore.collection('waiting_room');
  try {
    _statusEndMatchUser = "lose"; // Set user as loser
    _statusEndMatchOpponent = "win"; // Set opponent as winner

    // Update the status for user and opponent in the play_room document
    await playRoomDoc.update({
      '$userID.status': _statusEndMatchUser,
      '$opponentID.status': _statusEndMatchOpponent,
    });

    // Fetch the play room document to get the grade
    DocumentSnapshot playRoomSnapshot = await playRoomDoc.get();
    String? grade = playRoomSnapshot.get('grade'); // Retrieve the grade field

    // Update ranks based on the grade if it exists
    if (grade != null) {
      // Update loser's rank (user) by subtracting 15 points, with a minimum of 0
      DocumentReference userDoc = _firestore.collection('gameplay').doc(_userID);
      if (_statusEndMatchUser == "lose") {
        DocumentSnapshot userSnapshot = await userDoc.get();
        Map<String, dynamic>? userData = userSnapshot.data() as Map<String, dynamic>?;
        if (userData != null) {
          if (grade == "grade_1") {
            int newRank = (_rank_grade_1 - 15).clamp(0, double.infinity).toInt(); 
            _rank_grade_1 = newRank; 
            await userDoc.update({
              'rank_grade_1': newRank,
            });
          } else if (grade == "grade_2") {
            int newRank = (_rank_grade_2 - 15).clamp(0, double.infinity).toInt();
            _rank_grade_2 = newRank; 
            await userDoc.update({
              'rank_grade_2': newRank,
            });
          } else if (grade == "grade_3") {
            int newRank = (_rank_grade_3 - 15).clamp(0, double.infinity).toInt();
            _rank_grade_3 = newRank; 
            await userDoc.update({
              'rank_grade_3': newRank,
            });
          }
        }
      }

      // Update winner's rank (opponent) by adding 15 points
      DocumentReference opponentDoc = _firestore.collection('gameplay').doc(_opponentID);
      if (_statusEndMatchOpponent == "win") {
        DocumentSnapshot opponentSnapshot = await opponentDoc.get();
        Map<String, dynamic>? opponentData = opponentSnapshot.data() as Map<String, dynamic>?;
        if (opponentData != null) {
          if (grade == "grade_1") {
            int currentRank = opponentData['rank_grade_1'] ?? 0;
            int newRank = currentRank + 15;
            await opponentDoc.update({
              'rank_grade_1': newRank,
            });
          } else if (grade == "grade_2") {
            int currentRank = opponentData['rank_grade_2'] ?? 0;
            int newRank = currentRank + 15;
            await opponentDoc.update({
              'rank_grade_2': newRank,
            });
          } else if (grade == "grade_3") {
            int currentRank = opponentData['rank_grade_3'] ?? 0;
            int newRank = currentRank + 15;
            await opponentDoc.update({
              'rank_grade_3': newRank,
            });
          }
        }
      }
    }

    // Notify listeners about the changes (e.g., for UI updates)
    notifyListeners();

    // Clean up by deleting waiting room entries for both user and opponent
    await waitingRoom.doc(_opponentID).delete();
    await waitingRoom.doc(_userID).delete();
  } catch (error) {
    print('Error exiting play room: $error'); // Log any errors
  }
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

//Handle endmatch with win and lose, plus point to winner and minus to loser
Future<void> updateEndMatchStatus() async {
  DocumentReference playRoomDoc = _firestore.collection('play_rooms').doc(_playRoomID);
  try {
    _statusEndMatchUser = "win";
    _statusEndMatchOpponent = "lose";

    // Update the status for user and opponent in play_room
    await playRoomDoc.update({
      '$userID.status': _statusEndMatchUser,
      '$opponentID.status': _statusEndMatchOpponent,
    });

    // Get the play room document to fetch the grade
    DocumentSnapshot playRoomSnapshot = await playRoomDoc.get();
    String? grade = playRoomSnapshot.get('grade'); // Fetch the grade field



    // Update ranks based on the grade
    if (grade != null) {
      // Update winner's rank (user)
      DocumentReference userDoc = _firestore.collection('gameplay').doc(_userID);
      if (_statusEndMatchUser == "win") {
        if (grade == "grade_1") {
            _rank_grade_1+=15;
          await userDoc.update({
            'rank_grade_1': _rank_grade_1
          });
        } else if (grade == "grade_2") {
          _rank_grade_2+=15;
          await userDoc.update({
            'rank_grade_2': _rank_grade_2, 
          });
        } else if (grade == "grade_3") {
          _rank_grade_3+=15;
          await userDoc.update({
            'rank_grade_3': _rank_grade_3, 
          });
        }
      }

      // Update loser's rank (opponent) with minimum of 0
      DocumentReference opponentDoc = _firestore.collection('gameplay').doc(_opponentID);
      if (_statusEndMatchOpponent == "lose") {
        DocumentSnapshot opponentSnapshot = await opponentDoc.get();
        Map<String, dynamic>? opponentData = opponentSnapshot.data() as Map<String, dynamic>?;
        if (opponentData != null) {
          if (grade == "grade_1") {
            int currentRank = opponentData['rank_grade_1'] ?? 0;
            int newRank = (currentRank - 15).clamp(0, double.infinity).toInt(); 
            await opponentDoc.update({
              'rank_grade_1': newRank,
            });
          } else if (grade == "grade_2") {
            int currentRank = opponentData['rank_grade_2'] ?? 0;
            int newRank = (currentRank - 15).clamp(0, double.infinity).toInt();
            await opponentDoc.update({
              'rank_grade_2': newRank,
            });
          } else if (grade == "grade_3") {
            int currentRank = opponentData['rank_grade_3'] ?? 0;
            int newRank = (currentRank - 15).clamp(0, double.infinity).toInt();
            await opponentDoc.update({
              'rank_grade_3': newRank,
            });
          }
        }
      }
    }

    // Notify listeners about the change
    notifyListeners();
  } catch (error) {
    print('Error updating end match status: $error');
  }
}

// Method to fetch and update local rank variables from Firestore
  Future<void> fetchAndUpdateRanks() async {
    final prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('user_uid');
    try {
      DocumentReference userDoc = _firestore.collection('gameplay').doc(userId);

      DocumentSnapshot userSnapshot = await userDoc.get();

      // Check if the document exists and has data
      if (userSnapshot.exists) {
        Map<String, dynamic>? userData = userSnapshot.data() as Map<String, dynamic>?;
        if (userData != null) {
          // Update local rank variables with values from Firestore, default to 0 if missing
          _rank_grade_1 = userData['rank_grade_1'] ?? 0;
          _rank_grade_2 = userData['rank_grade_2'] ?? 0;
          _rank_grade_3 = userData['rank_grade_3'] ?? 0;

          // Notify listeners to update the UI or other dependent components
          notifyListeners();

        } else {
          print('No data found in user document for user $userId');
        }
      } else {
        print('User document does not exist for user $userId');
      }
    } catch (error) {
      print('Error fetching ranks: $error');
    }
  }




}
