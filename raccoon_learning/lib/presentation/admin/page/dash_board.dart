import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:raccoon_learning/constants/assets/app_images.dart';

// Dashboard Page
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        buildHeader(context),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Dashboard',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _buildMetricCard('Total User', '40,689', '8.5% Up from yesterday', const Color(0xFFD6BCFA)),
                    _buildMetricCard('Total Order', '10293', '1.3% Up from past week', const Color(0xFFFFE4B5)),
                    _buildMetricCard('Total Sales', '\$89,000', '4.3% Down from yesterday', const Color(0xFFB2F5EA)),
                    _buildMetricCard('Total Pending', '2040', '1.8% Up from yesterday', const Color(0xFFFED7D7)),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'Sales Details',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  height: 300,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 2)),
                    ],
                  ),
                  child: LineChart(
                    LineChartData(
                      gridData: const FlGridData(show: false),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) => Text(
                              '${value.toInt()}%',
                              style: const TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            getTitlesWidget: (value, meta) => Text(
                              '${value.toInt()}k',
                              style: const TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                          ),
                        ),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: const [
                            FlSpot(0, 20),
                            FlSpot(10, 80),
                            FlSpot(20, 40),
                            FlSpot(30, 60),
                            FlSpot(40, 30),
                            FlSpot(50, 50),
                            FlSpot(60, 20),
                          ],
                          isCurved: true,
                          color: Colors.blue,
                          barWidth: 2,
                          dotData: const FlDotData(show: true),
                          belowBarData: BarAreaData(
                            show: true,
                            color: Colors.blue.withOpacity(0.1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, String subtitle, Color iconColor) {
    return Container(
      width: 250,
      margin: const EdgeInsets.symmetric(horizontal: 5),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: iconColor,
                child: Icon(
                  title.contains('User')
                      ? Icons.person
                      : title.contains('Order')
                          ? Icons.shopping_cart
                          : title.contains('Sales')
                              ? Icons.trending_up
                              : Icons.pending,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(width: 10),
              Text(title, style: const TextStyle(color: Colors.grey, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 10),
          Text(value, style: const TextStyle(color: Colors.black87, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}


  // Header widget with search bar and user profile
Widget buildHeader(BuildContext context) {
  return Container(
    padding: const EdgeInsets.all(10),
    color: Colors.white,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.end, // Align content to the right
      children: [
        const CircleAvatar(
          backgroundImage: AssetImage(AppImages.user),
          radius: 15,
        ),
        const SizedBox(width: 5), // Space between avatar and text
        const Text('Admin', style: TextStyle(color: Colors.black87)),
        const SizedBox(width:  20,),
      ],
    ),
  );
}
