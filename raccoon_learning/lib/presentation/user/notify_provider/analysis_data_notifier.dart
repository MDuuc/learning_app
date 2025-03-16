import 'package:flutter/material.dart';
import 'package:raccoon_learning/presentation/home/analysis_data/analysis.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AnalysisDataNotifier extends ChangeNotifier {
  final Map<String, Map<String, double>> _stats = {};
  Map<String, double> _weights = {}; // Store weights locally

  Map<String, Map<String, double>> get stats => _stats;
  Map<String, double> get weights => _weights; // Getter for weights

  AnalysisDataNotifier() {
    // _initialize();
  }

  // Future<void> _initialize() async {
  //   await loadStats();
  //   await loadWeights(); // Load weights during initialization
  //   if (_weights.isEmpty && _stats.isNotEmpty) {
  //     // If no weights exist but stats do, calculate weights
  //     _weights = calculateWeights();
  //     await _saveWeights();
  //   }
  //   print("📊 Stats Loaded: $_stats");
  //   print("📊 Weights Loaded: $_weights");
  // }

  /// Update data and save to SharedPreferences
  void updateStat(String operator, double accuracy, double time) {
    if (!_stats.containsKey(operator)) {
      _stats[operator] = {"accuracy": accuracy, "time": time};
    } else {
      _stats[operator]!["accuracy"] = accuracy;
      _stats[operator]!["time"] = time;
    }
    // Recalculate weights whenever stats change
    calculateWeights();
    notifyListeners();
    _saveStats();
    _saveWeights(); // Save weights after recalculation
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
      loadedStats.forEach((key, value) {
        if (!_stats.containsKey(key)) {
          _stats[key] = {
            "accuracy": value["accuracy"]?.toDouble() ?? 0.0,
            "time": value["time"]?.toDouble() ?? 0.0
          };
        } else {
          _stats[key]!["accuracy"] = value["accuracy"]?.toDouble() ?? 0.0;
          _stats[key]!["time"] = value["time"]?.toDouble() ?? 0.0;
        }
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
      _weights = loadedWeights.map((key, value) => MapEntry(key, value.toDouble()));
      notifyListeners();
    }
  }

  Future<void> loadAnalysisData() async {
    await analyzeMathData();
    await loadStats();
    await loadWeights(); 
    print('📊 Weight Calculation: $_weights');
  }

  /// Calculate the precedence of an operation and return weights
  Future<void> calculateWeights() async {
    if (_stats.isEmpty) {
      print("⚠ No stats available");
    }

    List<double> accuracyList = _stats.values
        .map((e) => e["accuracy"])
        .where((value) => value != null)
        .cast<double>()
        .toList();

    List<double> timeList = _stats.values
        .map((e) => e["time"])
        .where((value) => value != null)
        .cast<double>()
        .toList();

    if (accuracyList.isEmpty || timeList.isEmpty) {
      print("⚠ Incomplete stats, cannot calculate weights");
    }

    double maxAccuracy = accuracyList.reduce((a, b) => a > b ? a : b);
    double maxTime = timeList.reduce((a, b) => a > b ? a : b);

    for (var entry in _stats.entries) {
      String op = entry.key;
      double? accuracy = entry.value["accuracy"];
      double? time = entry.value["time"];

      if (accuracy == null || time == null) continue;

      // Formula: Higher weight for lower accuracy and higher time
          _weights[op] = double.parse(((maxAccuracy - accuracy) + ((time / maxTime) * 10) + 10).toStringAsFixed(2)
    );
    }
    // print('📊 Weight Calculation: $_weights');
  }
}