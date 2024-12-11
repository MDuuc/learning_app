import 'dart:math';

class Grade3 {
  final String operation;

  Grade3(this.operation);

  // Generate Random Question
  String generateRandomQuestion({required Function(int) onAnswerGenerated}) {
    final random = Random();
    int a, b, correctAnswer;
    String operator;

    switch (operation) {
      case 'addition':
        // Addition: Total does not exceed 100
        a = random.nextInt(51) + 1; // a = 1 -> 51
        b = random.nextInt(101 - a); //a + b <= 100
        operator = "+";
        correctAnswer = a + b;
        break;

      case 'subtraction':
        // Subtraction: Total does not exceed 100
        a = random.nextInt(101); // a = 0 -> 100
        b = random.nextInt(a + 1); // b <= a
        operator = "-";
        correctAnswer = a - b;
        break;

      case 'multiplication':
        // Multiplication: Product does not exceed 100
        a = random.nextInt(13) + 1; // a = 1 -> 12
        b = random.nextInt((100 ~/ a)) + 1; //  a * b <= 100
        operator = "×";
        correctAnswer = a * b;
        break;

      case 'division':
        // Division: Result is an integer
        b = random.nextInt(12) + 1; // b = 1 -> 12
        correctAnswer = random.nextInt(9) + 1; // result = 1 -> 9
        a = b * correctAnswer;
        operator = "÷";
        break;

      case 'mix_operations':
        // choose random +, -, ×, ÷, 
        int operationIndex = random.nextInt(4); // 0: +, 1: -, 2: ×, 3: ÷
        if (operationIndex == 0) {
          operator = "+";
          a = random.nextInt(51) + 1;
          b = random.nextInt(101 - a);
          correctAnswer = a + b;
        } else if (operationIndex == 1) {
          operator = "-";
          a = random.nextInt(101);
          b = random.nextInt(a + 1);
          correctAnswer = a - b;
        } else if (operationIndex == 2) {
          operator = "×";
          a = random.nextInt(13) + 1;
          b = random.nextInt((100 ~/ a)) + 1;
          correctAnswer = a * b;
        } else{
          operator = "÷";
          b = random.nextInt(12) + 1;
          correctAnswer = random.nextInt(9) + 1;
          a = b * correctAnswer;
        } 
        break;

      default:
        return '';
    }
    // send anwser through callback
    onAnswerGenerated(correctAnswer);

    // Generate question
    return "$a $operator $b = ?";
  }
}
