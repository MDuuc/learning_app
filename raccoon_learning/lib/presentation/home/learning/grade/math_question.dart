class MathQuestion {
  final String question; 
  final String operator; 
  final int correctAnswer; 
  final String? correctCompare; 


  MathQuestion({
    required this.question,
    required this.operator,
    required this.correctAnswer,
    this.correctCompare,
  });
}