import 'package:flutter/material.dart';
import 'package:raccoon_learning/presentation/home/learning/grade/grade1.dart';
import 'package:raccoon_learning/presentation/home/learning/grade/grade2.dart';
import 'package:raccoon_learning/presentation/home/learning/grade/grade3.dart';
import 'package:raccoon_learning/presentation/home/learning/grade/math_question.dart';

class TwoPlayersNotifier extends ChangeNotifier{
  int _pointPlayerOne = 0;
  int _pointPlayerTwo = 0;
  List<String> _questions = [];
  List<int> _answers = [];
  List<String> _compares = [];
  int _currentIndex = 0;

  int get pointPlayerOne => _pointPlayerOne;
  int get pointPlayerTwo => _pointPlayerTwo;
  String get currentQuestion => _questions.isNotEmpty ? _questions[_currentIndex] : "";
  int get correctAnswer => _answers.isNotEmpty ? _answers[_currentIndex] : 0;
  String get correctCompare => _compares.isNotEmpty ? _compares[_currentIndex] : "";

  Function? clearPadFirstPlayer;
  Function? clearPadSecondPlayer;

  set pointPlayerOne(int value) {
    _pointPlayerOne = value;
  }

  set pointPlayerTwo(int value) {
    _pointPlayerTwo = value;
  }

  void registerClearPadFirst(Function callback) {
    clearPadFirstPlayer = callback;
  }
    void registerClearPadSecond(Function callback) {
    clearPadSecondPlayer = callback;
  }
    void clearPad() {
    clearPadFirstPlayer?.call();
    clearPadSecondPlayer?.call();
  }

// Generate 30 questions based on grade and operation
  Future<void> generateQuestions(BuildContext context, String grade, String operation) async {
    _questions.clear();
    _answers.clear();
    _compares.clear();

    for (int i = 0; i < 30; i++) {
      switch (grade) {
        case 'grade_1':
          final grade1 = Grade1(operation); 
          try {
            final MathQuestion mathQuestion = await grade1.generateRandomQuestion(context: context);
            _questions.add(mathQuestion.question);
            _answers.add(mathQuestion.correctAnswer);
            _compares.add(mathQuestion.correctCompare!); 
          } catch (e) {
            print('Error generating Grade 1 question: $e');
          }
          break;

        case 'grade_2':
          final grade2 = Grade2(operation);
          try {
            final MathQuestion mathQuestion = await grade2.generateRandomQuestion(context: context);
            _questions.add(mathQuestion.question);
            _answers.add(mathQuestion.correctAnswer);
            _compares.add(mathQuestion.correctCompare!); 
          } catch (e) {
            print('Error generating Grade 2 question: $e');
          }
          break;

        case 'grade_3':
          final grade3 = Grade3(operation);
          try {
            final MathQuestion mathQuestion = await grade3.generateRandomQuestion(context: context);
            _questions.add(mathQuestion.question);
            _answers.add(mathQuestion.correctAnswer);
            _compares.add(mathQuestion.correctCompare!); 
          } catch (e) {
            print('Error generating Grade 3 question: $e');
          }
          break;

        default:
          print('Unsupported grade: $grade');
          break;
      }
    }

    _currentIndex = 0;
    notifyListeners();
  }

    void nextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      _currentIndex++;
    } else {
      _currentIndex = 0; 
    }
    notifyListeners();
  }

  void updateQuestion(String userAnswer) {
    if (_questions.isNotEmpty && _questions[_currentIndex].contains("?")) {
      _questions[_currentIndex] = _questions[_currentIndex].replaceFirst("?", userAnswer);
      notifyListeners(); 
    }
  }


// Update Point of one two players
  Future <void> updatePoint({required bool isPlayerOne})async {
    int point =1;
    if (isPlayerOne){
      _pointPlayerOne+=point;
    }else{
      _pointPlayerTwo+=point;
    }
  }
}