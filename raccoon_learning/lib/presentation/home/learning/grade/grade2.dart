import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raccoon_learning/presentation/home/learning/grade/math_question.dart';
import 'package:raccoon_learning/presentation/user/notify_provider/analysis_data_notifier.dart';

class Grade2 {
  final String operation;

  Grade2(this.operation);

  // Generates a random math question based on the specified operation
  MathQuestion generateRandomQuestion({
    required BuildContext context,
  }) {
    final random = Random();
    int a, b, correctAnswer;
    String operator = '';

    // Lấy weights từ AnalysisDataNotifier
    final analysisDataNotifier = Provider.of<AnalysisDataNotifier>(context, listen: false);
    Map<String, double> weights = analysisDataNotifier.weights['grade_2'] ?? {};
    print('📊 Weight for Grade 2: $weights');
    if (weights.isEmpty) {
      print("⚠ Weights empty, using default equal weights");
      weights = {"+": 1.0, "-": 1.0, "×": 1.0}; 
    }

    switch (operation) {
      case 'addition':
        a = random.nextInt(51) + 1; // a = 1 -> 51
        b = random.nextInt(101 - a); // b sao cho a + b <= 100
        operator = "+";
        correctAnswer = a + b;
        break;

      case 'subtraction':
        a = random.nextInt(101); // a = 0 -> 100
        b = random.nextInt(a + 1); // b sao cho a - b >= 0
        operator = "-";
        correctAnswer = a - b;
        break;

      case 'multiplication':
        a = random.nextInt(10); // a = 0 -> 9
        b = random.nextInt(10); // b = 0 -> 9
        operator = "×";
        correctAnswer = a * b;
        break;

      case 'mix_operations':
        List<String> operators = ["+", "-", "×"];
        List<double> cumulativeWeights = [];
        double sum = 0;

        for (String op in operators) {
          double weight = weights[op] ?? 1.0;
          sum += weight;
          cumulativeWeights.add(sum);
        }

        double rand = random.nextDouble() * sum;
        for (int i = 0; i < cumulativeWeights.length; i++) {
          if (rand >= (i == 0 ? 0 : cumulativeWeights[i - 1]) && rand < cumulativeWeights[i]) {
            operator = operators[i];
            break;
          }
        }

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
          case "×":
            a = random.nextInt(10);
            b = random.nextInt(10);
            correctAnswer = a * b;
            break;
          default:
            throw Exception('Error: No valid operator selected');
        }
        break;

      default:
        throw Exception('Error: Invalid operation');
    }

    String question = "$a $operator $b = ?";
    print("Generated question with operator: $operator"); // Debug log
    return MathQuestion(
      question: question,
      operator: operator,
      correctAnswer: correctAnswer,
    );
  }
}