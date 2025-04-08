import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:raccoon_learning/presentation/home/competitive/history/model/competititve_history_model.dart';
import 'package:raccoon_learning/presentation/home/competitive/history/model/grade_history_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryNotifier extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<GradeHistoryModel> _gradeHistories = [];
  bool _isLoading = false;

  List<GradeHistoryModel> get gradeHistories => _gradeHistories;
  bool get isLoading => _isLoading;

  Future<void> loadCompetitiveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('user_uid');
    try {
      _isLoading = true;
      notifyListeners();

      // Get competitive history from user's document
      DocumentSnapshot userDoc = await _firestore
          .collection('gameplay')
          .doc(userId)
          .get();

      if (!userDoc.exists) {
        _gradeHistories = [];
        _isLoading = false;
        notifyListeners();
        return;
      }

      List<dynamic> historyArray = userDoc.get('competitiveHistory') ?? [];

      // print('Raw competitiveHistory array: $historyArray');
      List<CompetititveHistoryModel> allHistories = historyArray
          .map((item) => CompetititveHistoryModel.fromMap(item as Map<String, dynamic>))
          .toList();

    //       print('Parsed histories count: ${allHistories.length}');
    // print('All histories:');
    // allHistories.forEach((h) => print(
    //   'PlayRoomID: ${h.playRoomId}, Grade: ${h.grade}, OpponentID: ${h.opponentId}'
    // ));

      // Group histories by grade
      Map<String, List<CompetititveHistoryModel>> groupedByGrade = {};
      for (var history in allHistories) {
        if (!groupedByGrade.containsKey(history.grade)) {
          groupedByGrade[history.grade] = [];
        }
        groupedByGrade[history.grade]!.add(history);
      }

      // Fetch additional data for each history entry
      List<GradeHistoryModel> tempGradeHistories = [];
      for (String grade in groupedByGrade.keys) {
        List<CompetititveHistoryModel> gradeHistories = [];
        
        for (CompetititveHistoryModel history in groupedByGrade[grade]!) {
          // Get play room data
          DocumentSnapshot playRoomDoc = await _firestore
              .collection('play_rooms')
              .doc(history.playRoomId)
              .get();

          if (playRoomDoc.exists) {
            Map<String, dynamic> playRoomData = 
                playRoomDoc.data() as Map<String, dynamic>;
            
            // Get user and opponent scores/status
            int? userScore = playRoomData[userId]?['score'];
            String? status = playRoomData[userId]?['status'];
            int? opponentScore = playRoomData[history.opponentId]?['score'];

// print('User Score: $userScore, Status: $status, Opponent Score: $opponentScore');
            gradeHistories.add(CompetititveHistoryModel(
              playRoomId: history.playRoomId,
              grade: history.grade,
              opponentId: history.opponentId,
              userScore: userScore,
              opponentScore: opponentScore,
              status: status,
            ));
          } else {
            gradeHistories.add(history);
          }
        }
        
        tempGradeHistories.add(GradeHistoryModel(
          grade: grade,
          histories: gradeHistories,
        ));
      }

      _gradeHistories = tempGradeHistories;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error loading competitive history: $e');
      _isLoading = false;
      notifyListeners();
    }
  }
}