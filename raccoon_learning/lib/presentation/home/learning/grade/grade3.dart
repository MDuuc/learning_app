import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:raccoon_learning/presentation/home/learning/grade/math_question.dart';
import 'package:raccoon_learning/presentation/user/notify_provider/analysis_data_notifier.dart';

class Grade3 {
  final String operation;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Firestore instance for word problems

  Grade3(this.operation);

  // Generates a random math question based on the specified operation
  Future<MathQuestion> generateRandomQuestion({
    required BuildContext context,
  }) async {
    final random = Random();
    int a = 0; // Default initialization for first number
    int b = 0; // Default initialization for second number
    int correctAnswer = 0; // Default initialization for the answer
    String operator = ''; // Default operator
    String correctCompare = ''; // Default comparison result (kept for consistency with Grade1)
    String question = ''; // Default question string

    // Fetch weights from AnalysisDataNotifier for operation selection
    final analysisDataNotifier = Provider.of<AnalysisDataNotifier>(context, listen: false);
    Map<String, double> weights = analysisDataNotifier.weights['grade_3'] ?? {};
    print('📊 Weight: $weights');
    if (weights.isEmpty) {
      print("⚠ Weights empty, using default equal weights");
      weights = {"+": 1.0, "-": 1.0, "x": 1.0, "/": 1.0}; // Default weights for +, -, x, /
    }

    // Determine the type of operation and generate corresponding question
    switch (operation) {
      case 'addition':
        a = random.nextInt(51) + 1; // Generate a: 1 to 51
        b = random.nextInt(101 - a); // Generate b so that a + b <= 100
        operator = "+";
        correctAnswer = a + b;
        question = "$a $operator $b = ?";
        break;

      case 'subtraction':
        a = random.nextInt(101); // Generate a: 0 to 100
        b = random.nextInt(a + 1); // Generate b so that a - b >= 0
        operator = "-";
        correctAnswer = a - b;
        question = "$a $operator $b = ?";
        break;

      case 'multiplication':
        a = random.nextInt(13) + 1; // Generate a: 1 to 13
        b = random.nextInt((100 ~/ a)) + 1; // Generate b so that a * b <= 100
        operator = "x";
        correctAnswer = a * b;
        question = "$a $operator $b = ?";
        break;

      case 'division':
        b = random.nextInt(12) + 1; // Generate b (divisor): 1 to 12
        correctAnswer = random.nextInt(9) + 1; // Generate quotient: 1 to 9
        a = b * correctAnswer; // Calculate a (dividend) as b * quotient
        operator = "/";
        question = "$a $operator $b = ?";
        break;

      case 'word_problem':
        // Fetch a random word problem from Firestore for Grade 3
        final snapshot = await _firestore
            .collection('questions')
            .doc('grade3') // Use grade3 document
            .collection('items')
            .get();

        if (snapshot.docs.isEmpty) {
          throw Exception('No word problems found in Firestore for Grade 3');
        }

        // Select a random question from the fetched documents
        final randomDoc = snapshot.docs[random.nextInt(snapshot.docs.length)];
        final data = randomDoc.data();
        String templateQuestion = data['question'] ?? '';
        String templateAnswer = data['answer'] ?? '';

        // Map to store variable values 
        Map<String, int> variables = {};
        List<String> variableNames = ['A', 'B', 'C', 'D'];

        // Replace variables in the question based on the operation in templateAnswer
        for (int i = 0; i < variableNames.length; i++) {
          String varName = variableNames[i];
          final pattern = RegExp(r'\b' + varName + r'\b'); // Match standalone variables only
          if (templateQuestion.contains(varName)) {
            if (templateAnswer.contains('-') && i == 0) {
              // Subtraction: First variable (A) should be large (50-100)
              variables[varName] = random.nextInt(51) + 50; // Range: 50 to 100
            } else if (templateAnswer.contains('-') && i == 1) {
              // Subtraction: Second variable (B) should be less than A
              int maxB = variables[variableNames[0]]! - 1;
              variables[varName] = random.nextInt(maxB) + 1; // Range: 1 to A-1
            } else if (templateAnswer.contains('x')) {
              // Multiplication: Keep numbers reasonable (1-13)
              variables[varName] = random.nextInt(13) + 1; // Range: 1 to 13
            } else if (templateAnswer.contains('/') && i == 0) {
              // Division: First variable (A) is the dividend, calculated as B * quotient
              if (variables.containsKey(variableNames[1])) {
                // If B is already set, calculate A = B * random quotient
                int quotient = random.nextInt(9) + 1; // Quotient: 1 to 9
                variables[varName] = variables[variableNames[1]]! * quotient;
              } else {
                variables[varName] = random.nextInt(100) + 1; // Default: 1-100
              }
            } else if (templateAnswer.contains('/') && i == 1) {
              // Division: Second variable (B) is the divisor
              variables[varName] = random.nextInt(12) + 1; // Range: 1 to 12
              // If A is already set, adjust A to be divisible by B
              if (variables.containsKey(variableNames[0])) {
                int quotient = variables[variableNames[0]]! ~/ variables[varName]!;
                if (quotient > 9) quotient = 9; // Cap quotient at 9
                variables[variableNames[0]] = variables[varName]! * quotient;
              }
            } else if (templateAnswer.contains('+') && i == 0) {
              // Addition: First variable (A) from 1-51
              variables[varName] = random.nextInt(51) + 1; // Range: 1 to 51
            } else if (templateAnswer.contains('+') && i == 1) {
              // Addition: Second variable (B) so that A + B <= 100
              int maxB = 100 - variables[variableNames[0]]!;
              variables[varName] = random.nextInt(maxB + 1); // Range: 0 to 100-A
            } else {
              // Default case: Random number from 1-100
              variables[varName] = random.nextInt(100) + 1;
            }
            templateQuestion = templateQuestion.replaceAll(
              pattern,
              variables[varName]!.toString(),
            );
          }
        }

        // Calculate the correct answer based on the templateAnswer
        correctAnswer = _evaluateExpression(templateAnswer, variables);
        operator = '';
        correctCompare = '';
        question = templateQuestion;
        break;

      case 'mix_operations':
        List<String> operators = ["+", "-", "x", "/"];
        List<double> cumulativeWeights = [];
        double sum = 0;

        // Calculate cumulative weights for weighted random selection
        for (String op in operators) {
          double weight = weights[op] ?? 1.0;
          sum += weight;
          cumulativeWeights.add(sum);
        }

        // Select an operator based on weighted random value
        double rand = random.nextDouble() * sum;
        for (int i = 0; i < cumulativeWeights.length; i++) {
          if (rand >= (i == 0 ? 0 : cumulativeWeights[i - 1]) && rand < cumulativeWeights[i]) {
            operator = operators[i];
            break;
          }
        }

        // Generate question based on selected operator
        switch (operator) {
          case "+":
            a = random.nextInt(51) + 1;
            b = random.nextInt(101 - a);
            correctAnswer = a + b;
            break;
          case "-":
            a = random.nextInt(101);
            b = random.nextInt(a + 1);
            correctAnswer = a - b;
            break;
          case "x":
            a = random.nextInt(13) + 1;
            b = random.nextInt((100 ~/ a)) + 1;
            correctAnswer = a * b;
            break;
          case "/":
            b = random.nextInt(12) + 1;
            correctAnswer = random.nextInt(9) + 1;
            a = b * correctAnswer;
            break;
          default:
            throw Exception('Error: No valid operator selected');
        }
        question = "$a $operator $b = ?";
        break;

      default:
        throw Exception('Error: Invalid operation');
    }

    print("Generated question with operator: $operator"); // Debug log
    return MathQuestion(
      question: question,
      operator: operator,
      correctAnswer: correctAnswer,
      correctCompare: correctCompare, // Kept for consistency with Grade1
    );
  }

  // Evaluates the expression in templateAnswer and returns the result
  int _evaluateExpression(String expression, Map<String, int> variables) {
    expression = expression.trim();

    // Replace variables with their values, ensuring standalone matches only
    for (String varName in variables.keys) {
      final pattern = RegExp(r'\b' + varName + r'\b');
      expression = expression.replaceAll(pattern, variables[varName]!.toString());
    }

    // Handle basic arithmetic operations
    if (expression.contains('+')) {
      final parts = expression.split('+');
      return int.parse(parts[0].trim()) + int.parse(parts[1].trim());
    } else if (expression.contains('-')) {
      final parts = expression.split('-');
      return int.parse(parts[0].trim()) - int.parse(parts[1].trim());
    } else if (expression.contains('x')) {
      final parts = expression.split('x');
      return int.parse(parts[0].trim()) * int.parse(parts[1].trim());
    } else if (expression.contains('/')) {
      final parts = expression.split('/');
      return int.parse(parts[0].trim()) ~/ int.parse(parts[1].trim()); // Integer division
    } else {
      return int.parse(expression); // Return number if no operator is present
    }
  }
}