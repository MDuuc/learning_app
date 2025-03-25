import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:raccoon_learning/presentation/user/notify_provider/analysis_data_notifier.dart';

Future<File> getLocalFile() async {
  final directory = await getApplicationDocumentsDirectory();
  return File('${directory.path}/math_data.csv');
  
}

//this using for test file csv
// Future<void> copyCsvIfNotExists() async {
//   File localFile = await getLocalFile();
  
//   if (!await localFile.exists()) {
//     String csvData = await rootBundle.loadString('assets/data/math_data.csv');
//     await localFile.writeAsString(csvData);
//     print('CSV file has been copied to the application folder.');
//   } else {
//     print('CSV file already exists, using existing data.');
//   }
// }

Future<String> analyzeMathData() async {
  try {
    File localFile = await getLocalFile();
    
    // If local file doesn't exist, create it with headers
    if (!await localFile.exists()) {
      await localFile.writeAsString("operator,correct,time,grade\n");
      // await copyCsvIfNotExists();
    }
    
    // Read the local file
    final rawData = await localFile.readAsString();
    
    // Clean up the raw data by splitting into lines and filtering out empty ones
    List<String> lines = rawData.split('\n').where((line) => line.trim().isNotEmpty).toList();
    if (lines.isEmpty) return "Error: CSV file is empty!";
    
    // Parse CSV manually if needed, or use CsvToListConverter on cleaned lines
    List<List<dynamic>> rows = lines.map((line) => const CsvToListConverter().convert(line)).expand((x) => x).toList();

    if (rows.isEmpty) return "Error: No valid rows found after parsing!";

    // Get headers from first row
    List<String> headers = rows.first.map((e) => e.toString().trim()).toList();
    
    // Check for required columns
    int operatorIndex = headers.indexOf("operator");
    int correctIndex = headers.indexOf("correct");
    int timeIndex = headers.indexOf("time");
    int gradeIndex = headers.indexOf("grade");


    if (gradeIndex == -1 || operatorIndex == -1 || correctIndex == -1 || timeIndex == -1) {
      return "Error: Required columns (grade, operator, correct, time) not found! Headers found: $headers";
    }

    // Aggregate data
    Map<String, Map<String, List<double>>> dataMap = {};
    for (var row in rows.skip(1)) { // Skip header
      try {
        String grade = row[gradeIndex].toString().trim();
        String operator = row[operatorIndex].toString().trim();
        int correct = int.parse(row[correctIndex].toString().trim());
        int time = int.parse(row[timeIndex].toString().trim());

        dataMap.putIfAbsent(grade, () => {});
        dataMap[grade]!.putIfAbsent(operator, () => [0, 0, 0]);
        
        dataMap[grade]![operator]![0] += correct;
        dataMap[grade]![operator]![1] += time;
        dataMap[grade]![operator]![2] += 1;
      } catch (e) {
        print('Skipping invalid row: $row - Error: $e');
        continue;
      }
    }

    if (dataMap.isEmpty) return "Error: No valid data rows found!";

    // Calculate statistics
    Map<String, Map<String, Map<String, double>>> stats = {};
    dataMap.forEach((grade, operators) {
      stats[grade] = {};
      operators.forEach((operator, values) {
        double accuracy = values[0] / values[2];
        double avgTime = values[1] / values[2];
        double quantity = values[2];
        stats[grade]![operator] = {
          "accuracy": accuracy,
          "avg_time": avgTime,
          "quantity": quantity
        };
      });
    });
  AnalysisDataNotifier analysisDataNotifier =   AnalysisDataNotifier();
    String result = "📊 Detailed analysis by grade:\n";
    stats.forEach((grade, operators) {
      result += "\n🟢 Grade: $grade\n";
      var sortedOperators = operators.entries.toList()
        ..sort((a, b) => b.value["accuracy"]!.compareTo(a.value["accuracy"]!));
      for (var entry in sortedOperators) {
        result += "🔹 ${entry.key} - Accuracy: ${(entry.value["accuracy"]! * 100).toStringAsFixed(1)}%, "
            "Time: ${entry.value["avg_time"]!.toStringAsFixed(1)}, "
            "Quantity: ${entry.value["quantity"]!.toStringAsFixed(1)}\n";
        analysisDataNotifier.updateStat(grade, entry.key, entry.value["accuracy"]! * 100, entry.value["avg_time"]!, entry.value["quantity"]!);
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
    if (!await localFile.exists()) {
      await localFile.writeAsString("operator,correct,time,grade\n");
    }
    String csvData = '\n$operator,$correct,$time,$grade';
    await localFile.writeAsString(csvData, mode: FileMode.append);
    printCsvContent();
    print('Appended new record to CSV file.');
    await printCsvContent(); // Verify the append
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
