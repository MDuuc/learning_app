import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path_provider/path_provider.dart';
import 'package:raccoon_learning/presentation/user/notify_provider/analysis_data_notifier.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

Future<Map<String, Map<String, Map<String, double>>>> analyzeMathData() async {
  try {
    File localFile = await getLocalFile();

    // if CSV not exist, create file
    if (!await localFile.exists()) {
      await localFile.writeAsString("operator,correct,time,grade\n");
      return {}; 
    }

    // reade file CSV
    final rawData = await localFile.readAsString();
    List<String> lines = rawData.split('\n').where((line) => line.trim().isNotEmpty).toList();
    if (lines.isEmpty) {
      print('CSV file is empty.');
      return {};
    }

    // Parse CSV
    List<List<dynamic>> rows = lines.map((line) => const CsvToListConverter().convert(line)).expand((x) => x).toList();
    if (rows.isEmpty) {
      print('No valid rows found after parsing.');
      return {};
    }

    // take headers from first row
    List<String> headers = rows.first.map((e) => e.toString().trim()).toList();
    int operatorIndex = headers.indexOf("operator");
    int correctIndex = headers.indexOf("correct");
    int timeIndex = headers.indexOf("time");
    int gradeIndex = headers.indexOf("grade");

    if (gradeIndex == -1 || operatorIndex == -1 || correctIndex == -1 || timeIndex == -1) {
      print('Error: Required columns (grade, operator, correct, time) not found! Headers found: $headers');
      return {};
    }

    Map<String, Map<String, List<double>>> dataMap = {};
    for (var row in rows.skip(1)) {
      try {
        String grade = row[gradeIndex].toString().trim();
        String operator = row[operatorIndex].toString().trim();
        int correct = int.parse(row[correctIndex].toString().trim());
        int time = int.parse(row[timeIndex].toString().trim());

        dataMap.putIfAbsent(grade, () => {});
        dataMap[grade]!.putIfAbsent(operator, () => [0, 0, 0]);
        dataMap[grade]![operator]![0] += correct; //  correct
        dataMap[grade]![operator]![1] += time;   // time
        dataMap[grade]![operator]![2] += 1;      // quantity
      } catch (e) {
        print('Skipping invalid row: $row - Error: $e');
        continue;
      }
    }

    // Caculation 
    Map<String, Map<String, Map<String, double>>> stats = {};
    dataMap.forEach((grade, operators) {
      stats[grade] = {};
      operators.forEach((operator, values) {
        double accuracy = values[2] > 0 ? values[0] / values[2] : 0;
        double avgTime = values[2] > 0 ? values[1] / values[2] : 0;
        double quantity = values[2];
        stats[grade]![operator] = {
          "accuracy": accuracy,
          "avg_time": avgTime,
          "quantity": quantity,
        };
      });
    });

    return stats;
  } catch (e) {
    print('Error analyzing data: $e');
    return {};
  }
}

Future<String> analyzeCombinedData() async {
  try {
    final analysisDataNotifier = AnalysisDataNotifier();
    Map<String, Map<String, List<double>>> combinedDataMap = {};

    // Take data from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    String? analyticsJson = prefs.getString('analytics_data');
    if (analyticsJson != null && analyticsJson.isNotEmpty) {
      Map<String, dynamic> analyticsData = jsonDecode(analyticsJson);
      analyticsData.forEach((grade, operators) {
        combinedDataMap.putIfAbsent(grade, () => {});
        (operators as Map<String, dynamic>).forEach((operator, stats) {
          double correct = (stats['accuracy'] / 100) * stats['quantity'];
          double time = stats['avg_time'] * stats['quantity'];
          double quantity = stats['quantity'];
          combinedDataMap[grade]!.putIfAbsent(operator, () => [correct, time, quantity]);
        });
      });
    }

    // Get data from file CSV through analyzeMathData
    Map<String, Map<String, Map<String, double>>> csvStats = await analyzeMathData();
    csvStats.forEach((grade, operators) {
      combinedDataMap.putIfAbsent(grade, () => {});
      operators.forEach((operator, stats) {
        double correct = stats['accuracy']! * stats['quantity']!;
        double time = stats['avg_time']! * stats['quantity']!;
        double quantity = stats['quantity']!;
        if (combinedDataMap[grade]!.containsKey(operator)) {
          combinedDataMap[grade]![operator]![0] += correct;
          combinedDataMap[grade]![operator]![1] += time;
          combinedDataMap[grade]![operator]![2] += quantity;
        } else {
          combinedDataMap[grade]![operator] = [correct, time, quantity];
        }
      });
    });

    //Caculation
    if (combinedDataMap.isEmpty) {
      return "Error: No valid data found from SharedPreferences or CSV!";
    }

    Map<String, Map<String, Map<String, double>>> finalStats = {};
    combinedDataMap.forEach((grade, operators) {
      finalStats[grade] = {};
      operators.forEach((operator, values) {
        double accuracy = values[2] > 0 ? values[0] / values[2] : 0;
        double avgTime = values[2] > 0 ? values[1] / values[2] : 0;
        double quantity = values[2];
        finalStats[grade]![operator] = {
          "accuracy": accuracy,
          "avg_time": avgTime,
          "quantity": quantity,
        };
      });
    });

    // Update AnalysisDataNotifier
    String result = "📊 Detailed analysis by grade:\n";
    finalStats.forEach((grade, operators) {
      result += "\n🟢 Grade: $grade\n";
      var sortedOperators = operators.entries.toList()
        ..sort((a, b) => b.value["accuracy"]!.compareTo(a.value["accuracy"]!));
      for (var entry in sortedOperators) {
        result += "🔹 ${entry.key} - Accuracy: ${(entry.value["accuracy"]! * 100).toStringAsFixed(1)}%, "
            "Time: ${entry.value["avg_time"]!.toStringAsFixed(1)}, "
            "Quantity: ${entry.value["quantity"]!.toStringAsFixed(1)}\n";
        analysisDataNotifier.updateStat(
          grade,
          entry.key,
          entry.value["accuracy"]! * 100,
          entry.value["avg_time"]!,
          entry.value["quantity"]!,
        );
      }
    });

    print(result);
    return result;
  } catch (e) {
    print('Error analyzing combined data: $e');
    return "Error analyzing data: $e";
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

Future<void> fetchAnalyticsOnLogin() async {
  try {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      print('Error: No user is logged in.');
      return;
    }

    // get data from Firestore
    final firestore = FirebaseFirestore.instance;
    DocumentSnapshot doc = await firestore.collection('gameplay').doc(userId).get();
    Map<String, dynamic> analyticsData = {};

    if (doc.exists && doc['analytics'] != null) {
      analyticsData = Map<String, dynamic>.from(doc['analytics']);
    } else {
      print('No analytics data found in Firestore for user $userId');
    }

    // save to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('analytics_data', jsonEncode(analyticsData));
    print('Analytics data saved to SharedPreferences: $analyticsData');

    // create file CSV if not exist
    File localFile = await getLocalFile();
    if (!await localFile.exists()) {
      await localFile.writeAsString("operator,correct,time,grade\n");
      print('Created new CSV file at ${localFile.path}');
    }
  } catch (e) {
    print('Error fetching analytics data on login: $e');
  }
}

Future<void> uploadAnalyticsOnLogout() async {
  try {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      print('Error: No user is logged in.');
      return;
    }

    // Calulation data form SharedPreferences and CSV
    Map<String, Map<String, List<double>>> combinedDataMap = {};
    final prefs = await SharedPreferences.getInstance();

    // Get data from SharedPreferences
    String? analyticsJson = prefs.getString('analytics_data');
    if (analyticsJson != null && analyticsJson.isNotEmpty) {
      Map<String, dynamic> analyticsData = jsonDecode(analyticsJson);
      analyticsData.forEach((grade, operators) {
        combinedDataMap.putIfAbsent(grade, () => {});
        (operators as Map<String, dynamic>).forEach((operator, stats) {
          double correct = (stats['accuracy'] / 100) * stats['quantity'];
          double time = stats['avg_time'] * stats['quantity'];
          double quantity = stats['quantity'];
          combinedDataMap[grade]!.putIfAbsent(operator, () => [correct, time, quantity]);
        });
      });
    }

    // Get data from CSV
    File localFile = await getLocalFile();
    List<List<dynamic>> existingCsvRows = [];
    if (await localFile.exists()) {
      final rawData = await localFile.readAsString();
      List<String> lines = rawData.split('\n').where((line) => line.trim().isNotEmpty).toList();
      if (lines.isNotEmpty) {
        existingCsvRows = lines.map((line) => const CsvToListConverter().convert(line)).expand((x) => x).toList();
      }
    }

    // Combine data between CSV amd combinedDataMap
    if (existingCsvRows.isNotEmpty) {
      List<String> headers = existingCsvRows.first.map((e) => e.toString().trim()).toList();
      int operatorIndex = headers.indexOf("operator");
      int correctIndex = headers.indexOf("correct");
      int timeIndex = headers.indexOf("time");
      int gradeIndex = headers.indexOf("grade");

      if (gradeIndex != -1 && operatorIndex != -1 && correctIndex != -1 && timeIndex != -1) {
        for (var row in existingCsvRows.skip(1)) {
          try {
            String grade = row[gradeIndex].toString().trim();
            String operator = row[operatorIndex].toString().trim();
            int correct = int.parse(row[correctIndex].toString().trim());
            int time = int.parse(row[timeIndex].toString().trim());

            combinedDataMap.putIfAbsent(grade, () => {});
            combinedDataMap[grade]!.putIfAbsent(operator, () => [0, 0, 0]);
            combinedDataMap[grade]![operator]![0] += correct;
            combinedDataMap[grade]![operator]![1] += time;
            combinedDataMap[grade]![operator]![2] += 1;
          } catch (e) {
            print('Skipping invalid CSV row: $row - Error: $e');
            continue;
          }
        }
      }
    }

    // Caculation
    Map<String, Map<String, Map<String, double>>> finalStats = {};
    if (combinedDataMap.isNotEmpty) {
      combinedDataMap.forEach((grade, operators) {
        finalStats[grade] = {};
        operators.forEach((operator, values) {
          double accuracy = values[2] > 0 ? values[0] / values[2] : 0;
          double avgTime = values[2] > 0 ? values[1] / values[2] : 0;
          double quantity = values[2];
          // Double to Interger
          finalStats[grade]![operator] = {
            "accuracy": (accuracy * 100).roundToDouble(), 
            "avg_time": avgTime.roundToDouble(), 
            "quantity": quantity,
          };
        });
      });
    }

    //Write data to file CSV
    if (finalStats.isNotEmpty) {
      List<List<dynamic>> newCsvRows = [];
      newCsvRows.add(['operator', 'correct', 'time', 'grade']); // Header
      finalStats.forEach((grade, operators) {
        operators.forEach((operator, stats) {
          double correct = (stats['accuracy']! / 100) * stats['quantity']!;
          double time = stats['avg_time']! * stats['quantity']!;
          newCsvRows.add([operator, correct.round(), time.round(), grade]);
        });
      });

      String csvContent = const ListToCsvConverter().convert(newCsvRows);
      await localFile.writeAsString(csvContent);
      print('Updated CSV file with final analytics data.');
    }

    // Push Data to Firestore
    if (finalStats.isNotEmpty) {
      await FirebaseFirestore.instance.collection('gameplay').doc(userId).set({
        'analytics': finalStats,
        'last_updated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      print('Analytics data successfully uploaded to Firestore for user $userId');
    } else {
      print('No analytics data to upload to Firestore.');
    }

    // Delete CSV and SharedPreferences
    if (await localFile.exists()) {
      await localFile.delete();
      print('Deleted CSV file on logout.');
    }
    await prefs.remove('analytics_data');
    print('Cleared analytics data from SharedPreferences.');
  } catch (e) {
    print('Error uploading analytics data on logout: $e');
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