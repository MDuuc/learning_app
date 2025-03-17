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
    File localFile = await getLocalFile();
    if (!await localFile.exists()) {
      await copyCsvIfNotExists();
    }
    final rawData = await localFile.readAsString();

    List<List<dynamic>> rows = const CsvToListConverter().convert(rawData);
    if (rows.isEmpty) return "Error: CSV file is empty!";

    List<String> headers = rows.first.map((e) => e.toString()).toList();
    int gradeIndex = headers.indexOf("grade");
    int operatorIndex = headers.indexOf("operator");
    int correctIndex = headers.indexOf("correct");
    int timeIndex = headers.indexOf("time");

    if (gradeIndex == -1 || operatorIndex == -1 || correctIndex == -1 || timeIndex == -1) {
      return "Error: Required columns (grade, operator, correct, time) not found!";
    }

    Map<String, Map<String, List<double>>> dataMap = {};
    for (var row in rows.skip(1)) {
      try {
        String grade = row[gradeIndex].toString();
        String operator = row[operatorIndex].toString();
        double correct = double.parse(row[correctIndex].toString());
        double time = double.parse(row[timeIndex].toString());

        if (!dataMap.containsKey(grade)) {
          dataMap[grade] = {};
        }
        if (!dataMap[grade]!.containsKey(operator)) {
          dataMap[grade]![operator] = [0, 0, 0]; // [correct, time, count]
        }
        dataMap[grade]![operator]![0] += correct;
        dataMap[grade]![operator]![1] += time;
        dataMap[grade]![operator]![2] += 1;
      } catch (e) {
        print('Skipping invalid row: $row - Error: $e');
        continue;
      }
    }

    if (dataMap.isEmpty) return "Error: No valid data rows found!";

    Map<String, Map<String, Map<String, double>>> stats = {};
    dataMap.forEach((grade, operators) {
      stats[grade] = {};
      operators.forEach((operator, values) {
        double accuracy = values[0] / values[2];
        double avgTime = values[1] / values[2];
        stats[grade]![operator] = {"accuracy": accuracy, "avg_time": avgTime};
      });
    });

    String result = "📊 Detailed analysis by grade:\n";
    AnalysisDataNotifier analysisData = AnalysisDataNotifier();

    stats.forEach((grade, operators) {
      result += "\n🟢 Grade: $grade\n";
      var sortedOperators = operators.entries.toList()
        ..sort((a, b) {
          int accCompare = a.value["accuracy"]!.compareTo(b.value["accuracy"]!);
          if (accCompare == 0) {
            return b.value["avg_time"]!.compareTo(a.value["avg_time"]!);
          }
          return accCompare;
        });
      for (var entry in sortedOperators) {
        analysisData.updateStat(grade,entry.key,(entry.value["accuracy"]! * 100), entry.value["avg_time"]!);
        result += "🔹 ${entry.key} - Accuracy: ${(entry.value["accuracy"]! * 100).toStringAsFixed(1)}%, Time: ${entry.value["avg_time"]!.toStringAsFixed(1)}s\n";
      }
    });

    print(result);
    return result;
  } catch (e) {
    return "Error analyzing data: $e";
  }
}

//add new data to file math csv
Future<void> appendToMathDataCsv({
  required String operator,
  required int correct,
  required int time,
  required String grade,
}) async {
  try {
    File localFile = await getLocalFile();
    List<String> newRow = [operator, correct.toString(), time.toString(), grade];
    String csvData = const ListToCsvConverter().convert([newRow]);
    await localFile.writeAsString('\n$csvData', mode: FileMode.append);
    printCsvContent();
    print('Appended new record to CSV file.');
  } catch (e) {
    print('Error appending to CSV: $e');
    rethrow;
  }
}


// test to print check out csv
Future<void> printCsvContent() async {
  try {
    File localFile = await getLocalFile();
    if (!await localFile.exists()) {
      print('CSV file does not exist yet.');
      return;
    }

    String content = await localFile.readAsString();
    if (content.isEmpty) {
      print('CSV file is empty.');
      return;
    }

    List<String> lines = content.trim().split('\n');
    int startIndex = lines.length > 10 ? lines.length - 10 : 0;
    List<String> last10Lines = lines.sublist(startIndex);

    print('=== Last 10 lines of CSV File ===');
    for (var line in last10Lines) {
      print(line);
    }
    print('=================================');
  } catch (e) {
    print('Error reading CSV file: $e');
  }
}
