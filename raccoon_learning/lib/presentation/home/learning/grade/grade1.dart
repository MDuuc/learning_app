import 'dart:math';

class Grade1 {
  final String operation;

  Grade1(this.operation); 

  // Hàm generateRandomQuestion
  String generateRandomQuestion({required Function(int) onAnswerGenerated, required Function(String) onAnswerCompare}) {
    final random = Random();
    int a, b, correctAnswer;
    String correctCompare;
    String operator;

    switch (operation) {
      case 'addition':
        // Addition: Total does not exceed 10
        a = random.nextInt(6) + 1;  // a= 1->6
        b = random.nextInt(11 - a) ;  // b with conditition a + b <= 10
        operator = "+";
        correctAnswer = a + b;
        correctCompare='';
        break;

      case 'subtraction':
        // Subtraction: Total does not exceed 10
        a = random.nextInt(11); // a= 0 ->10
        b = random.nextInt(a + 1); // b with conditition a - b <= 10
        operator = "-";
        correctAnswer = a - b;
        correctCompare='';
        break;

      case 'comparation':  // comparing
        a = random.nextInt(10) + 1; 
        b = random.nextInt(10) + 1;

        // Chose random operation: ">", "<", "="
        int operatorIndex = random.nextInt(3);
        if (operatorIndex == 0) {
          operator = ">";
          correctCompare = (a > b ? ">" : "<"); // correct ">" if  a > b
        } else if (operatorIndex == 1) {
          operator = "<";
          correctCompare = (a > b ? ">" : "<"); // correct "<" if a < b
        } else {
          operator = "=";
          correctCompare = (a == b ? "=" : (a > b ? ">" : "<")); // check "=" before ">" or "<"
        }

        correctAnswer = 0;
        break;


      case 'mix_operations':
        operator = random.nextBool() ? "+" : (random.nextBool() ? "-" : (random.nextBool() ? ">" : "<"));
        if (operator == "+") {
          a = random.nextInt(6) + 1; 
          b = random.nextInt(11 - a); 
          correctAnswer = a + b;  
          correctCompare='';
        } else if (operator == "-") {
          a = random.nextInt(11); 
          b = random.nextInt(a + 1); 
          correctAnswer = a - b;
           correctCompare='';
        } else {
          a = random.nextInt(10) + 1; 
          b = random.nextInt(10) + 1;  
          correctCompare = (a == b ? "=" : (a > b ? ">" : "<")); 
          correctAnswer=0;
        } 
        break;

      default:
        return ''; 
    }

    // Sending the correct answer via callback
    onAnswerGenerated(correctAnswer);
    onAnswerCompare(correctCompare);

    // Generate question
    if (operator == ">" || operator == "<" || operator == "=") {
      return "$a ? $b ";
    }
    return "$a $operator $b = ?";
  }
}
