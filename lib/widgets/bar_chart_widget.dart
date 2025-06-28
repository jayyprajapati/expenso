import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class YearlyBarChart extends StatelessWidget {
  final Map<String, double> categoryTotals;

  const YearlyBarChart({super.key, required this.categoryTotals});

  @override
  Widget build(BuildContext context) {
    if (categoryTotals.isEmpty) {
      return const Center(child: Text('No data for this year.'));
    }

    final barGroups = <BarChartGroupData>[];
    final labels = <String>[];

    final colors = [
      Colors.teal,
      Colors.orange,
      Colors.purple,
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.brown,
      Colors.cyan,
    ];

    int index = 0;
    categoryTotals.forEach((category, amount) {
      labels.add(
        category.length > 10 ? '${category.substring(0, 10)}…' : category,
      );
      barGroups.add(
        BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: amount,
              color: colors[index % colors.length],
              width: 20,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      );
      index++;
    });

    return BarChart(
      BarChartData(
        maxY: _getMaxY(categoryTotals.values),
        barGroups: barGroups,
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: _getYAxisInterval(categoryTotals.values),
              getTitlesWidget: (value, _) => Text(
                '₹${value.toInt()}',
                style: const TextStyle(fontSize: 10),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              getTitlesWidget: (value, _) {
                final i = value.toInt();
                return SideTitleWidget(
                  axisSide: AxisSide.bottom,
                  child: Text(labels[i], style: const TextStyle(fontSize: 10)),
                );
              },
            ),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: false),
      ),
    );
  }

  double _getMaxY(Iterable<double> values) {
    final max = values.reduce((a, b) => a > b ? a : b);
    return (max * 1.2).ceilToDouble(); // add 20% headroom
  }

  double _getYAxisInterval(Iterable<double> values) {
    final max = values.reduce((a, b) => a > b ? a : b);
    if (max <= 500) return 100;
    if (max <= 2000) return 500;
    return 1000;
  }
}
