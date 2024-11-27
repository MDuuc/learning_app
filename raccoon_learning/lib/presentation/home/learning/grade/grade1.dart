import 'dart:math';

class Grade1 {
  String generateRandomQuestion({required Function(int) onAnswerGenerated}) {
    final random = Random();
    int a = random.nextInt(9) + 1;
    int b = random.nextInt(9) + 1;
    String operator = random.nextBool() ? "+" : "-";

  // check it valid question 
    if (operator == "-" && a < b) {
      int temp = a;
      a = b;
      b = temp;
    }

    int correctAnswer = operator == "+" ? a + b : a - b;

    // sent through callback
    onAnswerGenerated(correctAnswer);

    return "$a $operator $b = ?";
  }
}
