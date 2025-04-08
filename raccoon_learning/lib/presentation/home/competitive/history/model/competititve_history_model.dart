class CompetititveHistoryModel {
  final String playRoomId;
  final String grade;
  final String opponentId;
  final int? userScore;
  final int? opponentScore;
  final String? status;

  CompetititveHistoryModel({
    required this.playRoomId,
    required this.grade,
    required this.opponentId,
    this.userScore,
    this.opponentScore,
    this.status,
  });

  factory CompetititveHistoryModel.fromMap(Map<String, dynamic> data) {
    return CompetititveHistoryModel(
      playRoomId: data['playRoomID'] ?? '',
      grade: data['grade'] ?? '',
      opponentId: data['opponentID'] ?? '',
    );
  }
}