import 'dart:math';

class Grade2 {
  final String operation;

  Grade2(this.operation); 

  // Hàm generateRandomQuestion
  String generateRandomQuestion({required Function(int) onAnswerGenerated}) {
    final random = Random();
    int a, b, correctAnswer;
    String operator;

    switch (operation) {
      case 'addition':
        // Addition: Total does not exceed 100
        a = random.nextInt(51) + 1;  // a= 1->51
        b = random.nextInt(101 - a) ;  // b with conditition a + b <= 100
        operator = "+";
        correctAnswer = a + b;
        break;

      case 'subtraction':
        // Subtraction: Total does not exceed 10
        a = random.nextInt(101); // a= 0 ->100
        b = random.nextInt(a + 1); // b with conditition a - b <= 100
        operator = "-";
        correctAnswer = a - b;
        break;

      case 'multiplication':
        // Addition: Total does not exceed 100
        a = random.nextInt(10) ;  // a= 1->9
        b = random.nextInt(10) ;  // b= 1 ->9
        operator = "x";
        correctAnswer = a * b;
        break;


      case 'mix_operations':
        // choose random +, -, ×, ÷, 
        int operationIndex = random.nextInt(3); // 0: +, 1: -, 2: ×
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
        } else {
          operator = "×";
          a = random.nextInt(10) ;  // a= 1->9
          b = random.nextInt(10) ;  // b= 1 ->9
          correctAnswer = a * b;
        } 
      default:
        return ''; 
    }

    // Sending the correct answer via callback
    onAnswerGenerated(correctAnswer);

    // Generate question
    return "$a $operator $b = ?";
  }
}
