import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:raccoon_learning/presentation/home/learning/grade/math_question.dart';
import 'package:raccoon_learning/presentation/user/notify_provider/analysis_data_notifier.dart';

class Grade2 {
  final String operation;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Grade2(this.operation);

  Future<MathQuestion> generateRandomQuestion({
    required BuildContext context,
  }) async {
    final random = Random();
    int a = 0;
    int b = 0;
    int correctAnswer = 0;
    String operator = '';
    String correctCompare = '';
    String question = '';

    final analysisDataNotifier = Provider.of<AnalysisDataNotifier>(context, listen: false);
    Map<String, double> weights = analysisDataNotifier.weights['grade_2'] ?? {};
    print('📊 Weights for Grade 2: $weights');
    if (weights.isEmpty) {
      print("⚠ Weights empty, using default equal weights");
      // weights = {"+": 1.0, "-": 1.0, "x": 1.0, "word_problem": 1.0};
      weights = {"+": 1.0, "-": 1.0, "x": 1.0};
    }

    switch (operation) {
      case 'addition':
        a = random.nextInt(51) + 1; // Generate a: 1 to 51
        b = random.nextInt(101 - a); // Generate b so that a + b <= 100
        operator = "+";
        correctAnswer = a + b;
        correctCompare = '';
        question = "$a $operator $b = ?";
        break;

      case 'subtraction':
        a = random.nextInt(101); // Generate a: 0 to 100
        b = random.nextInt(a + 1); // Generate b so that a - b >= 0
        operator = "-";
        correctAnswer = a - b;
        correctCompare = '';
        question = "$a $operator $b = ?";
        break;

      case 'multiplication': 
        a = random.nextInt(10); 
        b = random.nextInt(10); 
        operator = "x";
        correctAnswer = a * b;
        question = "$a $operator $b = ?"; 
        correctCompare = '';
        break;

      case 'word_problem':
        final snapshot = await _firestore
            .collection('questions')
            .doc('grade2')
            .collection('items')
            .get();

        if (snapshot.docs.isEmpty) {
          throw Exception('No word problems found in Firestore for Grade 1');
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
          if (templateQuestion.contains(varName) || templateAnswer.contains(varName)) {
            if (templateAnswer.contains('-') && i == 0) {
              variables[varName] = random.nextInt(6) + 5;
            } else if (templateAnswer.contains('-') && i == 1) {
              int maxB = variables[variableNames[0]]! - 1;
              variables[varName] = random.nextInt(maxB) + 1;
            } else {
              variables[varName] = random.nextInt(10) + 1;
            }
            templateQuestion = templateQuestion.replaceAll(pattern, variables[varName]!.toString());
            templateAnswer = templateAnswer.replaceAll(pattern, variables[varName]!.toString());
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
        List<String> operators = ["+", "-", "x"];
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
            a = random.nextInt(51) + 1; // Generate a: 1 to 51
            b = random.nextInt(101 - a); // Generate b so that a + b <= 100
            correctAnswer = a + b;
            correctCompare = '';
            question = "$a $operator $b = ?";
            break;
          case "-":
            a = random.nextInt(101); // Generate a: 0 to 100
            b = random.nextInt(a + 1); // Generate b so that a - b >= 0
            correctAnswer = a - b;
            correctCompare = '';
            question = "$a $operator $b = ?";
            break;
          case "x":
            a = random.nextInt(10);
            b = random.nextInt(10);
            correctAnswer = a * b;
            correctCompare = '';
            question = "$a $operator $b = ?";
            break;
        }
        break;

      default:
        throw Exception('Error: Invalid operation');
    }

    print("Generated question with operator: $operator");
    return MathQuestion(
      question: question,
      operator: operator,
      correctAnswer: correctAnswer,
      correctCompare: correctCompare,
    );
  }

  int _evaluateExpression(String templateAnswer, Map<String, int> variables) {
    templateAnswer = templateAnswer.trim();

    for (String varName in variables.keys) {
      templateAnswer = templateAnswer.replaceAll(varName, variables[varName]!.toString());
    }
    print("Evaluating: $templateAnswer");

    if (templateAnswer.contains('x') || templateAnswer.contains('*')) {
      final parts = templateAnswer.contains('x') ? templateAnswer.split('x') : templateAnswer.split('*');
      return int.parse(parts[0].trim()) * int.parse(parts[1].trim());
    } else if (templateAnswer.contains('+')) {
      final parts = templateAnswer.split('+');
      return int.parse(parts[0].trim()) + int.parse(parts[1].trim());
    } else if (templateAnswer.contains('-')) {
      final parts = templateAnswer.split('-');
      return int.parse(parts[0].trim()) - int.parse(parts[1].trim());
    } else {
      return int.parse(templateAnswer);
    }
  }
}