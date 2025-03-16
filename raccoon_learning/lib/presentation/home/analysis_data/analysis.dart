import 'dart:io';
import 'package:flutter/services.dart' show ByteData, rootBundle;
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:raccoon_learning/presentation/user/notify_provider/analysis_data_notifier.dart';

Future<File> getLocalFile() async {
  final directory = await getApplicationDocumentsDirectory();
  return File('${directory.path}/math_data.csv');
}

Future<void> copyCsvIfNotExists() async {
  File localFile = await getLocalFile();
  if (!await localFile.exists()) {
    ByteData data = await rootBundle.load('assets/data/math_data.csv');
    List<int> bytes = data.buffer.asUint8List();
    await localFile.writeAsBytes(bytes);
    print('CSV file has been copied to the application folder.');
  } else {
    print('CSV file already exists, no need to copy.');
  }
}

Future<String> analyzeMathData() async {
  try {
    // Read from the local file instead of assets
    File localFile = await getLocalFile();
    if (!await localFile.exists()) {
      await copyCsvIfNotExists(); // Ensure file exists
    }
    final rawData = await localFile.readAsString();

    List<List<dynamic>> rows = const CsvToListConverter().convert(rawData);
    if (rows.isEmpty) return "Error: CSV file is empty!";

    // Extract headers
    List<String> headers = rows.first.map((e) => e.toString()).toList();
    int operatorIndex = headers.indexOf("operator");
    int correctIndex = headers.indexOf("correct");
    int timeIndex = headers.indexOf("time");

    if (operatorIndex == -1 || correctIndex == -1 || timeIndex == -1) {
      return "Error: Required columns (operator, correct, time) not found!";
    }

    // Aggregate data
    Map<String, List<double>> dataMap = {};
    for (var row in rows.skip(1)) {
      try {
        String operator = row[operatorIndex].toString();
        double correct = double.parse(row[correctIndex].toString());
        double time = double.parse(row[timeIndex].toString());

        if (!dataMap.containsKey(operator)) {
          dataMap[operator] = [0, 0, 0]; // [correct, time, count]
        }
        dataMap[operator]![0] += correct;
        dataMap[operator]![1] += time;
        dataMap[operator]![2] += 1;
      } catch (e) {
        print('Skipping invalid row: $row - Error: $e');
        continue;
      }
    }

    if (dataMap.isEmpty) return "Error: No valid data rows found!";

    // Calculate stats
    Map<String, Map<String, double>> stats = {};
    dataMap.forEach((operator, values) {
      double accuracy = values[0] / values[2];
      double avgTime = values[1] / values[2];
      stats[operator] = {"accuracy": accuracy, "avg_time": avgTime};
    });

    // Sort by accuracy (descending for "weakest" first), then time (descending)
    var sortedOperators = stats.entries.toList()
      ..sort((a, b) {
        int accCompare = a.value["accuracy"]!.compareTo(b.value["accuracy"]!);
        if (accCompare == 0) {
          return b.value["avg_time"]!.compareTo(a.value["avg_time"]!);
        }
        return accCompare;
      });

    // Format result
    String result = "📊 Rank the operations from strongest to weakest:\n";
    AnalysisDataNotifier analysisData = AnalysisDataNotifier();
    for (var entry in sortedOperators) {
      analysisData.updateStat(entry.key,(entry.value["accuracy"]! * 100), entry.value["avg_time"]!);
      result +=
          "🔸 ${entry.key} - Accuracy: ${(entry.value["accuracy"]! * 100).toStringAsFixed(1)}%, Time: ${entry.value["avg_time"]!.toStringAsFixed(1)}s\n";
    }
    print(result);
    return result;
  } catch (e) {
    return "Error analyzing data: $e";
  }
}