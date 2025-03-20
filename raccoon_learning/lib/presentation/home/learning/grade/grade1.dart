import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raccoon_learning/presentation/home/learning/grade/math_question.dart';
import 'package:raccoon_learning/presentation/user/notify_provider/analysis_data_notifier.dart';

class Grade1 {
  final String operation;

  Grade1(this.operation);

  // Generates a random math question based on the specified operation
  MathQuestion generateRandomQuestion({
    required BuildContext context,
  }) {
    final random = Random();
    int a, b, correctAnswer;
    String operator = '';
    String correctCompare = '';

    // Take weights from AnalysisDataNotifier
    final analysisDataNotifier = Provider.of<AnalysisDataNotifier>(context, listen: false);
    Map<String, double> weights = analysisDataNotifier.weights['grade_1'] ?? {};
    print('📊 Weight for Grade 1: $weights');
    if (weights.isEmpty) {
      print("⚠ Weights empty, using default equal weights");
      weights = {"+": 1.0, "-": 1.0, ">": 1.0}; 
    }

    switch (operation) {
      case 'addition':
        a = random.nextInt(6) + 1; // a = 1 -> 6
        b = random.nextInt(11 - a); // b sao cho a + b <= 10
        operator = "+";
        correctAnswer = a + b;
        correctCompare = '';
        break;

      case 'subtraction':
        a = random.nextInt(11); // a = 0 -> 10
        b = random.nextInt(a + 1); // b sao cho a - b >= 0
        operator = "-";
        correctAnswer = a - b;
        correctCompare = '';
        break;

      case 'comparison':
        operator = ">";
        a = random.nextInt(10) + 1; // a = 1 -> 10
        b = random.nextInt(10) + 1; // b = 1 -> 10
        correctCompare = (a == b ? "=" : (a > b ? ">" : "<"));
        correctAnswer = 0;
        break;

      case 'mix_operations':
        List<String> operators = ["+", "-", ">"];
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
            a = random.nextInt(6) + 1;
            b = random.nextInt(11 - a);
            correctAnswer = a + b;
            correctCompare = '';
            break;
          case "-":
            a = random.nextInt(11);
            b = random.nextInt(a + 1);
            correctAnswer = a - b;
            correctCompare = '';
            break;
          case ">":
            a = random.nextInt(10) + 1;
            b = random.nextInt(10) + 1;
            correctCompare = (a == b ? "=" : (a > b ? ">" : "<"));
            correctAnswer = 0;
            break;
          default:
            throw Exception('Error: No valid operator selected');
        }
        break;

      default:
        throw Exception('Error: Invalid operation');
    }

    // Tạo chuỗi câu hỏi dựa trên operator
    String question = (operator == ">" || operator == "<")
        ? "$a ? $b"
        : "$a $operator $b = ?";
    
    print("Generated question with operator: $operator"); // Debug log
    return MathQuestion(
      question: question,
      operator: operator,
      correctAnswer: correctAnswer,
      correctCompare: correctCompare
    );
  }
}