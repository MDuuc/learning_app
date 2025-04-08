import 'package:raccoon_learning/presentation/home/competitive/history/model/competititve_history_model.dart';

class GradeHistoryModel {
  final String grade;
  final List<CompetititveHistoryModel> histories;

  GradeHistoryModel({
    required this.grade,
    required this.histories,
  });
}