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
        final snapshot = await _firestore
            .collection('questions')
            .doc('grade3')
            .collection('items')
            .get();

        if (snapshot.docs.isEmpty) {
          throw Exception('No word problems found in Firestore for Grade 3');
        }

        final randomDoc = snapshot.docs[random.nextInt(snapshot.docs.length)];
        final data = randomDoc.data();
        String templateQuestion = data['question'] ?? '';
        String templateAnswer = data['answer'] ?? '';

        Map<String, int> variables = {};
        List<String> variableNames = ['A', 'B', 'C', 'D'];

        for (int i = 0; i < variableNames.length; i++) {
          String varName = variableNames[i];
          final pattern = RegExp(r'\b' + varName + r'\b');
          if (templateQuestion.contains(varName)) {
            if (templateAnswer.contains('-') && i == 0) {
              variables[varName] = random.nextInt(51) + 50; // A: 50-100
            } else if (templateAnswer.contains('-') && i == 1) {
              int maxB = variables[variableNames[0]]! - 1;
              variables[varName] = random.nextInt(maxB) + 1; // B: 1 to A-1
            } else if (templateAnswer.contains('x')) {
              variables[varName] = random.nextInt(13) + 1; // 1-13
            } else if (templateAnswer.contains('/') && i == 0) {
              // Division: A (dividend) sẽ được tính sau khi B được gán
              if (!variables.containsKey(variableNames[1])) {
                variables[varName] = 0; // Placeholder, sẽ cập nhật sau
              }
            } else if (templateAnswer.contains('/') && i == 1) {
              // Division: Gán B trước, rồi tính A dựa trên B
              variables[varName] = random.nextInt(12) + 1; // B: 1-12
              int b = variables[varName]!;
              int quotient = random.nextInt(9) + 1; // Quotient: 1-9
              variables[variableNames[0]] = b * quotient; // A = B * quotient
              int a = variables[variableNames[0]]!;
              print("Generated: $a/$b");
              // Cập nhật templateQuestion cho cả A và B
              templateQuestion = templateQuestion.replaceAll(
                RegExp(r'\b' + variableNames[0] + r'\b'),
                a.toString(),
              );
              templateQuestion = templateQuestion.replaceAll(
                pattern,
                b.toString(),
              );
            } else if (templateAnswer.contains('+') && i == 0) {
              variables[varName] = random.nextInt(51) + 1; // A: 1-51
            } else if (templateAnswer.contains('+') && i == 1) {
              int maxB = 100 - variables[variableNames[0]]!;
              variables[varName] = random.nextInt(maxB + 1); // B: 0 to 100-A
            } else {
              variables[varName] = random.nextInt(100) + 1; // Default: 1-100
            }
            if (!(templateAnswer.contains('/') && i == 0)) {
              templateQuestion = templateQuestion.replaceAll(
                pattern,
                variables[varName]!.toString(),
              );
            }
          }
        }
        if (templateAnswer.contains('+')) {
          operator = '+';
        } else if (templateAnswer.contains('-')) {
          operator = '-';
        } else if (templateAnswer.contains('x') || templateAnswer.contains('*')) {
          operator = 'x';
        } else if (templateAnswer.contains('/')) {
          operator = '/';
        } else {
          operator = ''; 
        }

        correctAnswer = _evaluateExpression(templateAnswer, variables);
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

  // Evaluates the templateAnswer in templateAnswer and returns the result
  int _evaluateExpression(String templateAnswer, Map<String, int> variables) {
    templateAnswer = templateAnswer.trim();

    // Replace variables with their values, ensuring standalone matches only
    for (String varName in variables.keys) {
      templateAnswer = templateAnswer.replaceAll(varName, variables[varName]!.toString());
    }
    print(templateAnswer);

    // Handle basic arithmetic operations
    if (templateAnswer.contains('+')) {
      final parts = templateAnswer.split('+');
      return int.parse(parts[0].trim()) + int.parse(parts[1].trim());
    } else if (templateAnswer.contains('-')) {
      final parts = templateAnswer.split('-');
      return int.parse(parts[0].trim()) - int.parse(parts[1].trim());
    } else if (templateAnswer.contains('x') || templateAnswer.contains('*')) {
      final parts = templateAnswer.contains('x') ? templateAnswer.split('x') : templateAnswer.split('*');
      return int.parse(parts[0].trim()) * int.parse(parts[1].trim());
    } else if (templateAnswer.contains('/')) {
      final parts = templateAnswer.split('/');
      return int.parse(parts[0].trim()) ~/ int.parse(parts[1].trim()); // Integer division
    } else {
      return int.parse(templateAnswer); // Return number if no operator is present
    }
  }
}