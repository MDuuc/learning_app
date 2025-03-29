import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:raccoon_learning/presentation/home/learning/grade/math_question.dart';
import 'package:raccoon_learning/presentation/user/notify_provider/analysis_data_notifier.dart';

class Grade1 {
  final String operation;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Grade1(this.operation);

  // Generates a random math question based on the specified operation
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

    // Take weights from AnalysisDataNotifier
    final analysisDataNotifier = Provider.of<AnalysisDataNotifier>(context, listen: false);
    Map<String, double> weights = analysisDataNotifier.weights['grade_1'] ?? {};
    print('📊 Weight for Grade 1: $weights');
    if (weights.isEmpty) {
      print("⚠ Weights empty, using default equal weights");
      weights = {"+": 1.0, "-": 1.0, ">": 1.0, "word_problem": 1.0}; // Thêm word_problem
    }

    switch (operation) {
      case 'addition':
        a = random.nextInt(6) + 1; // a = 1 -> 6
        b = random.nextInt(11 - a); // a + b <= 10
        operator = "+";
        correctAnswer = a + b;
        correctCompare = '';
        question = "$a $operator $b = ?";
        break;

      case 'subtraction':
        a = random.nextInt(11); // a = 0 -> 10
        b = random.nextInt(a + 1); // a - b >= 0
        operator = "-";
        correctAnswer = a - b;
        correctCompare = '';
        question = "$a $operator $b = ?";
        break;

      case 'comparison':
        operator = ">";
        a = random.nextInt(10) + 1; // a = 1 -> 10
        b = random.nextInt(10) + 1; // b = 1 -> 10
        correctCompare = (a == b ? "=" : (a > b ? ">" : "<"));
        correctAnswer = 0;
        question = "$a ? $b";
        break;

      case 'word_problem':
        // Randomly get a word problem from Firestore
        final snapshot = await _firestore
            .collection('questions')
            .doc('grade1')
            .collection('items')
            .get();

        if (snapshot.docs.isEmpty) {
          throw Exception('No word problems found in Firestore for Grade 1');
        }

        // Randomly select a question
        final randomDoc = snapshot.docs[random.nextInt(snapshot.docs.length)];
        final data = randomDoc.data();
        String templateQuestion = data['question'] ?? '';
        String templateAnswer = data['answer'] ?? '';

        // Create a map to store the values ​​of variables 
        Map<String, int> variables = {};
        List<String> variableNames = ['A', 'B', 'C', 'D'];

        // Replace variables in question
          for (int i = 0; i < variableNames.length; i++) {
            String varName = variableNames[i];
            final pattern = RegExp(r'\b' + varName + r'\b');
            if (templateQuestion.contains(varName)) {
              if (templateAnswer.contains('-') && i == 0) {
                // If it is subtraction and this is the first variable (A), choose the larger number
                variables[varName] = random.nextInt(6) + 5; // 5 -> 10
              } else if (templateAnswer.contains('-') && i == 1) {
                // If it is subtraction and this is the second variable (B), choose the number less than A
                int maxB = variables[variableNames[0]]! - 1; // Ensure B < A
                variables[varName] = random.nextInt(maxB) + 1; // 1 -> A-1
              } else {
                // Otherwise, randomly select from 1-10
                variables[varName] = random.nextInt(10) + 1;
              }
              templateQuestion = templateQuestion.replaceAll(
                pattern,
                variables[varName]!.toString(),
              );
            }
          }
        if (templateAnswer.contains('+')) {
          operator = '+';
        } else if (templateAnswer.contains('-')) {
          operator = '-';
        } else {
          operator = '';
        }

        // Calculate answer based on templateAnswer
        correctAnswer = _evaluateExpression(templateAnswer, variables);
        correctCompare = '';
        question = templateQuestion;
        break;

      case 'mix_operations':
        // List<String> operators = ["+", "-", ">", "word_problem"];
        List<String> operators = ["+", "-",];

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
            question = "$a $operator $b = ?";
            break;
          case "-":
            a = random.nextInt(11);
            b = random.nextInt(a + 1);
            correctAnswer = a - b;
            correctCompare = '';
            question = "$a $operator $b = ?";
            break;
          case ">":
            a = random.nextInt(10) + 1;
            b = random.nextInt(10) + 1;
            correctCompare = (a == b ? "=" : (a > b ? ">" : "<"));
            correctAnswer = 0;
            question = "$a ? $b";
            break;
          // case "word_problem":
          //   final snapshot = await _firestore
          //       .collection('questions')
          //       .doc('grade1')
          //       .collection('items')
          //       .get();

          //   if (snapshot.docs.isEmpty) {
          //     throw Exception('No word problems found in Firestore for Grade 1');
          //   }

          //   final randomDoc = snapshot.docs[random.nextInt(snapshot.docs.length)];
          //   final data = randomDoc.data();
          //   String templateQuestion = data['question'] ?? '';
          //   String templateAnswer = data['answer'] ?? '';

          //   Map<String, int> variables = {};
          //   List<String> variableNames = ['X', 'Y', 'Z', 'H'];

          //   for (String varName in variableNames) {
          //     if (templateQuestion.contains(varName)) {
          //       variables[varName] = random.nextInt(10) + 1;
          //       templateQuestion = templateQuestion.replaceAll(varName, variables[varName]!.toString());
          //     }
          //   }

          //   correctAnswer = _evaluateExpression(templateAnswer, variables);
          //   operator = '';
          //   correctCompare = '';
          //   question = templateQuestion;
          //   break;
        }
        break;

      default:
        throw Exception('Error: Invalid operation');
    }

    print("Generated question with operator: $operator"); // Debug log
    return MathQuestion(
      question: question,
      operator: operator,
      correctAnswer: correctAnswer,
      correctCompare: correctCompare,
    );
  }

  // Hàm tính toán biểu thức từ template answer
  int _evaluateExpression(String templateAnswer, Map<String, int> variables) {
    templateAnswer = templateAnswer.trim();

    // Thay thế biến bằng giá trị
    for (String varName in variables.keys) {
      templateAnswer = templateAnswer.replaceAll(varName, variables[varName]!.toString());
    }
    print(templateAnswer);

    // Xử lý các phép tính đơn giản (+ và -)
    if (templateAnswer.contains('+')) {
      final parts = templateAnswer.split('+');
      return int.parse(parts[0].trim()) + int.parse(parts[1].trim());
    } else if (templateAnswer.contains('-')) {
      final parts = templateAnswer.split('-');
      return int.parse(parts[0].trim()) - int.parse(parts[1].trim());
    } else {
      return int.parse(templateAnswer); // Nếu không có toán tử, trả về số trực tiếp
    }
  }
}