import 'package:flutter/material.dart';
import 'package:raccoon_learning/presentation/home/analysis_data/analysis.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AnalysisDataNotifier extends ChangeNotifier {
  final Map<String, Map<String, Map<String, double>>> _stats = {}; // grade -> operator -> {accuracy, time}
  Map<String, Map<String, double>> _weights = {}; // grade -> operator -> weight

  Map<String, Map<String, Map<String, double>>> get stats => _stats;
  Map<String, Map<String, double>> get weights => _weights;


  /// Update stats and recalculate weights
  void updateStat(String grade, String operator, double accuracy, double time) {
    _stats.putIfAbsent(grade, () => {});
    _stats[grade]!.putIfAbsent(operator, () => {});

    _stats[grade]![operator]!['accuracy'] = accuracy;
    _stats[grade]![operator]!['time'] = time;

    calculateWeights(grade);
    notifyListeners();
    _saveStats();
    _saveWeights();
  }

  /// Save stats to SharedPreferences
  Future<void> _saveStats() async {
    final prefs = await SharedPreferences.getInstance();
    final statsJson = jsonEncode(_stats);
    await prefs.setString('math_stats', statsJson);
  }

  /// Save weights to SharedPreferences
  Future<void> _saveWeights() async {
    final prefs = await SharedPreferences.getInstance();
    final weightsJson = jsonEncode(_weights);
    await prefs.setString('math_weights', weightsJson);
  }

  /// Load stats from SharedPreferences
  Future<void> loadStats() async {
    final prefs = await SharedPreferences.getInstance();
    final statsJson = prefs.getString('math_stats');

    if (statsJson != null) {
      final Map<String, dynamic> loadedStats = jsonDecode(statsJson);
      loadedStats.forEach((grade, operators) {
        _stats[grade] = {};
        (operators as Map<String, dynamic>).forEach((operator, values) {
          _stats[grade]![operator] = {
            "accuracy": values["accuracy"]?.toDouble() ?? 0.0,
            "time": values["time"]?.toDouble() ?? 0.0,
          };
        });
      });
      notifyListeners();
    }
  }

  /// Load weights from SharedPreferences
  Future<void> loadWeights() async {
    final prefs = await SharedPreferences.getInstance();
    final weightsJson = prefs.getString('math_weights');

    if (weightsJson != null) {
      final Map<String, dynamic> loadedWeights = jsonDecode(weightsJson);
      _weights = loadedWeights.map((grade, operators) => 
        MapEntry(grade, (operators as Map<String, dynamic>).map(
          (op, value) => MapEntry(op, value.toDouble()))
        ));
      notifyListeners();
    }
  }

  /// Calculate weights for a specific grade
  Future<void> calculateWeights(String grade) async {
    if (!_stats.containsKey(grade) || _stats[grade]!.isEmpty) {
      print("⚠ No stats available for grade $grade");
      return;
    }

    List<double> accuracyList = _stats[grade]!.values
        .map((e) => e["accuracy"])
        .where((value) => value != null)
        .cast<double>()
        .toList();

    List<double> timeList = _stats[grade]!.values
        .map((e) => e["time"])
        .where((value) => value != null)
        .cast<double>()
        .toList();

    if (accuracyList.isEmpty || timeList.isEmpty) {
      print("⚠ Incomplete stats for grade $grade, cannot calculate weights");
      return;
    }

    double maxAccuracy = accuracyList.reduce((a, b) => a > b ? a : b);
    double maxTime = timeList.reduce((a, b) => a > b ? a : b);

    _weights[grade] = {};
    for (var entry in _stats[grade]!.entries) {
      String op = entry.key;
      double? accuracy = entry.value["accuracy"];
      double? time = entry.value["time"];

      if (accuracy == null || time == null) continue;

      _weights[grade]![op] = double.parse(((maxAccuracy - accuracy) + ((time / maxTime) * 10) + 10).toStringAsFixed(2));
    }
  }

    Future<void> loadAnalysisData() async {
    await analyzeMathData();
    await loadStats();
    await loadWeights(); 
    print('📊 Weight Calculation: $_weights');
  }
}


