import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raccoon_learning/presentation/user/notify_provider/analysis_data_notifier.dart';
import 'package:raccoon_learning/presentation/widgets/appbar/app_bar.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class ChartPage extends StatefulWidget {
  const ChartPage({super.key});

  @override
  State<ChartPage> createState() => _ChartPageState();
}

class _ChartPageState extends State<ChartPage> {
  String _selectedGrade = "Grade 1"; 

  final Map<String, String> _gradeMapping = {
  "Grade 1": "grade_1",
  "Grade 2": "grade_2",
  "Grade 3": "grade_3",
};

// create list of DataModel from stats of grade choosen
  List<DataModel> _getDataList(Map<String, Map<String, Map<String, double>>> stats) {
  String dataGrade = _gradeMapping[_selectedGrade] ?? _selectedGrade; 
    if (!stats.containsKey(dataGrade) || stats[dataGrade]!.isEmpty) {
      return []; //return empty
    }

    return stats[dataGrade]!.entries.map((entry) {
      return DataModel(
        key: entry.key ,
        accuracy: entry.value["accuracy"]?.toString() ?? "0",
        times: entry.value["quantity"]?.toString() ?? "0",
      );
    }).toList();
  }

  double getMaxTimes(List<DataModel> dataList) {
    if (dataList.isEmpty) return 100.0; 
    return dataList
        .map((data) => double.parse(data.times!))
        .reduce((a, b) => a > b ? a : b);
  }


  @override
  Widget build(BuildContext context) {
    final analysisData = Provider.of<AnalysisDataNotifier>(context); 
    final dataList = _getDataList(analysisData.stats); 
    final maxTimes = getMaxTimes(dataList);
    return Scaffold(
      backgroundColor: const Color(0xFF040F2F),
      appBar: BasicAppBar(hideBack: true, title: Text("Math Performance Analysis", style: TextStyle( color: Colors.white),),),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20 ,bottom: 50),
            child: Align(
              alignment: Alignment.centerLeft,
              child: DropdownButton2<String>(
                value: _selectedGrade,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedGrade = newValue!;
                  });
                },
                items: ['Grade 1', 'Grade 2', 'Grade 3'].map((String grade) {
                  return DropdownMenuItem<String>(
                    value: grade,
                    child: Text(
                      grade,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  );
                }).toList(),
                dropdownStyleData: DropdownStyleData(
                  maxHeight: 200,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: const Color(0xFF1A2A6C),
                  ),
                  elevation: 8,
                  offset: const Offset(0, -5),
                ),
                buttonStyleData: ButtonStyleData(
                  height: 50,
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                    color: const Color(0xFF1A2A6C),
                  ),
                ),
                iconStyleData: const IconStyleData(
                  icon: Icon(Icons.arrow_drop_down, color: Colors.white),
                  iconSize: 24,
                ),
                underline: const SizedBox(), 
              ),
            ),
          ),
          // Legend
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildLegendItem(Colors.greenAccent, 'Accuracy'),
                const SizedBox(width: 10),
                _buildLegendItem(Colors.redAccent, 'Times'),
              ],
            ),
          ),
          // Bar Chart
          Container(
            height: 400,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: BarChart(
              BarChartData(
                maxY: 100,
                alignment: BarChartAlignment.spaceEvenly,
                barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                  tooltipRoundedRadius: 8,
                  tooltipPadding: const EdgeInsets.all(8),
                  tooltipMargin: 8,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    String weekDay = dataList[group.x.toInt()].key!;
                    String label = rodIndex == 0 ? 'Accuracy' : 'Times';
                    double actualValue = rodIndex == 0
                        ? rod.toY
                        : rod.toY * (maxTimes / 100);
                    return BarTooltipItem(
                      '$weekDay - $label\n',
                      const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      children: [
                        TextSpan(
                            text: actualValue.toStringAsFixed(0),
                            style: TextStyle(
                              color: rod.gradient?.colors.first ?? rod.color,
                              fontWeight: FontWeight.w500,
                            ))
                      ],
                    );
                  },
                )),
                barGroups: _chartGroups(maxTimes, dataList),
                borderData: FlBorderData(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                    left: BorderSide(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                    right: BorderSide(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                ),
                gridData: FlGridData(
                  drawHorizontalLine: true,
                  horizontalInterval: 20,
                  drawVerticalLine: false,
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          dataList[value.toInt()].key!,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 20,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.greenAccent,
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 200,
                      getTitlesWidget: (value, meta) {
                        final actualValue = (value * (maxTimes / 100)).toInt();
                        if (actualValue <= maxTimes) {
                          return Text(
                            actualValue.toString(),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.redAccent,
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<BarChartGroupData> _chartGroups(double maxTimes, List<DataModel>dataList ) {
    return List.generate(dataList.length, (index) {
      final accuracy = double.parse(dataList[index].accuracy!);
      final times = double.parse(dataList[index].times!);
      final scaledTimes = (times / maxTimes) * 100;
      return BarChartGroupData(x: index, barRods: [
        BarChartRodData(
          toY: accuracy,
          width: 18,
          gradient: const LinearGradient(
            colors: [Colors.greenAccent, Colors.blueAccent],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
          borderRadius: const BorderRadius.all(
            Radius.circular(5),
          ),
        ),
        BarChartRodData(
          toY: scaledTimes,
          width: 18,
          gradient: const LinearGradient(
            colors: [Colors.redAccent, Colors.orangeAccent],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
          borderRadius: const BorderRadius.all(
            Radius.circular(5),
          ),
        ),
      ]);
    });
  }
}

Widget _buildLegendItem(Color color, String text) {
  return Row(
    children: [
      Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
      ),
      const SizedBox(width: 4),
      Text(
        text,
        style: const TextStyle(fontSize: 16, color: Colors.white),
      ),
    ],
  );
}

class DataModel {
  final String? key;
  final String? accuracy;
  final String? times;
  DataModel({this.key, this.accuracy, this.times});
}