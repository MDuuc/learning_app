import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raccoon_learning/presentation/user/notify_provider/analysis_data_notifier.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Grade3 {
  final String operation;

  Grade3(this.operation);

  // Generates a random math question based on the specified operation
  String generateRandomQuestion({
    required BuildContext context,
    required Function(int) onAnswerGenerated,
  }) {
    final random = Random();
    int a, b, correctAnswer;
    String operator = '';

  final analysisDataNotifier = Provider.of<AnalysisDataNotifier>(context, listen: false);
  Map<String, double> weights = analysisDataNotifier.weights;
    print('📊 Weight: $weights');
    // Map<String, double> weights = await loadWeights();
    if (weights.isEmpty) {
      print('📊 Weight: $weights');
      print("⚠ Weights empty, using default equal weights");
      weights = {"+": 1.0, "-": 1.0, "×": 1.0, "÷": 1.0};
    }

    // Determine the type of operation and generate corresponding question
    switch (operation) {
      case 'addition':
        a = random.nextInt(51) + 1;
        b = random.nextInt(101 - a);
        operator = "+";
        correctAnswer = a + b;
        break;

      case 'subtraction':
        a = random.nextInt(101);
        b = random.nextInt(a + 1);
        operator = "-";
        correctAnswer = a - b;
        break;

      case 'multiplication':
        a = random.nextInt(13) + 1;
        b = random.nextInt((100 ~/ a)) + 1;
        operator = "×";
        correctAnswer = a * b;
        break;

      case 'division':
        b = random.nextInt(12) + 1;
        correctAnswer = random.nextInt(9) + 1;
        a = b * correctAnswer;
        operator = "÷";
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
            return 'Error: No valid operator selected';
        }
        break;

      default:
        return 'Error: Invalid operation';
    }

    onAnswerGenerated(correctAnswer);
    print("Generated question with operator: $operator"); // Debug log
    return "$a $operator $b = ?";
  }
}